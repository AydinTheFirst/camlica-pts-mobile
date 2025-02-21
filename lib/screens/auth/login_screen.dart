import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/screens/auth/twofa_login_screen.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '/services/http_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.saveAndValidate()) return;
    setIsLoading(true);

    final data = _formKey.currentState!.value;

    try {
      await HttpService.dio.post(
        '/auth/login',
        data: data,
      );

      ToastService.success(message: "Doğrulama kodu gönderildi!");

      Get.to(TwoFactorLoginScreen(
        username: data['username'],
        password: data['password'],
      ));
    } on DioException catch (e) {
      HttpService.handleError(
        e,
      );
    }

    setIsLoading(false);
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
              Spacer(),
              FormBuilderTextField(
                name: "username",
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                  helperText: 'Örn: 5551234567',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Lütfen kullanıcı adınızı girin";
                  }

                  return null;
                },
              ),
              FormBuilderTextField(
                  name: "password",
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                    helper: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.toNamed("/forgot-password");
                          },
                          child: Text(
                            'Şifremi unuttum!',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  validator: FormBuilderValidators.password(
                    minLength: 6,
                    errorText: "Şifre en az 6 karakter olmalıdır",
                  )),
              StyledButton(
                isLoading: _isLoading,
                onPressed: _login,
                fullWidth: true,
                child: const Text('Giriş Yap'),
              ),
              Spacer(),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  void openWeb(String path) async {
    final url = Uri.parse("https://camlica-pts.riteknoloji.com$path");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => openWeb("/tos"),
          child: const Text('Kullanım Koşulları'),
        ),
        TextButton(
          onPressed: () => openWeb("/privacy"),
          child: const Text('Gizlilik Politikası'),
        ),
        TextButton(
          onPressed: () => openWeb("/kvkk"),
          child: const Text('KVKK'),
        ),
      ],
    );
  }
}
