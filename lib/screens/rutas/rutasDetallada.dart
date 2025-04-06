import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class RutaDetalleScreen extends StatefulWidget {
  const RutaDetalleScreen({Key? key}) : super(key: key);

  @override
  _RutaDetalleScreenState createState() => _RutaDetalleScreenState();
}

class _RutaDetalleScreenState extends State<RutaDetalleScreen> {
  late MapController mapController;
  LatLng? origen;           // Coordenada de inicio (origenCd)
  LatLng? destino;          // Coordenada de destino
  LatLng? vehiclePosition;  // Posición actual del carro (se actualiza vía MQTT)
  double tempMin = 0, tempMax = 50;
  double humMin = 0, humMax = 100;
  List<LatLng> routeCoordinates = [];
  bool _isDataFetched = false;
  final String _mapboxToken =
      'pk.eyJ1IjoiZGF5a2V2MTIiLCJhIjoiY204MTd5NzR3MGdxYTJqcGlsa29odnQ5YiJ9.tbAEt453VxfJoDatpU72YQ';

  // MQTT Client
  late MqttServerClient mqttClient;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _connectToMqtt();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataFetched) {
      _fetchRutaDetalle();
      _isDataFetched = true;
    }
  }

  Future<void> _connectToMqtt() async {
    mqttClient = MqttServerClient('localhost', '');
    mqttClient.port = 1883;
    mqttClient.logging(on: true);
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onConnected = _onMqttConnected;
    mqttClient.onDisconnected = _onMqttDisconnected;
    mqttClient.onSubscribed = _onMqttSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient.connectionMessage = connMess;

    try {
      await mqttClient.connect();
    } catch (e) {
      debugPrint('Error al conectar al broker: $e');
      mqttClient.disconnect();
    }

    // Escuchar mensajes entrantes
    mqttClient.updates!.listen(_onMqttMessage);
  }

  void _onMqttConnected() {
    debugPrint('Conectado al broker MQTT');
    // Suscribirse a los tópicos deseados
    mqttClient.subscribe('logix/gps', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/alerts', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/temperature', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/humidity', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/gps/command', MqttQos.atLeastOnce);
  }

  void _onMqttDisconnected() {
    debugPrint('Desconectado del broker MQTT');
  }

  void _onMqttSubscribed(String topic) {
    debugPrint('Suscrito al tópico: $topic');
  }

  // Callback para mensajes entrantes
  void _onMqttMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;
    final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    debugPrint('Mensaje recibido en ${event[0].topic}: $message');

    if (event[0].topic == 'logix/gps/command') {
      _handleGpsCommand(message);
    } else if (event[0].topic == 'logix/gps') {
      try {
        final data = json.decode(message);
        if (data['lat'] != null && data['lon'] != null) {
          setState(() {
            vehiclePosition = LatLng(
              double.parse(data['lat'].toString()),
              double.parse(data['lon'].toString()),
            );
            // Mover el mapa a la posición actual del vehículo
            mapController.move(vehiclePosition!, mapController.zoom);
          });
        }
      } catch (e) {
        debugPrint('Error al parsear el mensaje MQTT: $e');
      }
    }
  }

  // Maneja el comando recibido para actualizar origen y destino
  Future<void> _handleGpsCommand(String message) async {
    try {
      final commandData = json.decode(message);
      if (commandData['latinicio'] != null &&
          commandData['longinicio'] != null &&
          commandData['latdestino'] != null &&
          commandData['longdestino'] != null) {
        setState(() {
          origen = LatLng(
            double.parse(commandData['latinicio'].toString()),
            double.parse(commandData['longinicio'].toString()),
          );
          destino = LatLng(
            double.parse(commandData['latdestino'].toString()),
            double.parse(commandData['longdestino'].toString()),
          );
          // Opcional: También actualizar vehiclePosition si se desea centrar
          vehiclePosition = origen;
        });

        // Actualiza la ruta usando las nuevas coordenadas
        await _fetchRouteFromMapbox();

        // Se obtiene la ciudad usando el origen (puedes ajustarlo)
        String city = "Desconocida";
        if (origen != null) {
          city = await _getCityFromCoordinates(origen!);
        }
        final dataToPublish = {
          'lat': origen?.latitude ?? 0,
          'lon': origen?.longitude ?? 0,
          'temperature': tempMax, // o tempMin/promedio según tu lógica
          'humidity': humMax,     // o humMin según tu lógica
          'city': city
        };
        _publishMqttMessage('logix/gps', json.encode(dataToPublish));
        debugPrint('Datos publicados desde comando: $dataToPublish');
      }
    } catch (e) {
      debugPrint('Error al manejar el comando: $e');
    }
  }

  Future<void> _fetchRutaDetalle() async {
    final client = GraphQLProvider.of(context).value;
    const String query = r'''
      query GetRutaDetalle {
        ruta(id: 1) {
          entregas {
            paquete {
              producto {
                destinatario {
                  latitud
                  longitud
                }
                calculoenvio {
                  origenCd {
                    ubicacion {
                      latitud
                      longitud
                    }
                  }
                  tipoProducto {
                    temperatura {
                      rangoMinimo
                      rangoMaximo
                    }
                    humedad {
                      rangoMinimo
                      rangoMaximo
                    }
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final QueryResult result = await client.query(
      QueryOptions(document: gql(query)),
    );

    if (result.hasException) {
      debugPrint(result.exception.toString());
      return;
    }

    final rutaData = result.data?['ruta'];
    if (rutaData != null && rutaData['entregas'] != null) {
      dynamic entregaData = rutaData['entregas'];
      if (entregaData is List && entregaData.isNotEmpty) {
        entregaData = entregaData[0];
      }

      final producto = entregaData['paquete']['producto'];
      final origenData = producto['calculoenvio']['origenCd']['ubicacion'];
      final destinoData = producto['destinatario'];
      final tempData = producto['calculoenvio']['tipoProducto']['temperatura'];
      final humData = producto['calculoenvio']['tipoProducto']['humedad'];

      setState(() {
        // Usamos la ubicación de origenCd como punto inicial del carro
        origen = LatLng(
          double.parse(origenData['latitud'].toString()),
          double.parse(origenData['longitud'].toString()),
        );
        // También asignamos vehiclePosition al mismo valor para centrar el carro al inicio
        vehiclePosition = origen;
        destino = LatLng(
          double.parse(destinoData['latitud'].toString()),
          double.parse(destinoData['longitud'].toString()),
        );
        // Valores de temperatura y humedad
        tempMin = double.parse(tempData['rangoMinimo'].toString());
        tempMax = double.parse(tempData['rangoMaximo'].toString());
        humMin = double.parse(humData['rangoMinimo'].toString());
        humMax = double.parse(humData['rangoMaximo'].toString());
      });

      await _fetchRouteFromMapbox();
    }
  }

  Future<void> _fetchRouteFromMapbox() async {
    if (origen == null || destino == null) return;
    final url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${origen!.longitude},${origen!.latitude};${destino!.longitude},${destino!.latitude}?geometries=geojson&overview=full&access_token=$_mapboxToken";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
      List<LatLng> points = coordinates
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
      setState(() {
        routeCoordinates = points;
        // vehiclePosition ya fue inicializado en _fetchRutaDetalle, se mantiene
      });
    } else {
      debugPrint('Error al obtener la ruta: ${response.statusCode}');
    }
  }

  Future<String> _getCityFromCoordinates(LatLng coords) async {
    final url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/${coords.longitude},${coords.latitude}.json?access_token=$_mapboxToken";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        for (var feature in data['features']) {
          if (feature['place_type'] != null &&
              (feature['place_type'] as List).contains('place')) {
            return feature['text'];
          }
        }
        return data['features'][0]['text'];
      }
    }
    return "Desconocida";
  }

  Future<void> _simulateVehicleMovement() async {
    // Simula el movimiento publicando cada iteración vía MQTT
    for (int i = 0; i < routeCoordinates.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        vehiclePosition = routeCoordinates[i];
        // Mover el mapa a la nueva posición del vehículo
        mapController.move(vehiclePosition!, mapController.zoom);
      });

      // Se obtiene la ciudad a partir de las coordenadas actuales
      String city = await _getCityFromCoordinates(vehiclePosition!);
      final dataToPublish = {
        'lat': vehiclePosition!.latitude,
        'lon': vehiclePosition!.longitude,
        'temperature': tempMax,
        'humidity': humMax,
        'city': city
      };
      _publishMqttMessage('logix/gps', json.encode(dataToPublish));
      debugPrint('Datos publicados: $dataToPublish');
    }
  }

  // Método publicador MQTT
  void _publishMqttMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('Publisher envía: $message a $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Ruta')),
      body: origen == null || destino == null || routeCoordinates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    // Usamos vehiclePosition (si existe) para centrar el mapa; de lo contrario, el origen
                    center: vehiclePosition ?? origen,
                    zoom: 14,
                    maxZoom: 18,
                    interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=$_mapboxToken",
                      additionalOptions: {
                        'accessToken': _mapboxToken,
                        'id': 'mapbox.streets',
                      },
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeCoordinates,
                          color: Colors.blue.withOpacity(0.7),
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: origen!,
                          width: 40,
                          height: 40,
                          builder: (context) => const Icon(
                              Icons.location_on, color: Colors.green, size: 30),
                        ),
                        Marker(
                          point: destino!,
                          width: 40,
                          height: 40,
                          builder: (context) => const Icon(
                              Icons.location_on, color: Colors.red, size: 30),
                        ),
                        if (vehiclePosition != null)
                          Marker(
                            point: vehiclePosition!,
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                                Icons.local_shipping,
                                color: Colors.black,
                                size: 30),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  top: 100,
                  child: _buildSensorPanel(),
                ),
              ],
            ),
    );
  }

  Widget _buildSensorPanel() {
    return Container(
      width: 220,
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
      child: Column(
        children: [
          const Text('Sensores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Temp: $tempMin°C - $tempMax°C'),
          const SizedBox(height: 8),
          Text('Hum: $humMin% - $humMax%'),
          const SizedBox(height: 16),
          // Botón para enviar comando usando las coordenadas del query (origen y destino)
          ElevatedButton(
            onPressed: () {
              if (origen != null && destino != null) {
                final commandPayload = {
                  "latinicio": origen!.latitude,
                  "longinicio": origen!.longitude,
                  "latdestino": destino!.latitude,
                  "longdestino": destino!.longitude,
                };
                final message = json.encode(commandPayload);
                debugPrint("Antes de iniciar viaje: Publicando comando: $message");
                _publishMqttMessage('logix/gps/command', message);
              } else {
                debugPrint("Las coordenadas aún no están disponibles");
              }
            },
            child: const Text("Enviar comando"),
          ),
          const SizedBox(height: 16),
          // Botón para iniciar la simulación del viaje
          ElevatedButton(
            onPressed: () {
              _simulateVehicleMovement();
            },
            child: const Text('Iniciar viaje'),
          ),
        ],
      ),
    );
  }
}
