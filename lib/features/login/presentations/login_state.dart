import 'package:inventory/core/models/user_model.dart';

class LoginState {
  const LoginState({
    this.isInitializing = true,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  final bool isInitializing;
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  LoginState copyWith({
    bool? isInitializing,
    bool? isLoading,
    UserModel? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
