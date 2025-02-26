import 'dart:async';
import 'dart:convert';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/socket.dart';
import 'package:camlica_pts/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* final scanTokenProvider = AutoDisposeFutureProvider((ref) async {
  final response = await HttpService.fetcher("/qrcode/token");
  return response;
}); */

class AdminQrPage extends StatefulWidget {
  const AdminQrPage({super.key});

  @override
  State<AdminQrPage> createState() => _AdminQrPageState();
}

class _AdminQrPageState extends State<AdminQrPage> {
  String scanToken = "";
  DateTime lastUpdatedAt = DateTime.now();

  void handleTokenUpdate(String token) {
    setScanToken(token);
    setLastUpdatedAt();
  }

  void setScanToken(String token) {
    setState(() {
      scanToken = token;
    });
  }

  void setLastUpdatedAt() {
    setState(() {
      lastUpdatedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    String getQrCode() {
      final data = jsonEncode(
        {"token": scanToken, "type": "camlica-pts-token"},
      );
      return "https://api.qrserver.com/v1/create-qr-code/?data=$data";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("QR"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed("/admin");
          },
        ),
      ),
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "QR Kodu ile Giriş/Çıkış Yap",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            scanToken.isEmpty
                ? CircularProgressIndicator()
                : Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(getQrCode()),
                    ),
                  ),
            Text(
              "Token: $scanToken",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Text(
              "Son Güncelleme: ${formatTime(lastUpdatedAt)}",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Clock(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    socket.emit("join", "admins");

    socket.on("token", (data) {
      logger.d("Token received: $data");
      handleTokenUpdate(data);
    });
  }

  @override
  void dispose() {
    socket.off("token");
    super.dispose();
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime now = DateTime.now();
  Timer? timer;

  void setNow() {
    setState(() {
      now = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setNow();
    });
  }

  @override
  void dispose() {
    super.dispose();

    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatFullDate(now),
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
