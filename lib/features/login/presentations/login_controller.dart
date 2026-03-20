import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/data_sources/local/hive_service.dart';
import 'package:inventory/core/data_sources/local/secure_storage_service.dart';
import 'package:inventory/core/models/models.dart';
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
    return LoginState.initial();
  }

  Future<void> _hydrateSession() async {
    debugPrint('[login] hydrate session: loading cached user');
    final cachedUser = await ref.read(hiveServiceProvider).getUser();
    if (!ref.mounted) return;

    if (cachedUser != null) {
      state = state.copyWith(
        status: LoginSubmitStatus.success,
        user: cachedUser,
        errorMessage: null,
      );
      debugPrint(
        '[login] hydrate session: cache found user=${cachedUser.id} role=${cachedUser.role}',
      );
      return;
    }

    state = state.copyWith(
      status: LoginSubmitStatus.initial,
      user: null,
      errorMessage: null,
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  Future<void> submit() async {
    final email = state.email.trim();
    final password = state.password;

    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: LoginSubmitStatus.error,
        errorMessage: 'Email dan password wajib diisi.',
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(
        status: LoginSubmitStatus.error,
        errorMessage: 'Format email tidak valid.',
      );
      return;
    }

    await login(email: email, password: password);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(
      status: LoginSubmitStatus.loading,
      errorMessage: null,
    );
    try {
      debugPrint('[login] attempting login for $email');
      final result = await ref
          .read(loginRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(secureStorageServiceProvider).saveToken(result.token);
      await ref.read(hiveServiceProvider).saveUser(result.user);
      state = state.copyWith(
        status: LoginSubmitStatus.success,
        user: result.user,
        errorMessage: null,
      );
      debugPrint(
        '[login] login success user=${result.user.id} role=${result.user.role}',
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginSubmitStatus.error,
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
    state = state.copyWith(
      status: LoginSubmitStatus.loading,
      errorMessage: null,
    );
    try {
      debugPrint('[login] attempting register for $email role=$role');
      final result = await ref
          .read(registerRepositoryProvider)
          .register(name: name, email: email, password: password, role: role);
      await ref.read(secureStorageServiceProvider).saveToken(result.token);
      await ref.read(hiveServiceProvider).saveUser(result.user);
      state = state.copyWith(
        status: LoginSubmitStatus.success,
        user: result.user,
        errorMessage: null,
      );
      debugPrint(
        '[login] register success user=${result.user.id} role=${result.user.role}',
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginSubmitStatus.error,
        errorMessage: mapDioErrorToMessage(e),
      );
      debugPrint('[login] register failed: ${mapDioErrorToMessage(e)}');
    }
  }

  void setUser(UserModel user) {
    state = state.copyWith(
      status: LoginSubmitStatus.success,
      user: user,
      errorMessage: null,
    );
  }

  Future<void> logout() async {
    await ref.read(secureStorageServiceProvider).clearToken();
    await ref.read(hiveServiceProvider).clearSessionCache();
    state = state.copyWith(
      status: LoginSubmitStatus.initial,
      user: null,
      errorMessage: null,
    );
    debugPrint('[login] logout: cleared session');
  }
}
