import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
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
  IdType? _selectedIdType;
  final _idNumberController = TextEditingController();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'alt_phone': _altPhoneController.text.trim().isEmpty ? null : _altPhoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'gstin': _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim(),
      'id_type': _selectedIdType?.toString().split('.').last,
      'id_number': _idNumberController.text.trim().isEmpty ? null : _idNumberController.text.trim(),
      'store_id': 'default-store-id', // TODO: Get from auth context
    };

    try {
      if (widget.customer != null) {
        await ref.read(customerOperationsProvider).updateCustomer(widget.customer!.id, body);
      } else {
        await ref.read(customerOperationsProvider).createCustomer(body);
      }

      if (mounted) {
        ref.invalidate(customersProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: _buildInputLabel('Name', isRequired: true),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  label: _buildInputLabel('Phone', isRequired: true),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _altPhoneController,
                decoration: InputDecoration(
                  label: _buildInputLabel('Alternate Phone', isRequired: false),
                  border: const OutlineInputBorder(),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  label: _buildInputLabel('Email', isRequired: false),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  label: _buildInputLabel('Address', isRequired: false),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gstinController,
                decoration: InputDecoration(
                  label: _buildInputLabel('GSTIN', isRequired: false),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IdType>(
                initialValue: _selectedIdType,
                decoration: InputDecoration(
                  label: _buildInputLabel('ID Type', isRequired: false),
                  border: const OutlineInputBorder(),
                ),
                items: IdType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(
                  label: _buildInputLabel('ID Number', isRequired: false),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Update Customer' : 'Create Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
