import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timelog_model.g.dart';

@JsonSerializable()
class TimeLog {
  final String id;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String userId;
  final User? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeLog({
    required this.id,
    required this.checkIn,
    this.checkOut,
    required this.userId,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeLog.fromJson(Map<String, dynamic> json) =>
      _$TimeLogFromJson(json);
  Map<String, dynamic> toJson() => _$TimeLogToJson(this);
}
