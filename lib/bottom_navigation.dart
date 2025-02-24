import 'package:camlica_pts/components/badges.dart';
import 'package:camlica_pts/screens/notifications_page.dart';
import 'package:flutter/material.dart';

import 'screens/qr_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  final String currentKey;

  const BottomNavigation({super.key, required this.currentKey});

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  String _currentKey = 'home';

  final _pages = [
    {
      "label": "Duyurular",
      "key": "home",
      "page": HomeScreen(),
      "icon": PostsBadge()
    },
    {
      "label": "Bildirimler",
      "key": "notifications",
      "page": NotificationsPage(),
      "icon": NotificationsBadge()
    },
    {
      "label": "Görevler",
      "key": "tasks",
      "page": TasksScreen(),
      "icon": TasksBadge()
    },
    {
      "label": "Qr Kod",
      "key": "qr",
      "page": QrScreen(),
      "icon": Icon(Icons.qr_code)
    },
    {
      "label": "Profil",
      "key": "profile",
      "page": ProfileScreen(),
      "icon": Icon(Icons.person)
    }
  ];

  @override
  void initState() {
    super.initState();
    _currentKey = widget.currentKey;
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex =
        _pages.indexWhere((element) => element['key'] == _currentKey);

    void handleTap(int index) {
      setState(() {
        _currentKey = _pages[index]['key'] as String;
      });
    }

    return Scaffold(
      body: _pages[currentIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: handleTap,
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
