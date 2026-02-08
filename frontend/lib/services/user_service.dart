import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';

class UserService {
  final SupabaseClient _sb = Supabase.instance.client;

  /// Convert age group display text to backend key
  String? _normalizeAgeBracket(String? ageGroup) {
    if (ageGroup == null) return null;
    
    // If already in correct format, return as-is
    if (['kid', 'teen', 'adult', 'senior'].contains(ageGroup.toLowerCase())) {
      return ageGroup.toLowerCase();
    }
    
    // Convert old display format to key
    final Map<String, String> conversion = {
      '0-12 (Kid)': 'kid',
      '13-17 (Teen)': 'teen',
      '18-59 (Adult)': 'adult',
      '60+ (Senior)': 'senior',
    };
    
    return conversion[ageGroup] ?? ageGroup.toLowerCase();
  }

  /// Get current authenticated user ID
  String? getUserId() {
    return _sb.auth.currentUser?.id;
  }

  /// Get current user profile from profiles table
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = getUserId();
    if (userId == null) return null;

    try {
      final response = await _sb
          .from('profiles')
          .select('id, username, email, age_group, interest, onboarding_done')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Get user profile and stats from backend API
  Future<Map<String, dynamic>?> getUserProfileWithStats() async {
    final userId = getUserId();
    if (userId == null) return null;

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileEndpoint}/$userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile with stats: $e');
      return null;
    }
  }

  /// Get user's age group and interests for personalization
  Future<Map<String, dynamic>> getUserPreferences() async {
    final profile = await getUserProfile();
    if (profile == null) {
      return {'age_group': null, 'interests': null};
    }

    return {
      'age_group': _normalizeAgeBracket(profile['age_group']),
      'interests': profile['interest'], // comma-separated string
    };
  }

  /// Check if user completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final profile = await getUserProfile();
    return profile?['onboarding_done'] == true;
  }

  /// Get recent scans from backend
  Future<List<Map<String, dynamic>>> getRecentScans({int limit = 3}) async {
    final userId = getUserId();
    if (userId == null) return [];

    try {
      final response = await _sb
          .from('scans')
          .select('id, landmark_name, description, timestamp, lat, lng')
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent scans: $e');
      return [];
    }
  }
}