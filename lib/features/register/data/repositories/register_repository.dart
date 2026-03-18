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
    final response = await _dio.post<dynamic>(
      Endpoint.register,
      data: {'name': name, 'email': email, 'password': password, 'role': role},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid register response');
    }

    final token = data['token']?.toString() ?? '';
    final userJson = data['user_data'] ?? data['data'] ?? data['user'];
    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid register payload');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
