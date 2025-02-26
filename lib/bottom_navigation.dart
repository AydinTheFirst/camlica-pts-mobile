import 'package:camlica_pts/components/badges.dart';
import 'package:camlica_pts/screens/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/qr_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key});

  final _pages = [
    {
      "label": "Duyurular",
      "key": "/",
      "page": HomeScreen(),
      "icon": PostsBadge()
    },
    {
      "label": "Bildirimler",
      "key": "/notifications",
      "page": NotificationsPage(),
      "icon": NotificationsBadge()
    },
    {
      "label": "Görevler",
      "key": "/tasks",
      "page": TasksScreen(),
      "icon": TasksBadge()
    },
    {
      "label": "Qr Kod",
      "key": "/qr",
      "page": QrScreen(),
      "icon": Icon(Icons.qr_code)
    },
    {
      "label": "Profil",
      "key": "/profile",
      "page": ProfileScreen(),
      "icon": Icon(Icons.person)
    }
  ];

  @override
  Widget build(BuildContext context) {
    String currentRoute = Get.currentRoute;

    int currentIndex = _pages.indexWhere((page) => page['key'] == currentRoute);

    return Scaffold(
      body: _pages[currentIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          String selectedRoute = _pages[index]['key'] as String;
          Get.offAllNamed(selectedRoute); // Sayfayı değiştir, geçmişi temizle
        },
        items: _pages
            .map(
              (page) => BottomNavigationBarItem(
                icon: page['icon'] as Widget,
                label: page['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }
}
