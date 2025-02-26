import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminPostAddPage extends StatelessWidget {
  const AdminPostAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyuru Ekle'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed("/admin");
          },
        ),
      ),
      body: FormBody(),
    );
  }
}

class FormBody extends ConsumerWidget {
  FormBody({super.key});

  final _formKey = GlobalKey<FormBuilderState>();

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    final formData = Map.from(_formKey.currentState!.value);

    if (formData["validUntil"] != null) {
      formData["validUntil"] =
          "${(formData["validUntil"] as DateTime).toIso8601String()}Z";
    }

    if (formData["relatedUnits"] == null) {
      formData["relatedUnits"] = [];
    }

    logger.d(formData);

    try {
      await HttpService.dio.post("/posts", data: formData);
      ToastService.success(message: "Duyuru gönderildi");
      Future.delayed(Duration(seconds: 1), () {
        Get.toNamed("/admin");
      });
    } on DioException catch (e) {
      HttpService.handleError(e);
    } catch (e) {
      ToastService.error(message: "Bir hata oluştu $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsyncValue = ref.watch(unitsProvider);

    final units = unitsAsyncValue.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(
              "Duyuru Ekle",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FormBuilderTextField(
              name: "title",
              decoration: InputDecoration(
                labelText: "Başlık",
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(3),
              ]),
            ),
            FormBuilderTextField(
              name: "body",
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Açıklama",
                border: OutlineInputBorder(),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(3),
              ]),
            ),
            units == null
                ? CircularProgressIndicator()
                : FormBuilderCheckboxGroup<String>(
                    name: "relatedUnits",
                    decoration: InputDecoration(
                      labelText: "İlgili Birimler",
                    ),
                    options: units
                        .map((unit) => FormBuilderFieldOption(
                              value: unit.id,
                              child: Text(unit.name),
                            ))
                        .toList(),
                  ),
            FormBuilderDateTimePicker(
              name: "validUntil",
              inputType: InputType.date,
              format: DateFormat("yyyy-MM-dd"),
              decoration: InputDecoration(
                labelText: "Geçerlilik Tarihi",
                border: OutlineInputBorder(),
              ),
            ),
            StyledButton(
              onPressed: handleSubmit,
              fullWidth: true,
              child: Text("Gönder"),
            )
          ],
        ),
      ),
    );
  }
}
