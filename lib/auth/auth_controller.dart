import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/models.dart';
import 'auth_storage.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthSession {
  AuthSession({required this.user, this.preview = false});
  final UserProfile user;
  final bool preview;
}

class AuthState {
  AuthState({required this.status, this.session, this.error});
  final AuthStatus status;
  final AuthSession? session;
  final String? error;

  AuthState copyWith({AuthStatus? status, AuthSession? session, String? error}) =>
      AuthState(
        status: status ?? this.status,
        session: session ?? this.session,
        error: error,
      );

  static AuthState initial() => AuthState(status: AuthStatus.unknown);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.initial()) {
    _restore();
  }

  final Ref _ref;
  ApiClient get _client => _ref.read(apiClientProvider);
  AuthStorage get _storage => _ref.read(authStorageProvider);

  Future<void> _restore() async {
    final profile = await _storage.profile();
    final token = await _storage.accessToken();
    if (token != null && profile['id'] != null) {
      state = AuthState(
        status: AuthStatus.signedIn,
        session: AuthSession(
          user: UserProfile(
            id: profile['id']!,
            email: profile['email'] ?? '',
            fullName: profile['name'] ?? 'Partner',
            role: profile['role'] ?? 'operator',
          ),
          preview: token == 'preview-token',
        ),
      );
    } else {
      state = AuthState(status: AuthStatus.signedOut);
    }
  }

  Future<void> signInAsPreview({String name = 'Demo Partner'}) async {
    await _storage.write(
      accessToken: 'preview-token',
      refreshToken: 'preview-refresh',
      userId: 'preview-operator',
      email: 'partner@preview.dev',
      fullName: name,
      role: 'operator',
    );
    state = AuthState(
      status: AuthStatus.signedIn,
      session: AuthSession(
        user: UserProfile(
          id: 'preview-operator',
          email: 'partner@preview.dev',
          fullName: name,
          role: 'operator',
        ),
        preview: true,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final r = await _client.dio.post('/auth/login',
          data: {'email': email, 'password': password});
      if (r.statusCode == null || r.statusCode! >= 400) {
        throw Exception(r.data?['message'] ?? 'Login failed.');
      }
      await _persist(r.data as Map<String, dynamic>);
    } catch (e) {
      if (ApiConfig.devBypassAuth) {
        debugPrint('signIn fell back to preview: $e');
        await signInAsPreview();
        return;
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final r = await _client.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': 'operator',
      });
      if (r.statusCode == null || r.statusCode! >= 400) {
        throw Exception(r.data?['message'] ?? 'Registration failed.');
      }
      await _persist(r.data as Map<String, dynamic>);
    } catch (e) {
      if (ApiConfig.devBypassAuth) {
        await signInAsPreview(name: fullName);
        return;
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> _persist(Map<String, dynamic> body) async {
    final data = (body['data'] ?? body) as Map<String, dynamic>;
    final tokens = (data['tokens'] ?? data) as Map<String, dynamic>;
    final user = (data['user'] ?? data) as Map<String, dynamic>;
    final access = (tokens['access_token'] ?? tokens['accessToken'] ?? '').toString();
    final refresh = (tokens['refresh_token'] ?? tokens['refreshToken'] ?? '').toString();
    final profile = UserProfile.fromJson(user);
    await _storage.write(
      accessToken: access,
      refreshToken: refresh,
      userId: profile.id,
      email: profile.email,
      fullName: profile.fullName,
      role: profile.role,
    );
    state = AuthState(
      status: AuthStatus.signedIn,
      session: AuthSession(user: profile),
    );
  }

  Future<void> signOut() async {
    await _storage.clear();
    state = AuthState(status: AuthStatus.signedOut);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(AuthController.new);
