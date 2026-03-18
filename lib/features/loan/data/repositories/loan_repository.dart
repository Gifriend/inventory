import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/loan_model.dart';

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepository(ref.watch(dioProvider)),
);

class LoanRepository {
  LoanRepository(this._dio);

  final Dio _dio;

  Future<List<LoanModel>> getLoans() async {
    final response = await _dio.get<dynamic>(Endpoint.loans);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid loans response');
    }

    final list = data['data'];
    if (list is! List) {
      return [];
    }

    return list
        .whereType<Map>()
        .map((e) => LoanModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> createLoan({
    required PlatformFile pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final multipartFile = await MultipartFile.fromFile(
      pdfFile.path!,
      filename: pdfFile.name,
      contentType: DioMediaType('application', 'pdf'),
    );

    final formData = FormData.fromMap({
      'pdf_file': multipartFile,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    });

    await _dio.post<dynamic>(Endpoint.loans, data: formData);
  }

  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  }) async {
    await _dio.patch<dynamic>(
      Endpoint.approveLoan(loanId),
      data: {'room_id': roomId, 'desk_id': deskId},
    );
  }

  Future<void> rejectLoan({required int loanId, required String notes}) async {
    await _dio.patch<dynamic>(
      Endpoint.rejectLoan(loanId),
      data: {'admin_notes': notes},
    );
  }

  Future<void> checkIn({required int roomId, required int deskId}) async {
    await _dio.post<dynamic>(
      Endpoint.checkIn,
      data: {'room_id': roomId, 'desk_id': deskId},
    );
  }

  Future<void> checkOut() async {
    await _dio.post<dynamic>(Endpoint.checkOut);
  }
}
