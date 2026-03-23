import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/models/loan_model.dart';
import 'package:inventory/features/loan/data/repositories/loan_repository.dart';

final loanServiceProvider = Provider<LoanService>(
  (ref) => LoanServiceImpl(ref.watch(loanRepositoryProvider)),
);

abstract class LoanService {
  Future<List<LoanModel>> getLoans();
  Future<List<LoanModel>> getLoanHistory();
  Future<void> createLoan({
    required DateTime startTime,
    required DateTime endTime,
    String? pdfFilePath,
  });
  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  });
  Future<void> rejectLoan({
    required int loanId,
    required String notes,
  });
  Future<void> checkIn({
    required int roomId,
    required int deskId,
  });
  Future<void> checkOut();
}

class LoanServiceImpl implements LoanService {
  LoanServiceImpl(this._repository);

  final LoanRepository _repository;

  @override
  Future<List<LoanModel>> getLoans() => _repository.getLoans();

  @override
  Future<List<LoanModel>> getLoanHistory() => _repository.getLoanHistory();

  @override
  Future<void> createLoan({
    required DateTime startTime,
    required DateTime endTime,
    String? pdfFilePath,
  }) async {
    await _repository.createLoan(
      pdfFilePath: pdfFilePath,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<void> approveLoan({
    required int loanId,
    required int roomId,
    required int deskId,
  }) {
    return _repository.approveLoan(
      loanId: loanId,
      roomId: roomId,
      deskId: deskId,
    );
  }

  @override
  Future<void> rejectLoan({
    required int loanId,
    required String notes,
  }) {
    return _repository.rejectLoan(loanId: loanId, notes: notes);
  }

  @override
  Future<void> checkIn({
    required int roomId,
    required int deskId,
  }) {
    return _repository.checkIn(roomId: roomId, deskId: deskId);
  }

  @override
  Future<void> checkOut() => _repository.checkOut();
}
