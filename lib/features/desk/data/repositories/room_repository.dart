import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepositoryImpl(ref.watch(dioProvider)),
);

abstract class RoomRepository {
  Future<List<RoomModel>> getAllRooms();

  Future<List<DeskModel>> getRoomDesks(int roomId);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<RoomModel>> getAllRooms() async {
    final response = await _dio.get<dynamic>(Endpoint.rooms);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid rooms response');
    }

    final roomsData = data['data'];
    if (roomsData is! List) {
      return [];
    }

    return roomsData
        .whereType<Map>()
        .map((e) => RoomModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<List<DeskModel>> getRoomDesks(int roomId) async {
    final response = await _dio.get<dynamic>(Endpoint.roomDesks(roomId));
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid desks response');
    }

    final desksData = data['data'];
    if (desksData is! List) {
      return [];
    }

    return desksData
        .whereType<Map>()
        .map((e) => DeskModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
