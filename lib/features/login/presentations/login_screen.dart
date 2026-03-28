import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/features/login/application.dart';
import 'package:inventory/features/login/presentations/widgets/auth_header_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final bool _obscurePassword = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    await ref.read(loginControllerProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      final previousMessage = previous?.errorMessage;
      final nextMessage = next.errorMessage;
      if (nextMessage != null && nextMessage != previousMessage) {
        debugPrint('LoginScreen auth error: $nextMessage');
        _showMessage(nextMessage);
      }
    });

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      final previousUser = previous?.user;
      final nextUser = next.user;
      final didLogin = previousUser == null && nextUser != null;
      if (!didLogin) return;

      final role = (nextUser.role ?? 'user').toLowerCase();
      final targetPath = role == 'aslab' ? '/aslab' : '/user';
      context.go(targetPath);
    });

    final authState = ref.watch(loginControllerProvider);
    final isLoading = authState.status == LoginSubmitStatus.loading;

    return ScaffoldWidget(
      disablePadding: true,
      disableSingleChildScrollView: true,
      backgroundColor: BaseColor.primaryinventory2,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(BaseSize.w16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: BaseSize.customWidth(460)),
            child: Container(
              decoration: BoxDecoration(
                color: BaseColor.white,
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                boxShadow: BaseShadow.shadow,
              ),
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeaderCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Selamat datang kembali',
                      subtitle:
                          'Masuk untuk lanjut memantau peminjaman dan penggunaan desk.',
                    ),
                    Gap.h20,
                    InputWidget<String>.text(
                      borderColor: BaseColor.primaryinventory2,
                      currentInputValue: authState.email,
                      onChanged: (value) => ref
                          .read(loginControllerProvider.notifier)
                          .updateEmail(value),
                      label: 'Email',
                      hint: 'nama@email.com',
                      textInputType: TextInputType.emailAddress,
                      validators: (value) {
                        if (value.isEmpty) return 'Email wajib diisi.';
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Format email tidak valid.';
                        }
                        return '';
                      },
                    ),
                    Gap.h12,
                    InputWidget<String>.text(
                      borderColor: BaseColor.primaryinventory2,
                      currentInputValue: authState.password,
                      onChanged: (value) => ref
                          .read(loginControllerProvider.notifier)
                          .updatePassword(value),
                      label: 'Password',
                      obscureText: _obscurePassword,
                      validators: (value) {
                        if (value.isEmpty) return 'Password wajib diisi.';
                        return '';
                      },
                      endIcon: null,
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: IconButton(
                    //     onPressed: () => setState(() {
                    //       _obscurePassword = !_obscurePassword;
                    //     }),
                    //     icon: Icon(
                    //       _obscurePassword
                    //           ? Icons.visibility_off_outlined
                    //           : Icons.visibility_outlined,
                    //       color: BaseColor.neutral[700],
                    //     ),
                    //   ),
                    // ),
                    Gap.h16,
                    ButtonWidget.primary(
                      color: BaseColor.primaryinventory,
                      text: isLoading ? 'Loading...' : 'Login',
                      onTap: isLoading ? null : _submit,
                    ),
                    Gap.h4,
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text('Belum punya akun? Daftar', style: BaseTypography.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
