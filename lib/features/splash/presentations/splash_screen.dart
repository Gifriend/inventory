import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/widgets/widgets.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
