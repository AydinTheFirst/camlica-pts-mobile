import 'dart:io';

import 'package:camlica_pts/models/enums.dart';
import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/services/http_service.dart';
import 'package:camlica_pts/services/toast_service.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String appVersion = "";
  String webVersion = "";

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }

  void _fetchAppVersion() async {
    final pkg = await PackageInfo.fromPlatform();
    final info = await HttpService.fetcher("/");
    setState(() {
      appVersion = pkg.version;
      webVersion = info["version"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ProfileCard(
        appVersion: appVersion,
        webVersion: webVersion,
      ),
    );
  }
}

class ProfileCard extends HookWidget {
  final String appVersion;
  final String webVersion;

  const ProfileCard({
    super.key,
    required this.appVersion,
    required this.webVersion,
  });

  void onLogout(BuildContext context) {
    TokenStorage.deleteToken();
    Get.offAllNamed("/login");
  }

  void getSupport(User user) async {
    const phoneNumber = '+905434989203'; // Replace with your support number
    final message = [
      "Merhaba desteğe ihtiyacım var",
      "Adım: ${user.firstName} ${user.lastName.toUpperCase()}",
      "Numaram: ${user.phone ?? "-"}",
      "Platform: ${Platform.operatingSystem}",
      "Uygulama Sürümü: $appVersion",
      "Sunucu Sürümü: $webVersion",
    ].join("\n");

    final whatsappUrl = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      ToastService.error(message: "WhatsApp uygulaması bulunamadı");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = useQuery(["user"], getProfile);

    if (user.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (user.isError) {
      return Center(child: Text("Bir hata oluştu: ${user.error}"));
    }

    if (user.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text("Kullanıcı bilgileri bulunamadı"),
                    SizedBox(height: 10),
                    Text(
                      "Lütfen tekrar giriş yapın",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
              StyledButton(
                onPressed: () => Get.toNamed("/login"),
                child: const Text("Giriş Yap"),
              ),
            ],
          ),
        ),
      );
    }

    final userData = user.data as User;
    final bool isAdmin = userData.roles.contains(UserRole.ADMIN);

    return RefreshIndicator(
      onRefresh: () async {
        return user.refetch();
      },
      child: ListView(
        children: [
          Center(
            child: Card(
              margin: const EdgeInsets.all(20),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 20,
                  children: [
                    _buildRow("Ad", userData.firstName),
                    _buildRow("Soyad", userData.lastName),
                    _buildRow("Email", userData.email),
                    _buildRow("Telefon", userData.phone ?? "-"),
                    _buildRow("Web Versiyon", webVersion),
                    _buildRow("App Versiyon", appVersion),
                    if (userData.birthDate != null)
                      _buildRow("Doğum Tarihi", userData.birthDate.toString()),
                    isAdmin
                        ? StyledButton(
                            fullWidth: true,
                            onPressed: () => onLogout(context),
                            variant: Variants.danger,
                            child: const Text("Çıkış Yap"),
                          )
                        : SizedBox.shrink(),
                    StyledButton(
                      fullWidth: true,
                      onPressed: () => getSupport(userData),
                      variant: Variants.success,
                      child: Text("Destek Al"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Yardımcı fonksiyon: Satırdaki metinleri dinamik şekilde oluşturur
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
