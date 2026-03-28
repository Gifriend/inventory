import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/assets/assets.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/login/application.dart';
import 'package:inventory/features/loan/presentations/loan_controller.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _locked = false;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'qr_view');
  QRViewController? _scannerController;

  bool _shouldAllowQrAction() {
    final user = ref.read(loginControllerProvider).user;
    return user != null;
  }

  Future<void> _handleQr(String rawValue) async {
    if (_locked) return;
    _locked = true;

    // Haptic UX: Vibrate when a QR is detected!
    HapticFeedback.vibrate();

    // Pause camera temporarily to avoid duplicate scans while API runs.
    await _scannerController?.pauseCamera();

    try {
      if (!_shouldAllowQrAction()) {
        throw const FormatException('Anda harus login terlebih dahulu.');
      }

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

      // Call API
      await ref
          .read(loanActionControllerProvider.notifier)
          .checkIn(roomId: roomId, deskId: deskId);

      if (!mounted) return;

      // 3. Navigation UX: Show success dialog, then EXIT the scanner screen
      await showDialog<void>(
        context: context,
        barrierDismissible: false, // Must click OK
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Check-In Berhasil'),
            ],
          ),
          content: const Text(
            'Anda berhasil melakukan check-in. Selamat menggunakan fasilitas lab!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(
                  context,
                ).pop(); // Close camera screen (return to previous page)
              },
              child: Text('Tutup & Selesai', style: BaseTypography.bodySmall),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mapDioErrorToMessage(error)),
          backgroundColor: Colors.red.shade700, // Clear error color
        ),
      );

      await _scannerController?.resumeCamera();
    } finally {
      // Release the lock (even if the camera is already stopped/started, this is best practice)
      _locked = false;
    }
  }

  void _onQrViewCreated(QRViewController controller) {
    _scannerController = controller;
    controller.scannedDataStream.listen((scanData) {
      final value = scanData.code;
      if (value == null || value.isEmpty) return;
      _handleQr(value);
    });
  }

  Future<void> _handleCheckOut() async {
    try {
      if (!_shouldAllowQrAction()) {
        throw const FormatException('Anda harus login terlebih dahulu.');
      }

      // Show an improved confirmation UI (modal bottom sheet)
      final confirm = await _showCheckOutConfirmationSheet();

      if (confirm != true || !mounted) return;

      await ref.read(loanActionControllerProvider.notifier).checkOut();

      if (!mounted) return;

      // Successful check-out: tactile feedback + animated success overlay
      HapticFeedback.lightImpact();
      await _showCheckOutSuccessOverlay();
      if (!mounted) return;
      Navigator.of(context).pop(); // Close scanner screen after success overlay
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mapDioErrorToMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Shows a modal bottom sheet with a clearer confirmation and brief summary
  Future<bool?> _showCheckOutConfirmationSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Konfirmasi Check-Out',
                      style: BaseTypography.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Gap.h8,
              const Text(
                'Apakah Anda yakin ingin menyelesaikan sesi peminjaman sekarang?',
              ),
              Gap.h12,
              // small hint / summary area
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSize.w12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• Semua perangkat akan dikembalikan ke inventaris.'),
                    SizedBox(height: 4),
                    Text('• Riwayat peminjaman akan tersimpan di akun Anda.'),
                  ],
                ),
              ),
              Gap.h16,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text('Batal', style: BaseTypography.bodySmall),
                    ),
                  ),
                  Gap.w8,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text('Ya, Check-Out', style: BaseTypography.bodySmall),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Shows an animated centered success dialog with auto-close and manual close
  Future<void> _showCheckOutSuccessOverlay() async {
    // Use a general dialog so we can animate scale/opacity
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'CheckOutSuccess',
      pageBuilder: (ctx, a1, a2) {
        return const SizedBox.shrink(); // will be built in transitionBuilder
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final scale = Curves.elasticOut.transform(animation.value);
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(BaseSize.w24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(BaseSize.radiusXl),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 88,
                      ),
                      Gap.h12,
                      Text(
                        'Check-Out Berhasil',
                        style: BaseTypography.titleLarge.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      Gap.h8,
                      const Text(
                        'Terima kasih telah menggunakan fasilitas lab.',
                      ),
                      Gap.h16,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Selesai', style: BaseTypography.bodySmall),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    ).then((_) async {
      // safety haptic and small pause so the dialog feel complete
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
    });
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
            onPressed: actionState.isLoading ? null : _handleCheckOut,
            child: actionState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Check Out',
                    style: BaseTypography.titleSmall.copyWith(
                      color: BaseColor.white,
                    ),
                  ),
          ),
        ],
      ),
      child: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQrViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: BaseColor.primaryinventory,
              borderRadius: 16,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: 250,
            ),
          ),

          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code yang ada di meja',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actionState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
