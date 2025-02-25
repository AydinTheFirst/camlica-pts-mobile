import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _forgotPassword() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() {
      _isLoading = true;
    });

    final formData = _formKey.currentState!.value;

    try {
      await HttpService.dio.post(
        '/auth/forget-password',
        data: formData,
      );

      ToastService.success(
        message:
            "Şifre sıfırlama bağlantısı e-posta adresinize veya sms olarak gönderildi",
      );

      await Future.delayed(Duration(seconds: 3));
      Get.toNamed("/login");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifremi unuttum'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormBuilderTextField(
                name: "query",
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  helperText: "Örn: 5551234567",
                ),
              ),
              const SizedBox(height: 16),
              StyledButton(
                onPressed: _forgotPassword,
                isLoading: _isLoading,
                fullWidth: true,
                child: const Text('Şifremi sıfırla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
