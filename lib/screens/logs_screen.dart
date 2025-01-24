import 'package:camlica_pts/models/timelog_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';

class LogsScreen extends HookWidget {
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

class LogsTable extends HookWidget {
  const LogsTable({super.key});

  String calculateTotal(TimeLog log) {
    if (log.checkOut == null) {
      return "-";
    }

    final diff = log.checkOut!.difference(log.checkIn);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return "$hours saat $minutes dakika";
  }

  @override
  Widget build(BuildContext context) {
    final logs = useQuery(["attendances"], getTimeLogs);

    if (logs.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (logs.error != null) {
      return Center(child: Text("Bir hata oluştu: ${logs.error}"));
    }

    if (logs.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Loglar bulunamadı"),
              IconButton(
                onPressed: () {
                  logs.refetch();
                },
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      );
    }

    final logsData = logs.data!;

    return RefreshIndicator(
      onRefresh: () => logs.refetch(),
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
              for (final log in logsData)
                DataRow(
                  cells: [
                    DataCell(Text(formatDate(log.checkIn))),
                    DataCell(Text(formatTime(log.checkIn))),
                    DataCell(Text(log.checkOut != null
                        ? formatTime(log.checkOut!)
                        : "-")),
                    DataCell(Text(calculateTotal(log))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
