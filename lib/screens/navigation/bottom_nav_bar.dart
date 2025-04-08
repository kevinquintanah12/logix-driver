import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GNav(
        gap: 8, // Espaciado entre icono y texto
        activeColor: Colors.blueAccent, // Color activo
        color: Colors.grey, // Color inactivo
        iconSize: 24, // Tamaño de los iconos
        // ignore: deprecated_member_use
        tabBackgroundColor: Colors.blueAccent.withOpacity(0.2), // Fondo activo
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding interno de los tabs
        duration: const Duration(milliseconds: 400), // Animación
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Inicio',
          ),
          GButton(
            icon: Icons.search,
            text: 'Buscar',
          ),
          GButton(
            icon: Icons.person,
            text: 'Perfil',
            iconSize: 40, // Resaltar el ícono del perfil
          ),
        ],
        selectedIndex: widget.currentIndex,
        onTabChange: widget.onTap,
      ),
    );
  }
}
