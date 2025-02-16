import 'package:camlica_pts/screens/logs_screen.dart';
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

  final List<Map<String, Widget>> _screens = [
    {'home': HomeScreen()},
    {'tasks': TasksScreen()},
    {'qr': QrScreen()},
    {'logs': LogsScreen()},
    {'profile': ProfileScreen()},
  ];

  @override
  void initState() {
    super.initState();
    _currentKey = widget.currentKey;
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex =
        _screens.indexWhere((element) => element.keys.first == _currentKey);

    void handleTap(int index) {
      setState(() {
        _currentKey = _screens[index].keys.first;
      });
    }

    return Scaffold(
      body: _screens[currentIndex].values.first,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: handleTap,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Qr Kod',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Kayıtlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
