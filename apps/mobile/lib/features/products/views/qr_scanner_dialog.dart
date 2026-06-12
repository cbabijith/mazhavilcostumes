import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../viewmodels/providers/product_provider.dart';

class QRScannerDialog extends ConsumerStatefulWidget {
  final Function(String productId)? onScanMatched;
  final Function(String code)? onRawCodeScanned;

  const QRScannerDialog({
    super.key,
    this.onScanMatched,
    this.onRawCodeScanned,
  });

  @override
  ConsumerState<QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends ConsumerState<QRScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedCode(String code) async {
    if (code.trim().isEmpty) return;

    if (widget.onRawCodeScanned != null) {
      Navigator.pop(context);
      widget.onRawCodeScanned!(code);
      return;
    }

    if (widget.onScanMatched != null) {
      setState(() => _isSearching = true);
      try {
        // 1. Check local list first
        final productsState = ref.read(productsProvider).value;
        if (productsState != null) {
          final localMatch = productsState.products.where((p) =>
              p.sku?.toUpperCase() == code.toUpperCase() ||
              p.barcode?.toUpperCase() == code.toUpperCase() ||
              p.id == code);
          if (localMatch.isNotEmpty) {
            Navigator.pop(context); // Close dialog
            widget.onScanMatched!(localMatch.first.id);
            return;
          }
        }

        // 2. Query API via repository
        final repo = ref.read(productRepositoryProvider);
        final paginatedResult = await repo.getProducts(search: code, limit: 1);

        if (paginatedResult.products.isNotEmpty) {
          final match = paginatedResult.products.first;
          if (mounted) {
            Navigator.pop(context); // Close dialog
            widget.onScanMatched!(match.id);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No product found for code: "$code"'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final productsState = ref.watch(productsProvider).value;
    final products = productsState?.products ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.r(16))),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: Responsive.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QR/Barcode Scanner',
                    style: TextStyle(
                      fontSize: Responsive.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: Responsive.icon(22)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: Responsive.h(12)),
              
              // Viewfinder Scanner with Camera
              Container(
                width: Responsive.w(220),
                height: Responsive.w(220),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(Responsive.r(16)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Responsive.r(16)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          if (_isSearching) return;
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            final code = barcode.rawValue;
                            if (code != null && code.isNotEmpty) {
                              _handleScannedCode(code);
                              break;
                            }
                          }
                        },
                        errorBuilder: (context, error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.videocam_off_rounded, color: Colors.redAccent, size: 40),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Camera error: ${error.errorCode.name}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Moving Scan Line overlay
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Positioned(
                            top: _animController.value * Responsive.w(180) + Responsive.w(20),
                            left: Responsive.w(20),
                            right: Responsive.w(20),
                            child: Container(
                              height: Responsive.h(3),
                              decoration: const BoxDecoration(
                                color: AppColors.warning,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Frame guide lines
                      Padding(
                        padding: Responsive.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54, width: 2),
                            borderRadius: BorderRadius.circular(Responsive.r(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(16)),
              
              // Simulated Quick Scanner Options
              if (products.isNotEmpty && widget.onScanMatched != null) ...[
                Text(
                  'Simulation Shortcuts (Tap to Scan):',
                  style: TextStyle(
                    fontSize: Responsive.sp(11),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: Responsive.h(6)),
                Wrap(
                  spacing: Responsive.w(6),
                  runSpacing: Responsive.h(6),
                  children: products.take(4).map((p) {
                    final code = p.sku ?? p.name;
                    return InkWell(
                      onTap: () => _handleScannedCode(p.sku ?? p.id),
                      borderRadius: BorderRadius.circular(Responsive.r(8)),
                      child: Container(
                        padding: Responsive.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(Responsive.r(8)),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            fontSize: Responsive.sp(11),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: Responsive.h(16)),
              ],
              
              // Manual Code Input
              TextField(
                controller: _codeController,
                textInputAction: TextInputAction.done,
                onSubmitted: _handleScannedCode,
                decoration: InputDecoration(
                  hintText: 'Enter SKU or Barcode manually...',
                  hintStyle: TextStyle(fontSize: Responsive.sp(13), color: Colors.grey[400]),
                  contentPadding: Responsive.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.keyboard_rounded, size: Responsive.icon(18), color: Colors.grey),
                  suffixIcon: _isSearching
                      ? Padding(
                          padding: Responsive.all(12),
                          child: const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.arrow_forward_rounded, size: Responsive.icon(18), color: AppColors.primary),
                          onPressed: () => _handleScannedCode(_codeController.text),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
