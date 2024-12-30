import '/models/task_model.dart';
import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_model.g.dart';

@JsonSerializable()
class Unit {
  final String id;
  final String name;
  final List<String> userIds;
  final List<User> users;
  final List<Task> tasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Unit({
    required this.id,
    required this.name,
    required this.userIds,
    required this.users,
    required this.tasks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
