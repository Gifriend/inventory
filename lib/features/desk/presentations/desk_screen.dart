import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory/core/routing/app_routing.dart';
import 'package:inventory/core/utils/dio_error_mapper.dart';
import 'package:inventory/features/desk/presentations/desk_controller.dart';

class DeskSelectionScreen extends ConsumerWidget {
  const DeskSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final desksAsync = ref.watch(roomDesksProvider);
    final selectedRoomId = ref.watch(selectedRoomIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Desk'), elevation: 0),
      body: Column(
        children: [
          // Room Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: roomsAsync.when(
              data: (rooms) {
                return DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text('Select a room'),
                  value: selectedRoomId,
                  items: rooms.map((room) {
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text(room.name),
                    );
                  }).toList(),
                  onChanged: (roomId) {
                    if (roomId != null) {
                      ref
                          .read(selectedRoomIdProvider.notifier)
                          .setRoomId(roomId);
                    }
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) =>
                  Text('Error loading rooms: ${mapDioErrorToMessage(error)}'),
            ),
          ),
          // Desk Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: desksAsync.when(
                data: (desks) {
                  if (desks.isEmpty) {
                    return const Center(
                      child: Text('No desks found for this room'),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.35,
                        ),
                    itemCount: desks.length,
                    itemBuilder: (context, index) {
                      final desk = desks[index];
                      final isAvailable = desk.status == 'available';
                      final tileColor = isAvailable ? Colors.green : Colors.red;

                      return InkWell(
                        onTap: !isAvailable
                            ? null
                            : () {
                                ref
                                    .read(selectedDeskProvider.notifier)
                                    .setDesk(desk);
                                context.pushNamed(AppRoute.loanRequest);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              desk.deskNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text(mapDioErrorToMessage(error))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
