import 'dart:io';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void handleForegroundMessage(RemoteMessage message) {
  logger.d("Firebase message received in foreground: $message");

  if (Get.isDialogOpen ?? false) {
    Get.back();
  }

  Get.dialog(
    AlertDialog(
      title: Text(message.notification?.title ?? ""),
      content: Text(message.notification?.body ?? ""),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("OK"),
        ),
      ],
    ),
  );

  globalRef?.invalidate(notificationsProvider);
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  logger.d("Firebase message received in background: $message");
}

void handleMessagePressed(RemoteMessage message) {
  logger.d("Firebase message pressed: $message");
  globalRef?.invalidate(notificationsProvider);
}

class FirebaseApi {
  final _messaging = FirebaseMessaging.instance;

  void handleToken(String token) async {
    try {
      await HttpService.dio.post("/auth/firebase", data: {"token": token});
      logger.d("Firebase token updated: $token");
    } on DioException catch (e) {
      logger.e("Firebase token update failed: ${e.message}");
    }
  }

  Future<void> init() async {
    await _messaging.requestPermission();

    // **📌 APNs token alınana kadar bekle**
    String? apnsToken;
    // if ios
    final isDarwin = Platform.isMacOS || Platform.isIOS;
    while (apnsToken == null && isDarwin) {
      apnsToken = await _messaging.getAPNSToken();
      await Future.delayed(const Duration(seconds: 1));
    }
    logger.d("APNs token received: $apnsToken");

    // **📌 Firebase token'ı APNs token geldikten sonra al**
    String? fcmToken = await _messaging.getToken();
    handleToken(fcmToken ?? "");

    _messaging.onTokenRefresh.listen(handleToken);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessagePressed);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
