import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/features/login/presentation.dart';
import 'package:inventory/core/constants/constants.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextMessage)));
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                      FilledButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(loginControllerProvider.notifier)
                                    .login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
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
