import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

// Colores de la paleta
const Color darkBlue = Color(0xFF000414);
const Color blueGray = Color(0xFF3B4263);
const Color vibrantBlue = Color(0xFF5055D4);
const Color lightBlue = Color(0xFF61A5E4);
const Color paleBlue = Color(0xFFECF8FF);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RutasAsignadasScreen(),
    );
  }
}

class RutasAsignadasScreen extends StatelessWidget {
  final List<Ruta> rutas = [
    Ruta(prioridad: "Alta", origen: "Calle 3", destino: "Calle 10", tiempo: "30 min", paradas: 3),
    Ruta(prioridad: "Media", origen: "Calle 1", destino: "Calle 8", tiempo: "45 min", paradas: 5),
    Ruta(prioridad: "Baja", origen: "Calle 6", destino: "Calle 12", tiempo: "50 min", paradas: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleBlue,
      appBar: AppBar(
        title: Text(
          "Logix",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: darkBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Rutas Asignadas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: blueGray,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rutas.length,
                itemBuilder: (context, index) {
                  return GlassCard(ruta: rutas[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ruta {
  final String prioridad;
  final String origen;
  final String destino;
  final String tiempo;
  final int paradas;

  Ruta({
    required this.prioridad,
    required this.origen,
    required this.destino,
    required this.tiempo,
    required this.paradas,
  });
}

class GlassCard extends StatelessWidget {
  final Ruta ruta;

  GlassCard({required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [lightBlue.withOpacity(0.3), vibrantBlue.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: vibrantBlue.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prioridad: ${ruta.prioridad}",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text("Origen: ${ruta.origen}", style: TextStyle(color: blueGray, fontSize: 16)),
                Text("Destino: ${ruta.destino}", style: TextStyle(color: blueGray, fontSize: 16)),
                Text("Tiempo Estimado: ${ruta.tiempo}", style: TextStyle(color: blueGray, fontSize: 16)),
                Text("Paradas: ${ruta.paradas}", style: TextStyle(color: blueGray, fontSize: 16)),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vibrantBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetalleRutaScreen(ruta: ruta)),
                    );
                  },
                  child: Center(child: Text("Iniciar Ruta")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetalleRutaScreen extends StatelessWidget {
  final Ruta ruta;

  DetalleRutaScreen({required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleBlue,
      appBar: AppBar(
        title: Text("Detalle de Ruta"),
        backgroundColor: darkBlue,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          "Ruta de ${ruta.origen} a ${ruta.destino}",
          style: TextStyle(color: blueGray, fontSize: 20),
        ),
      ),
    );
  }
}