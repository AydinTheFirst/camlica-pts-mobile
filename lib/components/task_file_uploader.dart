import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TaskFileUploader extends StatefulWidget {
  final Task task;

  const TaskFileUploader({super.key, required this.task});

  @override
  State<TaskFileUploader> createState() => _TaskFileUploaderState();
}

class _TaskFileUploaderState extends State<TaskFileUploader> {
  bool _isLoading = false;
  List<XFile> files = [];
  final _picker = ImagePicker();

  Future<void> _openImagePicker() async {
    final List<XFile> pickedImages =
        await _picker.pickMultiImage(requestFullMetadata: true);

    if (pickedImages.isEmpty) {
      return ToastService.error(message: "Lütfen bir resim seçin");
    }

    logger.f('Picked images: $pickedImages');

    setState(() {
      files = pickedImages;
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Dosyayı form-data'ya ekle
      FormData formData = FormData();

      for (var file in files) {
        String fileName = file.path.split('/').last; // Dosya adı
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      // HTTP isteği gönder
      final response = await HttpService.dio.post(
        "/files", // Endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data', // Form-data olduğunu belirt
          },
        ),
      );

      await HttpService.dio.patch("/tasks/${widget.task.id}", data: {
        "files": response.data,
      });

      // Başarılı sonuç
      ToastService.success(message: "Resim başarıyla yüklendi");
      queryClient.invalidateQueries(["tasks"]);
      setState(() {
        files = [];
      });
    } on DioException catch (e) {
      HttpService.handleError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 8,
      children: [
        Row(
          spacing: 10,
          children: [
            StyledButton(
              onPressed: _openImagePicker,
              variant: Variants.secondary,
              child: Text('Resim Seç'),
            ),
            StyledButton(
              onPressed: _uploadImage,
              variant: Variants.success,
              isDisabled: files.isEmpty,
              child: Text(
                _isLoading ? "Yükleniyor..." : 'Resmi Yükle',
              ),
            ),
          ],
        ),
        if (files.isNotEmpty)
          Column(
            spacing: 3,
            children: [
              for (var file in files) Text(file.path.split('/').last),
            ],
          ),
      ],
    );
  }
}
