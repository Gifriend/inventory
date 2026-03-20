import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> _runAction(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    state = result;

    if (result case AsyncError<void>(:final error, :final stackTrace)) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> createLoan({
    PlatformFile? pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _runAction(() async {
      await ref
          .read(loanRepositoryProvider)
          .createLoan(pdfFile: pdfFile, startTime: startTime, endTime: endTime);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  }) async {
    await _runAction(() async {
      await ref
          .read(loanRepositoryProvider)
          .approveLoan(loanId: loanId, roomId: roomId, deskId: deskId);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> rejectLoan({required int loanId, required String notes}) async {
    await _runAction(() async {
      await ref
          .read(loanRepositoryProvider)
          .rejectLoan(loanId: loanId, notes: notes);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> checkIn({required int roomId, required int deskId}) async {
    await _runAction(() async {
      await ref
          .read(loanRepositoryProvider)
          .checkIn(roomId: roomId, deskId: deskId);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> checkOut() async {
    await _runAction(() async {
      await ref.read(loanRepositoryProvider).checkOut();
      ref.invalidate(loansProvider);
    });
  }
}
