import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shift_model.g.dart';

@JsonSerializable()
class Shift {
  final String id;
  final String name;
  final String startAt;
  final String endAt;
  final List<String> userIds;
  final List<User> users;
  final DateTime createdAt;
  final DateTime updatedAt;

  Shift({
    required this.id,
    required this.name,
    required this.startAt,
    required this.endAt,
    required this.userIds,
    required this.users,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
  Map<String, dynamic> toJson() => _$ShiftToJson(this);
}
