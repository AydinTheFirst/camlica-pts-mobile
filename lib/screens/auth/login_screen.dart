import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/screens/auth/twofa_login_screen.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/http_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await HttpService.dio.post(
        '/auth/login',
        data: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      ToastService.success(message: "Doğrulama kodu gönderildi!");

      Get.to(TwoFactorLoginScreen(
        username: _usernameController.text,
        password: _passwordController.text,
      ));
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

  void _loginAsAdmin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await HttpService.dio.post(
        '/auth/login',
        data: {
          'username': 'admin',
          'password': 'admin',
        },
      );

      ToastService.success(message: "Doğrulama kodu gönderildi!");

      Get.to(TwoFactorLoginScreen(
        username: 'admin',
        password: 'admin',
      ));
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
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
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
              TextFormField(
                controller: _passwordController,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi girin';
                  } else if (value.length < 6) {
                    return 'Şifreniz en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              StyledButton(
                isLoading: _isLoading,
                onPressed: _login,
                fullWidth: true,
                child: const Text('Giriş Yap'),
              ),
              SizedBox(height: 10),
              kDebugMode
                  ? StyledButton(
                      isLoading: _isLoading,
                      onPressed: _loginAsAdmin,
                      fullWidth: true,
                      child: const Text('Admin Olarak Giriş Yap'),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
