import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inventory/core/models/desk_model.dart';
import 'package:inventory/core/models/room_model.dart';
import 'package:inventory/core/models/user_model.dart';

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

@freezed
abstract class LoanModel with _$LoanModel {
  const factory LoanModel({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'room_id') int? roomId,
    @JsonKey(name: 'desk_id') int? deskId,
    @JsonKey(name: 'document_path') String? documentPath,
    required String status,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'check_in_time') String? checkInTime,
    @JsonKey(name: 'check_out_time') String? checkOutTime,
    @JsonKey(name: 'approved_by') int? approvedBy,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    UserModel? user,
    RoomModel? room,
    DeskModel? desk,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _LoanModel;

  factory LoanModel.fromJson(Map<String, dynamic> json) =>
      _$LoanModelFromJson(json);
}
