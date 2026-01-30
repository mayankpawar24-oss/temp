import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client}) : _client = client ?? _tryGetClient();

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  Map<String, dynamic>? get currentUser =>
      _client == null ? null : _mapUser(_client!.auth.currentUser);

  Map<String, dynamic> get userMetadata =>
      _client?.auth.currentUser?.userMetadata ?? {};

  Future<bool> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    if (_client == null) return false;
    final response = await _client!.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    return response.user != null;
  }

  Future<bool> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    if (_client == null) return false;
    final response = await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user != null;
  }

  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
  }

  Future<bool> updateUserMetadata(Map<String, dynamic> data) async {
    if (_client == null) return false;
    final response = await _client!.auth.updateUser(
      UserAttributes(data: data),
    );
    return response.user != null;
  }

  Future<bool> updatePassword(String newPassword) async {
    if (_client == null) return false;
    final response = await _client!.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response.user != null;
  }

  static SupabaseClient? _tryGetClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
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
