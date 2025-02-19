import 'dart:convert';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scanTokenProvider = AutoDisposeFutureProvider((ref) async {
  final response = await HttpService.fetcher("/qrcode/token");
  return response;
});

class AdminQrPage extends ConsumerStatefulWidget {
  const AdminQrPage({super.key});

  @override
  ConsumerState<AdminQrPage> createState() => _AdminQrPageState();
}

class _AdminQrPageState extends ConsumerState<AdminQrPage> {
  final ValueNotifier<String> scanToken = ValueNotifier<String>("");

  void setScanToken(String token) {
    scanToken.value = token;
  }

  @override
  Widget build(BuildContext context) {
    final scanTokenAsyncValue = ref.watch(scanTokenProvider);

    scanTokenAsyncValue.whenData((data) {
      setScanToken(data);
    });

    String getQrCode() {
      final data = jsonEncode(
        {"token": scanToken.value, "type": "camlica-pts-token"},
      );
      return "https://api.qrserver.com/v1/create-qr-code/?data=$data";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("QR"),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: scanToken,
        builder: (context, value, child) {
          return Column(
            children: [
              Text("Token: $value"),
              Expanded(
                child: Center(
                  child: Image.network(getQrCode()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    ref.refresh(scanTokenProvider);

    logger.f("Websocket connecting... $socket");

    socket.emit("join", "admins");

    socket.on("token", (data) {
      logger.d("Token received: $data");
      setScanToken(data);
    });
  }

  @override
  void dispose() {
    socket.off("token");
    super.dispose();
  }
}
