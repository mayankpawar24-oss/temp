import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRepository {
  UserProfileRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> upsertProfile({
    required String userId,
    required String email,
    required String role,
    required String profileType,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'role': role,
      'profile_type': profileType,
    });
  }
}
