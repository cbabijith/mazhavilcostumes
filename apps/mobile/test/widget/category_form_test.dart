import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/categories/models/category.dart';
import 'package:mobile/features/categories/views/category_form_view.dart';
import 'package:mobile/features/categories/viewmodels/providers/category_provider.dart';
import 'package:mobile/features/categories/repositories/category_repository.dart';
import 'package:dio/dio.dart';

// ─── Mock Category Repository ────────────────────────────────────────────────
// We use a simple in-memory fake instead of hitting the real API.
// This lets us test form logic entirely in the terminal.

class MockCategoryRepository extends CategoryRepository {
  final List<Map<String, dynamic>> createdBodies = [];
  final List<Map<String, dynamic>> updatedBodies = [];
  Completer<void>? pendingSubmit;
  bool shouldThrow = false;
  String? throwMessage;

  @override
  Future<Category> createCategory(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    if (shouldThrow) throw Exception(throwMessage ?? 'Network error');
    createdBodies.add(body);
    await pendingSubmit?.future;
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

// ─── Helper: wrap widget with Riverpod + Material + override providers ────────
Widget buildTestApp(Widget child, {MockCategoryRepository? mockRepo}) {
  final repo = mockRepo ?? MockCategoryRepository();
  return ProviderScope(
    overrides: [
      // Override the repository provider so form uses our mock
      categoryRepositoryProvider.overrideWithValue(repo),
    ],
    child: MaterialApp(
      initialRoute: '/form',
      routes: {
        '/': (_) => const Scaffold(body: Text('Categories')),
        '/form': (_) => child,
      },
    ),
  );
}

/// Scroll lazy form fields into view before interacting with them.
Future<void> scrollTo(WidgetTester tester, String label) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text(label), 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

void main() {
  // ── Create Mode Tests ───────────────────────────────────────────────────────
  group('CategoryFormView — Create Mode', () {

    testWidgets('renders all form fields in create mode', (tester) async {
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Check key UI elements are visible
      expect(find.text('New Category'), findsOneWidget);        // AppBar title
      expect(find.text('Category Name *'), findsOneWidget);     // Name label
      expect(find.text('Slug *'), findsOneWidget);              // Slug label
      expect(find.text('Description'), findsOneWidget);         // Description label
      expect(find.text('Tap to add image'), findsOneWidget);
      await scrollTo(tester, 'Sort Order');
      expect(find.text('Sort Order'), findsOneWidget);          // Sort order label
      await scrollTo(tester, 'Create Category');
      expect(find.text('Create Category'), findsOneWidget);     // Submit button
    });

    testWidgets('shows validation error when name is empty on submit', (tester) async {
      await tester.pumpWidget(buildTestApp(const CategoryFormView()));
      await tester.pumpAndSettle();

      // Clear the name field (it starts empty, just tap submit)
      await scrollTo(tester, 'Create Category');
      await tester.tap(find.text('Create Category'));
      await tester.pumpAndSettle();

      // Validation error should appear
      await tester.scrollUntilVisible(find.text('Name is required'), -200, scrollable: find.byType(Scrollable).first);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows validation error when slug is empty on submit', (tester) async {
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
      await scrollTo(tester, 'Create Category');
      await tester.tap(find.text('Create Category'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Slug is required'), -200, scrollable: find.byType(Scrollable).first);
      expect(find.text('Slug is required'), findsOneWidget);
    });

    testWidgets('slug auto-generates from name as user types', (tester) async {
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

    testWidgets('calls repository.createCategory with correct body on valid submit', (tester) async {
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
      await scrollTo(tester, 'Create Category');
      await tester.tap(find.text('Create Category'));
      await tester.pumpAndSettle();

      // Mock repo should have been called
      expect(mockRepo.createdBodies, hasLength(1));
      expect(mockRepo.createdBodies[0]['name'], 'Bridal Wear');
      expect(mockRepo.createdBodies[0]['slug'], 'bridal-wear');
      expect(mockRepo.createdBodies[0]['description'], 'Wedding collection');
      expect(mockRepo.createdBodies[0]['is_active'], isTrue);
    });

    testWidgets('shows loading indicator while submitting', (tester) async {
      final pending = Completer<void>();
      final mockRepo = MockCategoryRepository()..pendingSubmit = pending;
      await tester.pumpWidget(buildTestApp(const CategoryFormView(), mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g. Bridal Wear'),
        'Test Category',
      );

      // Start tap but don't settle — catch loading state
      await scrollTo(tester, 'Create Category');
      await tester.tap(find.text('Create Category'));
      await tester.pump(); // just one pump, not pumpAndSettle

      // CircularProgressIndicator should be visible during loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows error snackbar when repository throws', (tester) async {
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

      await scrollTo(tester, 'Create Category');
      await tester.tap(find.text('Create Category'));
      await tester.pumpAndSettle();

      // Error snackbar should show
      expect(find.textContaining('Slug already exists'), findsOneWidget);
    });

    testWidgets('image section shows Add Image button when no image', (tester) async {
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
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      expect(find.text('Edit Category'), findsOneWidget);
      await scrollTo(tester, 'Update Category');
      expect(find.text('Update Category'), findsOneWidget); // Submit button
    });

    testWidgets('pre-populates fields with existing category data', (tester) async {
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      // Name and slug should be pre-filled
      expect(find.text('Lehenga'), findsWidgets);
      expect(find.text('lehenga'), findsWidgets);
    });

    testWidgets('shows Change/Remove image buttons when image exists', (tester) async {
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('tapping Remove hides the Remove button', (tester) async {
      await tester.pumpWidget(buildTestApp(CategoryFormView(category: existingCategory)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // After removing, Remove button should disappear (no image to remove)
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('calls repository.updateCategory (not create) in edit mode', (tester) async {
      final mockRepo = MockCategoryRepository();
      await tester.pumpWidget(buildTestApp(
        CategoryFormView(category: existingCategory),
        mockRepo: mockRepo,
      ));
      await tester.pumpAndSettle();

      await scrollTo(tester, 'Update Category');
      await tester.tap(find.text('Update Category'));
      await tester.pumpAndSettle();

      expect(mockRepo.createdBodies, hasLength(0));  // create NOT called
      expect(mockRepo.updatedBodies, hasLength(1));  // update IS called
      expect(mockRepo.updatedBodies[0]['id'], 'cat-001');
      expect(mockRepo.updatedBodies[0]['name'], 'Lehenga');
    });
  });
}
