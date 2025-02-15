import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void handleMessage(RemoteMessage message) {
  logger.d("Firebase message recieved: $message");
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  logger.d("Firebase message recieved in background: $message");
}

class FirebaseApi {
  final _messaging = FirebaseMessaging.instance;

  void handleToken(String token) async {
    await HttpService.dio.post("/auth/firebase", data: {"token": token});
    logger.d("Firebase token updated: $token");
  }

  Future<void> init() async {
    await _messaging.requestPermission();

    // Token refresh
    await _messaging.getToken().then((token) => handleToken(token ?? ""));
    _messaging.onTokenRefresh.listen(handleToken);

    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
