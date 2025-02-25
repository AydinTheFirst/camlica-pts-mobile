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

class AdminNotificationAddPage extends StatelessWidget {
  const AdminNotificationAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ekle'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

    final formData = _formKey.currentState?.value;

    if (formData == null) {
      ToastService.error(message: "Form verileri alınamadı");
      return;
    }

    logger.d(formData);

    try {
      await HttpService.dio.post("/notifications", data: {
        ...formData,
        "type": "INFO",
      });
      ToastService.success(message: "Bildirim gönderildi");
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
    final usersAsyncValue = ref.watch(usersProvider);

    final users = usersAsyncValue.maybeWhen(
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
              "Bildirim Ekle",
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
            users == null
                ? CircularProgressIndicator()
                : FormBuilderDropdown(
                    name: "userId",
                    decoration: InputDecoration(
                      labelText: "Kullanıcı",
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    initialValue: users[0].id,
                    items: users.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text("${user.firstName} ${user.lastName}"),
                      );
                    }).toList()),
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
