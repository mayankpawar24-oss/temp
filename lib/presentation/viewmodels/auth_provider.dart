import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maternal_infant_care/domain/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthStateNotifier extends StateNotifier<Map<String, dynamic>?> {
  AuthStateNotifier(this._authService) : super(_authService.currentUser) {
    if (_authService.isAvailable) {
      _subscription =
          Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        state = _authService.currentUser;
      });
    }
  }

  final AuthService _authService;
  StreamSubscription<AuthState>? _subscription;

  void setUser(Map<String, dynamic>? user) {
    state = user;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, Map<String, dynamic>?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authStateProvider);
});
