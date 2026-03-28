import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/constants/constants.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';

class ApproveAssignmentDialog extends ConsumerStatefulWidget {
  final int loanId;
  final VoidCallback onAssignmentSelected;

  const ApproveAssignmentDialog({
    required this.loanId,
    required this.onAssignmentSelected,
    super.key,
  });

  @override
  ConsumerState<ApproveAssignmentDialog> createState() =>
      _ApproveAssignmentDialogState();
}

class _ApproveAssignmentDialogState
    extends ConsumerState<ApproveAssignmentDialog> {
  RoomModel? selectedRoom;
  DeskModel? selectedDesk;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final desksAsync = selectedRoom != null
        ? ref.watch(roomDesksProvider)
        : const AsyncValue<List<DeskModel>>.data([]);

    return AlertDialog(
      title: Text('Assign Room & Desk', style: BaseTypography.bodySmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Room Selection Dropdown
            roomsAsync.when(
              data: (rooms) {
                return DropdownButton<RoomModel>(
                  isExpanded: true,
                  hint: Text('Select Room', style: BaseTypography.bodySmall),
                  value: selectedRoom,
                  items: rooms.map((room) {
                    return DropdownMenuItem(
                      value: room,
                      child: Text(room.name, style: BaseTypography.bodySmall),
                    );
                  }).toList(),
                  onChanged: (room) {
                    setState(() {
                      selectedRoom = room;
                      selectedDesk = null;
                      // Update the selected room provider for desks fetching
                      if (room != null) {
                        ref
                            .read(selectedRoomIdProvider.notifier)
                            .setRoomId(room.id);
                      }
                    });
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) =>
                  Text('Error loading rooms: ${mapDioErrorToMessage(error)}'),
            ),
            Gap.h16,
            // Desk Selection Dropdown
            if (selectedRoom != null)
              desksAsync.when(
                data: (desks) {
                  final availableDesks = desks
                      .where((d) => d.status == 'available')
                      .toList();
                  return DropdownButton<DeskModel>(
                    isExpanded: true,
                    hint: Text('Select Desk', style: BaseTypography.bodySmall),
                    value: selectedDesk,
                    items: availableDesks.map((desk) {
                      return DropdownMenuItem(
                        value: desk,
                        child: Text('Desk ${desk.deskNumber}', style: BaseTypography.bodySmall),
                      );
                    }).toList(),
                    onChanged: (desk) {
                      setState(() {
                        selectedDesk = desk;
                      });
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, _) =>
                    Text('Error loading desks: ${mapDioErrorToMessage(error)}', style: BaseTypography.bodySmall),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: BaseTypography.bodySmall),
        ),
        ElevatedButton(
          onPressed: selectedRoom != null && selectedDesk != null
              ? () {
                  Navigator.pop(context, {
                    'roomId': selectedRoom!.id,
                    'deskId': selectedDesk!.id,
                  });
                }
              : null,
          child: Text('Confirm', style: BaseTypography.bodySmall),
        ),
      ],
    );
  }
}
