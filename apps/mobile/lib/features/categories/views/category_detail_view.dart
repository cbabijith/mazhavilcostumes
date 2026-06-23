import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/viewmodels/providers/auth_provider.dart';
import '../models/category.dart';
import '../viewmodels/providers/category_provider.dart';
import 'category_form_view.dart';

/// Category detail page — view, edit, and delete a category.
/// Accepts the full [Category] object directly to avoid extra API calls.
class CategoryDetailView extends ConsumerStatefulWidget {
  final Category initialCategory;
  const CategoryDetailView({super.key, required this.initialCategory});

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  late Category _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final canManage = ref.watch(canManageProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Category Details',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontXLarge),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (canManage) ...[
            IconButton(
              onPressed: () => _navigateToEdit(),
              icon: Icon(
                Icons.edit_outlined,
                size: Responsive.icon(AppSizes.iconMedium),
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(
                Icons.delete_outline,
                size: Responsive.icon(AppSizes.iconMedium),
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
      body: _buildDetail(context, canManage),
    );
  }

  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CategoryFormView(category: _category)),
    ).then((_) {
      // Refresh the list when coming back
      ref.invalidate(categoriesProvider);
      // Try to get updated data from the refreshed list
      final allAsync = ref.read(categoriesProvider);
      allAsync.whenData((all) {
        final updated = all.where((c) => c.id == _category.id).firstOrNull;
        if (updated != null && mounted) {
          setState(() => _category = updated);
        }
      });
    });
  }

  Widget _buildCoverBanner() {
    final hasImage = _category.imageUrl != null && _category.imageUrl!.isNotEmpty;
    return Container(
      height: Responsive.h(180),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(Responsive.r(AppSizes.radiusXXLarge)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage) ...[
            Image.network(
              _category.imageUrl!,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                    const Color(0xFF065F46), // Dark Emerald green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
          CustomPaint(
            painter: _BannerDecorationPainter(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: Responsive.h(30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, bool canManage) {
    // Determine level label
    String levelLabel = 'Main Category';
    if (_category.parentId != null) {
      final allAsync = ref.watch(categoriesProvider);
      allAsync.whenData((all) {
        final parent = all.where((c) => c.id == _category.parentId).firstOrNull;
        if (parent != null && parent.parentId != null) {
          levelLabel = 'Variant';
        } else {
          levelLabel = 'Sub Category';
        }
      });
      if (levelLabel == 'Main Category') {
        levelLabel = 'Sub Category';
      }
    }

    IconData levelIcon = Icons.folder_copy_rounded;
    Color levelColor = AppColors.primary;
    if (levelLabel == 'Sub Category') {
      levelIcon = Icons.folder_zip_rounded;
      levelColor = AppColors.info;
    } else if (levelLabel == 'Variant') {
      levelIcon = Icons.label_important_rounded;
      levelColor = AppColors.warning;
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildCoverBanner(),
        
        Transform.translate(
          offset: Offset(0, -Responsive.h(40)),
          child: Padding(
            padding: Responsive.symmetric(horizontal: AppSizes.screenPaddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Main Card (Image, Title, Description) ──
                Container(
                  padding: Responsive.all(AppSizes.spacingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusLarge)),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: Responsive.r(AppSizes.radiusMedium),
                        offset: Offset(0, Responsive.h(AppSizes.spacingTiny / 2)),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryImage(_category, size: 76, hasShadow: true),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: Responsive.w(AppSizes.spacingSmall),
                                  runSpacing: Responsive.h(AppSizes.spacingTiny),
                                  children: [
                                    _buildPillBadge(levelLabel, levelColor, icon: levelIcon),
                                    _buildPillBadge(
                                      _category.isActive ? 'Active' : 'Inactive',
                                      _category.isActive ? AppColors.success : AppColors.secondaryText,
                                      icon: _category.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                    ),
                                  ],
                                ),
                                SizedBox(height: Responsive.h(AppSizes.spacingSmall + 2)),
                                Text(
                                  _category.name,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(AppSizes.fontXXLarge),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                                Container(
                                  padding: Responsive.symmetric(
                                    horizontal: AppSizes.spacingSmall,
                                    vertical: AppSizes.spacingTiny,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                    border: Border.all(color: AppColors.border, width: 1.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link_rounded,
                                        size: Responsive.icon(AppSizes.iconTiny),
                                        color: AppColors.secondaryText,
                                      ),
                                      SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                                      Text(
                                        _category.slug,
                                        style: TextStyle(
                                          fontSize: Responsive.sp(AppSizes.fontSmall),
                                          color: AppColors.secondaryText,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Description
                      if (_category.description != null && _category.description!.isNotEmpty) ...[
                        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                        Container(
                          width: double.infinity,
                          padding: Responsive.all(AppSizes.spacingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground,
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESCRIPTION',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryText,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                              Text(
                                _category.description!,
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontMedium),
                                  height: 1.5,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: Responsive.h(AppSizes.spacingMedium)),

                // ── Metrics Tiles ──
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Sort Order',
                        '${_category.sortOrder}',
                        Icons.swap_vert_rounded,
                        AppColors.info,
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: _buildMetricTile(
                        'GST Rate',
                        '${_category.gstPercentage}%',
                        Icons.percent_rounded,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        'Scope',
                        _category.isGlobal ? 'Global' : 'Local',
                        Icons.public_rounded,
                        AppColors.success,
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: _buildMetricTile(
                        'Created On',
                        _formatDate(_category.createdAt),
                        Icons.calendar_today_rounded,
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // ── Edit Button ──
                if (canManage) ...[
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.h(AppSizes.buttonMedium),
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToEdit(),
                      icon: Icon(Icons.edit_rounded, size: Responsive.icon(AppSizes.iconSmall)),
                      label: Text(
                        'Edit Category Details',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontMedium),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          width: AppSizes.spacingTiny / 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Children Section ──
                if (levelLabel != 'Variant') ...[
                  ref.watch(categoriesProvider).when(
                    data: (all) {
                      final children = all.where((c) => c.parentId == _category.id).toList();
                      final sortedChildren = children..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                      final hasChildren = sortedChildren.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    levelLabel == 'Main Category' ? 'Sub Categories' : 'Variants',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontLarge),
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                  Container(
                                    padding: Responsive.symmetric(
                                      horizontal: AppSizes.spacingSmall,
                                      vertical: AppSizes.spacingTiny / 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                                    ),
                                    child: Text(
                                      '${sortedChildren.length}',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontSmall),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (canManage)
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => CategoryFormView(initialParentId: _category.id)),
                                    ).then((_) {
                                      ref.invalidate(categoriesProvider);
                                    });
                                  },
                                  icon: Icon(Icons.add_rounded, size: Responsive.icon(AppSizes.iconSmall)),
                                  label: Text(
                                    levelLabel == 'Main Category' ? 'Add Sub' : 'Add Variant',
                                    style: TextStyle(
                                      fontSize: Responsive.sp(AppSizes.fontSmall),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: Responsive.symmetric(horizontal: AppSizes.spacingSmall, vertical: AppSizes.spacingTiny),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),

                          if (canManage && hasChildren) ...[
                            Container(
                              padding: Responsive.all(AppSizes.spacingMedium),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: Responsive.icon(AppSizes.iconSmall), color: AppColors.primary),
                                  SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                  Expanded(
                                    child: Text(
                                      'Tip: Drag items by their grip handle (⋮⋮) to change their display order.',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontSmall),
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                          ],

                          if (sortedChildren.isEmpty)
                            Container(
                              padding: Responsive.all(AppSizes.spacingXLarge),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1.0),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: Responsive.icon(AppSizes.iconXLarge),
                                      color: AppColors.secondaryText.withValues(alpha: 0.3),
                                    ),
                                    SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                                    Text(
                                      levelLabel == 'Main Category'
                                          ? 'No sub-categories yet'
                                          : 'No variants yet',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontSmall),
                                        color: AppColors.secondaryText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (canManage)
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: sortedChildren.length,
                              onReorderItem: (oldIndex, newIndex) async {
                                final allCategories = ref.read(categoriesProvider).value;
                                if (allCategories == null) return;

                                final allCategoriesCopy = [...allCategories];

                                // 1. Get siblings sorted by sortOrder
                                final siblings = allCategoriesCopy.where((c) => c.parentId == _category.id).toList()
                                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                                // 2. Move item
                                final moved = siblings.removeAt(oldIndex);
                                siblings.insert(newIndex, moved);

                                // 3. Construct payload and update locally
                                final List<Map<String, dynamic>> payload = [];
                                for (int i = 0; i < siblings.length; i++) {
                                  final cat = siblings[i];
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
                                        backgroundColor: AppColors.success,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save order: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                              itemBuilder: (context, index) {
                                final child = sortedChildren[index];
                                return _buildChildCategoryRow(context, child, canManage, index: index);
                              },
                            )
                          else
                            Column(
                              children: sortedChildren
                                  .map((child) => _buildChildCategoryRow(context, child, canManage))
                                  .toList(),
                            )
                        ],
                      );
                    },
                    loading: () => Column(
                      children: [
                        SizedBox(height: Responsive.h(AppSizes.spacingXXLarge)),
                        _buildChildrenShimmerList(),
                      ],
                    ),
                    error: (e, _) => const Text('Error loading', style: TextStyle(color: AppColors.error)),
                  ),
                ],

                SizedBox(height: Responsive.h(AppSizes.spacingHuge)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: Responsive.symmetric(
        horizontal: AppSizes.spacingSmall + 2,
        vertical: AppSizes.spacingTiny,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXXLarge)),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: AppSizes.spacingTiny / 4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Responsive.icon(AppSizes.iconTiny - 2), color: color),
            SizedBox(width: Responsive.w(4)),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: Responsive.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: Responsive.all(AppSizes.spacingTiny * 1.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
            ),
            child: Icon(icon, size: Responsive.icon(AppSizes.iconSmall), color: color),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontTiny - 1),
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontLarge),
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChildCategoryRow(BuildContext context, Category child, bool canManage, {int? index}) {
    return Container(
      key: ValueKey(child.id),
      margin: Responsive.only(bottom: AppSizes.spacingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(AppSizes.radiusSmall),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: Responsive.w(4),
            child: Container(
              color: child.isActive ? AppColors.success : AppColors.secondaryText.withValues(alpha: 0.4),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CategoryDetailView(initialCategory: child)),
                ).then((_) {
                  ref.invalidate(categoriesProvider);
                });
              },
              child: Padding(
                padding: Responsive.only(
                  left: AppSizes.spacingMedium + 4,
                  right: AppSizes.spacingMedium,
                  top: AppSizes.spacingSmall + 2,
                  bottom: AppSizes.spacingSmall + 2,
                ),
                child: Row(
                  children: [
                    if (canManage && index != null)
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: Responsive.only(right: AppSizes.spacingSmall),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: Responsive.icon(AppSizes.iconSmall),
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    _buildCategoryImage(child, size: 44),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontMedium),
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          Row(
                            children: [
                              Container(
                                width: Responsive.w(6),
                                height: Responsive.w(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: child.isActive ? AppColors.success : AppColors.secondaryText.withValues(alpha: 0.4),
                                ),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingTiny + 2)),
                              Text(
                                child.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontTiny),
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              SizedBox(width: Responsive.w(AppSizes.spacingSmall + 2)),
                              Container(
                                padding: Responsive.symmetric(
                                  horizontal: AppSizes.spacingSmall,
                                  vertical: AppSizes.spacingTiny / 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall / 2)),
                                ),
                                child: Text(
                                  '${child.gstPercentage}% GST',
                                  style: TextStyle(
                                    fontSize: Responsive.sp(AppSizes.fontTiny),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: Responsive.icon(AppSizes.iconMedium),
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage(Category cat, {double size = 40, bool hasShadow = false}) {
    final s = Responsive.w(size);
    Widget imageWidget;
    if (cat.imageUrl != null && cat.imageUrl!.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(size * 0.25)),
        child: Image.network(
          cat.imageUrl!,
          width: s,
          height: s,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildSmallIconAvatar(s, size),
        ),
      );
    } else {
      imageWidget = _buildSmallIconAvatar(s, size);
    }

    if (hasShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.r(size * 0.25)),
          border: Border.all(color: Colors.white, width: Responsive.w(3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: Responsive.r(8),
              offset: Offset(0, Responsive.h(4)),
            ),
          ],
        ),
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildSmallIconAvatar(double s, double size) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.r(size * 0.25)),
      ),
      child: Icon(
        Icons.folder_rounded,
        size: s * 0.45,
        color: AppColors.primary,
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Category',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontLarge),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this category? This cannot be undone.',
          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = ref.read(categoryRepositoryProvider);
                await repo.deleteCategory(_category.id);
                ref.invalidate(categoriesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenShimmerList() {
    return Column(
      children: List.generate(3, (index) => Container(
        margin: Responsive.only(bottom: AppSizes.spacingSmall),
        padding: Responsive.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                width: Responsive.w(AppSizes.iconXXLarge),
                height: Responsive.w(AppSizes.iconXXLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                ),
              ),
              SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Responsive.w(100),
                      height: Responsive.h(AppSizes.fontMedium),
                      color: Colors.white,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                    Container(
                      width: Responsive.w(60),
                      height: Responsive.h(AppSizes.fontSmall),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _BannerDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle circles
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.height * 0.6,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.height * 0.4,
      paint,
    );

    // Draw a subtle grid pattern
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
