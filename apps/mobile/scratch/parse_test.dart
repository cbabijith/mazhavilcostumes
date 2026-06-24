import 'dart:convert';
import 'dart:io';
import '../lib/features/orders/models/order.dart';

void main() async {
  print("=== RUNNING OFFLINE DART PARSE TEST ===");
  try {
    final file = File('scratch/orders.json');
    if (!file.existsSync()) {
      print("File scratch/orders.json does not exist!");
      return;
    }
    
    final responseBody = await file.readAsString();
    final ordersData = jsonDecode(responseBody) as List<dynamic>;
    
    print("Read ${ordersData.length} orders from file. Parsing...");
    
    for (var i = 0; i < ordersData.length; i++) {
      try {
        final orderMap = ordersData[i] as Map<String, dynamic>;
        print("Parsing order index $i, ID: ${orderMap['id']}");
        Order.fromJson(orderMap);
      } catch (e, stack) {
        print("Failed to parse order at index $i: $e");
        print(stack);
        break;
      }
    }
  } catch (e, stack) {
    print("Exception: $e");
    print(stack);
  }
}
