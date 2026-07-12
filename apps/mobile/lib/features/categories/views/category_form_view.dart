import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/upload_repository.dart';
import '../models/category.dart';
import '../viewmodels/providers/category_provider.dart';

/// Create / Edit form for a category.
/// If [category] is null → Create mode. Otherwise → Edit mode.
class CategoryFormView extends ConsumerStatefulWidget {
  final Category? category;
  final String? initialParentId;
  const CategoryFormView({super.key, this.category, this.initialParentId});

  @override
  ConsumerState<CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends ConsumerState<CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _descriptionController;
  late TextEditingController _sortOrderController;
  bool _isActive = true;
  bool _isGlobal = false;
  String? _parentId;
  int _gstPercentage = 5;
  bool _hasBuffer = true;
  bool _isLoading = false;
  bool _isUploading = false;

  // Image state
  File? _pickedFile;           // Locally picked file (not yet uploaded)
  String? _uploadedImageUrl;   // URL from server after upload / existing URL
  bool _imageRemoved = false;  // User explicitly removed the image

  bool get isEditing => widget.category != null;

  final _imagePicker = ImagePicker();
  final _uploadRepo = UploadRepository();

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameController = TextEditingController(text: c?.name ?? '');
    _slugController = TextEditingController(text: c?.slug ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _sortOrderController = TextEditingController(text: '${c?.sortOrder ?? 0}');
    _isActive = c?.isActive ?? true;
    _isGlobal = c?.isGlobal ?? true;
    _gstPercentage = c?.gstPercentage ?? 5;
    _hasBuffer = c?.hasBuffer ?? false;
    _parentId = c?.parentId ?? widget.initialParentId;
    _uploadedImageUrl = c?.imageUrl;

    // Auto-generate slug from name
    _nameController.addListener(_onNameChanged);

    // Recover image if Android killed the activity during image picker
    _retrieveLostImage();
  }

  /// Recovers a picked image if the Android OS killed our Activity
  /// while the camera/gallery was open.
  Future<void> _retrieveLostImage() async {
    try {
      final LostDataResponse response = await _imagePicker.retrieveLostData();
      if (response.isEmpty || response.file == null) return;
      if (!mounted) return;
      setState(() {
        _pickedFile = File(response.file!.path);
        _imageRemoved = false;
      });
    } catch (e) {
      debugPrint('Error retrieving lost image: $e');
    }
  }

  void _onNameChanged() {
    if (!isEditing || _slugController.text == _generateSlug(widget.category!.name)) {
      _slugController.text = _generateSlug(_nameController.text);
    }
  }

