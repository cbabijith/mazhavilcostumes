import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'api_client.dart';

/// Shared upload repository for uploading files via the Next.js API to Cloudflare R2.
class UploadRepository {
  /// Upload a file via the backend API.
  /// [file] — the local file to upload.
  /// [folder] — logical folder name on the server (e.g. "products").
  /// Returns the public URL of the uploaded file.
  Future<String> uploadFile(File file, {String folder = 'uploads'}) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'folder': folder,
      });

      final response = await apiClient.post(
        '/upload',
        data: formData,
      );

      final data = response.data;
      // Handle response structure { success: true, data: { url: '...' } }
      final resData = data['data'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
      final url = resData['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('API response did not return a valid URL');
      }

      return url;
    } catch (e) {
      throw Exception('Failed to upload file to backend: $e');
    }
  }
}

