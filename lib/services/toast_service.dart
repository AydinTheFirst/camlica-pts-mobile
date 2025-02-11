import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastService {
  static void show(GetSnackBar snackbar) {
    Get.closeAllSnackbars();

    Get.showSnackbar(GetSnackBar(
      title: snackbar.title ?? "Hata!",
      message: snackbar.message ?? "Bir hata oluştu.",
      duration: snackbar.duration ?? const Duration(seconds: 3),
      backgroundColor: snackbar.backgroundColor,
      snackPosition: SnackPosition.BOTTOM,
      icon: snackbar.icon ?? Icon(Icons.info, color: Colors.white),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
    ));
  }

  static void info({
    String? title,
    required String message,
  }) {
    show(GetSnackBar(
      title: "Bilgi",
      message: message,
      backgroundColor: Colors.blue,
      icon: Icon(Icons.info, color: Colors.white),
    ));
  }

  static void error({
    String? title,
    required String message,
  }) {
    show(GetSnackBar(
      title: title ?? "Hata!",
      message: message,
      backgroundColor: Colors.red,
      icon: Icon(Icons.error, color: Colors.white),
    ));
  }

  static void success({
    String? title,
    required String message,
  }) {
    show(GetSnackBar(
      title: title ?? "Başarılı!",
      message: message,
      backgroundColor: Colors.green,
      icon: Icon(Icons.check, color: Colors.white),
    ));
  }

  static void warning({
    String? title,
    required String message,
  }) {
    show(GetSnackBar(
      title: title ?? "Uyarı!",
      message: message,
      backgroundColor: Colors.orange,
      icon: Icon(Icons.warning, color: Colors.white),
    ));
  }

  static void custom(GetSnackBar snackbar) {
    show(snackbar);
  }
}
