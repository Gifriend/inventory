import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/login/presentation.dart';
import 'package:inventory/features/loan/presentations/my_loans_screen.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginControllerProvider).user;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Dashboard',
        trailIcon: Assets.svg.logOut,
        trailIconColor: BaseColor.white,
        onPressedTrailIcon: () =>
            () => ref.read(loginControllerProvider.notifier).logout(),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w16, vertical: BaseSize.h16),
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
    return
    // Container(
    //   decoration: BoxDecoration(
    //     color: BaseColor.white,
    //     borderRadius: BorderRadius.circular(BaseSize.radiusMd),
    //     boxShadow: [
    //       BoxShadow(
    //         color: BaseColor.black.withValues(alpha: 0.4),
    //         blurRadius: 4,
    //         offset: const Offset(0, 4),
    //       ),
    //     ],
    //   ),
    //   child: Padding(
    //     padding: const EdgeInsets.all(16),
    //     child:
    Row(
      children: [
        // CircleAvatar(
        //   backgroundColor: BaseColor.primaryinventory,
        //   child: Icon(
        //     Icons.person_outline,
        //     color: BaseColor.cardBackground1,
        //   ),
        // ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $name', style: BaseTypography.titleLarge),
              Gap.h4,
              Text(
                'Pilih menu yang ingin kamu akses hari ini.',
                style: BaseTypography.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
    //   ),
    // );
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
    return Container(
      margin: EdgeInsets.only(bottom: BaseSize.h8),
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BaseColor.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: BaseSize.w12,
          vertical: BaseSize.h8,
        ),
        leading: CircleAvatar(
          backgroundColor: BaseColor.primaryinventory,
          child: Icon(icon, color: BaseColor.cardBackground1),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
