import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/login/application.dart';

class AslabHomeScreen extends ConsumerWidget {
  const AslabHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loginControllerProvider).user;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Dashboard Aslab',
        trailIcon: Assets.svg.logOut,
        trailIconColor: BaseColor.white,
        onPressedTrailIcon: () =>
            ref.read(loginControllerProvider.notifier).logout(),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h16,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w16),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: BaseShadow.shadow,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: BaseColor.primaryinventory,
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: BaseColor.cardBackground1,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${user?.name ?? 'Aslab'}',
                        style: BaseTypography.titleLarge,
                      ),
                      Gap.h4,
                      Text(
                        'Kelola persetujuan peminjaman dari satu dashboard.',
                        style: BaseTypography.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap.h12,
          Container(
            margin: EdgeInsets.only(bottom: BaseSize.h8),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: BaseShadow.shadow,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: BaseSize.w12,
                vertical: BaseSize.h8,
              ),
              leading: CircleAvatar(
                backgroundColor: BaseColor.primaryinventory,
                child: const Icon(
                  Icons.approval_outlined,
                  color: BaseColor.cardBackground1,
                ),
              ),
              title: Text(
                'Approval Dashboard',
                style: BaseTypography.titleMedium,
              ),
              subtitle: Text(
                'Setujui atau tolak permintaan yang masuk',
                style: BaseTypography.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(AppRoute.approval),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: BaseSize.h8),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: BaseShadow.shadow,
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: BaseSize.w12,
                vertical: BaseSize.h8,
              ),
              leading: CircleAvatar(
                backgroundColor: BaseColor.primaryinventory,
                child: const Icon(
                  Icons.qr_code,
                  color: BaseColor.cardBackground1,
                ),
              ),
              title: Text('QR Meja', style: BaseTypography.titleMedium),
              subtitle: Text(
                'Lihat dan unduh QR untuk setiap meja',
                style: BaseTypography.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(AppRoute.aslabDeskQr),
            ),
          ),
        ],
      ),
    );
  }
}
