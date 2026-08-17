import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/categories/models/category.dart';
import 'package:mobile/features/categories/views/category_form_view.dart';
import 'package:mobile/features/categories/viewmodels/providers/category_provider.dart';
import 'package:mobile/features/categories/repositories/category_repository.dart';
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

// ─── Mock Category Repository ────────────────────────────────────────────────
// We use a simple in-memory fake instead of hitting the real API.
// This lets us test form logic entirely in the terminal.

class MockCategoryRepository extends CategoryRepository {
  final List<Category> categoriesList;
  final List<Map<String, dynamic>> createdBodies = [];
  final List<Map<String, dynamic>> updatedBodies = [];
  bool shouldThrow = false;
  String? throwMessage;

  MockCategoryRepository({this.categoriesList = const []});

  @override
  Future<List<Category>> getCategories({CancelToken? cancelToken}) async {
    return categoriesList;
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    if (shouldThrow) throw Exception(throwMessage ?? 'Network error');
    createdBodies.add(body);
    return Category(
      id: 'mock-id-123',
      name: body['name'] as String,
      slug: body['slug'] as String,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<Category> updateCategory(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    if (shouldThrow) throw Exception(throwMessage ?? 'Network error');
    updatedBodies.add({...body, 'id': id});
    return Category(
      id: id,
      name: body['name'] as String,
      slug: body['slug'] as String,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}

void setTestWindowSize(WidgetTester tester, {Size size = const Size(800, 2400)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class DelayingMockCategoryRepository extends MockCategoryRepository {
  final Completer<Category> completer = Completer<Category>();

  @override
  Future<Category> createCategory(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    return completer.future;
  }
}

// ─── Helper: wrap widget with Riverpod + Material + override providers ────────
Widget buildTestApp(Widget child, {MockCategoryRepository? mockRepo, List<Category>? categories}) {
  final repo = mockRepo ?? MockCategoryRepository(categoriesList: categories ?? []);
  return ProviderScope(
    overrides: [
      // Override the repository provider so form uses our mock
      categoryRepositoryProvider.overrideWithValue(repo),
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

  // ── Create Mode Tests ───────────────────────────────────────────────────────
  group('CategoryFormView — Create Mode', () {

    testWidgets('renders all form fields in create mode', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Check key UI elements are visible
      expect(find.text('New Main Category'), findsOneWidget);    // AppBar title
      expect(find.text('Category Name *'), findsOneWidget);     // Name label
      expect(find.text('Slug *'), findsOneWidget);              // Slug label
      expect(find.text('Description'), findsOneWidget);         // Description label
      expect(find.text('Tap to add image'), findsOneWidget);    // Image placeholder

      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      expect(submitButton, findsOneWidget);     // Submit button
    });

    testWidgets('shows validation error when name is empty on submit', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Scroll to submit button and tap
      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Validation error should appear
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows validation error when slug is empty on submit', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Enter a name (which auto-fills slug)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Test',
      );
      await tester.pumpAndSettle();

      // Clear the slug field manually
      await tester.enterText(
        find.widgetWithText(TextFormField, 'auto-generated-slug'),
        '',
      );
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Slug is required'), findsOneWidget);
    });

    testWidgets('slug auto-generates from name as user types', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Type in name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Bridal Wear',
      );
      await tester.pumpAndSettle();

      // Slug field should have auto-populated
      // Find the slug TextFormField by its hint text
      final slugField = find.widgetWithText(TextFormField, 'auto-generated-slug');
      final slugController = (tester.widget<TextFormField>(slugField)
          .controller as TextEditingController);
      expect(slugController.text, 'bridal-wear');
    });

    testWidgets('subcategory slug automatically includes parent category slug', (tester) async {
      setTestWindowSize(tester);
      final parentCategory = Category(
        id: 'parent-123',
        name: 'Bharatanatyam',
        slug: 'bharatanatyam',
        createdAt: '2026-01-01T00:00:00Z',
      );

      await tester.pumpWidget(buildTestApp(
        const CategoryFormView(initialParentId: 'parent-123'),
        categories: [parentCategory],
      ));
      await tester.pumpAndSettle();

      // Type subcategory name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Costumes',
      );
      await tester.pumpAndSettle();

      // Slug field should include parent slug: bharatanatyam-costumes
      final slugField = find.widgetWithText(TextFormField, 'auto-generated-slug');
      final slugController = (tester.widget<TextFormField>(slugField)
          .controller as TextEditingController);
      expect(slugController.text, 'bharatanatyam-costumes');
    });

    testWidgets('calls repository.createCategory with correct body on valid submit', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = MockCategoryRepository();
      await tester.pumpWidget(buildTestApp(const CategoryFormView(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Bridal Wear',
      );
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Optional description...'),
        'Wedding collection',
      );
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Mock repo should have been called
      expect(mockRepo.createdBodies, hasLength(1));
      expect(mockRepo.createdBodies[0]['name'], 'Bridal Wear');
      expect(mockRepo.createdBodies[0]['slug'], 'bridal-wear');
      expect(mockRepo.createdBodies[0]['description'], 'Wedding collection');
      expect(mockRepo.createdBodies[0]['is_active'], isTrue);
    });

    testWidgets('shows loading indicator while submitting', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = DelayingMockCategoryRepository();
      await tester.pumpWidget(buildTestApp(const CategoryFormView(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Test Category',
      );

      // Start tap but don't settle — catch loading state
      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(submitButton);
      await tester.pump(); // just one pump, while createCategory future is pending

      // CircularProgressIndicator should be visible inside submit button during loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future so test completes cleanly
      mockRepo.completer.complete(Category(
        id: 'mock-123',
        name: 'Test Category',
        slug: 'test-category',
        createdAt: DateTime.now().toIso8601String(),
      ));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error snackbar when repository throws', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = MockCategoryRepository()
        ..shouldThrow = true
        ..throwMessage = 'Slug already exists';

      await tester.pumpWidget(buildTestApp(const CategoryFormView(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Bridal Wear',
      );
      await tester.pumpAndSettle();

      final submitButton = find.text('Create Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Error snackbar should show
      expect(find.textContaining('already exists'), findsOneWidget);
    });

    testWidgets('image section shows Add Image button when no image', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      expect(find.text('Add Image'), findsOneWidget);
      expect(find.text('Remove'), findsNothing); // Remove only shows when image exists
    });
  });

  // ── Edit Mode Tests ──────────────────────────────────────────────────────────
  group('CategoryFormView — Edit Mode', () {
    final existingCategory = Category(
      id: 'cat-001',
      name: 'Lehenga',
      slug: 'lehenga',
      description: 'Traditional bridal lehenga',
      imageUrl: 'https://cdn.example.com/lehenga.jpg',
      sortOrder: 1,
      isActive: true,
      createdAt: '2026-01-01T00:00:00Z',
    );

    testWidgets('renders Edit Category title in edit mode', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      expect(find.text('Edit Category'), findsOneWidget);
      final submitButton = find.text('Update Category');
      await tester.scrollUntilVisible(submitButton, 200.0, scrollable: find.byType(Scrollable).first);
      expect(submitButton, findsOneWidget); // Submit button
    });

    testWidgets('pre-populates fields with existing category data', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      // Name and slug should be pre-filled
      expect(find.text('Lehenga'), findsWidgets);
      expect(find.text('lehenga'), findsWidgets);
    });

    testWidgets('shows Change/Remove image buttons when image exists', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('tapping Remove hides the Remove button', (tester) async {
      setTestWindowSize(tester);
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // After removing, Remove button should disappear (no image to remove)
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('calls repository.updateCategory (not create) in edit mode', (tester) async {
      setTestWindowSize(tester);
      final mockRepo = MockCategoryRepository();
      await tester.pumpWidget(buildTestApp(
        CategoryFormView(category: existingCategory),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      final updateButton = find.text('Update Category');
      await tester.scrollUntilVisible(updateButton, 200.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      expect(mockRepo.createdBodies, hasLength(0));  // create NOT called
      expect(mockRepo.updatedBodies, hasLength(1));  // update IS called
      expect(mockRepo.updatedBodies[0]['id'], 'cat-001');
      expect(mockRepo.updatedBodies[0]['name'], 'Lehenga');
    });
  });
}
