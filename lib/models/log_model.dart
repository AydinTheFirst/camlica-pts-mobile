import '/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_model.g.dart';

@JsonSerializable()
class Log {
  final String id;
  final LogLevel level;
  final String message;
  final dynamic meta;
  final DateTime createdAt;
  final DateTime updatedAt;

  Log({
    required this.id,
    required this.level,
    required this.message,
    required this.meta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);
}
