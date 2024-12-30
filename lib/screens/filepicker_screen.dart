import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/main.dart';
import '/services/http_service.dart';

class FilepickerScreen extends StatefulWidget {
  const FilepickerScreen({super.key});

  @override
  State<FilepickerScreen> createState() => _FilepickerScreenState();
}

class _FilepickerScreenState extends State<FilepickerScreen> {
  // This is the file that will be used to store the image
  List<File> files = [];

  // This is the image picker
  final _picker = ImagePicker();

  // Implementing the image picker
  Future<void> _openImagePicker() async {
    final List<XFile> pickedImages =
        await _picker.pickMultiImage(requestFullMetadata: true);

    if (pickedImages.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Dosya Seçmediniz")));
      return;
    }

    setState(() {
      files = pickedImages.map((f) => File(f.path)).toList();
    });
  }

  // Function to upload the image
  Future<void> _uploadImage() async {
    if (files.isEmpty) {
      // Kullanıcı bir resim seçmemişse hata döndür
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir resim seçin")),
      );
      return;
    }

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

      logger.f(response.data);

      // Başarılı sonuç
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dosya başarıyla yüklendi!")),
        );
      }
    } on DioException catch (e) {
      // Hata durumunda mesaj göster
      HttpService.handleError(
        e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosya Yükleme'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Column(
            children: [
              Center(
                // this button is used to open the image picker
                child: ElevatedButton(
                  onPressed: _openImagePicker,
                  child: const Text('Resim Seç'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('Resmi Yükle'),
              ),
              const SizedBox(height: 35),
              // The picked image will be displayed here
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: files.isNotEmpty
                    ? Column(
                        children: [
                          ...files.map((file) => Image.file(
                                file,
                                height: 100,
                                fit: BoxFit.contain,
                              )),
                        ],
                      )
                    : const Text('Lütfen bir resim seçin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
