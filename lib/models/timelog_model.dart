import '/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timelog_model.g.dart';

@JsonSerializable()
class TimeLog {
  final String id;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String userId;
  final User? user;
  double total = 0;
  bool isEarlyOut = false;
  bool isLateIn = false;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeLog({
    required this.id,
    required this.checkIn,
    this.checkOut,
    required this.userId,
    this.user,
    this.total = 0,
    this.isEarlyOut = false,
    this.isLateIn = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeLog.fromJson(Map<String, dynamic> json) =>
      _$TimeLogFromJson(json);
  Map<String, dynamic> toJson() => _$TimeLogToJson(this);
}
/** model TimeLog {
  id       String    @id @default(uuid())
  checkIn  DateTime
  checkOut DateTime?
  total    Float     @default(0)

  isEarlyOut Boolean @default(false)
  isLateIn   Boolean @default(false)

  userId String
  user   User   @relation(fields: [userId], references: [id])

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("timelogs")
} */
