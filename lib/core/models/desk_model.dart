import 'package:freezed_annotation/freezed_annotation.dart';

part 'desk_model.freezed.dart';
part 'desk_model.g.dart';

@freezed
abstract class DeskModel with _$DeskModel {
  const factory DeskModel({
    required int id,
    @JsonKey(name: 'room_id') int? roomId,
    @JsonKey(name: 'desk_number') required String deskNumber,
    required String status,
    @JsonKey(name: 'qr_payload') String? qrPayload,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _DeskModel;

  factory DeskModel.fromJson(Map<String, dynamic> json) =>
      _$DeskModelFromJson(json);
}
