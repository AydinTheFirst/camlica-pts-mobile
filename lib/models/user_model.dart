import 'package:camlica_pts/models/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart'; // Bu dosya otomatik olarak üretilecek

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String password;
  final String firstName;
  final String lastName;
  final String? unitId;
  final DateTime? birthDate;
  final List<UserRole> roles;
  final String? firebaseToken;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.unitId,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    this.firebaseToken,
    required this.roles,
  });

  // Otomatik olarak üretilen metodlar
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
