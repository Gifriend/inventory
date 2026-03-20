import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/models/user_model.dart';
import 'package:inventory/core/services/login_service.dart';

final loginRepositoryProvider = Provider<LoginRepository>(
  (ref) => LoginRepositoryImpl(ref.watch(loginServiceProvider)),
);

abstract class LoginRepository {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });
}

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl(this._service);

  final LoginService _service;

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) {
    return _service.login(email: email, password: password);
  }
}
