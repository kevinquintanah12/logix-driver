import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dashboard'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              // Si deseas centrar verticalmente cuando haya espacio extra,
              // puedes ajustar mainAxisAlignment o envolver en un Container de altura fija.
              children: [
                const SizedBox(height: 50),
                _buildDashboardButton(
                  icon: CupertinoIcons.map,
                  label: 'Rutas',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, rutasAsignadas);
                  },
                ),
                const SizedBox(height: 30),
                _buildDashboardButton(
                  icon: CupertinoIcons.cube_box,
                  label: 'Paquetes',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, paquetes);
                  },
                ),
                const SizedBox(height: 30),
                _buildDashboardButton(
                  icon: CupertinoIcons.person_fill,
                  label: 'Perfil',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, dashboardRoute );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF000814), // Midnight Black
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C365E), // Slate Blue
            ),
          ),
        ],
      ),
    );
  }
}
