import '/models/enums.dart';
import '/models/unit_model.dart';
import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskMap {
  final String url;
  final String title;

  TaskMap({
    required this.url,
    required this.title,
  });

  factory TaskMap.fromJson(Map<String, dynamic> json) =>
      _$TaskMapFromJson(json);
  Map<String, dynamic> toJson() => _$TaskMapToJson(this);
}

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
  final TaskMap selectedMap;

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
    required this.selectedMap,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

/**
 * 
model Task {
  id          String     @id @default(uuid())
  title       String
  description String?
  status      TaskStatus @default(PENDING)
  files       String[]
  notes       String?

  locationX   Float?
  locationY   Float?
  locationZ   Float?
  location    String?
  selectedMap Json

  assignedToId String?
  assignedTo   User?   @relation(name: "AssignedTo", fields: [assignedToId], references: [id])
  assignedById String
  assignedBy   User    @relation(name: "AssignedBy", fields: [assignedById], references: [id])
  unitId       String
  unit         Unit    @relation(fields: [unitId], references: [id])

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("tasks")
}
 */
