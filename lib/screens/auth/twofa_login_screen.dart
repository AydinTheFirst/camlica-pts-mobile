import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await HttpService.dio.post(
        '/auth/login/2fa',
        data: {
          'username': widget.username,
          'password': widget.password,
          "code": _codeController.text,
        },
      );

      TokenStorage.saveToken(res.data['token']);
      ToastService.success(message: "Giriş başarılı");

      Get.offAllNamed("/");
    } on DioException catch (e) {
      HttpService.handleError(
        e,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Doğrulama Kodu',
                  prefixIcon: Icon(Icons.verified),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen doğrulama kodunu girin';
                  } else if (value.length != 6) {
                    return 'Doğrulama kodu 6 karakter olmalıdır';
                  }
                  return null;
                },
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
