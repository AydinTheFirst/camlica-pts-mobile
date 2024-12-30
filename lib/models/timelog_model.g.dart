// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timelog_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeLog _$TimeLogFromJson(Map<String, dynamic> json) => TimeLog(
      id: json['id'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: json['checkOut'] == null
          ? null
          : DateTime.parse(json['checkOut'] as String),
      userId: json['userId'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TimeLogToJson(TimeLog instance) => <String, dynamic>{
      'id': instance.id,
      'checkIn': instance.checkIn.toIso8601String(),
      'checkOut': instance.checkOut?.toIso8601String(),
      'userId': instance.userId,
      'user': instance.user,
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.PRESENT: 'PRESENT',
  AttendanceStatus.ABSENT: 'ABSENT',
  AttendanceStatus.LATE: 'LATE',
  AttendanceStatus.ON_LEAVE: 'ON_LEAVE',
};
