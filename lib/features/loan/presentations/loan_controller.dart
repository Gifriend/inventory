import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:inventory/core/models/loan_model.dart';
import 'package:inventory/features/loan/data/repositories/loan_repository.dart';

final loansProvider = FutureProvider<List<LoanModel>>((ref) {
  return ref.read(loanRepositoryProvider).getLoans();
});

final loanActionControllerProvider =
    AsyncNotifierProvider<LoanActionController, void>(LoanActionController.new);

class LoanActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createLoan({
    PlatformFile? pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('LoanActionController.createLoan start');
        await ref
            .read(loanRepositoryProvider)
            .createLoan(pdfFile: pdfFile, startTime: startTime, endTime: endTime);
        ref.invalidate(loansProvider);
        debugPrint('LoanActionController.createLoan success');
      } catch (e, st) {
        debugPrint('LoanActionController.createLoan error: $e');
        if (e is DioException) {
          debugPrint('Dio status: ${e.response?.statusCode}');
          debugPrint('Dio response data: ${e.response?.data}');
        }
        debugPrint(st.toString());
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: st as StackTrace?,
          library: 'LoanActionController',
          context: ErrorDescription('createLoan'),
        ));
        rethrow;
      }
    });
  }

  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('LoanActionController.approveLoan start -> loanId=$loanId');
        await ref
            .read(loanRepositoryProvider)
            .approveLoan(loanId: loanId, roomId: roomId, deskId: deskId);
        ref.invalidate(loansProvider);
        debugPrint('LoanActionController.approveLoan success -> loanId=$loanId');
      } catch (e, st) {
        debugPrint('LoanActionController.approveLoan error: $e');
        if (e is DioException) {
          debugPrint('Dio status: ${e.response?.statusCode}');
          debugPrint('Dio response data: ${e.response?.data}');
        }
        debugPrint(st.toString());
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: st as StackTrace?,
          library: 'LoanActionController',
          context: ErrorDescription('approveLoan'),
        ));
        rethrow;
      }
    });
  }

  Future<void> rejectLoan({required int loanId, required String notes}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('LoanActionController.rejectLoan start -> loanId=$loanId');
        await ref
            .read(loanRepositoryProvider)
            .rejectLoan(loanId: loanId, notes: notes);
        ref.invalidate(loansProvider);
        debugPrint('LoanActionController.rejectLoan success -> loanId=$loanId');
      } catch (e, st) {
        debugPrint('LoanActionController.rejectLoan error: $e');
        if (e is DioException) {
          debugPrint('Dio status: ${e.response?.statusCode}');
          debugPrint('Dio response data: ${e.response?.data}');
        }
        debugPrint(st.toString());
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: st as StackTrace?,
          library: 'LoanActionController',
          context: ErrorDescription('rejectLoan'),
        ));
        rethrow;
      }
    });
  }

  Future<void> checkIn({required int roomId, required int deskId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('LoanActionController.checkIn start -> roomId=$roomId deskId=$deskId');
        await ref
            .read(loanRepositoryProvider)
            .checkIn(roomId: roomId, deskId: deskId);
        ref.invalidate(loansProvider);
        debugPrint('LoanActionController.checkIn success');
      } catch (e, st) {
        debugPrint('LoanActionController.checkIn error: $e');
        if (e is DioException) {
          debugPrint('Dio status: ${e.response?.statusCode}');
          debugPrint('Dio response data: ${e.response?.data}');
        }
        debugPrint(st.toString());
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: st as StackTrace?,
          library: 'LoanActionController',
          context: ErrorDescription('checkIn'),
        ));
        rethrow;
      }
    });
  }

  Future<void> checkOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        debugPrint('LoanActionController.checkOut start');
        await ref.read(loanRepositoryProvider).checkOut();
        ref.invalidate(loansProvider);
        debugPrint('LoanActionController.checkOut success');
      } catch (e, st) {
        debugPrint('LoanActionController.checkOut error: $e');
        if (e is DioException) {
          debugPrint('Dio status: ${e.response?.statusCode}');
          debugPrint('Dio response data: ${e.response?.data}');
        }
        debugPrint(st.toString());
        FlutterError.reportError(FlutterErrorDetails(
          exception: e,
          stack: st as StackTrace?,
          library: 'LoanActionController',
          context: ErrorDescription('checkOut'),
        ));
        rethrow;
      }
    });
  }
}
