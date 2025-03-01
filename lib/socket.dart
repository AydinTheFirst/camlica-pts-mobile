import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

void notificationHandler(data) {
  logger.d("Notification received: $data");
  Get.dialog(AlertDialog(
    title: Text(data["title"]),
    content: Text(data["body"]),
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text("OK"),
      ),
    ],
  ));
}

Socket socket = io(apiUrl.replaceAll("/api", ""), <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

class WebsocketClient {
  static void connect() {
    socket.onConnect((_) async {
      logger.d("Connected to websocket server");

      socket.emit("auth", await TokenStorage.getToken());
    });

    socket.onDisconnect((_) {
      logger.d("Disconnected from websocket server");
    });

    socket.connect();
  }
}
