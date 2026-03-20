import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/user_model.dart';

final registerRepositoryProvider = Provider<RegisterRepository>(
  (ref) => RegisterRepositoryImpl(ref.watch(dioProvider)),
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
  RegisterRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post<dynamic>(
      Endpoint.register,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );

    final loginResponse = await _dio.post<dynamic>(
      Endpoint.login,
      data: {'email': email, 'password': password},
    );

    final loginData = loginResponse.data;
    if (loginData is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response after register');
    }

    final token = loginData['token']?.toString() ?? '';
    final userJson =
        loginData['user_data'] ?? loginData['data'] ?? loginData['user'];
    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid login payload after register');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
