import 'package:camlica_pts/models/task_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_config_model.g.dart';

@JsonSerializable()
class AppConfig {
  final String id;
  final String title;
  final List<TaskMap> maps;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppConfig({
    required this.id,
    required this.title,
    required this.maps,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}



/* model AppConfig {
  id String @id @default(uuid())

  title String @default("App")
  maps  Json[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
 */