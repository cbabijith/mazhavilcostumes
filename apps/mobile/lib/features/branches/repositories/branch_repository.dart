import 'package:dio/dio.dart';
import '../../../core/supabase/api_client.dart';
import '../models/branch.dart';

/// Repository layer for Branches communicating with Next.js API via Dio.
class BranchRepository {
  final _api = apiClient;

  /// Fetch all branches from Next.js API.
  Future<List<Branch>> getBranches({bool simple = false, CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/branches',
        queryParameters: {'simple': simple.toString()},
        cancelToken: cancelToken,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  /// Fetch a single branch by ID.
  Future<Branch> getBranchById(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.get(
        '/branches/$id',
        cancelToken: cancelToken,
      );

      return Branch.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load branch: $e');
    }
  }

  /// Create a new branch.
  Future<Branch> createBranch(Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.post(
        '/branches',
        data: body,
        cancelToken: cancelToken,
      );

      return Branch.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  /// Update an existing branch.
  Future<Branch> updateBranch(String id, Map<String, dynamic> body, {CancelToken? cancelToken}) async {
    try {
      final response = await _api.patch(
        '/branches/$id',
        data: body,
        cancelToken: cancelToken,
      );

      return Branch.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  /// Delete a branch.
  Future<void> deleteBranch(String id, {CancelToken? cancelToken}) async {
    try {
      await _api.delete(
        '/branches/$id',
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }
}
