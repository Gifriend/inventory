import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/data_sources/local/hive_service.dart';
import 'package:inventory/core/data_sources/local/secure_storage_service.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/login/data/repositories/login_repository.dart';
import 'package:inventory/features/login/presentations/login_state.dart';
import 'package:inventory/features/register/data/repositories/register_repository.dart';

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    _hydrateSession();
    return const LoginState();
  }

  Future<void> _hydrateSession() async {
    debugPrint('[login] hydrate session: loading cached user');
    final cachedUser = await ref.read(hiveServiceProvider).getUser();
    if (!ref.mounted) {
      return;
    }

    if (state.user != null) {
      state = state.copyWith(isInitializing: false);
      debugPrint('[login] hydrate session: state already has user, skip cache');
      return;
    }

    state = state.copyWith(isInitializing: false, user: cachedUser);
    debugPrint(
      '[login] hydrate session: cache found user=${cachedUser?.id} role=${cachedUser?.role}',
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      debugPrint('[login] attempting login for $email');
      final result = await ref
          .read(loginRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(secureStorageServiceProvider).saveToken(result.token);
      await ref.read(hiveServiceProvider).saveUser(result.user);
      state = state.copyWith(
        isInitializing: false,
        isLoading: false,
        user: result.user,
        clearError: true,
      );
      debugPrint(
        '[login] login success user=${result.user.id} role=${result.user.role}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapDioErrorToMessage(e),
      );
      debugPrint('[login] login failed: ${mapDioErrorToMessage(e)}');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      debugPrint('[login] attempting register for $email role=$role');
      final result = await ref
          .read(registerRepositoryProvider)
          .register(name: name, email: email, password: password, role: role);
      await ref.read(secureStorageServiceProvider).saveToken(result.token);
      await ref.read(hiveServiceProvider).saveUser(result.user);
      state = state.copyWith(
        isInitializing: false,
        isLoading: false,
        user: result.user,
        clearError: true,
      );
      debugPrint(
        '[login] register success user=${result.user.id} role=${result.user.role}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapDioErrorToMessage(e),
      );
      debugPrint('[login] register failed: ${mapDioErrorToMessage(e)}');
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageServiceProvider).clearToken();
    await ref.read(hiveServiceProvider).clearSessionCache();
    state = state.copyWith(
      isInitializing: false,
      isLoading: false,
      clearUser: true,
      clearError: true,
    );
    debugPrint('[login] logout: cleared session');
  }
}
