// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      unitId: json['unitId'] as String?,
      password: json['password'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: json['birthDate'] == null
          ? null
          : DateTime.parse(json['birthDate'] as String),
      firebaseToken: json['firebaseToken'] as String?,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => $enumDecode(_$UserRoleEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'unitId': instance.unitId,
      'birthDate': instance.birthDate?.toIso8601String(),
      'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
      'firebaseToken': instance.firebaseToken,
    };

const _$UserRoleEnumMap = {
  UserRole.USER: 'USER',
  UserRole.STAFF: 'STAFF',
  UserRole.MANAGER: 'MANAGER',
  UserRole.ADMIN: 'ADMIN',
};
