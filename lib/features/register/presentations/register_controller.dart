import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/data_sources/local/hive_service.dart';
import 'package:inventory/core/data_sources/local/secure_storage_service.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/login/data/services/auth_service.dart';
import 'package:inventory/features/login/presentations/login_controller.dart';
import 'package:inventory/features/register/presentations/register_state.dart';

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => RegisterState.initial();

  void updateName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  Future<void> submit() async {
    final name = state.name.trim();
    final email = state.email.trim();
    final password = state.password;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: RegisterSubmitStatus.error,
        errorMessage: 'Nama, email, dan password wajib diisi.',
      );
      return;
    }

    if (password.length < 6) {
      state = state.copyWith(
        status: RegisterSubmitStatus.error,
        errorMessage: 'Password minimal 6 karakter.',
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(
        status: RegisterSubmitStatus.error,
        errorMessage: 'Format email tidak valid.',
      );
      return;
    }

    await register(name: name, email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: RegisterSubmitStatus.loading,
      errorMessage: null,
    );
    try {
      debugPrint('[register] attempting register for $email');
      final result = await ref.read(authServiceProvider).register(
            name: name,
            email: email,
            password: password,
            role: 'user',
          );
      await ref.read(secureStorageServiceProvider).saveToken(result.token);
      await ref.read(hiveServiceProvider).saveUser(result.user);

      // sync with login controller state for auth flow
      ref.read(loginControllerProvider.notifier).setUser(result.user);

      state = state.copyWith(
        status: RegisterSubmitStatus.success,
        user: result.user,
        errorMessage: null,
      );
      debugPrint(
        '[register] register success user=${result.user.id} role=${result.user.role}',
      );
    } catch (e) {
      state = state.copyWith(
        status: RegisterSubmitStatus.error,
        errorMessage: mapDioErrorToMessage(e),
      );
      debugPrint('[register] register failed: ${mapDioErrorToMessage(e)}');
    }
  }
}
