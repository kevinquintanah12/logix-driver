import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RutasMap extends StatefulWidget {
  const RutasMap({Key? key}) : super(key: key);

  @override
  State<RutasMap> createState() => _RutasMapState();
}

class _RutasMapState extends State<RutasMap> {
  final String mapboxToken = "pk.eyJ1IjoiZXRlMTIiLCJhIjoiY204c3luNmw1MDVvdTJscHk2MGNsYXZseSJ9.lsWk079QN6p2c80GZTPonQ"; 

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
          center: LatLng(19.0595, -96.7317), // Coordenadas iniciales (Orizaba)
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=$mapboxToken",
            additionalOptions: {
              'accessToken': mapboxToken,
              'id': 'mapbox.streets',
            },
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(19.0595, -96.7317), // Punto de referencia
                builder: (ctx) => const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
