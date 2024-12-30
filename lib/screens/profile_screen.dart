import 'package:camlica_pts/models/user_model.dart';
import 'package:camlica_pts/providers.dart';
import 'package:camlica_pts/components/styled_button.dart';
import 'package:camlica_pts/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:get/get.dart';

class ProfileScreen extends HookWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ProfileCard(),
    );
  }
}

class ProfileCard extends HookWidget {
  const ProfileCard({super.key});

  void onLogout(BuildContext context) {
    TokenStorage.deleteToken();
    Get.toNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    final user = useQuery(["user"], getProfile);

    if (user.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (user.error != null) {
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
                    if (userData.birthDate != null)
                      _buildRow("Doğum Tarihi", userData.birthDate.toString()),
                    StyledButton(
                      onPressed: () => onLogout(context),
                      variant: Variants.danger,
                      child: const Text("Çıkış Yap"),
                    )
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
