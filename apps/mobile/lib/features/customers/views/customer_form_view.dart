import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/upload_repository.dart';
import '../models/customer.dart';
import '../viewmodels/providers/customer_provider.dart';

class CustomerFormView extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerFormView({super.key, this.customer});

  @override
  ConsumerState<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends ConsumerState<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _idNumberController = TextEditingController();

  IdType? _selectedIdType;

  // R2 Upload State Variables
  final _uploadRepo = UploadRepository();
  final _imagePicker = ImagePicker();

  String? _photoUrl;
  String? _frontImageUrl;
  String? _backImageUrl;

  bool _isUploadingPhoto = false;
  bool _isUploadingFront = false;
  bool _isUploadingBack = false;
  bool _isLoading = false;

  // Progress step tracking (visual only)
  int _activeStep = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _altPhoneController.text = widget.customer!.altPhone ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _gstinController.text = widget.customer!.gstin ?? '';
      _selectedIdType = widget.customer!.idType;
      _idNumberController.text = widget.customer!.idNumber ?? '';
      _photoUrl = widget.customer!.photoUrl;

      // Parse ID documents
      final existingFront = widget.customer!.idDocuments?.firstWhere(
        (doc) => doc.type == 'front',
        orElse: () => IdDocument(url: '', type: 'front'),
      );
      if (existingFront != null && existingFront.url.isNotEmpty) {
        _frontImageUrl = existingFront.url;
      }

      final existingBack = widget.customer!.idDocuments?.firstWhere(
        (doc) => doc.type == 'back',
        orElse: () => IdDocument(url: '', type: 'back'),
      );
      if (existingBack != null && existingBack.url.isNotEmpty) {
        _backImageUrl = existingBack.url;
      }
    }

    _scrollController.addListener(_updateStepFromScroll);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _idNumberController.dispose();
    _scrollController.removeListener(_updateStepFromScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateStepFromScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    int newStep;
    if (offset < maxScroll * 0.35) {
      newStep = 0;
    } else if (offset < maxScroll * 0.7) {
      newStep = 1;
    } else {
      newStep = 2;
    }

    if (newStep != _activeStep) {
      setState(() => _activeStep = newStep);
    }
  }

  // Pick and Upload helper
  Future<void> _pickAndUploadImage({
    required String folder,
    required Function(bool) setUploading,
    required Function(String) setUrl,
  }) async {
    FocusScope.of(context).unfocus();

    // Show source picker sheet
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.r(AppSizes.radiusXLarge))),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: Responsive.all(AppSizes.spacingXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(AppSizes.spacingHuge),
                height: Responsive.h(AppSizes.spacingTiny),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(Responsive.r(2)),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
              Text(
                'Choose Source',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: AppColors.primary,
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                  _buildSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: AppColors.info,
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        setState(() => setUploading(true));
        final uploadedUrl = await _uploadRepo.uploadFile(
          File(pickedFile.path),
          folder: folder,
        );
        setState(() {
          setUrl(uploadedUrl);
          setUploading(false);
        });
      }
    } catch (e) {
      setState(() => setUploading(false));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Widget _buildSourceTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      child: Container(
        width: Responsive.w(110),
        padding: Responsive.symmetric(vertical: AppSizes.spacingLarge),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        ),
        child: Column(
          children: [
            Container(
              padding: Responsive.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: Responsive.icon(AppSizes.iconMedium)),
            ),
            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontMedium),
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Build ID Documents payload
    final idDocuments = <Map<String, String>>[];
    if (_frontImageUrl != null && _frontImageUrl!.isNotEmpty) {
      idDocuments.add({'url': _frontImageUrl!, 'type': 'front'});
    }
    if (_backImageUrl != null && _backImageUrl!.isNotEmpty) {
      idDocuments.add({'url': _backImageUrl!, 'type': 'back'});
    }

    final body = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'alt_phone': _altPhoneController.text.trim().isEmpty ? null : _altPhoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? '' : _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? '' : _addressController.text.trim(),
      'gstin': _gstinController.text.trim().isEmpty ? '' : _gstinController.text.trim().toUpperCase(),
      'id_type': _idTypeToDbString(_selectedIdType),
      'id_number': _idNumberController.text.trim().isEmpty ? '' : _idNumberController.text.trim(),
      'photo_url': _photoUrl ?? '',
      'id_documents': idDocuments,
      'store_id': 'default-store-id', // Single-shop tenant id
    };

    try {
      if (widget.customer != null) {
        await ref.read(customerOperationsProvider).updateCustomer(widget.customer!.id, body);
      } else {
        await ref.read(customerOperationsProvider).createCustomer(body);
      }

      if (mounted) {
        ref.invalidate(customersProvider);
        if (widget.customer != null) {
          ref.invalidate(customerProvider(widget.customer!.id));
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isEditing = widget.customer != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Header with Step Indicator ────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: Responsive.r(AppSizes.spacingSmall),
                      offset: Offset(0, Responsive.h(2)),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Title bar
                      Padding(
                        padding: Responsive.symmetric(
                          horizontal: AppSizes.spacingSmall,
                          vertical: AppSizes.spacingSmall,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.text,
                                size: Responsive.icon(AppSizes.iconMedium),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                            Expanded(
                              child: Text(
                                isEditing ? 'Edit Customer' : 'New Customer',
                                style: TextStyle(
                                  fontSize: Responsive.sp(AppSizes.fontXLarge),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Step progress bar
                      Padding(
                        padding: Responsive.only(
                          left: AppSizes.screenPaddingSmall,
                          right: AppSizes.screenPaddingSmall,
                          bottom: AppSizes.spacingMedium,
                        ),
                        child: _buildStepIndicator(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Form Body ────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: Responsive.all(AppSizes.screenPaddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Personal Information Section
                        _buildFormSection(
                          title: 'Personal Information',
                          description: 'Basic contact and billing details',
                          icon: Icons.person_outline_rounded,
                          color: AppColors.primary,
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter full name',
                              prefixIcon: Icons.person_rounded,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'e.g. +91 9876543210',
                              prefixIcon: Icons.phone_rounded,
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _altPhoneController,
                              label: 'Alternate Phone',
                              hint: 'Optional second contact number',
                              prefixIcon: Icons.phone_forwarded_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (value.trim().length < 10 || value.trim().length > 20) {
                                    return 'Phone must be between 10 and 20 digits';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'customer@email.com',
                              prefixIcon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!regex.hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              hint: 'Full postal address',
                              prefixIcon: Icons.location_on_rounded,
                              maxLines: 3,
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _gstinController,
                              label: 'GSTIN',
                              hint: 'e.g. 22AAAAA0000A1Z5',
                              prefixIcon: Icons.receipt_long_rounded,
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (value.trim().length != 15) {
                                    return 'GSTIN must be exactly 15 characters';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

                        // Identity Verification Card
                        _buildFormSection(
                          title: 'Identity Verification',
                          description: 'Verify identity documents',
                          icon: Icons.badge_outlined,
                          color: AppColors.primary,
                          children: [
                            _buildDropdownField<IdType>(
                              label: 'ID Type',
                              value: _selectedIdType,
                              prefixIcon: Icons.credit_card_rounded,
                              items: IdType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.toString().split('.').last.toUpperCase(),
                                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedIdType = val);
                              },
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            _buildTextField(
                              controller: _idNumberController,
                              label: 'ID Number',
                              hint: 'Enter ID document number',
                              prefixIcon: Icons.numbers_rounded,
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
                            // ID Document upload
                            Text(
                              'Upload ID Documents',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildImageUploadSlot(
                                    title: 'Front Side',
                                    imageUrl: _frontImageUrl,
                                    isUploading: _isUploadingFront,
                                    onPick: () => _pickAndUploadImage(
                                      folder: 'customers/id-documents',
                                      setUploading: (val) => _isUploadingFront = val,
                                      setUrl: (url) => _frontImageUrl = url,
                                    ),
                                    onRemove: () => setState(() => _frontImageUrl = null),
                                  ),
                                ),
                                SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                                Expanded(
                                  child: _buildImageUploadSlot(
                                    title: 'Back Side',
                                    imageUrl: _backImageUrl,
                                    isUploading: _isUploadingBack,
                                    onPick: () => _pickAndUploadImage(
                                      folder: 'customers/id-documents',
                                      setUploading: (val) => _isUploadingBack = val,
                                      setUrl: (url) => _backImageUrl = url,
                                    ),
                                    onRemove: () => setState(() => _backImageUrl = null),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),

                        // Customer Profile Photo Card
                        _buildFormSection(
                          title: 'Profile Photo',
                          description: 'Add a customer photo for identification',
                          icon: Icons.camera_alt_outlined,
                          color: AppColors.primary,
                          children: [
                            Center(
                              child: _buildProfilePhotoSlot(
                                imageUrl: _photoUrl,
                                isUploading: _isUploadingPhoto,
                                onPick: () => _pickAndUploadImage(
                                  folder: 'customers/photos',
                                  setUploading: (val) => _isUploadingPhoto = val,
                                  setUrl: (url) => _photoUrl = url,
                                ),
                                onRemove: () => setState(() => _photoUrl = null),
                              ),
                            ),
                          ],
                        ),

                        // Margin for bottom sticky actions
                        SizedBox(height: Responsive.h(AppSizes.buttonLarge + AppSizes.spacingMassive + AppSizes.spacingLarge)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Bottom Actions Bar ────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: Responsive.symmetric(
                horizontal: AppSizes.screenPaddingSmall,
                vertical: AppSizes.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: Responsive.r(AppSizes.spacingMedium),
                    offset: Offset(0, -Responsive.h(AppSizes.spacingTiny)),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: Responsive.symmetric(vertical: AppSizes.spacingMedium + 2),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: Responsive.r(AppSizes.spacingMedium),
                              offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: Responsive.symmetric(vertical: AppSizes.spacingMedium + 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: Responsive.w(AppSizes.spacingXLarge),
                                  height: Responsive.h(AppSizes.spacingXLarge),
                                  child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing ? Icons.check_circle_rounded : Icons.person_add_rounded,
                                      size: Responsive.icon(AppSizes.iconSmall),
                                    ),
                                    SizedBox(width: Responsive.w(AppSizes.spacingSmall)),
                                    Text(
                                      isEditing ? 'Update Customer' : 'Create Customer',
                                      style: TextStyle(
                                        fontSize: Responsive.sp(AppSizes.fontMedium),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Modal Barrier
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Step Progress Indicator ──────────────────────────
  Widget _buildStepIndicator() {
    const steps = ['Personal', 'Identity', 'Photo'];
    const stepIcons = [Icons.person_rounded, Icons.badge_rounded, Icons.camera_alt_rounded];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = index == _activeStep;
        final isCompleted = index < _activeStep;

        return Expanded(
          child: Row(
            children: [
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted || isActive
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
              Container(
                padding: Responsive.symmetric(
                  horizontal: AppSizes.spacingSmall + 2,
                  vertical: AppSizes.spacingTiny + 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : isCompleted
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusXLarge)),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : isCompleted
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_rounded : stepIcons[index],
                      size: Responsive.icon(AppSizes.fontSmall + 2),
                      color: isActive
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.success
                              : AppColors.secondaryText.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: Responsive.w(AppSizes.spacingTiny)),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : isCompleted
                                ? AppColors.success
                                : AppColors.secondaryText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Form Section Card ───────────────────────────────
  Widget _buildFormSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: Responsive.r(AppSizes.spacingMedium),
            offset: Offset(0, Responsive.h(2)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent strip
              Container(
                width: Responsive.w(AppSizes.spacingTiny),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: Responsive.all(AppSizes.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        children: [
                          Container(
                            padding: Responsive.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: Responsive.icon(AppSizes.iconSmall),
                            ),
                          ),
                          SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                SizedBox(height: Responsive.h(2)),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: Responsive.sp(AppSizes.fontSmall),
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                      Container(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                      ...children,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Text Field ──────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontSmall + 1),
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontMedium),
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: Responsive.sp(AppSizes.fontMedium),
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: Responsive.only(left: AppSizes.spacingMedium, right: AppSizes.spacingSmall),
                    child: Icon(
                      prefixIcon,
                      color: AppColors.secondaryText.withValues(alpha: 0.4),
                      size: Responsive.icon(AppSizes.iconSmall),
                    ),
                  )
                : null,
            prefixIconConstraints: prefixIcon != null
                ? BoxConstraints(minWidth: Responsive.w(AppSizes.iconXLarge))
                : null,
            filled: true,
            fillColor: AppColors.scaffoldBackground,
            contentPadding: Responsive.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: const BorderSide(color: AppColors.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Dropdown Field ──────────────────────────────────
  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontSmall + 1),
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: AppColors.text),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: Responsive.only(left: AppSizes.spacingMedium, right: AppSizes.spacingSmall),
                    child: Icon(
                      prefixIcon,
                      color: AppColors.secondaryText.withValues(alpha: 0.4),
                      size: Responsive.icon(AppSizes.iconSmall),
                    ),
                  )
                : null,
            prefixIconConstraints: prefixIcon != null
                ? BoxConstraints(minWidth: Responsive.w(AppSizes.iconXLarge))
                : null,
            filled: true,
            fillColor: AppColors.scaffoldBackground,
            contentPadding: Responsive.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingMedium,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Image Upload Slot (Dashed border) ────────────────
  Widget _buildImageUploadSlot({
    required String title,
    required String? imageUrl,
    required bool isUploading,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            decoration: BoxDecoration(
              color: hasImage ? Colors.transparent : AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
              border: hasImage
                  ? null
                  : Border.all(
                      color: AppColors.secondaryText.withValues(alpha: 0.2),
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
              boxShadow: hasImage
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: Responsive.r(AppSizes.spacingSmall),
                        offset: Offset(0, Responsive.h(2)),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: isUploading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: Responsive.w(AppSizes.spacingXLarge),
                        height: Responsive.h(AppSizes.spacingXLarge),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                      Text(
                        'Uploading...',
                        style: TextStyle(
                          fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          // Title label
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              padding: Responsive.symmetric(
                                vertical: AppSizes.spacingSmall,
                                horizontal: AppSizes.spacingMedium,
                              ),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.sp(AppSizes.fontSmall),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: Responsive.h(AppSizes.spacingTiny),
                            right: Responsive.w(AppSizes.spacingTiny),
                            child: GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                padding: Responsive.all(AppSizes.spacingTiny),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: Responsive.r(AppSizes.spacingTiny),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.error,
                                  size: Responsive.icon(AppSizes.iconSmall - 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: onPick,
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: Responsive.all(AppSizes.spacingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.primary.withValues(alpha: 0.6),
                                size: Responsive.icon(AppSizes.iconMedium),
                              ),
                            ),
                            SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontSmall),
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: Responsive.h(2)),
                            Text(
                              'Tap to upload',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontTiny),
                                color: AppColors.secondaryText.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  // ── Profile Photo Slot ──────────────────────────────
  Widget _buildProfilePhotoSlot({
    required String? imageUrl,
    required bool isUploading,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final size = Responsive.w(110);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.scaffoldBackground,
            border: Border.all(
              color: hasImage ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
              width: 2,
            ),
            boxShadow: hasImage
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: Responsive.r(AppSizes.spacingMedium),
                      offset: Offset(0, Responsive.h(AppSizes.spacingTiny)),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: isUploading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : InkWell(
                      onTap: onPick,
                      borderRadius: BorderRadius.circular(Responsive.r(AppSizes.spacingMassive)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: Responsive.all(AppSizes.spacingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.primary.withValues(alpha: 0.5),
                              size: Responsive.icon(AppSizes.iconMedium),
                            ),
                          ),
                          SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              fontSize: Responsive.sp(AppSizes.fontTiny),
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
        if (hasImage && !isUploading)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: Responsive.all(AppSizes.spacingTiny + 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: Responsive.r(AppSizes.spacingTiny),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: Responsive.icon(AppSizes.iconSmall - 2),
                ),
              ),
            ),
          ),
        if (hasImage && !isUploading)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: Responsive.all(AppSizes.spacingTiny + 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: Responsive.r(AppSizes.spacingTiny),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary,
                  size: Responsive.icon(AppSizes.iconSmall - 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String? _idTypeToDbString(IdType? type) {
    if (type == null) return null;
    switch (type) {
      case IdType.aadhaar:
        return 'Aadhaar';
      case IdType.pan:
        return 'PAN';
      case IdType.drivingLicence:
        return 'Driving Licence';
      case IdType.passport:
        return 'Passport';
      case IdType.others:
        return 'Others';
    }
  }
}
