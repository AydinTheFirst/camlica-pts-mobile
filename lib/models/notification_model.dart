import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart'; // Bu dosya otomatik olarak üretilecek

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  // Otomatik olarak üretilen metodlar
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
