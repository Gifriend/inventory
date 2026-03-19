import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _locked = false;

  Future<void> _handleQr(String rawValue) async {
    if (_locked) return;
    _locked = true;

    try {
      final parsed = jsonDecode(rawValue);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Invalid QR payload');
      }

      final roomId = parsed['room_id'];
      final deskId = parsed['desk_id'];
      if (roomId is! int || deskId is! int) {
        throw const FormatException(
          'QR payload must include room_id and desk_id',
        );
      }

      await ref
          .read(loanActionControllerProvider.notifier)
          .checkIn(roomId: roomId, deskId: deskId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check-in success')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapDioErrorToMessage(error))));
    } finally {
      await Future<void>.delayed(const Duration(seconds: 2));
      _locked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(loanActionControllerProvider);

    return ScaffoldWidget(
      disablePadding: true,
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'QR Check-in / Check-out',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => Navigator.of(context).pop(),
        actions: [
          TextButton(
            onPressed: actionState.isLoading
                ? null
                : () async {
                    try {
                      await ref
                          .read(loanActionControllerProvider.notifier)
                          .checkOut();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Check-out success')),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(mapDioErrorToMessage(error))),
                      );
                    }
                  },
            child: Text(
              'Check Out',
              style: BaseTypography.titleSmall.copyWith(color: BaseColor.white),
            ),
          ),
        ],
      ),
      child: MobileScanner(
        onDetect: (capture) {
          if (capture.barcodes.isEmpty) {
            return;
          }
          final barcode = capture.barcodes.first;
          final value = barcode.rawValue;
          if (value == null || value.isEmpty) {
            return;
          }
          _handleQr(value);
        },
      ),
    );
  }
}
