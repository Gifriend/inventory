import 'package:dio/dio.dart';

String mapDioErrorToMessage(Object error) {
  if (error is String && error.trim().isNotEmpty) {
    return error;
  }

  if (error is FormatException) {
    final message = error.message;
    if (message.trim().isNotEmpty) return message;
  }

  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Cannot connect to server. Check your internet connection.';
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      // Prefer explicit message from backend
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      // If API uses envelope {status, message, data}
      final status = responseData['status'];
      final data = responseData['data'];
      if (status is String && status.toLowerCase() == 'success') {
        if (data == null ||
            (data is List && data.isEmpty) ||
            (data is Map && data.isEmpty)) {
          return 'Data tidak ditemukan.';
        }

        // success with data set but no explicit message
        return 'Sukses menerima data.';
      }

      if (status is String && status.toLowerCase() == 'error') {
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
        return 'Terjadi kesalahan pada server.';
      }

      final errors = responseData['errors'];
      if (errors is Map<String, dynamic>) {
        final buffer = <String>[];
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List) {
            for (final item in value) {
              if (item is String && item.trim().isNotEmpty) {
                buffer.add(item.trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            buffer.add(value.trim());
          }
        }
        if (buffer.isNotEmpty) {
          return buffer.join('\n');
        }
      }
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 200) {
      // No failure info from server but still reached here
      return 'Permintaan diterima, namun hasil tidak bisa diproses.';
    }
    if (statusCode == 401) {
      return 'Email atau password salah.';
    }
    if (statusCode == 422) {
      return 'Data login tidak valid. Cek email/password Anda.';
    }
  }

  return 'Something went wrong. Please try again.';
}
