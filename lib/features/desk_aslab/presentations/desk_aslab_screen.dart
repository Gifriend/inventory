import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/core/widgets/widgets.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';

class AslabDeskQrScreen extends ConsumerWidget {
  const AslabDeskQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final desksAsync = ref.watch(roomDesksProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'QR Meja - Aslab',
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w16),
            margin: EdgeInsets.only(top: BaseSize.h12),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: BaseShadow.shadow,
            ),
            child: roomsAsync.when(
              data: (rooms) {
                return DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('Pilih ruangan', style: BaseTypography.titleSmall),
                  value: ref.watch(selectedRoomIdProvider),
                  items: rooms.map((room) {
                    return DropdownMenuItem(value: room.id, child: Text(room.name));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) ref.read(selectedRoomIdProvider.notifier).setRoomId(v);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(mapDioErrorToMessage(e)),
            ),
          ),
          Gap.h12,
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: desksAsync.when(
                data: (desks) {
                  if (desks.isEmpty) return Center(child: Text('Tidak ada meja', style: BaseTypography.titleMedium));

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: BaseSize.w8,
                      mainAxisSpacing: BaseSize.h8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: desks.length,
                    itemBuilder: (context, index) => _DeskQrTile(desk: desks[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(mapDioErrorToMessage(e))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskQrTile extends StatelessWidget {
  const _DeskQrTile({required this.desk});
  final DeskModel desk;

  String _qrUrlForDesk(DeskModel d) {
    final payload = d.qrPayload ?? jsonEncode({'room_id': d.roomId, 'desk_id': d.id});
    // Use a public QR generator endpoint that returns a PNG image.
    // google chart API may be unreliable or blocked in some environments.
    return 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(payload)}';
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = desk.status == 'available';
    final qrUrl = _qrUrlForDesk(desk);

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('QR ${desk.deskNumber}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(qrUrl, width: 240, height: 240, errorBuilder: (_, _, _) => const Icon(Icons.broken_image)),
                  Gap.h12,
                  SelectableText(desk.qrPayload ?? 'payload kosong'),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tutup')),
              ],
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: isAvailable ? BaseColor.primaryinventory : BaseColor.grey.shade300,
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.network(
                  qrUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) {
                    debugPrint('QR image load failed for URL: $qrUrl');
                    debugPrint('Image error: $error');
                    return const Icon(Icons.broken_image);
                  },
                ),
              ),
              Gap.h8,
              Text(desk.deskNumber, style: BaseTypography.titleSmall.copyWith(color: isAvailable ? BaseColor.white : BaseColor.neutral)),
            ],
          ),
        ),
      ),
    );
  }
}
