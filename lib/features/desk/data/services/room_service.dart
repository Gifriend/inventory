import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';
import 'package:inventory/features/desk/data/repositories/room_repository.dart';

final roomServiceProvider = Provider<RoomService>(
  (ref) => RoomServiceImpl(ref.watch(roomRepositoryProvider)),
);

abstract class RoomService {
  Future<List<RoomModel>> getAllRooms();
  Future<List<DeskModel>> getRoomDesks(int roomId);
  Future<List<DeskModel>> getAvailableDesks(int roomId);
  Future<String> getDeskQrPayload(int deskId);
}

class RoomServiceImpl implements RoomService {
  RoomServiceImpl(this._repository);

  final RoomRepository _repository;

  @override
  Future<List<RoomModel>> getAllRooms() async {
    return _repository.getAllRooms();
  }

  @override
  Future<List<DeskModel>> getRoomDesks(int roomId) async {
    return _repository.getRoomDesks(roomId);
  }

  @override
  Future<List<DeskModel>> getAvailableDesks(int roomId) async {
    return _repository.getAvailableDesk(roomId);
  }

  @override
  Future<String> getDeskQrPayload(int deskId) async {
    return _repository.getDeskQrPayload(deskId);
  }
}
