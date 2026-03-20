import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inventory/core/models/user_model.dart';

part 'login_state.freezed.dart';

enum LoginSubmitStatus { initial, loading, success, error }

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginSubmitStatus.initial) LoginSubmitStatus status,
    @Default('') String email,
    @Default('') String password,
    UserModel? user,
    String? errorMessage,
  }) = _LoginState;

  factory LoginState.initial() => const LoginState();
}
