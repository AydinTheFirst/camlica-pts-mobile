import '/models/enums.dart';
import '/models/unit_model.dart';
import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final List<String> files;
  final String? assignedToId;
  final String assignedById;
  final String unitId;
  final Unit? unit;
  final User? assignedTo;
  final User? assignedBy;
  final double? locationX;
  final double? locationY;
  final String? location;

  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.files,
    this.assignedToId,
    required this.assignedById,
    required this.unitId,
    this.unit,
    this.assignedTo,
    this.assignedBy,
    required this.createdAt,
    required this.updatedAt,
    this.locationX,
    this.locationY,
    this.location,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
