import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/features/login/presentation.dart';
import 'package:inventory/features/loan/presentations/my_loans_screen.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
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
          _WelcomeCard(name: user?.name ?? 'User'),
          Gap.h12,
          _FeatureTile(
            title: 'Pilih Desk',
            subtitle: 'Lihat ketersediaan desk per ruangan',
            icon: Icons.event_seat,
            onTap: () => context.pushNamed(AppRoute.desks),
          ),
          // _FeatureTile(
          //   title: 'Ajukan Peminjaman',
          //   subtitle: 'Kirim permintaan pinjam desk',
          //   icon: Icons.description,
          //   onTap: () => context.pushNamed(AppRoute.loanRequest),
          // ),
          _FeatureTile(
            title: 'Riwayat Peminjaman',
            subtitle: 'Pantau status peminjaman kamu',
            icon: Icons.history,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyLoansScreen()),
            ),
          ),
          _FeatureTile(
            title: 'Scan QR',
            subtitle: 'Check-in/check-out dengan QR code',
            icon: Icons.qr_code_scanner,
            onTap: () => context.pushNamed(AppRoute.qr),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Gap.h4,
                  Text(
                    'Pilih menu yang ingin kamu akses hari ini.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
