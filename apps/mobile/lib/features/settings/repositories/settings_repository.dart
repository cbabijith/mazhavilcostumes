/// Reads and updates invoice settings through the shared admin API.
library;

import '../../../core/supabase/api_client.dart';

class SettingsRepository {
  /// Returns the server-resolved GSTIN, including an explicitly empty value.
  Future<String> getGstNumber() async {
    final response = await apiClient.get(
      '/settings',
      queryParameters: {'key': 'gst_number'},
    );
    return _readValue(response.data);
  }

  /// Saves the GSTIN using the API's validation and authenticated store scope.
  Future<String> saveGstNumber(String value) async {
    final response = await apiClient.patch(
      '/settings',
      data: {'key': 'gst_number', 'value': value},
    );
    return _readValue(response.data);
  }

  String _readValue(Object? response) {
    if (response is Map && response['success'] == true) {
      final data = response['data'];
      if (data is Map && data['value'] is String) {
        return data['value'] as String;
      }
    }
    // A failed/malformed response is not a cleared GSTIN.
    throw const FormatException('Invalid invoice settings response');
  }
}
