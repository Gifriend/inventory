import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
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
  
  // Add controller to manage camera on/off
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQr(String rawValue) async {
    if (_locked) return;
    _locked = true;

    // Haptic UX: Vibrate when a QR is detected!
    HapticFeedback.vibrate();

    // Performance UX: Pause the camera temporarily to avoid heavy load & duplicate scans
    _scannerController.stop();

    try {
      final parsed = jsonDecode(rawValue);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Invalid QR payload');
      }

      final roomId = parsed['room_id'];
      final deskId = parsed['desk_id'];
      if (roomId is! int || deskId is! int) {
        throw const FormatException('QR payload must include room_id and desk_id');
      }

      // Call API
      await ref.read(loanActionControllerProvider.notifier).checkIn(roomId: roomId, deskId: deskId);
      
      if (!mounted) return;
      
      // 3. Navigation UX: Show success dialog, then EXIT the scanner screen
      await showDialog<void>(
        context: context,
        barrierDismissible: false, // Must click OK
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseSize.radiusMd)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Check-In Berhasil'),
            ],
          ),
          content: const Text('Anda berhasil melakukan check-in. Selamat menggunakan fasilitas lab!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Close camera screen (return to previous page)
              }, 
              child: const Text('Tutup & Selesai')
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
        )
      );
      
      // Because of an error, restart the camera so the user can retry scanning
      _scannerController.start();
    } finally {
      // Release the lock (even if the camera is already stopped/started, this is best practice)
      _locked = false;
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      // Confirm before check-out (prevent accidental taps)
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menyelesaikan sesi peminjaman dan check-out sekarang?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ya, Check-Out')),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      await ref.read(loanActionControllerProvider.notifier).checkOut();
      
      if (!mounted) return;

      // Successful check-out
      HapticFeedback.lightImpact();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Check-Out Berhasil'),
          content: const Text('Terima kasih telah menggunakan fasilitas lab. Sampai jumpa!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Close scanner screen
              }, 
              child: const Text('OK')
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapDioErrorToMessage(error)), backgroundColor: Colors.red),
      );
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
            onPressed: actionState.isLoading ? null : _handleCheckOut,
            child: actionState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Check Out', style: BaseTypography.titleSmall.copyWith(color: BaseColor.white)),
          ),
        ],
      ),
      // Use a Stack so we can place Loading UI and overlay on top of the camera
      child: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;
              final value = capture.barcodes.first.rawValue;
              if (value == null || value.isEmpty) return;
              _handleQr(value);
            },
          ),
          
          // Visual UX: Scanner guide box (overlay)
          // Add a transparent shadow around the central box
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.red, // This color becomes the transparent hole area due to BlendMode.dstOut
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Border for the scanner box to make it more distinct
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: BaseColor.primaryinventory, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code yang ada di meja',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          // Loading overlay when state is loading (waiting for Check-In/Out API)
          if (actionState.isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}