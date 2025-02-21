import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

class TwoFactorLoginScreen extends StatefulWidget {
  final String username;
  final String password;

  const TwoFactorLoginScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<TwoFactorLoginScreen> createState() => _TwoFactorLoginScreenState();
}

class _TwoFactorLoginScreenState extends State<TwoFactorLoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    setIsLoading(true);

    final data = _formKey.currentState!.value;

    try {
      final res = await HttpService.dio.post(
        '/auth/login/2fa',
        data: {
          'username': widget.username,
          'password': widget.password,
          'code': data['code'],
          "deviceId": await getDeviceId(),
        },
      );

      TokenStorage.saveToken(res.data['token']);
      ToastService.success(message: "Giriş başarılı");

      Get.offAllNamed("/");
    } on DioException catch (e) {
      HttpService.handleError(
        e,
      );
    }

    setIsLoading(false);
  }

  void handleResend() async {
    try {
      await HttpService.dio.post(
        '/auth/login',
        data: {
          'username': widget.username,
          'password': widget.password,
        },
      );

      ToastService.success(message: "Doğrulama kodu gönderildi!");
    } on DioException catch (e) {
      HttpService.handleError(
        e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              FormBuilderTextField(
                name: 'code',
                decoration: const InputDecoration(
                  labelText: 'Doğrulama Kodu',
                  prefixIcon: Icon(Icons.verified),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Bu alan boş bırakılamaz',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Doğrulama kodu sadece rakamlardan oluşabilir',
                  ),
                  FormBuilderValidators.equalLength(
                    6,
                    errorText: "Doğrulama kodu 6 haneli olmalıdır",
                  ),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: handleResend,
                    child: const Text('Tekrar Gönder'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              StyledButton(
                fullWidth: true,
                isLoading: _isLoading,
                onPressed: handleSubmit,
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
