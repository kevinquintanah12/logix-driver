import 'package:flutter/material.dart';

import '../constants.dart';


class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.inActiveColor,
    this.activeColor = primaryColor,
    this.size = 16.0, // Nuevo parámetro para tamaño
  });

  final bool isActive;
  final Color? inActiveColor, activeColor;
  final double size; // Tamaño personalizable

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: defaultDuration,
      height: isActive ? 12 : 4,
      width: 10,
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : inActiveColor ?? primaryMaterialColor.shade100,
      ),
    );
  }
}