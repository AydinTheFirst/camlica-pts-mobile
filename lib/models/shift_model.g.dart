// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift(
      id: json['id'] as String,
      name: json['name'] as String,
      startAt: json['startAt'] as String,
      endAt: json['endAt'] as String,
      userIds:
          (json['userIds'] as List<dynamic>).map((e) => e as String).toList(),
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'userIds': instance.userIds,
      'users': instance.users,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
