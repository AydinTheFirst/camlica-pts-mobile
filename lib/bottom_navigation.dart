import 'package:camlica_pts/screens/logs_screen.dart';
import 'package:flutter/material.dart';

import 'screens/qr_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    TasksScreen(),
    QrScreen(),
    LogsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
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
