import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RutasMap extends StatefulWidget {
  const RutasMap({super.key});

  @override
  State<RutasMap> createState() => _RutasMapState();
}

class _RutasMapState extends State<RutasMap> {
  final String mapboxToken = "pk.eyJ1IjoiZXRlMTIiLCJhIjoiY204c3luNmw1MDVvdTJscHk2MGNsYXZseSJ9.lsWk079QN6p2c80GZTPonQ";
  List<Marker> paqueteMarkers = [];

  void _agregarPaquete() {
    final nombreController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Paquete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del paquete'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Agregar'),
              onPressed: () {
                final nombre = nombreController.text.trim();
                final lat = double.tryParse(latController.text.trim());
                final lng = double.tryParse(lngController.text.trim());

                if (nombre.isNotEmpty && lat != null && lng != null) {
                  setState(() {
                    paqueteMarkers.add(
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(lat, lng),
                        builder: (ctx) => Column(
                          children: [
                            const Icon(Icons.local_shipping, color: Colors.blue, size: 35),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                              child: Text(nombre, style: const TextStyle(fontSize: 12, color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, ingresa datos válidos")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(19.0595, -96.7317),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=$mapboxToken",
            additionalOptions: {
              'accessToken': mapboxToken,
              'id': 'mapbox.streets',
            },
          ),
          MarkerLayer(
            markers: paqueteMarkers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarPaquete,
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}