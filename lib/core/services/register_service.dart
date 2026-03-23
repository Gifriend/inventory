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
    required String role,
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
    required String role,
  }) async {
    const defaultRole = 'user';

    await _dio.post<dynamic>(
      Endpoint.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': defaultRole,
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

    final token = envelope.data['token']?.toString() ?? '';
    final userJson = envelope.data['user_data'] ?? envelope.data['data'] ??
        envelope.data['user'];

    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid login payload after register');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
