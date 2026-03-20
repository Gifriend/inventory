import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/models/user_model.dart';
import 'package:inventory/core/services/register_service.dart';

final registerRepositoryProvider = Provider<RegisterRepository>(
  (ref) => RegisterRepositoryImpl(ref.watch(registerServiceProvider)),
);

abstract class RegisterRepository {
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });
}

class RegisterRepositoryImpl implements RegisterRepository {
  RegisterRepositoryImpl(this._service);

  final RegisterService _service;

  @override
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _service.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
