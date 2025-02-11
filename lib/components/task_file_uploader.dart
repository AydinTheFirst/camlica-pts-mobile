import 'dart:io';
import 'package:camlica_pts/components/file_picker_provider.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/main.dart';
import 'package:image_picker/image_picker.dart';

class TaskFileUploader extends ConsumerWidget {
  final Task task;

  const TaskFileUploader({super.key, required this.task});

  Future<void> _uploadImage(BuildContext context, WidgetRef ref) async {
    final files = ref.read(filePickerProvider); // Seçilen dosyaları al

    if (files.isEmpty) {
      ToastService.error(message: "Lütfen en az bir dosya seçin.");
      return;
    }

    try {
      FormData formData = FormData();

      for (var file in files) {
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      // HTTP isteği gönder
      final response = await HttpService.dio.post(
        "/files",
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      await HttpService.dio.patch("/tasks/${task.id}", data: {
        "files": response.data,
      });

      await HttpService.dio.patch(
        "/tasks/${task.id}/status",
        data: {
          "status": TaskStatus.DONE.name,
        },
      );

      // Başarı mesajı ve provider temizleme
      ToastService.success(message: "Resimler başarıyla yüklendi");
      queryClient.invalidateQueries(["tasks"]);
      ref
          .read(filePickerProvider.notifier)
          .clearFiles(); // Dosya listesini temizle
    } on DioException catch (e) {
      HttpService.handleError(e);
    }
  }

  Future<void> _openBottomSheet(BuildContext context, WidgetRef ref) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Galeriden Seç"),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(filePickerProvider.notifier).openGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Kamerayı Aç"),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(filePickerProvider.notifier).openCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImages(BuildContext context, List<XFile> files, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: files.isEmpty
            ? [Text("Dosya Bulunamadı")]
            : files
                .map(
                  (file) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(file.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(filePickerProvider.notifier)
                                .removeFile(file);
                          },
                          icon: Icon(Icons.cancel, color: Colors.red),
                        ),
                      )
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(filePickerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fotoğraflar (${files.length})",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildImages(context, files, ref),
        StyledButton(
          variant: Variants.secondary,
          fullWidth: true,
          onPressed: () => _openBottomSheet(context, ref),
          child: Text("Fotoğraf Ekle"),
        ),
        StyledButton(
          fullWidth: true,
          isDisabled: files.isEmpty,
          onPressed: () => _uploadImage(context, ref),
          child: Text("Dosya Yükle ve Tamamla"),
        ),
      ],
    );
  }
}
