import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/network/api_envelope.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepositoryImpl(ref.watch(dioProvider)),
);

abstract class RoomRepository {
  Future<List<RoomModel>> getAllRooms();

  Future<List<DeskModel>> getRoomDesks(int roomId);

  Future<List<DeskModel>> getAvailableDesk(int roomId);

  Future<String> getDeskQrPayload(int deskId);
}

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<RoomModel>> getAllRooms() async {
    final response = await _dio.get<dynamic>(Endpoint.rooms);

    return _parseList<RoomModel>(
      response.data,
      (item) => RoomModel.fromJson(Map<String, dynamic>.from(item as Map)),
    );
  }

  @override
  Future<List<DeskModel>> getRoomDesks(int roomId) async {
    final response = await _dio.get<dynamic>(Endpoint.roomDesks(roomId));

    return _parseList<DeskModel>(
      response.data,
      (item) => DeskModel.fromJson(Map<String, dynamic>.from(item as Map)),
    );
  }

  @override
  Future<List<DeskModel>> getAvailableDesk(int roomId) async {
    final response =
        await _dio.get<dynamic>(Endpoint.roomAvailableDesks(roomId));

    return _parseList<DeskModel>(
      response.data,
      (item) => DeskModel.fromJson(Map<String, dynamic>.from(item as Map)),
    );
  }

  @override
  Future<String> getDeskQrPayload(int deskId) async {
    final response = await _dio.get<dynamic>(Endpoint.deskQr(deskId));

    final envelope = ApiEnvelope.fromDynamic<Map<String, dynamic>>(
      response.data,
      dataParser: (data) {
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw const FormatException('Invalid desk QR payload');
      },
    );

    if (!envelope.isSuccess) {
      throw FormatException(envelope.message);
    }

    final payload = envelope.data['qr_payload']?.toString();
    if (payload == null || payload.isEmpty) {
      throw const FormatException('QR payload not available');
    }

    return payload;
  }

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Object data) parser,
  ) {
    final ApiResponse<List<T>> envelope = ApiEnvelope.fromDynamic<List<T>>(
      raw,
      dataParser: (data) {
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => parser(item))
              .toList(growable: false);
        }

        if (data is Map<String, dynamic>) {
          final maybeList = data['data'];
          if (maybeList is List) {
            return maybeList
                .whereType<Map>()
                .map((item) => parser(item))
                .toList(growable: false);
          }
        }

        throw const FormatException('Invalid list payload');
      },
    );

    if (!envelope.isSuccess) {
      throw FormatException(envelope.message);
    }

    return envelope.data;
  }
}
