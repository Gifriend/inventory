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

  Future<void> createLoan({
    required PlatformFile pdfFile,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(loanRepositoryProvider)
          .approveLoan(loanId: loanId, roomId: roomId, deskId: deskId);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> rejectLoan({required int loanId, required String notes}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(loanRepositoryProvider)
          .rejectLoan(loanId: loanId, notes: notes);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> checkIn({required int roomId, required int deskId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(loanRepositoryProvider)
          .checkIn(roomId: roomId, deskId: deskId);
      ref.invalidate(loansProvider);
    });
  }

  Future<void> checkOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loanRepositoryProvider).checkOut();
      ref.invalidate(loansProvider);
    });
  }
}
