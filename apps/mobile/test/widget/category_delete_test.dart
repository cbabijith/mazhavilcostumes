import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/categories/models/category.dart';
import 'package:mobile/features/categories/views/category_detail_view.dart';
import 'package:mobile/features/categories/viewmodels/providers/category_provider.dart';
import 'package:mobile/features/categories/repositories/category_repository.dart';
import 'package:mobile/features/auth/viewmodels/providers/auth_provider.dart';
import 'package:dio/dio.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => 0;
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class MockDeleteCategoryRepository extends CategoryRepository {
  final List<Category> categoriesList;
  bool shouldThrow = false;
  String? throwMessage;
  bool deleteCalled = false;

  MockDeleteCategoryRepository({this.categoriesList = const []});

  @override
  Future<List<Category>> getCategories({CancelToken? cancelToken}) async {
    return categoriesList;
  }

  @override
  Future<void> deleteCategory(String id, {CancelToken? cancelToken}) async {
    deleteCalled = true;
    if (shouldThrow) {
      throw Exception(throwMessage ?? 'Cannot delete category because it has linked products.');
    }
  }
}

void setTestWindowSize(WidgetTester tester, {Size size = const Size(800, 2400)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget buildTestApp(Widget child, {MockDeleteCategoryRepository? mockRepo, List<Category>? categories}) {
  final repo = mockRepo ?? MockDeleteCategoryRepository(categoriesList: categories ?? []);
  return ProviderScope(
    overrides: [
      categoryRepositoryProvider.overrideWithValue(repo),
      canManageProvider.overrideWith((ref) => true),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Category Delete Reason Validation Tests', () {
    final parentCategory = Category(
      id: 'parent-001',
      name: 'Bharatanatyam',
      slug: 'bharatanatyam',
      createdAt: '2026-01-01T00:00:00Z',
    );

    final subCategory = Category(
      id: 'sub-001',
      parentId: 'parent-001',
      name: 'Costumes',
      slug: 'bharatanatyam-costumes',
      createdAt: '2026-01-01T00:00:00Z',
    );

    testWidgets('shows explicit dialog explaining subcategories exist when attempting to delete parent', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = MockDeleteCategoryRepository(categoriesList: [parentCategory, subCategory]);

      await tester.pumpWidget(buildTestApp(
        CategoryDetailView(initialCategory: parentCategory),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // Tap delete icon in AppBar
      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Should show 'Cannot Delete Category' title with subcategory explanation
      expect(find.text('Cannot Delete Category'), findsOneWidget);
      expect(find.textContaining('has 1 subcategory(ies): "Costumes"'), findsOneWidget);
      expect(find.textContaining('Please delete or reassign all subcategories first.'), findsOneWidget);

      // Repository delete should NOT have been called
      expect(mockRepo.deleteCalled, isFalse);
    });

    testWidgets('shows specific error reason in SnackBar when server blocks deletion', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = MockDeleteCategoryRepository(categoriesList: [subCategory])
        ..shouldThrow = true
        ..throwMessage = 'Cannot delete category because it has linked products. Please reassign or delete products first.';

      await tester.pumpWidget(buildTestApp(
        CategoryDetailView(initialCategory: subCategory),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      // Tap delete icon in AppBar
      final deleteIcon = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Confirmation dialog opens
      expect(find.text('Delete Category'), findsOneWidget);

      // Tap 'Delete' button in confirmation dialog
      final confirmDeleteButton = find.widgetWithText(TextButton, 'Delete');
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      // Repository delete WAS called
      expect(mockRepo.deleteCalled, isTrue);

      // Error SnackBar should display the specific server error reason string
      expect(
        find.text('Cannot delete category because it has linked products. Please reassign or delete products first.'),
        findsOneWidget,
      );
    });
  });
}
