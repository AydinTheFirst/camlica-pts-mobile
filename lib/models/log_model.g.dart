// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) => Log(
      id: json['id'] as String,
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      message: json['message'] as String,
      meta: json['meta'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
      'id': instance.id,
      'level': _$LogLevelEnumMap[instance.level]!,
      'message': instance.message,
      'meta': instance.meta,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LogLevelEnumMap = {
  LogLevel.INFO: 'INFO',
  LogLevel.WARN: 'WARN',
  LogLevel.ERROR: 'ERROR',
  LogLevel.DEBUG: 'DEBUG',
};
