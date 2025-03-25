import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dashboard'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDashboardButton(
                icon: CupertinoIcons.map,
                label: 'Rutas',
                onTap: () {
                  // Acción para rutas
                },
              ),
              const SizedBox(height: 30),

              _buildDashboardButton(
                icon: CupertinoIcons.cube_box,
                label: 'Paquetes',
                onTap: () {
                  // Acción para paquetes
                },
              ),
              const SizedBox(height: 30),

              _buildDashboardButton(
                icon: CupertinoIcons.chart_bar,
                label: 'Sensores',
                onTap: () {
                  // Acción para sensores
                },
              ),
            ],
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
              color: Color(0xFF000814), // Midnight Black
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

