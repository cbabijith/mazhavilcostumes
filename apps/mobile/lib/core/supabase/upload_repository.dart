import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared upload repository for uploading files directly to Supabase Storage.
class UploadRepository {
  final _supabase = Supabase.instance.client;

  /// Upload a file directly to Supabase Storage.
  /// [file] — the local file to upload.
  /// [folder] — logical folder name on the server (e.g. "categories").
  /// Returns the public URL of the uploaded file.
  Future<String> uploadFile(File file, {String folder = 'uploads'}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      final path = '$folder/$fileName';
      
      const bucketName = 'mazhavilcostumes';
      
      await _supabase.storage.from(bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final url = _supabase.storage.from(bucketName).getPublicUrl(path);
      return url;
    } catch (e) {
      throw Exception('Failed to upload file to Supabase: $e');
    }
  }
}

