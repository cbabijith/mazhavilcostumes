import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../customers/models/customer.dart';
import '../../../customers/viewmodels/providers/customer_provider.dart';

class AddCustomerDialog extends ConsumerStatefulWidget {
  final String initialName;
  final String initialPhone;
  final Function(Customer) onCustomerCreated;

  const AddCustomerDialog({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.onCustomerCreated,
  });

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _phoneController.text = widget.initialPhone;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _altPhoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final operations = ref.read(customerOperationsProvider);
      final customer = await operations.createCustomer({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alt_phone': _altPhoneController.text.trim().isEmpty
            ? null
            : _altPhoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      });

      if (mounted) {
        widget.onCustomerCreated(customer);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create customer: $e')),
        );
      }
    }
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: Responsive.sp(AppSizes.fontMedium),
          color: Colors.grey[700],
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
                color: Colors.grey[500],
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusMedium)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: Responsive.all(AppSizes.spacingXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Customer',
                style: TextStyle(
                  fontSize: Responsive.sp(AppSizes.fontXLarge),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                      decoration: InputDecoration(
                        label: _buildInputLabel('Phone Number', isRequired: true),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        contentPadding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingMedium,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                      decoration: InputDecoration(
                        label: _buildInputLabel('Alternate Phone', isRequired: false),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        contentPadding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingMedium,
                        ),
                      ),
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
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                      decoration: InputDecoration(
                        label: _buildInputLabel('Name', isRequired: true),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        contentPadding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingMedium,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: Responsive.h(AppSizes.spacingMedium)),
                    TextFormField(
                      controller: _addressController,
                      style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium)),
                      decoration: InputDecoration(
                        label: _buildInputLabel('Address', isRequired: false),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        contentPadding: Responsive.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingMedium,
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.h(AppSizes.spacingXLarge)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: Responsive.sp(AppSizes.fontMedium - 1)),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.w(AppSizes.spacingMedium)),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Responsive.r(AppSizes.radiusSmall)),
                        ),
                        padding: Responsive.symmetric(vertical: AppSizes.spacingMedium),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save & Select',
                              style: TextStyle(
                                fontSize: Responsive.sp(AppSizes.fontMedium - 1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
