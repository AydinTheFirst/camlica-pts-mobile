import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

void notificationHandler(data) {
  logger.d("Notification received: $data");
  ToastService.info(message: data["body"], title: data["title"]);
}

class WebsocketClient {
  Future<void> connect() async {
    final socket = io(apiUrl.replaceAll("/api", ""), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      "auth": {
        'token': await TokenStorage.getToken(),
      }
    });

    socket.onConnect((_) {
      logger.d("Connected to websocket server");
    });

    socket.onDisconnect((_) {
      logger.d("Disconnected from websocket server");
    });

    socket.on("notification", notificationHandler);
  }
}
