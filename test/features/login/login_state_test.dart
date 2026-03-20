// import 'package:flutter_test/flutter_test.dart';
// import 'package:inventory/core/models/user_model.dart';
// import 'package:inventory/features/login/presentations/login_state.dart';

// void main() {
//   group('LoginState', () {
//     test('copyWith updates values', () {
//       const state = LoginState();

//       final next = state.copyWith(isLoading: true, errorMessage: 'failed');

//       expect(next.isLoading, isTrue);
//       expect(next.errorMessage, 'failed');
//       expect(next.isInitializing, isTrue);
//     });

//     test('clearUser removes user', () {
//       const user = UserModel(id: 1, name: 'Test User', role: 'user');
//       const state = LoginState(user: user);

//       final next = state.copyWith(clearUser: true);

//       expect(next.user, isNull);
//     });

//     test('clearError removes error message', () {
//       const state = LoginState(errorMessage: 'x');

//       final next = state.copyWith(clearError: true);

//       expect(next.errorMessage, isNull);
//     });
//   });
// }
