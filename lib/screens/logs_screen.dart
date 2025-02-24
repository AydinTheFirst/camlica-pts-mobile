import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsRef = ref.watch(timelogsProvider);

    return logsRef.when(
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      data: (logs) {
        return RefreshIndicator(
          onRefresh: () {
            ref.invalidate(timelogsProvider);
            return Future.value();
          },
          child: ListView(
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Tarih')),
                  DataColumn(label: Text('Giriş')),
                  DataColumn(label: Text('Çıkış')),
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
