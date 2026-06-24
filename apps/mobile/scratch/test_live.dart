import 'dart:convert';
import 'dart:io';
import '../lib/features/orders/models/order.dart';

void main() async {
  print("=== RUNNING LIVE API TEST ===");
  final client = HttpClient();
  try {
    // Construct the URL with query params
    final uri = Uri.parse(
      'https://mazhavilcostumes-admin.vercel.app/api/orders?page=1&limit=15&status=ongoing'
    );
    
    print("Fetching from: $uri");
    final request = await client.getUrl(uri);
    
    // Add bypass header if needed, but the endpoint might be public or protected.
    // Let's see if we get a 200 or 401.
    final response = await request.close();
    print("Response status: ${response.statusCode}");
    
    if (response.statusCode != 200) {
      final errorBody = await response.transform(utf8.decoder).join();
      print("Error body: $errorBody");
      return;
    }
    
    final responseBody = await response.transform(utf8.decoder).join();
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final ordersData = decoded['data'] as List<dynamic>? ?? [];
    
    print("Fetched ${ordersData.length} orders. Parsing...");
    
    for (var i = 0; i < ordersData.length; i++) {
      final orderMap = ordersData[i] as Map<String, dynamic>;
      print("Parsing order index $i, ID: ${orderMap['id']}");
      
      // Let's print out potential fields that are commonly Map but parsed as String
      print("  customer_id: ${orderMap['customer_id']} (${orderMap['customer_id'].runtimeType})");
      print("  branch_id: ${orderMap['branch_id']} (${orderMap['branch_id'].runtimeType})");
      print("  store_id: ${orderMap['store_id']} (${orderMap['store_id'].runtimeType})");
      print("  cancelled_by: ${orderMap['cancelled_by']} (${orderMap['cancelled_by']?.runtimeType})");
      
      try {
        Order.fromJson(orderMap);
        print("  -> Success!");
      } catch (e, stack) {
        print("  -> Failed at index $i: $e");
        print(stack);
        break;
      }
    }
  } catch (e, stack) {
    print("Exception: $e");
    print(stack);
  } finally {
    client.close();
  }
}
