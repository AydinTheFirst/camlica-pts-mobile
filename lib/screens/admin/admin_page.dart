import 'package:camlica_pts/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  Future<void> openWeb(String path) async {
    const frontend = "https://camlica-pts.riteknoloji.com";
    final url = Uri.parse("$frontend$path");

    if (!await canLaunchUrl(url)) {
      ToastService.error(message: "Tarayıcı açılamadı");
    }

    launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Admin"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Column(
          children: [
            ListTile(
              leading: Icon(Icons.qr_code),
              title: Text("QR Kod"),
              onTap: () {
                Get.toNamed("/admin/qr");
              },
            ),
            ListTile(
              trailing: Icon(Icons.add),
              leading: Icon(Icons.post_add),
              title: Text("Duyuru Ekle"),
              onTap: () {
                Get.toNamed("/admin/post-add");
              },
            ),
            ListTile(
              trailing: Icon(Icons.add),
              leading: Icon(Icons.notifications),
              title: Text("Bildirim Ekle"),
              onTap: () {
                Get.toNamed("/admin/notification-add");
              },
            ),
            ListTile(
              trailing: Icon(Icons.add),
              leading: Icon(Icons.task),
              title: Text("Görev Ekle"),
              onTap: () {
                Get.toNamed("/admin/task-add");
              },
            ),
            ListTile(
              trailing: Icon(Icons.open_in_browser),
              leading: Icon(Icons.person_add),
              title: Text("Kullanıcı Ekle"),
              onTap: () => openWeb("/dashboard/users/add"),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Anasayfa"),
              onTap: () {
                Get.toNamed("/");
              },
            ),
          ],
        ));
  }
}
