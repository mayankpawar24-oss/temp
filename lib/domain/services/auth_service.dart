import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Map<String, dynamic>? get currentUser => _mapUser(_client.auth.currentUser);

  Map<String, dynamic> get userMetadata => _client.auth.currentUser?.userMetadata ?? {};

  Future<bool> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    return response.user != null;
  }

  Future<bool> signInWithEmailAndPassword({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<bool> updateUserMetadata(Map<String, dynamic> data) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: data),
    );
    return response.user != null;
  }

  Future<bool> updatePassword(String newPassword) async {
    final response = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response.user != null;
  }

  Map<String, dynamic>? _mapUser(User? user) {
    if (user == null) return null;
    return {
      'id': user.id,
      'email': user.email,
      'phone': user.phone,
      'created_at': user.createdAt,
    };
  }
}
