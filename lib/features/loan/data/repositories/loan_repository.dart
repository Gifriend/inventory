import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/loan_model.dart';

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryImpl(ref.watch(dioProvider)),
);

abstract class LoanRepository {
  Future<List<LoanModel>> getLoans();

  Future<void> createLoan({
    PlatformFile? pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  });

  Future<void> rejectLoan({required int loanId, required String notes});

  Future<void> checkIn({required int roomId, required int deskId});

  Future<void> checkOut();
}

class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<LoanModel>> getLoans() async {
    final response = await _dio.get<dynamic>(Endpoint.loans);
    final data = response.data;
    // Support multiple possible response shapes:
    // - { "data": [ ... ] }
    // - [ ... ]
    // - any other -> return empty list instead of throwing
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => LoanModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => LoanModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    return [];
  }

  @override
  Future<void> createLoan({
    PlatformFile? pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final Map<String, dynamic> data = {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };

    if (pdfFile != null && pdfFile.path != null) {
      final multipartFile = await MultipartFile.fromFile(
        pdfFile.path!,
        filename: pdfFile.name,
        contentType: DioMediaType('application', 'pdf'),
      );
      data['pdf_file'] = multipartFile;
    }

    final formData = FormData.fromMap(data);

    await _dio.post<dynamic>(Endpoint.loans, data: formData);
  }

  @override
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

  @override
  Future<void> rejectLoan({required int loanId, required String notes}) async {
    await _dio.patch<dynamic>(
      Endpoint.rejectLoan(loanId),
      data: {'admin_notes': notes},
    );
  }

  @override
  Future<void> checkIn({required int roomId, required int deskId}) async {
    await _dio.post<dynamic>(
      Endpoint.checkIn,
      data: {'room_id': roomId, 'desk_id': deskId},
    );
  }

  @override
  Future<void> checkOut() async {
    await _dio.post<dynamic>(Endpoint.checkOut);
  }
}
