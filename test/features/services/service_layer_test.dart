import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/loan_model.dart';
import 'package:inventory/core/models/room_model.dart';
import 'package:inventory/core/models/user_model.dart';
import 'package:inventory/features/desk/data/repositories/room_repository.dart';
import 'package:inventory/features/desk/data/services/room_service.dart';
import 'package:inventory/features/login/data/repositories/login_repository.dart';
import 'package:inventory/features/register/data/repositories/register_repository.dart';
import 'package:inventory/features/login/data/services/auth_service.dart';
import 'package:inventory/features/loan/data/repositories/loan_repository.dart';
import 'package:inventory/features/loan/data/services/loan_service.dart';

class FakeLoginRepository implements LoginRepository {
  var loginInvoked = false;

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    loginInvoked = true;
    return (
      token: 'fake-token',
      user: const UserModel(id: 1, name: 'User', role: 'user'),
    );
  }
}

class FakeRegisterRepository implements RegisterRepository {
  var registerInvoked = false;

  @override
  Future<({String token, UserModel user})> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    registerInvoked = true;
    return (
      token: 'fake-token',
      user: const UserModel(id: 2, name: 'Registered User', role: 'user'),
    );
  }
}

class FakeLoanRepository implements LoanRepository {
  var getLoansCount = 0;
  var getHistoryCount = 0;
  var createLoanCount = 0;
  var approveLoanCount = 0;
  var rejectLoanCount = 0;
  var checkInCount = 0;
  var checkOutCount = 0;

  @override
  Future<List<LoanModel>> getLoans() async {
    getLoansCount += 1;
    return const [];
  }

  @override
  Future<List<LoanModel>> getLoanHistory() async {
    getHistoryCount += 1;
    return const [];
  }

  @override
  Future<void> createLoan({String? pdfFilePath, required DateTime startTime, required DateTime endTime}) async {
    createLoanCount += 1;
  }

  @override
  Future<void> approveLoan({required int loanId, required int roomId, required int deskId}) async {
    approveLoanCount += 1;
  }

  @override
  Future<void> rejectLoan({required int loanId, required String notes}) async {
    rejectLoanCount += 1;
  }

  @override
  Future<void> checkIn({required int roomId, required int deskId}) async {
    checkInCount += 1;
  }

  @override
  Future<void> checkOut() async {
    checkOutCount += 1;
  }
}

class FakeRoomRepository implements RoomRepository {
  var allRoomsCount = 0;
  var roomDesksCount = 0;
  var availableDesksCount = 0;
  var deskQrPayloadCount = 0;

  @override
  Future<List<DeskModel>> getAvailableDesk(int roomId) async {
    availableDesksCount += 1;
    return const [];
  }

  @override
  Future<List<DeskModel>> getRoomDesks(int roomId) async {
    roomDesksCount += 1;
    return const [];
  }

  @override
  Future<List<RoomModel>> getAllRooms() async {
    allRoomsCount += 1;
    return const [];
  }

  @override
  Future<String> getDeskQrPayload(int deskId) async {
    deskQrPayloadCount += 1;
    return 'payload';
  }
}

void main() {
  group('AuthService', () {
    test('login calls login repository', () async {
      final loginRepository = FakeLoginRepository();
      final registerRepository = FakeRegisterRepository();
      final container = ProviderContainer(overrides: [
        loginRepositoryProvider.overrideWithValue(loginRepository),
        registerRepositoryProvider.overrideWithValue(registerRepository),
      ]);
      addTearDown(container.dispose);

      final authService = container.read(authServiceProvider);
      final result = await authService.login(email: 'x@y.com', password: 'pass');

      expect(loginRepository.loginInvoked, isTrue);
      expect(result.token, 'fake-token');
      expect(result.user.name, 'User');
    });

    test('register calls register repository', () async {
      final loginRepository = FakeLoginRepository();
      final registerRepository = FakeRegisterRepository();
      final container = ProviderContainer(overrides: [
        loginRepositoryProvider.overrideWithValue(loginRepository),
        registerRepositoryProvider.overrideWithValue(registerRepository),
      ]);
      addTearDown(container.dispose);

      final authService = container.read(authServiceProvider);
      final result = await authService.register(
        name: 'test',
        email: 'x@y.com',
        password: 'pass',
        role: 'user',
      );

      expect(registerRepository.registerInvoked, isTrue);
      expect(result.token, 'fake-token');
      expect(result.user.name, 'Registered User');
    });
  });

  group('LoanService', () {
    test('calls repository methods', () async {
      final repo = FakeLoanRepository();
      final container = ProviderContainer(overrides: [
        loanRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      final service = container.read(loanServiceProvider);
      await service.getLoans();
      await service.getLoanHistory();
      await service.createLoan(startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(hours: 1)));
      await service.approveLoan(loanId: 1, roomId: 1, deskId: 1);
      await service.rejectLoan(loanId: 1, notes: 'nope');
      await service.checkIn(roomId: 1, deskId: 1);
      await service.checkOut();

      expect(repo.getLoansCount, 1);
      expect(repo.getHistoryCount, 1);
      expect(repo.createLoanCount, 1);
      expect(repo.approveLoanCount, 1);
      expect(repo.rejectLoanCount, 1);
      expect(repo.checkInCount, 1);
      expect(repo.checkOutCount, 1);
    });
  });

  group('RoomService', () {
    test('calls repository methods', () async {
      final repo = FakeRoomRepository();
      final container = ProviderContainer(overrides: [
        roomRepositoryProvider.overrideWithValue(repo),
      ]);
      addTearDown(container.dispose);

      final service = container.read(roomServiceProvider);
      await service.getAllRooms();
      await service.getRoomDesks(7);
      await service.getAvailableDesks(7);
      final payload = await service.getDeskQrPayload(99);

      expect(repo.allRoomsCount, 1);
      expect(repo.roomDesksCount, 1);
      expect(repo.availableDesksCount, 1);
      expect(repo.deskQrPayloadCount, 1);
      expect(payload, 'payload');
    });
  });
}
