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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage('Format email tidak valid.');
      return;
    }

    await ref
        .read(loginControllerProvider.notifier)
        .login(email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    final isLoading = authState.isLoading;

    return ScaffoldWidget(
      disablePadding: true,
      backgroundColor: BaseColor.cardBackground1,
      child: SafeArea(
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
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Gap.h12,
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      Gap.h16,
                      ButtonWidget.primary(
                        text: isLoading ? 'Loading...' : 'Login',
                        onTap: isLoading ? null : _submit,
                      ),
                      Gap.h4,
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Belum punya akun? Daftar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
