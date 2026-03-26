import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/data_sources/network/auth_session_event.dart';
import 'package:inventory/features/desk/presentation.dart';
import 'package:inventory/features/home/presentation.dart';
import 'package:inventory/features/loan/presentation.dart';
import 'package:inventory/features/login/application.dart';
import 'package:inventory/features/login/presentation.dart';
import 'package:inventory/features/qr/presentation.dart';
import 'package:inventory/features/register/presentation.dart';
import 'package:inventory/features/splash/presentation.dart';

class AppRoute {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String userHome = 'user-home';
  static const String aslabHome = 'aslab-home';
  static const String desks = 'desks';
  static const String aslabDeskQr = 'aslab-desk-qr';
  static const String loanRequest = 'loan-request';
  static const String approval = 'approval';
  static const String qr = 'qr';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(loginControllerProvider);
      final location = state.matchedLocation;
      final isGuestRoute = location == '/login' || location == '/register';

      if (location == '/') {
        return null;
      }

      final user = authState.user;
      final role = (user?.role ?? 'user').toLowerCase();
      final roleHome = role == 'aslab' ? '/aslab' : '/user';

      if (user == null) {
        if (isGuestRoute) return null;
        if (kDebugMode) debugPrint('[router] no user on $location -> /login');
        return '/login';
      }

      if (isGuestRoute) {
        if (kDebugMode) {
          debugPrint('[router] guest route with user -> $roleHome');
        }
        return roleHome;
      }

      final isAslabArea =
          location.startsWith('/aslab') || location.startsWith('/approval');
      if (role == 'aslab' && !isAslabArea) {
        if (kDebugMode) {
          debugPrint('[router] aslab blocked from $location -> /aslab');
        }
        return '/aslab';
      }

      if (role != 'aslab' && isAslabArea) {
        if (kDebugMode) {
          debugPrint('[router] user blocked from $location -> /user');
        }
        return '/user';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/user',
        name: AppRoute.userHome,
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: '/aslab',
        name: AppRoute.aslabHome,
        builder: (context, state) => const AslabHomeScreen(),
      ),
      GoRoute(
        path: '/desks',
        name: AppRoute.desks,
        builder: (context, state) => const DeskSelectionScreen(),
      ),
      GoRoute(
        path: '/aslab/desks-qr',
        name: AppRoute.aslabDeskQr,
        builder: (context, state) => const AslabDeskQrScreen(),
      ),
      GoRoute(
        path: '/loan-request',
        name: AppRoute.loanRequest,
        builder: (context, state) => const LoanRequestScreen(),
      ),
      GoRoute(
        path: '/approval',
        name: AppRoute.approval,
        builder: (context, state) => const ApprovalDashboardScreen(),
      ),
      GoRoute(
        path: '/qr',
        name: AppRoute.qr,
        builder: (context, state) => const QrScannerScreen(),
      ),
    ],
  );

  ref.listen<int>(authSessionExpiredEventProvider, (previous, next) {
    if (previous == next) return;

    unawaited(ref.read(loginControllerProvider.notifier).logout());
    router.go('/login');
  });

  // ref.listen<LoginState>(loginControllerProvider, (previous, next) {
  //   // final didInitializingChange =
  //       // previous?.isInitializing != next.isInitializing;
  //   final didUserChange = previous?.user != next.user;

  //   if (didInitializingChange || didUserChange) {
  //     router.refresh();
  //   }
  // });

  return router;
});
