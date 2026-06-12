import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../customers/models/customer.dart';
import '../../../customers/viewmodels/providers/customer_provider.dart';

class CustomerSearchDropdown extends ConsumerWidget {
  final String searchQuery;
  final Function(Customer) onSelectCustomer;
  final VoidCallback onAddCustomer;
  final VoidCallback onClose;

  const CustomerSearchDropdown({
    super.key,
    required this.searchQuery,
    required this.onSelectCustomer,
    required this.onAddCustomer,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Responsive.init(context);

    // Use hybrid search provider for 0ms local search + debounced remote search
    final searchState = ref.watch(customerSearchProvider);
    final customers = searchState.results;

    return Container(
      constraints: BoxConstraints(maxHeight: Responsive.h(200)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(8)),
        clipBehavior: Clip.antiAlias,
        child:
            (searchState.isLoading || searchState.isSearchingRemote) &&
                customers.isEmpty &&
                searchQuery.isEmpty
            ? Center(
                child: Padding(
                  padding: Responsive.all(16),
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            : searchState.error != null && customers.isEmpty
            ? Center(
                child: Padding(
                  padding: Responsive.all(16),
                  child: Text(
                    'Error loading customers',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: Responsive.sp(12),
                    ),
                  ),
                ),
              )
            : customers.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: Responsive.all(16),
                    child: Text(
                      'No customer found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: Responsive.sp(13),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: Responsive.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        onClose();
                        onAddCustomer();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: AppColors.primary,
                            size: Responsive.icon(18),
                          ),
                          SizedBox(width: Responsive.w(8)),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Create "$searchQuery"',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: Responsive.sp(13),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: customers.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: Responsive.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: Responsive.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.sp(13),
                        ),
                      ),
                      subtitle: Text(
                        customer.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: Responsive.sp(11),
                        ),
                      ),
                      onTap: () {
                        onSelectCustomer(customer);
                        onClose();
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
