import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/data_sources/local/hive_service.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';
import 'package:inventory/features/desk/data/repositories/room_repository.dart';

class SelectedRoomIdNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setRoomId(int roomId) {
    state = roomId;
  }
}

final selectedRoomIdProvider = NotifierProvider<SelectedRoomIdNotifier, int>(
  SelectedRoomIdNotifier.new,
);

class SelectedDeskNotifier extends Notifier<DeskModel?> {
  @override
  DeskModel? build() => null;

  void setDesk(DeskModel? desk) {
    state = desk;
  }
}

final selectedDeskProvider = NotifierProvider<SelectedDeskNotifier, DeskModel?>(
  SelectedDeskNotifier.new,
);

// Provider for all rooms
final allRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final rooms = await ref.read(roomRepositoryProvider).getAllRooms();
  return rooms;
});

final roomDesksProvider = FutureProvider<List<DeskModel>>((ref) async {
  final roomId = ref.watch(selectedRoomIdProvider);
  final desks = await ref.read(roomRepositoryProvider).getRoomDesks(roomId);
  await ref.read(hiveServiceProvider).saveLastRoomId(roomId);
  return desks;
});
