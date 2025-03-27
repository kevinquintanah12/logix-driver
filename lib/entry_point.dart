import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop/route/screen_export.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const ConfiguracionPage(),
    const DashboardPage(),
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
          
        ],
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: CupertinoColors.systemGrey,
      ),
    );
  }
}
