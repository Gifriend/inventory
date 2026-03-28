import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/splash/presentations/splash_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(splashBootstrapProvider, (previous, next) {
      next.whenData((route) {
        if (!context.mounted) return;
        context.go(route);
      });
    });

    final bootstrapState = ref.watch(splashBootstrapProvider);

    return ScaffoldWidget(
      disablePadding: true,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: BaseSize.customWidth(360)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: BaseSize.customWidth(42),
                    backgroundColor: BaseColor.primaryinventory,
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      size: 42,
                      color: BaseColor.cardBackground1,
                    ),
                  ),
                  Gap.h20,
                  Text(
                    'Inventory Desk Tracking',
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleLarge,
                  ),
                  Gap.h4,
                  Text(
                    'Menyiapkan sesi kamu...',
                    textAlign: TextAlign.center,
                    style: BaseTypography.titleSmall,
                  ),
                  Gap.h20,
                  if (bootstrapState.isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: BaseColor.red,
                          size: 28,
                        ),
                        Gap.h8,
                        Text(
                          'Gagal menyiapkan sesi. Coba lagi.',
                          style: BaseTypography.titleSmall,
                        ),
                        Gap.h8,
                        TextButton(
                          onPressed: () {
                            ref.invalidate(splashBootstrapProvider);
                          },
                          child: Text('Coba Lagi', style: BaseTypography.bodySmall),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
