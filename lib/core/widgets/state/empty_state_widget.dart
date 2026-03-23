import 'package:flutter/material.dart';
import 'package:inventory/core/constants/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: BaseSize.w64, color: BaseColor.grey),
            Gap.h16,
            Text(
              title,
              style: BaseTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Gap.h8,
            Text(
              subtitle,
              style: BaseTypography.bodyMedium.copyWith(color: BaseColor.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
