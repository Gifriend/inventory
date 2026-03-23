import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/models/user_model.dart';
import 'package:inventory/features/login/data/repositories/login_repository.dart';
import 'package:inventory/features/register/data/repositories/register_repository.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthServiceImpl(
    ref.watch(loginRepositoryProvider),
    ref.watch(registerRepositoryProvider),
  ),
);

abstract class AuthService {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });

  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._loginRepository, this._registerRepository);

  final LoginRepository _loginRepository;
  final RegisterRepository _registerRepository;

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    return _loginRepository.login(email: email, password: password);
  }

  @override
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return _registerRepository.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