  String _generateSlug(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  // ── Image Picking ──
  void _showImagePicker() {
    // CRITICAL: Unfocus any text field before launching external camera/gallery.
    // When a TextField holds focus, the keyboard + text input system keeps
    // extra native resources alive. This inflates the app's memory footprint
    // and makes Android's OOM killer more likely to terminate the process
    // while the camera Activity is in the foreground.
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.r(20)))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: Responsive.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(40), height: Responsive.h(4),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(Responsive.r(2))),
              ),
              SizedBox(height: Responsive.h(20)),
              Text('Choose Image', style: TextStyle(fontSize: Responsive.sp(16), fontWeight: FontWeight.bold)),
              SizedBox(height: Responsive.h(20)),
              Row(
                children: [
                  _buildPickerOption(Icons.camera_alt_rounded, 'Camera', AppColors.primary, () async {
                    Navigator.pop(ctx);
                    try {
                      final picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 60, maxWidth: 1024, maxHeight: 1024);
                      if (picked != null && mounted) {
                        setState(() {
                          _pickedFile = File(picked.path);
                          _imageRemoved = false;
                        });
                      }
                    } catch (e) {
                      debugPrint('Camera error: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open camera: $e')));
                      }
                    }
                  }),
                  SizedBox(width: Responsive.w(16)),
                  _buildPickerOption(Icons.photo_library_rounded, 'Gallery', const Color(0xFF26C6DA), () async {
                    Navigator.pop(ctx);
                    try {
                      final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60, maxWidth: 1024, maxHeight: 1024);
                      if (picked != null && mounted) {
                        setState(() {
                          _pickedFile = File(picked.path);
                          _imageRemoved = false;
                        });
                      }
                    } catch (e) {
                      debugPrint('Gallery error: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open gallery: $e')));
                      }
                    }
                  }),
                ],
              ),
              SizedBox(height: Responsive.h(12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: Responsive.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Responsive.r(14)),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, size: Responsive.icon(32), color: color),
              SizedBox(height: Responsive.h(8)),
              Text(label, style: TextStyle(fontSize: Responsive.sp(13), fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _pickedFile = null;
      _uploadedImageUrl = null;
      _imageRemoved = true;
    });
  }

  // ── Submit ──
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload image if a new one was picked
      String? finalImageUrl = _imageRemoved ? null : _uploadedImageUrl;
      if (_pickedFile != null) {
        setState(() => _isUploading = true);
        debugPrint('[CategoryForm] Uploading image: ${_pickedFile!.path}');
        finalImageUrl = await _uploadRepo.uploadFile(_pickedFile!, folder: 'categories');
        debugPrint('[CategoryForm] Upload success: $finalImageUrl');
        setState(() => _isUploading = false);
      }

      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'slug': _slugController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': finalImageUrl,
        'parent_id': _parentId,
        'sort_order': int.tryParse(_sortOrderController.text) ?? 0,
        'is_active': _isActive,
        'is_global': _isGlobal,
        'gst_percentage': _gstPercentage,
        'has_buffer': _hasBuffer,
      };

      debugPrint('[CategoryForm] Submitting body: $body');

      final repo = ref.read(categoryRepositoryProvider);
      if (isEditing) {
        await repo.updateCategory(widget.category!.id, body);
      } else {
        await repo.createCategory(body);
      }
      debugPrint('[CategoryForm] Success!');
      ref.invalidate(categoriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Category updated!' : 'Category created!'), backgroundColor: const Color(0xFF4CAF50)),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('[CategoryForm] ERROR: $e');
      debugPrint('[CategoryForm] Stack: $stackTrace');
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; _isUploading = false; });
    }
  }

  String _getFormTitle(List<Category> categories) {
    if (isEditing) return 'Edit Category';
    if (_parentId == null) return 'New Main Category';
    
    final parent = categories.cast<Category?>().firstWhere((c) => c?.id == _parentId, orElse: () => null);
    if (parent == null) return 'New Category';
    if (parent.parentId == null) return 'New Sub Category';
    return 'New Variant';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final title = _getFormTitle(categories);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontSize: Responsive.sp(18))),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: Responsive.all(16),
          children: [
            // Panel 1: Details
            _buildFormPanel(
              title: 'Category Details',
              description: 'Name, slug, and customer-facing description',
              icon: Icon(Icons.edit_note_rounded, size: Responsive.icon(22), color: Colors.grey[400]),
              children: [
                _buildLabel('Category Name *'),
                SizedBox(height: Responsive.h(6)),
                _buildTextField(_nameController, 'e.g. Bridal Wear',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                SizedBox(height: Responsive.h(16)),
                _buildLabel('Slug *'),
                SizedBox(height: Responsive.h(6)),
                _buildTextField(_slugController, 'auto-generated-slug',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Slug is required' : null),
                SizedBox(height: Responsive.h(16)),
                _buildLabel('Description'),
                SizedBox(height: Responsive.h(6)),
                _buildTextField(_descriptionController, 'Optional description...', maxLines: 3),
              ],
            ),

            // Panel 2: Image
            _buildFormPanel(
              title: 'Category Image',
              description: 'Use a clean image that makes the category easy to recognise',
              icon: Icon(Icons.image_outlined, size: Responsive.icon(20), color: Colors.grey[400]),
              children: [
                _buildImageSection(),
              ],
            ),

            // Panel 3: Hierarchy
            if (isEditing || _parentId != null)
              _buildFormPanel(
                title: 'Hierarchy',
                description: 'Placement controls where this category appears',
                icon: Icon(Icons.account_tree_outlined, size: Responsive.icon(20), color: Colors.grey[400]),
                children: [
                  _buildLabel('Parent Category'),
                  SizedBox(height: Responsive.h(6)),
                  isEditing ? _buildParentSelector() : _buildReadOnlyParent(),
                ],
              ),

            // Panel 4: Settings
            _buildFormPanel(
              title: 'Operational Settings',
              description: 'Control tax rates and booking behaviors',
              icon: Icon(Icons.settings_outlined, size: Responsive.icon(20), color: Colors.grey[400]),
              children: [
                _buildLabel('GST Rate *'),
                SizedBox(height: Responsive.h(6)),
                DropdownButtonFormField<int>(
                  initialValue: _gstPercentage,
                  style: TextStyle(fontSize: Responsive.sp(15), color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: Responsive.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.r(12)),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.r(12)),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.r(12)),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('0%')),
                    DropdownMenuItem(value: 5, child: Text('5%')),
                    DropdownMenuItem(value: 12, child: Text('12%')),
                    DropdownMenuItem(value: 18, child: Text('18%')),
                    DropdownMenuItem(value: 28, child: Text('28%')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _gstPercentage = val);
                    }
                  },
                ),
                SizedBox(height: Responsive.h(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cleaning Buffer Required',
                            style: TextStyle(
                              fontSize: Responsive.sp(13),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: Responsive.h(4)),
                          Text(
                            'Enforces a mandatory 1-day cleaning gap between rentals. Disable for items like ornaments.',
                            style: TextStyle(
                              fontSize: Responsive.sp(10),
                              color: Colors.grey[500],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.w(12)),
                    Switch(
                      value: _hasBuffer,
                      onChanged: (v) => setState(() => _hasBuffer = v),
                      activeTrackColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: Responsive.h(12)),

            // Submit Button
            SizedBox(
              height: Responsive.h(52),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(12))),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: Responsive.icon(18), width: Responsive.icon(18),
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: Responsive.w(10)),
                          Text(_isUploading ? 'Uploading image...' : 'Saving...',
                            style: TextStyle(fontSize: Responsive.sp(13), color: Colors.white)),
                        ],
                      )
                    : Text(isEditing ? 'Update Category' : 'Create Category',
                        style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: Responsive.h(32)),
          ],
        ),
      ),
    );
  }

  // ── Image Section ──
  Widget _buildImageSection() {
    final bool hasImage = _pickedFile != null || (_uploadedImageUrl != null && !_imageRemoved);

    return Column(
      children: [
        // Image preview
        GestureDetector(
          onTap: hasImage ? null : _showImagePicker,
          child: Container(
            width: double.infinity,
            height: Responsive.h(200),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FC),
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: hasImage ? _buildImagePreview() : _buildImagePlaceholder(),
          ),
        ),

        // Action buttons
        Padding(
          padding: Responsive.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showImagePicker,
                  icon: Icon(Icons.camera_alt_outlined, size: Responsive.icon(16)),
                  label: Text(hasImage ? 'Change' : 'Add Image', style: TextStyle(fontSize: Responsive.sp(12))),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    padding: Responsive.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                  ),
                ),
              ),
              if (hasImage) ...[
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: Icon(Icons.delete_outline, size: Responsive.icon(16)),
                    label: Text('Remove', style: TextStyle(fontSize: Responsive.sp(12))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B8A),
                      side: BorderSide(color: const Color(0xFFFF6B8A).withValues(alpha: 0.3)),
                      padding: Responsive.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(8))),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Responsive.r(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_pickedFile != null)
            Image.file(
              _pickedFile!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
            )
          else if (_uploadedImageUrl != null)
            Image.network(_uploadedImageUrl!, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder()),
          // Gradient overlay at bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: Responsive.h(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          // Badge
          Positioned(
            bottom: Responsive.h(8), left: Responsive.w(12),
            child: Container(
              padding: Responsive.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _pickedFile != null ? AppColors.primary.withValues(alpha: 0.9) : const Color(0xFF4CAF50).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(Responsive.r(6)),
              ),
              child: Text(
                _pickedFile != null ? 'New Image' : 'Current',
                style: TextStyle(fontSize: Responsive.sp(9), fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: Responsive.icon(40), color: Colors.grey[350]),
        SizedBox(height: Responsive.h(10)),
        Text('Tap to add image', style: TextStyle(fontSize: Responsive.sp(12), color: Colors.grey)),
        SizedBox(height: Responsive.h(4)),
        Text('Camera or Gallery', style: TextStyle(fontSize: Responsive.sp(10), color: Colors.grey[400])),
      ],
    );
  }

  // ── Shared Form Widgets ──
  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: Responsive.sp(14), fontWeight: FontWeight.w700, color: Colors.black87));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {String? Function(String?)? validator, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: Responsive.sp(15)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: Responsive.sp(14), color: Colors.grey),
        filled: true, fillColor: Colors.white,
        contentPadding: Responsive.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(12)), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(12)), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.r(12)), borderSide: BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }



  Widget _buildParentSelector() {
    final categoriesAsync = ref.watch(categoriesProvider);
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Failed to load parent categories: $e', style: TextStyle(fontSize: Responsive.sp(13), color: Colors.red)),
      data: (categories) {
        final c = widget.category;
        bool isDescendant(String id) {
          if (c == null) return false;
          final p = categories.cast<Category?>().firstWhere((cat) => cat?.id == id, orElse: () => null);
          if (p == null) return false;
          if (p.parentId == c.id) return true;
          if (p.parentId == null) return false;
          return isDescendant(p.parentId!);
        }

        final allowed = categories.where((item) {
          if (c != null && item.id == c.id) return false;
          if (c != null && isDescendant(item.id)) return false;
          return true;
        }).toList();

        final mains = allowed.where((cat) => cat.parentId == null).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        final subs = allowed.where((cat) {
          final parent = allowed.cast<Category?>().firstWhere((p) => p?.id == cat.parentId, orElse: () => null);
          return parent != null && parent.parentId == null;
        }).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return DropdownButtonFormField<String?>(
          initialValue: _parentId,
          style: TextStyle(fontSize: Responsive.sp(14), color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: Responsive.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('None (Main Category)'),
            ),
            ...mains.map((m) => DropdownMenuItem<String?>(
              value: m.id,
              child: Text(m.name),
            )),
            ...subs.map((s) {
              final parent = mains.cast<Category?>().firstWhere((m) => m?.id == s.parentId, orElse: () => null);
              final prefix = parent != null ? '${parent.name} > ' : '';
              return DropdownMenuItem<String?>(
                value: s.id,
                child: Text('$prefix${s.name}'),
              );
            }),
          ],
          onChanged: (val) {
            setState(() => _parentId = val);
          },
        );
      },
    );
  }

  Widget _buildReadOnlyParent() {
    final categoriesAsync = ref.watch(categoriesProvider);
    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e', style: TextStyle(fontSize: Responsive.sp(12), color: Colors.red)),
      data: (categories) {
        final parent = categories.cast<Category?>().firstWhere((c) => c?.id == _parentId, orElse: () => null);
        return Container(
          padding: Responsive.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(Responsive.r(8)),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_open_rounded, size: Responsive.icon(16), color: AppColors.primary),
              SizedBox(width: Responsive.w(8)),
              Expanded(
                child: Text(
                  'Creating inside: ${parent?.name ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: Responsive.sp(12),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormPanel({
    required String title,
    required String description,
    required List<Widget> children,
    Widget? icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.h(16)),
      padding: Responsive.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(16)),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: Responsive.r(10),
            offset: Offset(0, Responsive.h(2)),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Responsive.sp(15),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: Responsive.h(2)),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: Responsive.sp(11),
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: Responsive.w(8)),
                icon,
              ],
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }
}

