import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/user_model.dart';

final loginRepositoryProvider = Provider<LoginRepository>(
  (ref) => LoginRepositoryImpl(ref.watch(dioProvider)),
);

abstract class LoginRepository {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });
}

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      Endpoint.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response');
    }

    final token = data['token']?.toString() ?? '';
    final userJson = data['user_data'] ?? data['data'] ?? data['user'];
    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid login payload');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
