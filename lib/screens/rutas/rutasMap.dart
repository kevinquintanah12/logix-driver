import 'package:flutter/material.dart';

class RutasMap extends StatefulWidget {
  const RutasMap({Key? key}) : super(key: key);

  @override
  State<RutasMap> createState() => _RutasMapState();
}

class _RutasMapState extends State<RutasMap> {
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Ruta en Mapa'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Contenedor donde irá el mapa de Mapbox
          Expanded(
            child: Container(
              color: Colors.grey[300], // Temporal para visualizar la zona del mapa
              child: const Center(
                child: Text(
                  'Aquí irá el mapa de Mapbox',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
