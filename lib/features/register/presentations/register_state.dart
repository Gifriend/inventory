import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/models/user_model.dart';

part 'register_state.freezed.dart';

@freezed
abstract class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(RegisterSubmitStatus.initial) RegisterSubmitStatus status,
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    UserModel? user,
    String? errorMessage,
  }) = _RegisterState;

  factory RegisterState.initial() => const RegisterState();
}
