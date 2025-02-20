import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _forgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await HttpService.dio.post(
        '/auth/forget-password',
        data: {
          'query': _queryController.text,
        },
      );
      ToastService.success(
          message:
              "Şifre sıfırlama bağlantısı e-posta adresinize veya sms olarak gönderildi");

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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _queryController,
                decoration: const InputDecoration(
                    labelText: 'Telefon Numarası',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    helper: Row(
                      spacing: 10,
                      children: [
                        Icon(Icons.info, size: 16),
                        Flexible(
                          child: Text(
                            'Şifre sıfırlama bağlantısı telefon numaranıza gönderildi.',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _forgotPassword,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      child: const Text('Şifremi sıfırla'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
