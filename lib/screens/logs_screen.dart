import 'package:camlica_pts/models/timelog_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logsProvider = AutoDisposeFutureProvider((ref) async {
  final data = await HttpService.fetcher("/timelogs");
  return data;
});

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Çıkış Kayıtları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: LogsTable(),
    );
  }
}

class LogsTable extends ConsumerWidget {
  const LogsTable({super.key});

  String calculateTotal(TimeLog log) {
    if (log.total == 0) {
      return "-";
    }

    final diff = Duration(milliseconds: log.total.toInt());
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);

    return "$hours saat $minutes dakika";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsRef = ref.watch(logsProvider);

    return logsRef.when(
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      data: (data) {
        final logs = data.map((e) => TimeLog.fromJson(e)).toList();

        return RefreshIndicator(
          onRefresh: () {
            ref.refresh(logsProvider);
            return Future.value();
          },
          child: ListView(
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Tarih')),
                  DataColumn(label: Text('Giriş')),
                  DataColumn(label: Text('Çıkış')),
                  DataColumn(label: Text('Toplam')),
                ],
                rows: [
                  for (final log in logs)
                    DataRow(
                      cells: [
                        DataCell(Text(formatDate(log.createdAt))),
                        DataCell(
                          Text(
                            formatTime(log.checkIn),
                            style: TextStyle(
                              color: log.isLateIn ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            log.checkOut != null
                                ? formatTime(log.checkOut!)
                                : "-",
                            style: TextStyle(
                              color: log.isEarlyOut ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                        DataCell(Text(calculateTotal(log))),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
