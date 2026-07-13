import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/upload_repository.dart';
import '../../auth/viewmodels/auth_provider.dart' as core_auth;
import '../models/customer.dart';
import '../viewmodels/providers/customer_provider.dart';

enum ImageTarget { photo, idFront, idBack }

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
  IdType? _selectedIdType;
  final _idNumberController = TextEditingController();

  final _imagePicker = ImagePicker();
  final _uploadRepo = UploadRepository();

  File? _photoFile;
  String? _existingPhotoUrl;
  bool _photoRemoved = false;

  File? _idFrontFile;
  String? _existingIdFrontUrl;
  bool _idFrontRemoved = false;

  File? _idBackFile;
  String? _existingIdBackUrl;
  bool _idBackRemoved = false;

  bool _isLoading = false;
  bool _isUploading = false;

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

      _existingPhotoUrl = widget.customer!.photoUrl;
      final docs = widget.customer!.idDocuments;
      if (docs != null) {
        for (final doc in docs) {
          if (doc.type == 'front') {
            _existingIdFrontUrl = doc.url;
          } else if (doc.type == 'back') {
            _existingIdBackUrl = doc.url;
          }
        }
      }
    }
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
    super.dispose();
  }

  // ── Image Picking ──
  void _showImagePicker(ImageTarget target) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.r(AppSizes.radiusXLarge))),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: Responsive.all(AppSizes.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(40),
                height: Responsive.h(4),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall / 4)),
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              Text(
                'Choose Image',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontLarge),
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
              Row(
                children: [
                  _buildPickerOption(Icons.camera_alt_rounded, 'Camera', AppColors.primary, () async {
                    Navigator.pop(ctx);
                    await _pickImageFile(ImageSource.camera, target);
                  }),
                  SizedBox(width: Responsive.w(AppSizes.spacingLarge)),
                  _buildPickerOption(Icons.photo_library_rounded, 'Gallery', const Color(0xFF26C6DA), () async {
                    Navigator.pop(ctx);
                    await _pickImageFile(ImageSource.gallery, target);
                  }),
                ],
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFile(ImageSource source, ImageTarget target) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null && mounted) {
        setState(() {
          switch (target) {
            case ImageTarget.photo:
              _photoFile = File(picked.path);
              _photoRemoved = false;
              break;
            case ImageTarget.idFront:
              _idFrontFile = File(picked.path);
              _idFrontRemoved = false;
              break;
            case ImageTarget.idBack:
              _idBackFile = File(picked.path);
              _idBackRemoved = false;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Image picking error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPickerOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: Responsive.symmetric(vertical: AppSizes.spacingLarge),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
            border: Border.all(color: color.withValues(alpha: 0.2), width: AppSizes.spacingTiny / 4),
          ),
          child: Column(
            children: [
              Icon(icon, size: Responsive.icon(AppSizes.iconXLarge), color: color),
              SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontSmall + 1),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Upload files if needed
      String? photoUrl = _photoRemoved ? null : _existingPhotoUrl;
      if (_photoFile != null) {
        setState(() => _isUploading = true);
        photoUrl = await _uploadRepo.uploadFile(_photoFile!, folder: 'customers/photos');
      }

      String? idFrontUrl = _idFrontRemoved ? null : _existingIdFrontUrl;
      if (_idFrontFile != null) {
        setState(() => _isUploading = true);
        idFrontUrl = await _uploadRepo.uploadFile(_idFrontFile!, folder: 'customers/id-documents');
      }

      String? idBackUrl = _idBackRemoved ? null : _existingIdBackUrl;
      if (_idBackFile != null) {
        setState(() => _isUploading = true);
        idBackUrl = await _uploadRepo.uploadFile(_idBackFile!, folder: 'customers/id-documents');
      }

      setState(() => _isUploading = false);

      // 2. Build id_documents array
      final idDocuments = <Map<String, dynamic>>[];
      if (idFrontUrl != null && idFrontUrl.isNotEmpty) {
        idDocuments.add({'url': idFrontUrl, 'type': 'front'});
      }
      if (idBackUrl != null && idBackUrl.isNotEmpty) {
        idDocuments.add({'url': idBackUrl, 'type': 'back'});
      }

      final authState = ref.read(core_auth.authProvider);
      final storeId = authState.user?.storeId ?? 'default-store-id';

      final body = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alt_phone': _altPhoneController.text.trim().isEmpty ? null : _altPhoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? '' : _emailController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? '' : _addressController.text.trim(),
        'gstin': _gstinController.text.trim().isEmpty ? '' : _gstinController.text.trim().toUpperCase(),
        'photo_url': photoUrl ?? '',
        'id_type': _idTypeToString(_selectedIdType),
        'id_number': _idNumberController.text.trim().isEmpty ? '' : _idNumberController.text.trim(),
        'id_documents': idDocuments,
        'store_id': storeId,
      };

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.customer != null ? 'Customer updated successfully!' : 'Customer created successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String? _idTypeToString(IdType? type) {
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

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontMedium),
          color: AppColors.text.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            )
          else
            TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                fontSize: Responsive.sp(AppSizes.fontTiny + 1),
                color: AppColors.secondaryText,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final hasPhoto = _photoFile != null || (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty && !_photoRemoved);
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: Responsive.w(110),
                height: Responsive.w(110),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: AppSizes.spacingTiny / 2,
                  ),
                ),
                child: ClipOval(
                  child: _photoFile != null
                      ? Image.file(_photoFile!, fit: BoxFit.cover)
                      : (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty && !_photoRemoved
                          ? Image.network(_existingPhotoUrl!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person_rounded,
                              size: Responsive.icon(AppSizes.iconHuge),
                              color: AppColors.primary.withValues(alpha: 0.5),
                            )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePicker(ImageTarget.photo),
                  child: Container(
                    padding: Responsive.all(AppSizes.spacingSmall),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: Responsive.icon(AppSizes.iconSmall),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasPhoto) ...[
          SizedBox(height: Responsive.h(AppSizes.spacingSmall)),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _photoFile = null;
                _photoRemoved = true;
              });
            },
            icon: Icon(Icons.delete_outline, size: Responsive.icon(AppSizes.iconSmall), color: AppColors.error),
            label: Text(
              'Remove Photo',
              style: TextStyle(
                color: AppColors.error,
                fontSize: Responsive.sp(AppSizes.fontSmall),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIDDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Document Photos',
          style: TextStyle(
            fontSize: Responsive.sp(AppSizes.fontMedium),
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
        Row(
          children: [
            Expanded(
              child: _buildDocCard(
                label: 'Front Side',
                file: _idFrontFile,
                existingUrl: _existingIdFrontUrl,
                isRemoved: _idFrontRemoved,
                target: ImageTarget.idFront,
                onRemove: () {
                  setState(() {
                    _idFrontFile = null;
                    _idFrontRemoved = true;
                  });
                },
              ),
            ),
            SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
            Expanded(
              child: _buildDocCard(
                label: 'Back Side',
                file: _idBackFile,
                existingUrl: _existingIdBackUrl,
                isRemoved: _idBackRemoved,
                target: ImageTarget.idBack,
                onRemove: () {
                  setState(() {
                    _idBackFile = null;
                    _idBackRemoved = true;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocCard({
    required String label,
    required File? file,
    required String? existingUrl,
    required bool isRemoved,
    required ImageTarget target,
    required VoidCallback onRemove,
  }) {
    final imageWidget = file != null
        ? Image.file(file, fit: BoxFit.cover)
        : (existingUrl != null && existingUrl.isNotEmpty && !isRemoved
            ? Image.network(existingUrl, fit: BoxFit.cover)
            : null);

    return GestureDetector(
      onTap: () => _showImagePicker(target),
      child: Container(
        height: Responsive.h(120),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
          border: Border.all(
            color: AppColors.border,
            width: AppSizes.spacingTiny / 4,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall - 1)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageWidget != null) ...[
                imageWidget,
                Positioned(
                  top: Responsive.h(AppSizes.spacingTiny),
                  right: Responsive.w(AppSizes.spacingTiny),
                  child: GestureDetector(
                    onTap: () {
                      onRemove();
                    },
                    child: Container(
                      padding: Responsive.all(AppSizes.spacingTiny),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: Responsive.icon(AppSizes.iconTiny),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black45,
                    padding: Responsive.symmetric(vertical: AppSizes.spacingTiny),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: Responsive.icon(AppSizes.iconLarge),
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny)),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontSmall),
                        color: AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingTiny / 2)),
                    Text(
                      'Tap to upload',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontTiny),
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildDecoration({
    required Widget label,
    required String hintText,
  }) {
    return InputDecoration(
      label: label,
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: Responsive.sp(AppSizes.fontMedium),
        color: AppColors.secondaryText,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: Responsive.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingSmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isEditing = widget.customer != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: Responsive.all(AppSizes.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfilePhotoSection(),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('Name', isRequired: true),
                      hintText: 'Enter customer full name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _phoneController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('Phone', isRequired: true),
                      hintText: 'e.g. +91 9876543210',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _altPhoneController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('Alternate Phone', isRequired: false),
                      hintText: 'e.g. +91 9876543210',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length < 10) {
                          return 'Alternate phone must be at least 10 characters';
                        }
                        if (value.trim().length > 20) {
                          return 'Alternate phone must be at most 20 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('Email', isRequired: false),
                      hintText: 'customer@email.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _addressController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('Address', isRequired: false),
                      hintText: 'Full postal address',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _gstinController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('GSTIN', isRequired: false),
                      hintText: 'e.g. 22AAAAA0000A1Z5',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  DropdownButtonFormField<IdType>(
                    initialValue: _selectedIdType,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium), color: AppColors.text),
                    decoration: InputDecoration(
                      label: _buildInputLabel('ID Type', isRequired: false),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: Responsive.symmetric(
                        horizontal: AppSizes.spacingMedium,
                        vertical: AppSizes.spacingSmall,
                      ),
                    ),
                    items: IdType.values.map((type) {
                      String label = '';
                      switch (type) {
                        case IdType.aadhaar:
                          label = 'Aadhaar Card';
                          break;
                        case IdType.pan:
                          label = 'PAN Card';
                          break;
                        case IdType.drivingLicence:
                          label = 'Driving Licence';
                          break;
                        case IdType.passport:
                          label = 'Passport';
                          break;
                        case IdType.others:
                          label = 'Others';
                          break;
                      }
                      return DropdownMenuItem(
                        value: type,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIdType = value;
                      });
                    },
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  TextFormField(
                    controller: _idNumberController,
                    style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                    decoration: _buildDecoration(
                      label: _buildInputLabel('ID Number', isRequired: false),
                      hintText: 'Enter ID number',
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                  _buildIDDocumentSection(),
                  SizedBox(height: Responsive.h(AppSizes.spacingXXXLarge)),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: Responsive.symmetric(vertical: AppSizes.spacingLarge),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                      ),
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      isEditing ? 'Update Customer' : 'Create Customer',
                      style: TextStyle(
                        fontSize: Responsive.sp(AppSizes.fontMedium + 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: Responsive.all(AppSizes.spacingXXLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: Responsive.h(AppSizes.spacingLarge)),
                        Text(
                          _isUploading ? 'Uploading files...' : 'Saving customer...',
                          style: TextStyle(
                            fontSize: Responsive.sp(AppSizes.fontMedium),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
