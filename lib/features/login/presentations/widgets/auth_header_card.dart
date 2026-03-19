import 'package:flutter/material.dart';
import 'package:inventory/core/constants/constants.dart';


class AuthHeaderCard extends StatelessWidget {
  const AuthHeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 44, color: theme.colorScheme.primary),
        Gap.h12,
        Text(title, style: theme.textTheme.headlineSmall),
        Gap.h8,
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
