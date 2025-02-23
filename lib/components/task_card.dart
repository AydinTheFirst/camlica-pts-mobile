import 'package:camlica_pts/components/confirm_dialog.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/components/task_file_uploader.dart';
import 'package:camlica_pts/components/task_map_card.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isLoading = false;
  bool _isMapExpanded = false;
  bool _isFilesExpanded = false;

  void onPressed(TaskStatus status, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await HttpService.dio.patch(
        "/tasks/${widget.task.id}/status",
        data: {"status": status.name},
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev durumu güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      ref.invalidate(tasksProvider);
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
                    body: buildMap(context),
                    isExpanded: _isMapExpanded,
                  ),
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return const ListTile(
                        title: Text('Dosyalar'),
                      );
                    },
                    body: buildImages(context),
                    isExpanded: _isFilesExpanded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Oluşturulma Tarihi: ${formatFullDate(widget.task.createdAt)}"),
                  Text(
                      "Güncellenme Tarihi: ${formatFullDate(widget.task.updatedAt)}"),
                ],
              ),
              buildButtons(context),
              widget.task.status == TaskStatus.IN_PROGRESS
                  ? TaskFileUploader(task: widget.task)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMap(BuildContext context) {
    return widget.task.locationX != null && widget.task.locationY != null
        ? TaskMapCard(task: widget.task)
        : const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Konum bilgisi bulunmamaktadır."),
          );
  }

  Widget buildImages(BuildContext context) {
    return widget.task.files.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Dosya bulunmamaktadır."),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                children: [
                  for (var file in widget.task.files)
                    GestureDetector(
                      onTap: () {
                        Get.to(() => FullScreenImage(
                            imageUrl: HttpService.getFile(file)));
                      },
                      child: Image.network(
                        HttpService.getFile(file),
                        height: 100,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  void handleTaskDelete() async {
    final confirmed = await showConfirmationDialog(context);

    if (!confirmed) {
      return;
    }

    try {
      await HttpService.dio.delete("/tasks/${widget.task.id}");
      ToastService.success(message: "Görev silindi");
      ref.invalidate(tasksProvider);
    } on DioException catch (e) {
      HttpService.handleError(e);
    }
  }

  Widget buildButtons(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    final profile = profileAsync.maybeWhen(
      orElse: () => null,
      data: (user) => user,
    );

    final isAdmin = profile?.roles.contains(UserRole.ADMIN) ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            widget.task.status == TaskStatus.PENDING ||
                    widget.task.status == TaskStatus.REJECTED
                ? StyledButton(
                    onPressed: () => onPressed(
                      TaskStatus.IN_PROGRESS,
                      context,
                    ),
                    variant: Variants.primary,
                    child: Text("Başla"),
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
        ),
        if (isAdmin)
          StyledButton(
            onPressed: () => handleTaskDelete(),
            variant: Variants.danger,
            child: Text("Sil"),
          ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tam Ekran Resim'),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
