import 'dart:convert';

import 'package:camlica_pts/main.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _BarcodeScannerSimpleState();
}

class ScanResult {
  final bool success;
  final String type;
  final String token;

  ScanResult({
    required this.success,
    required this.type,
    required this.token,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      success: json['success'],
      type: json['type'],
      token: json['token'],
    );
  }
}

class _BarcodeScannerSimpleState extends State<QrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  Barcode? _barcode;
  ScanResult? _scanResult;
  bool _isScanning = false;
  bool _isTorchEnabled = false;

  void torchToggle() {
    _controller.toggleTorch();
    setIsTorchEnabled(!_isTorchEnabled);
  }

  void setIsTorchEnabled(bool value) {
    setState(() {
      _isTorchEnabled = value;
    });
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!mounted) return;

    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode == null) {
      logger.d('Barcode is null.');
      return;
    }

    if (barcode.displayValue != _barcode?.displayValue) {
      setState(() {
        _barcode = barcode;
      });

      _handleScan();
    }
  }

  void _handleScan() {
    final value = _barcode?.displayValue;
    if (value == null) return;

    void sendRequest() async {
      setState(() {
        _isScanning = true;
      });
      final json = jsonDecode(value);
      final type = json['type'];
      final token = json['token'];

      try {
        final res = await HttpService.fetcher("/qrcode/scan/$token");
        setState(() {
          _scanResult = ScanResult.fromJson(
            {"success": true, "type": type, "token": token},
          );
        });
        final isWorking = res["action"] == "checkin";
        ToastService.info(
          message: !isWorking ? "Giriş Başarılı" : "Çıkış Başarılı",
          title: "Başarılı",
        );
      } on DioException catch (e) {
        HttpService.handleError(e);
        setState(() {
          _scanResult = ScanResult.fromJson(
            {"success": false, "type": type, "token": token},
          );
        });
      }

      setState(() {
        _isScanning = false;
      });
    }

    if (value.startsWith("{") &&
        value.endsWith("}") &&
        value.contains("type") &&
        value.contains("token")) {
      sendRequest();
    }
  }

  Widget _buildResult(BuildContext context) {
    if (_scanResult == null) return const Placeholder();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _scanResult!.success ? "İşlem başarılı" : "İşlem başarısız",
          style: TextStyle(
            color: _scanResult!.success ? Colors.green : Colors.red,
            fontSize: 24,
          ),
        ),
        _scanResult!.success
            ? ElevatedButton(
                onPressed: () {
                  Get.toNamed("/tasks");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text("Devam et"),
              )
            : ElevatedButton(
                onPressed: () {
                  setState(() {
                    _scanResult = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text("Tekrar dene"),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qr Kodu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      backgroundColor: _scanResult == null ? Colors.black : Colors.white,
      body: Stack(
        children: [
          if (_isScanning)
            Center(child: CircularProgressIndicator())
          else if (_scanResult == null)
            MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
            )
          else
            Center(child: _buildResult(context)),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                _isTorchEnabled ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
              onPressed: () {
                _controller.toggleTorch();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withAlpha((0.4 * 255).toInt()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
