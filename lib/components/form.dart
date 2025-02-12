import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class FormPage extends StatelessWidget {
  FormPage({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final data = _formKey.currentState!.value;
    final files = (data["files"] as List<dynamic>).cast<XFile>();

    FormData formData = FormData();

    for (var file in files) {
      String fileName = file.path.split('/').last;
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ));
    }

    final res = await HttpService.dio.post(
      "/files",
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    logger.d("handleSubmit: $res");
    ToastService.success(message: "Dosya yüklendi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              spacing: 8,
              children: [
                FormBuilderImagePicker(
                  name: 'files',
                  decoration: InputDecoration(
                    labelText: "Dosya Yükle",
                    border: InputBorder.none,
                  ),
                ),
                StyledButton(
                  fullWidth: true,
                  onPressed: handleSubmit,
                  child: Text("Gönder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
