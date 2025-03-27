import 'package:flutter/material.dart';

class RutaDetallada extends StatefulWidget {
  const RutaDetallada({Key? key}) : super(key: key);

  @override
  State<RutaDetallada> createState() => _RutaDetalladaState();
}

class _RutaDetalladaState extends State<RutaDetallada> {
  // Valores iniciales para los sensores
  double temperature = 20.0; // Rango: 0 a 50°C
  double humidity = 50.0;    // Rango: 0 a 100%

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
      // Usamos un Stack para superponer el panel de sensores sobre el mapa
      body: Stack(
        children: [
          // Mapa de Mapbox (placeholder) ocupa toda la pantalla
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
            child: const Center(
              child: Text(
                'Aquí irá el mapa de Mapbox',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
            ),
          ),
          // Panel de información, sensores y clima, ubicado en el lateral
          Positioned(
            right: 16,
            top: 100,
            bottom: 100,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
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
                    // Datos de la ruta (opcional)
                    const Text(
                      'Datos de la Ruta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Origen, destino y tiempos estimados.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    // Termómetro digital para la temperatura
                    Text(
                      'Temp: ${temperature.toStringAsFixed(1)} °C',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Slider(
                      value: temperature,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      // Simula un gradiente de frío (azul) a caliente (rojo)
                      activeColor: Colors.red,
                      inactiveColor: Colors.blue,
                      onChanged: (value) {
                        setState(() {
                          temperature = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Higrómetro digital para la humedad
                    Text(
                      'Hum: ${humidity.toStringAsFixed(1)} %',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Slider(
                      value: humidity,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      // De seco (naranja) a húmedo (azul claro)
                      activeColor: Colors.lightBlueAccent,
                      inactiveColor: Colors.orangeAccent,
                      onChanged: (value) {
                        setState(() {
                          humidity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Información del clima
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wb_sunny, size: 20, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Soleado, 25°C',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Botón para iniciar el viaje
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Acción para iniciar el viaje
                      },
                      child: const Text(
                        'Iniciar viaje',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
