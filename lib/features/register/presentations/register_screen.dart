import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/features/login/presentations/widgets/auth_header_card.dart';
import 'package:inventory/features/register/application.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final bool _obscurePassword = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    await ref.read(registerControllerProvider.notifier).submit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RegisterState>(registerControllerProvider, (previous, next) {
      final previousMessage = previous?.errorMessage;
      final nextMessage = next.errorMessage;
      if (nextMessage != null && nextMessage != previousMessage) {
        debugPrint('RegisterScreen auth error: $nextMessage');
        _showMessage(nextMessage);
      }

      final didRegister =
          previous?.status != RegisterSubmitStatus.success &&
          next.status == RegisterSubmitStatus.success;
      if (didRegister && next.user != null) {
        _showMessage('Register berhasil, masuk otomatis.');
        final role = (next.user!.role ?? 'user').toLowerCase();
        final targetPath = role == 'aslab' ? '/aslab' : '/user';
        context.go(targetPath);
      }
    });

    final authState = ref.watch(registerControllerProvider);
    final isLoading = authState.status == RegisterSubmitStatus.loading;

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
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Buat akun baru',
                      subtitle:
                          'Isi data berikut untuk mulai menggunakan aplikasi.',
                    ),
                    Gap.h20,
                    InputWidget<String>.text(
                      borderColor: BaseColor.primaryinventory2,
                      currentInputValue: authState.name,
                      onChanged: (value) => ref
                          .read(registerControllerProvider.notifier)
                          .updateName(value),
                      label: 'Nama',
                      validators: (value) {
                        if (value.isEmpty) return 'Nama wajib diisi.';
                        return '';
                      },
                    ),
                    Gap.h12,
                    InputWidget<String>.text(
                      borderColor: BaseColor.primaryinventory2,
                      currentInputValue: authState.email,
                      onChanged: (value) => ref
                          .read(registerControllerProvider.notifier)
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
                          .read(registerControllerProvider.notifier)
                          .updatePassword(value),
                      label: 'Password',
                      obscureText: _obscurePassword,
                      validators: (value) {
                        if (value.isEmpty) return 'Password wajib diisi.';
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter.';
                        }
                        return '';
                      },
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
                      text: isLoading ? 'Loading...' : 'Register',
                      onTap: isLoading ? null : _submit,
                    ),
                    Gap.h4,
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sudah punya akun? Login'),
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
