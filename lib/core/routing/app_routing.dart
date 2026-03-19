import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/features/presentation.dart';

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
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(loginControllerProvider);
      final location = state.matchedLocation;
      final isGuestRoute = location == '/login' || location == '/register';

      final user = authState.user;
      final role = (user?.role ?? 'user').toLowerCase();
      final roleHome = role == 'aslab' ? '/aslab' : '/user';

      if (kDebugMode) {
        debugPrint('[router] redirect check -> loc=$location init=${authState.isInitializing} user=${user?.id} role=$role');
      }

      if (authState.isInitializing) {
        return null;
      }

      if (location == '/splash') {
        if (user == null) {
          if (kDebugMode) debugPrint('[router] at splash, no user -> /login');
          return '/login';
        }
        if (kDebugMode) debugPrint('[router] at splash, user -> $roleHome');
        return roleHome;
      }

      if (user == null) {
        if (isGuestRoute) return null;
        if (kDebugMode) debugPrint('[router] no user on $location -> /login');
        return '/login';
      }

      if (isGuestRoute) {
        if (kDebugMode) debugPrint('[router] guest route with user -> $roleHome');
        return roleHome;
      }

      final isAslabArea =
          location.startsWith('/aslab') || location.startsWith('/approval');
      if (role == 'aslab' && !isAslabArea) {
        if (kDebugMode) debugPrint('[router] aslab blocked from $location -> /aslab');
        return '/aslab';
      }

      if (role != 'aslab' && isAslabArea) {
        if (kDebugMode) debugPrint('[router] user blocked from $location -> /user');
        return '/user';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
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

  ref.listen<LoginState>(loginControllerProvider, (previous, next) {
    final didInitializingChange = previous?.isInitializing != next.isInitializing;
    final didUserChange = previous?.user != next.user;

    if (didInitializingChange || didUserChange) {
      router.refresh();
    }
  });

  return router;
});
