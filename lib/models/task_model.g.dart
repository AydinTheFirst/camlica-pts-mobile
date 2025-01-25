// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskMap _$TaskMapFromJson(Map<String, dynamic> json) => TaskMap(
      url: json['url'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$TaskMapToJson(TaskMap instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      files: (json['files'] as List<dynamic>).map((e) => e as String).toList(),
      assignedToId: json['assignedToId'] as String?,
      assignedById: json['assignedById'] as String,
      unitId: json['unitId'] as String,
      unit: json['unit'] == null
          ? null
          : Unit.fromJson(json['unit'] as Map<String, dynamic>),
      assignedTo: json['assignedTo'] == null
          ? null
          : User.fromJson(json['assignedTo'] as Map<String, dynamic>),
      assignedBy: json['assignedBy'] == null
          ? null
          : User.fromJson(json['assignedBy'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      locationX: (json['locationX'] as num?)?.toDouble(),
      locationY: (json['locationY'] as num?)?.toDouble(),
      location: json['location'] as String?,
      selectedMap:
          TaskMap.fromJson(json['selectedMap'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'files': instance.files,
      'assignedToId': instance.assignedToId,
      'assignedById': instance.assignedById,
      'unitId': instance.unitId,
      'unit': instance.unit,
      'assignedTo': instance.assignedTo,
      'assignedBy': instance.assignedBy,
      'locationX': instance.locationX,
      'locationY': instance.locationY,
      'location': instance.location,
      'selectedMap': instance.selectedMap,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TaskStatusEnumMap = {
  TaskStatus.PENDING: 'PENDING',
  TaskStatus.IN_PROGRESS: 'IN_PROGRESS',
  TaskStatus.DONE: 'DONE',
  TaskStatus.APPROVED: 'APPROVED',
};
