import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:latlong2/latlong.dart';

class RutasMap extends StatefulWidget {
  const RutasMap({super.key});

  @override
  State<RutasMap> createState() => _RutasMapState();
}

class _RutasMapState extends State<RutasMap> {
  final String mapboxToken =
      "pk.eyJ1IjoiZXRlMTIiLCJhIjoiY204c3luNmw1MDVvdTJscHk2MGNsYXZseSJ9.lsWk079QN6p2c80GZTPonQ";
  List<Marker> paqueteMarkers = [];

  final String rutasQuery = """
    query (\$estado: String!) {
      rutasPorEstado(estado: \$estado) {
        id
        entregas {
          id
          paquete {
            producto {
              destinatario {
                id
                latitud
                longitud
              }
            }
          }
        }
      }
    }
  """;

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
      body: Query(
        options: QueryOptions(
          document: gql(rutasQuery),
          variables: {
            'estado': 'por hacer', // Aquí se mantiene el estado correcto
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(child: Text("Error: ${result.exception.toString()}"));
          }

          final rutas = result.data?['rutasPorEstado'] ?? [];
          print("Datos obtenidos de rutas: $rutas");

          paqueteMarkers.clear();

          if (rutas is List) {
            for (var ruta in rutas) {
              final entregas = ruta['entregas'];
              if (entregas != null) {
                // Aseguramos que 'entregas' sea una lista o un solo objeto
                if (entregas is List) {
                  for (var entrega in entregas) {
                    _agregarMarcadorEntrega(entrega);
                  }
                } else {
                  _agregarMarcadorEntrega(entregas);
                }
              }
            }
          }

          return FlutterMap(
            options: MapOptions(
              center: paqueteMarkers.isNotEmpty
                  ? paqueteMarkers.first.point
                  : LatLng(19.0595,
                      -96.7317), // Centro predeterminado si no hay marcadores
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
              MarkerLayer(markers: paqueteMarkers),
            ],
          );
        },
      ),
    );
  }

  // Función para agregar marcadores a la lista
  void _agregarMarcadorEntrega(dynamic entrega) {
    try {
      final destinatario = entrega['paquete']?['producto']?['destinatario'];
      if (destinatario != null) {
        final lat = double.tryParse(destinatario['latitud'].toString());
        final lng = double.tryParse(destinatario['longitud'].toString());

        if (lat != null && lng != null) {
          final marker = Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lng),
            builder: (ctx) =>
                const Icon(Icons.location_on, color: Colors.red, size: 40),
          );
          paqueteMarkers.add(marker);
        }
      }
    } catch (e) {
      print("Excepción procesando entrega: $e");
    }
  }
}