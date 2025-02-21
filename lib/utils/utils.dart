import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '/models/enums.dart';
import 'package:intl/intl.dart';

String translateTaskStatus(TaskStatus status) {
  switch (status) {
    case TaskStatus.APPROVED:
      return "Onaylandı";
    case TaskStatus.DONE:
      return "Tamamlandı";
    case TaskStatus.IN_PROGRESS:
      return "Devam Ediyor";
    case TaskStatus.PENDING:
      return "Beklemede";
    case TaskStatus.REJECTED:
      return "Reddedildi";
  }
}

String formatDate(DateTime date) {
  initializeDateFormatting('tr_TR', null);
  final gmtPlus3 = date.toUtc().add(Duration(hours: 3));
  return DateFormat('dd.MM.yyyy', 'tr_TR').format(gmtPlus3);
}

String formatFullDate(DateTime date) {
  initializeDateFormatting('tr_TR', null);
  final gmtPlus3 = date.toUtc().add(Duration(hours: 3));
  return DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(gmtPlus3);
}

String formatTime(DateTime date) {
  initializeDateFormatting('tr_TR', null);
  final gmtPlus3 = date.toUtc().add(Duration(hours: 3));
  return DateFormat('HH:mm', 'tr_TR').format(gmtPlus3);
}

String uuid() {
  final uuid = Uuid();
  return uuid.v4();
}

Future<String> getDeviceId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  const key = "unique_device_id";
  String? deviceId = prefs.getString(key);

  if (deviceId == null) {
    deviceId = uuid();
    prefs.setString(key, deviceId);
  }

  return deviceId;
}
