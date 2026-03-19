import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/features/login/presentation.dart';

class AslabHomeScreen extends ConsumerWidget {
  const AslabHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginControllerProvider).user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aslab Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(loginControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Gap.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.name ?? 'Aslab'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Gap.h4,
                        Text(
                          'Kelola persetujuan peminjaman dari satu dashboard.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap.h12,
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.approval_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Approval Dashboard'),
              subtitle: const Text('Setujui atau tolak permintaan yang masuk'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(AppRoute.approval),
            ),
          ),
        ],
      ),
    );
  }
}
