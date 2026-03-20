import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';

void main() {
  group('mapDioErrorToMessage', () {
    test('returns string input as-is', () {
      const error = 'Custom error';
      expect(mapDioErrorToMessage(error), 'Custom error');
    });

    test('returns FormatException message', () {
      final error = const FormatException('Invalid payload format');
      expect(mapDioErrorToMessage(error), 'Invalid payload format');
    });

    test('maps 401 to credential message when backend message absent', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/login'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 401,
          data: const {},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(mapDioErrorToMessage(exception), 'Email atau password salah.');
    });

    test('uses backend message when available', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/login'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 422,
          data: const {'message': 'Validation failed from server'},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(mapDioErrorToMessage(exception), 'Validation failed from server');
    });
  });
}
