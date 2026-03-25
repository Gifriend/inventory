import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/api_envelope.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/user_model.dart';

final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginServiceImpl(ref.watch(dioProvider));
});

abstract class LoginService {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });
}

class LoginServiceImpl implements LoginService {
  LoginServiceImpl(this._dio);

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

    final envelope = ApiEnvelope.fromDynamic<Map<String, dynamic>>(
      response.data,
      dataParser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw const FormatException('Invalid login payload');
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
      throw const FormatException('Invalid login data');
    }

    return (token: token, user: UserModel.fromJson(userJson));
  }
}
