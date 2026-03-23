import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/api_envelope.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/loan_model.dart';

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryImpl(ref.watch(dioProvider)),
);

abstract class LoanRepository {
  Future<List<LoanModel>> getLoans();
  Future<List<LoanModel>> getLoanHistory();

  Future<void> createLoan({
    String? pdfFilePath,
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
    return _parseLoanModels(response.data);
  }

  @override
  Future<List<LoanModel>> getLoanHistory() async {
    final response = await _dio.get<dynamic>('${Endpoint.loans}/history');
    return _parseLoanModels(response.data);
  }

  @override
  Future<void> createLoan({
    String? pdfFilePath,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final Map<String, dynamic> body = {
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };

    if (pdfFilePath != null && pdfFilePath.isNotEmpty) {
      final multipartFile = await MultipartFile.fromFile(
        pdfFilePath,
        filename: pdfFilePath.split('/').last,
        contentType: DioMediaType('application', 'pdf'),
      );
      body['pdf_file'] = multipartFile;
    }

    final formData = FormData.fromMap(body);
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

  static List<LoanModel> _parseLoanModels(dynamic raw) {
    final ApiResponse<List<LoanModel>> envelope = ApiEnvelope.fromDynamic<List<LoanModel>>(
      raw,
      dataParser: (data) {
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => LoanModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false);
        }

        if (data is Map<String, dynamic>) {
          final dataList = data['data'];
          if (dataList is List) {
            return dataList
                .whereType<Map>()
                .map((item) => LoanModel.fromJson(Map<String, dynamic>.from(item)))
                .toList(growable: false);
          }
        }

        throw const FormatException('Invalid loan payload');
      },
    );

    if (!envelope.isSuccess) {
      throw FormatException(envelope.message);
    }

    return envelope.data;
  }
}
