import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'dart:async';

final myPosition = LatLng(18.857515, -97.072451);

final List<LatLng> routeCoordinates = [
  LatLng(18.857515, -97.072451), // Punto de inicio: Orizaba
  LatLng(18.8579468248985, -97.07179314427863),
  LatLng(18.85844781912303, -97.0705201486615),
  LatLng(18.858722094056237, -97.0687307519206),
  LatLng(18.860736076082095, -97.06905694027886),
  LatLng(18.864624860916802, -97.06876172055576),
  LatLng(18.868993662664966, -97.0654967010371),
  LatLng(18.876521, -97.059178),
  LatLng(18.883339, -97.051607),
  LatLng(18.893695, -97.042668),
  LatLng(18.904213, -97.032070),
  LatLng(18.906457, -97.027031),
  LatLng(18.907133744911103, -97.02505575656856),
  LatLng(18.907897, -97.025283),
  LatLng(18.909242, -97.024436),
  LatLng(18.909874, -97.024553),
  LatLng(18.911445, -97.025031),
  LatLng(18.913205, -97.026050),
  LatLng(18.913989, -97.026420),
  LatLng(18.914985, -97.026815), // Punto final: Ixtaczoquitlán
];

LatLng currentTruckPosition = routeCoordinates[0];
int currentTripIndex = 0;
/*

//ESTE SE USA PARA QUE MAPBOX CALCULE LA RUTA, PERO AHORITA ESTA HARCODEADO ASI QUE NO LO NECESITAS PORQUE TE VA A DAR MUCHOS RECORRIDOS
Future<List<LatLng>> getRouteFromMapbox() async {
  const String accessToken =
      'pk.eyJ1IjoiZGF5a2V2MTIiLCJhIjoiY204MTd5NzR3MGdxYTJqcGlsa29odnQ5YiJ9.tbAEt453VxfJoDatpU72YQ';
  final String url =
      "https://api.mapbox.com/directions/v5/mapbox/driving/${routeCoordinates.map((coord) => '${coord.longitude},${coord.latitude}').join(';')}?geometries=geojson&access_token=$accessToken";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> coordinates =
        data['routes'][0]['geometry']['coordinates'];

    return coordinates
        .map((coord) => LatLng(coord[1], coord[0]))
        .toList(); // Convertimos a lista de LatLng
  } else {
    throw Exception('Error al obtener la ruta');
  }
}*/

class RutaDetallada extends StatefulWidget {
  const RutaDetallada({super.key});

  @override
  State<RutaDetallada> createState() => _RutaDetalladaState();
}

class _RutaDetalladaState extends State<RutaDetallada> {
  final String mapboxAccessToken =
      'pk.eyJ1IjoiZGF5a2V2MTIiLCJhIjoiY204MTd5NzR3MGdxYTJqcGlsa29odnQ5YiJ9.tbAEt453VxfJoDatpU72YQ';

  double temperature = 20.0;
  double humidity = 50.0;

  late MapController mapController;
  Timer? simulationTimer;
  List<LatLng> polylinePoints = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    _initializeRoute();
  }

  void _initializeRoute() async {
    polylinePoints = routeCoordinates;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Ruta Detallada'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(center: myPosition, zoom: 15.0),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=$mapboxAccessToken",
                additionalOptions: {
                  'accessToken': mapboxAccessToken,
                  'id': 'mapbox.streets',
                },
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color:
                        const Color.fromARGB(255, 70, 79, 105).withOpacity(0.7),
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Marcador del camión
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: currentTruckPosition,
                    builder: (ctx) => const Icon(
                      Icons.local_shipping,
                      color: Color.fromARGB(255, 22, 107, 204),
                      size: 20,
                    ),
                  ),

                  // Marcador del punto de partida
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: routeCoordinates[0], // Punto inicial
                    builder: (ctx) => const Icon(
                      Icons.place,
                      color: Color.fromARGB(255, 61, 61, 61),
                      size: 20,
                    ),
                  ),

                  // Marcador del punto de llegada
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: routeCoordinates.last, // Punto final
                    builder: (ctx) => const Icon(
                      Icons.place,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            top: 100,
            bottom: 100,
            child: _buildSensorPanel(),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor:
                  const Color(0xFF0B3C5D), // Mismo color que tu tema
              onPressed: _centerOnTruck,
              child: const Icon(Icons.gps_fixed, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Panel lateral con sensores
  Widget _buildSensorPanel() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Datos de la Ruta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Origen, destino y tiempos estimados.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            _buildTemperatureSlider(),
            const SizedBox(height: 16),
            _buildHumiditySlider(),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 20, color: Colors.orange),
                SizedBox(width: 4),
                Text('Soleado, 25°C', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B3C5D),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                _startSimulation();
              },
              child:
                  const Text('Iniciar viaje', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// Control de temperatura
  Widget _buildTemperatureSlider() {
    return Column(
      children: [
        Text('Temp: ${temperature.toStringAsFixed(1)} °C',
            style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
        Slider(
          value: temperature,
          min: 0,
          max: 50,
          divisions: 50,
          activeColor: Colors.red,
          inactiveColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              temperature = value;
            });
          },
        ),
      ],
    );
  }

  /// Control de humedad
  Widget _buildHumiditySlider() {
    return Column(
      children: [
        Text('Hum: ${humidity.toStringAsFixed(1)} %',
            style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
        Slider(
          value: humidity,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: Colors.lightBlueAccent,
          inactiveColor: Colors.orangeAccent,
          onChanged: (value) {
            setState(() {
              humidity = value;
            });
          },
        ),
      ],
    );
  }

  void _startSimulation() {
    if (polylinePoints.isEmpty) return;

    simulationTimer?.cancel();
    currentTripIndex = 0; 
    currentTruckPosition =
        polylinePoints[currentTripIndex]; 
    setState(() {});

    simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTripIndex < polylinePoints.length - 1) {
        currentTripIndex++;
        setState(() {
          currentTruckPosition = polylinePoints[currentTripIndex];
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _centerOnTruck() {
    if (!mounted) return;
    final LatLng start = mapController.center; 
    final LatLng end = currentTruckPosition; 

    const int steps = 30; 
    const Duration stepDuration =
        Duration(milliseconds: 20); 

    int currentStep = 0;

    Timer.periodic(stepDuration, (timer) {
      if (currentStep >= steps) {
        timer.cancel(); 
      } else {
        double t = currentStep / steps; 
        double lat = _lerp(start.latitude, end.latitude, t);
        double lng = _lerp(start.longitude, end.longitude, t);

        mapController.move(
            LatLng(lat, lng), mapController.zoom); 

        currentStep++;
      }
    });
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
