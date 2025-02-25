import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/task_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TaskFileUploader extends ConsumerStatefulWidget {
  final Task task;

  const TaskFileUploader({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<TaskFileUploader> createState() => _TaskFileUploaderState();
}

class _TaskFileUploaderState extends ConsumerState<TaskFileUploader> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setIsLoading(true);

    final data = _formKey.currentState!.value;
    if (data["files"] != null) {
      final uploadedFiles = await HttpService.uploadFiles(data["files"]);

      if (uploadedFiles.isEmpty) {
        setIsLoading(false);
        return;
      }

      try {
        await HttpService.dio.patch(
          "/tasks/${widget.task.id}",
          data: {
            "files": [...widget.task.files, ...uploadedFiles],
            "status": TaskStatus.DONE.name,
          },
        );
        ToastService.success(message: "Görev başarıyla güncellendi!");
        ref.invalidate(tasksProvider);
      } on DioException catch (e) {
        HttpService.handleError(e);
      }
    }

    setIsLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
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
            validator: FormBuilderValidators.compose(
              [FormBuilderValidators.required()],
            ),
          ),
          StyledButton(
            fullWidth: true,
            isLoading: _isLoading,
            onPressed: handleSubmit,
            child: Text("Dosyaları yükle ve Bitir"),
          ),
        ],
      ),
    );
  }
}
