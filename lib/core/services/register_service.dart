import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/api_envelope.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/user_model.dart';

final registerServiceProvider = Provider<RegisterService>((ref) {
  return RegisterServiceImpl(ref.watch(dioProvider));
});

abstract class RegisterService {
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
  });
}

class RegisterServiceImpl implements RegisterService {
  RegisterServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post<dynamic>(
      Endpoint.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
      },
    );

    final loginResponse = await _dio.post<dynamic>(
      Endpoint.login,
      data: {'email': email, 'password': password},
    );

    final envelope = ApiEnvelope.fromDynamic<Map<String, dynamic>>(
      loginResponse.data,
      dataParser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw const FormatException('Invalid login response after register');
      },
    );

    if (!envelope.isSuccess) {
      throw FormatException(envelope.message);
    }

    return _parseAuthData(envelope.data);
  }

  static ({String token, UserModel user}) _parseAuthData(
    Map<String, dynamic> payload,
  ) {
    final token = payload['token']?.toString() ?? '';
    final userJson =
        payload['user_data'] ?? payload['user'] ?? payload['data'];

    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid login payload after register');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
