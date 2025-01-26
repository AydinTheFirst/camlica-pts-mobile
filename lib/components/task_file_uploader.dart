import 'dart:io';

import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/main.dart';

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
      files.addAll(pickedImages);
    });
  }

  Future<void> _openCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) {
      return ToastService.error(message: "Lütfen bir resim çekin");
    }

    logger.f('Picked image: $pickedImage');

    setState(() {
      files.add(pickedImage);
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

  Future<void> _openBottomSheet() async {
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
                  await _openImagePicker();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Kamerayı Aç"),
                onTap: () async {
                  Navigator.pop(context);
                  await _openCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImages(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: files.isEmpty
            ? [Text("Dosya Bulunamadı")]
            : files
                .map(
                  (file) => Padding(
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
                )
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fotoğraflar (${files.length})",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildImages(context),
        StyledButton(
          variant: Variants.secondary,
          fullWidth: true,
          onPressed: _openBottomSheet,
          child: Text("Fotoğraf Ekle"),
        ),
        StyledButton(
          fullWidth: true,
          isDisabled: files.isEmpty,
          isLoading: _isLoading,
          onPressed: _uploadImage,
          child: Text("Dosya Yükle"),
        ),
      ],
    );
  }
}
