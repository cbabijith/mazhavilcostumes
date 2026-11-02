import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shared upload repository for uploading files directly to Supabase Storage.
class UploadRepository {
  static Future<SupabaseClient>? _initializing;

  /// Preserve existing uploads without initializing their SDK before first paint.
  Future<SupabaseClient> _client() => _initializing ??= _initialize();

  static Future<SupabaseClient> _initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      final url = dotenv.env['SUPABASE_URL'] ?? const String.fromEnvironment('SUPABASE_URL');
      final key = dotenv.env['SUPABASE_ANON_KEY'] ?? const String.fromEnvironment('SUPABASE_ANON_KEY');
      await Supabase.initialize(url: url, anonKey: key);
      return Supabase.instance.client;
    } catch (_) {
      _initializing = null; // A later upload may retry a transient initialization failure.
      rethrow;
    }
  }

  /// Upload a file directly to Supabase Storage.
  /// [file] — the local file to upload.
  /// [folder] — logical folder name on the server (e.g. "categories").
  /// Returns the public URL of the uploaded file.
  Future<String> uploadFile(File file, {String folder = 'uploads'}) async {
    try {
      final supabase = await _client();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}';
      final path = '$folder/$fileName';
      
      const bucketName = 'mazhavilcostumes';
      
      await supabase.storage.from(bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final url = supabase.storage.from(bucketName).getPublicUrl(path);
      return url;
    } catch (e) {
      throw Exception('Failed to upload file to Supabase: $e');
    }
  }
}

