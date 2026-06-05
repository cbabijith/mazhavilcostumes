import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/branch.dart';

/// Repository layer for Branches communicating directly with Supabase.
class BranchRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all branches from Supabase.
  Future<List<Branch>> getBranches() async {
    try {
      final response = await _supabase.from('branches').select();
      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  /// Fetch a single branch by ID.
  Future<Branch> getBranchById(String id) async {
    try {
      final response = await _supabase.from('branches').select().eq('id', id).single();
      return Branch.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load branch: $e');
    }
  }

  /// Create a new branch.
  Future<Branch> createBranch(Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('branches').insert(body).select().single();
      return Branch.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  /// Update an existing branch.
  Future<Branch> updateBranch(String id, Map<String, dynamic> body) async {
    try {
      final response = await _supabase.from('branches').update(body).eq('id', id).select().single();
      return Branch.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  /// Delete a branch.
  Future<void> deleteBranch(String id) async {
    try {
      await _supabase.from('branches').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }
}
