import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/components/task_file_uploader.dart';
import 'package:camlica_pts/components/task_map_card.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isLoading = false;
  bool _isMapExpanded = false;
  bool _isFilesExpanded = false;

  void onPressed(TaskStatus status, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await HttpService.dio.patch("/tasks/${widget.task.id}/status",
          data: {"status": status.name});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev durumu güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // ignore: unused_result
      queryClient.invalidateQueries(["tasks"]);
      /*   widgetRef?.refresh(tasksProvider); */
    } on DioException catch (e) {
      HttpService.handleError(
        e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.task.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  Spacer(),
                  Text(_isLoading
                      ? "Güncelleniyor..."
                      : translateTaskStatus(widget.task.status)),
                ],
              ),
              Text(widget.task.description ?? "-"),
              const SizedBox(height: 10),
              ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    if (index == 0) {
                      _isMapExpanded = isExpanded;
                    } else if (index == 1) {
                      _isFilesExpanded = isExpanded;
                    }
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text('Harita Gösterimi'),
                      );
                    },
                    body: widget.task.locationX != null &&
                            widget.task.locationY != null
                        ? TaskMapCard(
                            locationX: widget.task.locationX,
                            locationY: widget.task.locationY,
                          )
                        : const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("Konum bilgisi bulunmamaktadır."),
                          ),
                    isExpanded: _isMapExpanded,
                  ),
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text('Dosyalar'),
                      );
                    },
                    body: widget.task.files.isNotEmpty
                        ? Column(
                            children: [
                              for (var file in widget.task.files)
                                Image.network(HttpService.getFile(file),
                                    height: 100,
                                    fit: BoxFit.contain, loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("Dosya bulunmamaktadır."),
                          ),
                    isExpanded: _isFilesExpanded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Oluşturulma Tarihi: ${formatDate(widget.task.createdAt.toLocal())}"),
                  Text(
                      "Güncellenme Tarihi: ${formatDate(widget.task.updatedAt.toLocal())}"),
                ],
              ),
              buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.task.status == TaskStatus.PENDING
            ? StyledButton(
                onPressed: () => onPressed(
                  TaskStatus.IN_PROGRESS,
                  context,
                ),
                variant: Variants.primary,
                child: Text("Başla"),
              )
            : const SizedBox.shrink(),
        widget.task.status == TaskStatus.IN_PROGRESS
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StyledButton(
                    onPressed: () => onPressed(
                      TaskStatus.DONE,
                      context,
                    ),
                    variant: Variants.success,
                    child: Text("Tamamla"),
                  ),
                  TaskFileUploader(task: widget.task),
                ],
              )
            : const SizedBox.shrink(),
        widget.task.status == TaskStatus.DONE
            ? StyledButton(
                onPressed: () => onPressed(
                  TaskStatus.PENDING,
                  context,
                ),
                variant: Variants.danger,
                child: Text("İptal"),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
