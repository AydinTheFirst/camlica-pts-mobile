import 'package:intl/date_symbol_data_local.dart';

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
  return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
}

String formatTime(DateTime date) {
  initializeDateFormatting('tr_TR', null);
  final gmtPlus3 = date.toUtc().add(Duration(hours: 3));
  return DateFormat('HH:mm', 'tr_TR').format(gmtPlus3);
}
