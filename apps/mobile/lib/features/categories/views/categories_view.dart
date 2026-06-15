import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../models/category.dart';
import '../viewmodels/providers/category_provider.dart';
import 'category_detail_view.dart';
import 'category_form_view.dart';

/// Categories listing view – hierarchical tree: Main → Sub → Variant.
class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final canManage = ref.watch(canManageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            categoriesAsync.when(
              data: (categories) => _buildContent(context, categories, canManage),
              loading: () => _buildShimmerList(),
              error: (error, _) => _buildError(error),
            ),
            // FAB — only for admin/manager
            if (canManage)
              Positioned(
                right: Responsive.w(16),
                bottom: Responsive.h(16),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoryFormView()),
                    ).then((_) => ref.invalidate(categoriesProvider));
                  },
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.primary,
                  icon: Icon(Icons.add, size: Responsive.icon(24)),
                  label: Text('Add Category', style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Category> categories, bool canManage) {
    // Apply search filter
    final filtered = _searchQuery.isEmpty
        ? categories
        : categories.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.slug.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (c.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    final allMainCats = categories.where((c) => c.parentId == null).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final filteredMainCats = filtered.where((c) => c.parentId == null).toList();

    // When searching, also show parents of matching sub/variants
    final Set<String> visibleMainIds = {};
    for (final c in filteredMainCats) {
      visibleMainIds.add(c.id);
    }
    // If a sub or variant matches, include its root main category
    for (final c in filtered) {
      if (c.parentId != null) {
        String? parentId = c.parentId;
        while (parentId != null) {
          final parent = categories.where((p) => p.id == parentId).firstOrNull;
          if (parent == null) break;
          if (parent.parentId == null) {
            visibleMainIds.add(parent.id);
            break;
          }
          parentId = parent.parentId;
        }
      }
    }

    final displayMainCats = _searchQuery.isEmpty
        ? allMainCats
        : allMainCats.where((c) => visibleMainIds.contains(c.id)).toList();

    if (categories.isEmpty) return _buildEmpty();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: Responsive.only(left: 16, right: 16, top: 12, bottom: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.r(14)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: Responsive.r(12), offset: Offset(0, Responsive.h(2)))],
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(fontSize: Responsive.sp(15)),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(fontSize: Responsive.sp(15), color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded, size: Responsive.icon(24), color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, size: Responsive.icon(22), color: Colors.grey),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                contentPadding: Responsive.symmetric(horizontal: 18, vertical: 16),
              ),
            ),
          ),
        ),

        // Stats row
        Padding(
          padding: Responsive.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildMiniStat('Total', '${categories.length}', AppColors.primary),
              SizedBox(width: Responsive.w(8)),
              _buildMiniStat('Main', '${allMainCats.length}', AppColors.primary),
              SizedBox(width: Responsive.w(8)),
              _buildMiniStat('Active', '${categories.where((c) => c.isActive).length}', AppColors.primary),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(6)),

        // No results
        if (displayMainCats.isEmpty && _searchQuery.isNotEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: Responsive.icon(48), color: Colors.grey[300]),
                  SizedBox(height: Responsive.h(12)),
                  Text('No results for "$_searchQuery"', style: TextStyle(fontSize: Responsive.sp(14), color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          // Category Tree
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => ref.invalidate(categoriesProvider),
              child: _searchQuery.isEmpty && canManage
                  ? ReorderableListView.builder(
                      padding: Responsive.only(left: 16, right: 16, bottom: 80),
                      itemCount: displayMainCats.length,
                      buildDefaultDragHandles: false,
                      onReorderItem: (oldIndex, newIndex) async {
                        final allCategories = ref.read(categoriesProvider).value;
                        if (allCategories == null) return;

                        final allCategoriesCopy = [...allCategories];

                        // 1. Get mains sorted by sortOrder
                        final mains = allCategoriesCopy.where((c) => c.parentId == null).toList()
                          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                        // 2. Move item
                        final moved = mains.removeAt(oldIndex);
                        mains.insert(newIndex, moved);

                        // 3. Construct payload and update locally
                        final List<Map<String, dynamic>> payload = [];
                        for (int i = 0; i < mains.length; i++) {
                          final cat = mains[i];
                          payload.add({
                            'id': cat.id,
                            'sort_order': i,
                          });

                          final updatedCat = cat.copyWith(sortOrder: i);
                          final indexInAll = allCategoriesCopy.indexWhere((c) => c.id == cat.id);
                          if (indexInAll != -1) {
                            allCategoriesCopy[indexInAll] = updatedCat;
                          }
                        }

                        // 4. Save changes
                        try {
                          await ref.read(categoriesProvider.notifier).reorder(allCategoriesCopy, payload);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order updated successfully'),
                                backgroundColor: Color(0xFF4CAF50),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save order: $e'),
                                backgroundColor: const Color(0xFFFF6B8A),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context, index) {
                        final main = displayMainCats[index];
                        final subs = categories.where((c) => c.parentId == main.id).toList();
                        return _buildMainCategoryCard(
                          context,
                          main,
                          subs,
                          categories,
                          canManage,
                          key: ValueKey(main.id),
                          dragHandle: ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: Responsive.only(right: 8),
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                size: Responsive.icon(22),
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: Responsive.only(left: 16, right: 16, bottom: 80),
                      itemCount: displayMainCats.length,
                      itemBuilder: (context, index) {
                        final main = displayMainCats[index];
                        final subs = categories.where((c) => c.parentId == main.id).toList();
                        return _buildMainCategoryCard(context, main, subs, categories, canManage);
                      },
                    ),
            ),
          ),
      ],
    );
  }

  // ── Mini Stat ──
  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: Responsive.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Responsive.r(12)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: Responsive.sp(18), fontWeight: FontWeight.w800, color: AppColors.primary)),
            SizedBox(height: Responsive.h(2)),
            Text(label, style: TextStyle(fontSize: Responsive.sp(11), fontWeight: FontWeight.w600, color: AppColors.primary.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoryCard(
    BuildContext context,
    Category main,
    List<Category> subs,
    List<Category> all,
    bool canManage, {
    Key? key,
    Widget? dragHandle,
  }) {
    return GestureDetector(
      key: key,
      onTap: () => _navigateToDetail(context, main),
      child: Container(
        margin: Responsive.only(bottom: 12),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(14)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: Responsive.r(8), offset: Offset(0, Responsive.h(2)))],
        ),
        child: Row(
          children: [
            ?dragHandle,
            _buildCategoryImage(main, size: 56),
            SizedBox(width: Responsive.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(main.name, style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.w800, color: AppColors.primary)),
                  SizedBox(height: Responsive.h(6)),
                  Row(
                    children: [
                      _buildStatusDot(main.isActive),
                      SizedBox(width: Responsive.w(6)),
                      Text(main.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      if (subs.isNotEmpty) ...[
                        SizedBox(width: Responsive.w(10)),
                        Container(
                          padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(Responsive.r(8))),
                          child: Text(' sub-categories', style: TextStyle(fontSize: Responsive.sp(10), fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: Responsive.icon(28), color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ── Category Image ──
  Widget _buildCategoryImage(Category cat, {double size = 40}) {
    final s = Responsive.w(size);
    if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(size * 0.25)),
        child: Image.network(cat.imageUrl!, width: s, height: s, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildIconAvatar(s)),
      );
    }
    return _buildIconAvatar(s);
  }

  Widget _buildIconAvatar(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.r(size * 0.25)),
      ),
      child: Icon(Icons.folder_rounded, size: size * 0.45, color: AppColors.primary),
    );
  }

  // ── Status Dot ──
  Widget _buildStatusDot(bool isActive) {
    return Container(
      width: Responsive.w(7), height: Responsive.w(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4CAF50) : Colors.grey[400],
      ),
    );
  }

  // ── Navigation ──
  void _navigateToDetail(BuildContext context, Category cat) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CategoryDetailView(initialCategory: cat)),
    ).then((_) => ref.invalidate(categoriesProvider));
  }

  // ── Empty State ──
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: Responsive.all(20),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), shape: BoxShape.circle),
            child: Icon(Icons.category_outlined, size: Responsive.icon(48), color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          SizedBox(height: Responsive.h(20)),
          Text('No categories yet', style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: Responsive.h(6)),
          Text('Tap + to add your first category', style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ── Error State ──
  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: Responsive.icon(48), color: const Color(0xFFFF6B8A)),
          SizedBox(height: Responsive.h(16)),
          Padding(
            padding: Responsive.symmetric(horizontal: 32),
            child: Text('Error loading categories\n$error', textAlign: TextAlign.center, style: TextStyle(fontSize: Responsive.sp(13))),
          ),
          SizedBox(height: Responsive.h(16)),
          ElevatedButton(
            onPressed: () => ref.invalidate(categoriesProvider),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Retry', style: TextStyle(fontSize: Responsive.sp(13))),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: Responsive.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        margin: Responsive.only(bottom: 12),
        padding: Responsive.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(14)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: Responsive.r(8), offset: Offset(0, Responsive.h(2)))],
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(width: Responsive.w(56), height: Responsive.w(56), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Responsive.r(14)))),
              SizedBox(width: Responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: Responsive.w(120), height: Responsive.h(16), color: Colors.white),
                    SizedBox(height: Responsive.h(10)),
                    Container(width: Responsive.w(80), height: Responsive.h(12), color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
