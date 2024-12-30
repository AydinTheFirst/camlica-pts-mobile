import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_model.g.dart';

@JsonSerializable()
class Token {
  final String id;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final String userId;
  final User? user;

  Token({
    required this.id,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.userId,
    this.user,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
