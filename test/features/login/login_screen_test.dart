import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/features/login/presentations/login_screen.dart';

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('shows validation when email/password are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Login'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Login').first);
    await tester.pump();

    expect(find.text('Email dan password wajib diisi.'), findsOneWidget);
  });
}
