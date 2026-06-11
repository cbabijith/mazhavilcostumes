import 'package:dio/dio.dart';

class OrderItemInput {
  String productId = '';
  String productName = '';
  int quantity = 1;
  double pricePerDay = 0.0;
  double gstPercentage = 0.0;
  bool isAvailable = true;
  bool isChecking = false;
  String? availableStockInfo;
  CancelToken? cancelToken;

  // Parity with website
  double discount = 0.0;
  String discountType = 'flat'; // 'flat' | 'percent'
  int available = 0;
  int availableWithPriority = 0;
  bool priorityCleaningNeeded = false;
  List<dynamic> priorityCleaningInfo = const [];
  List<dynamic> overlappingOrders = const [];

  OrderItemInput({
    this.productId = '',
    this.productName = '',
    this.quantity = 1,
    this.pricePerDay = 0.0,
    this.gstPercentage = 0.0,
    this.isAvailable = true,
    this.discount = 0.0,
    this.discountType = 'flat',
    this.available = 0,
    this.availableWithPriority = 0,
    this.priorityCleaningNeeded = false,
    this.priorityCleaningInfo = const [],
    this.overlappingOrders = const [],
    this.cancelToken,
  });
}
