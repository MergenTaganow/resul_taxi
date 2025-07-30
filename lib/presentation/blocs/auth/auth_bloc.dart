import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_event.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.loading()) {
    print('[AUTH BLOC] AuthBloc constructor called');
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<AppStarted>(_onAppStarted);
    on<FetchProfile>(_onFetchProfile);
    print('[AUTH BLOC] Event handlers registered');
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.loading());
      final token = await _authRepository.login(event.username, event.password);
      emit(AuthState.authenticated(token));
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.loading());
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    print('[AUTH BLOC] _onAppStarted called');
    try {
      emit(const AuthState.loading());
      print('[AUTH BLOC] Emitted loading state');

      // Check if token exists in storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      print(
          '[AUTH BLOC] Token from storage: ${token != null ? 'exists' : 'null'}');

      if (token == null || token.isEmpty) {
        print('[AUTH BLOC] No token found, emitting unauthenticated state');
        emit(const AuthState.unauthenticated());
        return;
      } else {
        print('[AUTH BLOC] Token found, emitting authenticated state');
        emit(AuthState.authenticated(token));
      }

      // Try to get profile to validate token AND get driver data
      try {
        final profileData = await _authRepository.getProfile();
        print(
            '[AUTH BLOC] Profile fetched successfully on app start: ${profileData.keys}');
      } catch (e) {
        print('[AUTH BLOC] Profile fetch failed on app start: $e');
        // If profile fetch fails, try to refresh token
        try {
          final refreshed = await _authRepository.refreshToken();
          if (refreshed) {
            // Get the new token from storage and try profile again
            final newToken = prefs.getString('access_token');
            emit(AuthState.authenticated(newToken ?? token));
            // Try to get profile with new token
            try {
              final profileData = await _authRepository.getProfile();
              print(
                  '[AUTH BLOC] Profile fetched successfully after token refresh: ${profileData.keys}');
            } catch (profileError) {
              print(
                  '[AUTH BLOC] Profile fetch failed even after token refresh: $profileError');
            }
          } else {
            // If refresh fails, logout and redirect to login
            await _authRepository.logout();
            emit(const AuthState.unauthenticated());
          }
        } catch (refreshError) {
          // If refresh also fails, logout and redirect to login
          await _authRepository.logout();
          emit(const AuthState.unauthenticated());
        }
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onFetchProfile(
      FetchProfile event, Emitter<AuthState> emit) async {
    try {
      emit(const AuthState.loading());

      // Try to get profile
      await _authRepository.getProfile();

      // If successful, get current token and emit authenticated
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      emit(AuthState.authenticated(token ?? ''));
    } catch (e) {
      // If profile fetch fails, try to refresh token
      try {
        final refreshed = await _authRepository.refreshToken();
        if (refreshed) {
          // Try to get profile again after refresh
          await _authRepository.getProfile();
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          emit(AuthState.authenticated(token ?? ''));
        } else {
          // If refresh fails, logout and redirect to login
          await _authRepository.logout();
          emit(const AuthState.unauthenticated());
        }
      } catch (refreshError) {
        // If refresh also fails, logout and redirect to login
        await _authRepository.logout();
        emit(const AuthState.unauthenticated());
      }
    }
  }
}
