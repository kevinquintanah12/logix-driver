import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop/route/screen_export.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SettingsPage(),
    DashboardPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: "Configuración",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: "Perfil",
          ),
        ],
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: CupertinoColors.systemGrey,
      ),
    );
  }
}
