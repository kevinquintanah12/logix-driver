import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RutaDetalleScreen extends StatefulWidget {
  const RutaDetalleScreen({Key? key}) : super(key: key);

  @override
  _RutaDetalleScreenState createState() => _RutaDetalleScreenState();
}

class _RutaDetalleScreenState extends State<RutaDetalleScreen> {
  late MapController mapController;
  LatLng? origen;
  LatLng? destino;
  LatLng? vehiclePosition;

  double tempMin = 0, tempMax = 50;
  double humMin = 0, humMax = 100;

  // Variables de sensores
  double currentTemperature = 25;
  double currentHumidity = 50;

  String alertMessage = "";
  List<LatLng> routeCoordinates = [];
  bool _isDataFetched = false;
  final String _mapboxToken =
      'pk.eyJ1IjoiZGF5a2V2MTIiLCJhIjoiY204MTd5NzR3MGdxYTJqcGlsa29odnQ5YiJ9.tbAEt453VxfJoDatpU72YQ';

  late MqttServerClient mqttClient;

  double _sensorPanelTop = 100;
  double _sensorPanelLeft = 16;

  // Variable para controlar el estado del botón de cancelar/reiniciar viaje
  bool _isCancelled = false;

  // Instancia de FlutterTts
  final FlutterTts flutterTts = FlutterTts();

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
    mqttClient = MqttServerClient('10.40.6.176', '');
    mqttClient.port = 1883;
    mqttClient.logging(on: true);
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onConnected = _onMqttConnected;
    mqttClient.onDisconnected = _onMqttDisconnected;
    mqttClient.onSubscribed = _onMqttSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
            'flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    mqttClient.connectionMessage = connMess;

    try {
      await mqttClient.connect();
    } catch (e) {
      debugPrint('Error al conectar al broker: $e');
      mqttClient.disconnect();
    }
    mqttClient.updates!.listen(_onMqttMessage);
  }

  void _onMqttConnected() {
    debugPrint('Conectado al broker MQTT');
    mqttClient.subscribe('logix/gps', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/alerts', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/temperature', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/humidity', MqttQos.atLeastOnce);
    mqttClient.subscribe('logix/gps/command', MqttQos.atLeastOnce);

    _publishMqttMessage('logix/controliot', json.encode({"command": "on"}));
  }

  void _onMqttDisconnected() {
    debugPrint('Desconectado del broker MQTT');
  }

  void _onMqttSubscribed(String topic) {
    debugPrint('Suscrito al tópico: $topic');
  }

  void _onMqttMessage(List<MqttReceivedMessage<MqttMessage>> event) {
    final recMess = event[0].payload as MqttPublishMessage;
    final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = event[0].topic;
    debugPrint('Mensaje recibido en $topic: $message');

    if (topic == 'logix/gps/command') {
      _handleGpsCommand(message);
    }
    // Actualización de la posición en "logix/gps"
    else if (topic == 'logix/gps') {
      try {
        final data = json.decode(message);
        if (data['lat'] != null && data['lon'] != null) {
          if (!mounted) return;
          setState(() {
            vehiclePosition = LatLng(
              double.parse(data['lat'].toString()),
              double.parse(data['lon'].toString()),
            );
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vehiclePosition != null && mounted) {
              mapController.move(vehiclePosition!, mapController.zoom);
            }
          });
        }
      } catch (e) {
        debugPrint('Error al parsear mensaje gps: $e');
      }
    }
    // Actualización de la temperatura
    else if (topic == 'logix/temperature') {
      try {
        final data = json.decode(message);
        if (data['temperature'] != null) {
          double newTemp = double.parse(data['temperature'].toString());
          if (!mounted) return;
          setState(() {
            currentTemperature = newTemp;
          });
          _speakSensorStatus();
        }
      } catch (e) {
        debugPrint('Error al parsear temperatura: $e');
      }
    }
    // Actualización de la humedad
    else if (topic == 'logix/humidity') {
      try {
        final data = json.decode(message);
        if (data['humidity'] != null) {
          double newHum = double.parse(data['humidity'].toString());
          if (!mounted) return;
          setState(() {
            currentHumidity = newHum;
          });
          _speakSensorStatus();
        }
      } catch (e) {
        debugPrint('Error al parsear humedad: $e');
      }
    }
    // Recepción y muestra de alertas del IoT Sensor, con lectura TTS
    else if (topic == 'logix/alerts') {
      try {
        final data = json.decode(message);
        if (data['alert'] != null) {
          if (!mounted) return;
          setState(() {
            alertMessage = data['alert'];
          });
          // Se lee la alerta usando TTS
          _speak(alertMessage);
        }
      } catch (e) {
        debugPrint('Error al parsear alerta: $e');
      }
    }
  }

  // Función para leer la actualización de sensores mediante TTS
  Future<void> _speakSensorStatus() async {
    if (!mounted) return;
    String message =
        "Temperatura actual: ${currentTemperature.toStringAsFixed(2)} grados, " +
        "humedad actual: ${currentHumidity.toStringAsFixed(0)} por ciento.";
    await _speak(message);
  }

  Future<void> _handleGpsCommand(String message) async {
    try {
      final commandData = json.decode(message);
      if (commandData['latinicio'] != null &&
          commandData['longinicio'] != null &&
          commandData['latdestino'] != null &&
          commandData['longdestino'] != null) {
        if (!mounted) return;
        setState(() {
          origen = LatLng(
            double.parse(commandData['latinicio'].toString()),
            double.parse(commandData['longinicio'].toString()),
          );
          destino = LatLng(
            double.parse(commandData['latdestino'].toString()),
            double.parse(commandData['longdestino'].toString()),
          );
          vehiclePosition = origen;
        });

        await _fetchRouteFromMapbox();

        String city = "Desconocida";
        if (origen != null) {
          city = await _getCityFromCoordinates(origen!);
        }
        final dataToPublish = {
          'lat': origen?.latitude ?? 0,
          'lon': origen?.longitude ?? 0,
          'temperature': currentTemperature,
          'humidity': currentHumidity,
          'city': city
        };
        _publishMqttMessage('logix/gps', json.encode(dataToPublish));
        debugPrint('Datos publicados desde comando: $dataToPublish');
      }
    } catch (e) {
      debugPrint('Error al manejar comando: $e');
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

      if (!mounted) return;
      setState(() {
        origen = LatLng(
          double.parse(origenData['latitud'].toString()),
          double.parse(origenData['longitud'].toString()),
        );
        vehiclePosition = origen;
        destino = LatLng(
          double.parse(destinoData['latitud'].toString()),
          double.parse(destinoData['longitud'].toString()),
        );
        tempMin = double.parse(tempData['rangoMinimo'].toString());
        tempMax = double.parse(tempData['rangoMaximo'].toString());
        humMin = double.parse(humData['rangoMinimo'].toString());
        humMax = double.parse(humData['rangoMaximo'].toString());

        // Inicializamos currentTemperature y currentHumidity
        currentTemperature = (tempMin + tempMax) / 2;
        currentHumidity = ((humMin + humMax) / 2).clamp(humMin, humMax);
      });

      _publishMqttMessage('logix/config', json.encode({
        "current_temp": currentTemperature,
        "current_hum": currentHumidity,
        "temp_min": tempMin,
        "temp_max": tempMax,
        "hum_min": humMin,
        "hum_max": humMax,
      }));

      const zoomLevel = 15.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (origen != null && mounted) {
          mapController.move(origen!, zoomLevel);
        }
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
      if (!mounted) return;
      setState(() {
        routeCoordinates = points;
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

  // Función para manejar el botón de cancelar/reiniciar viaje
  void _toggleTrip() {
    if (!_isCancelled) {
      _publishMqttMessage(
          'logix/controliot', json.encode({"command": "off"}));
      _publishMqttMessage(
          'logix/gps/control', json.encode({"command": "off"}));
      setState(() {
        _isCancelled = true;
        // Regresar la posición del vehículo al inicio (origen)
        vehiclePosition = origen;
      });
      // Se reposiciona el mapa al origen
      if (origen != null) {
        mapController.move(origen!, 15.0);
      }
      debugPrint("Viaje cancelado, se regresó al inicio y sensores apagados");
    } else {
      _publishMqttMessage(
          'logix/controliot', json.encode({"command": "on"}));
      _publishMqttMessage(
          'logix/gps/control', json.encode({"command": "on"}));
      setState(() {
        _isCancelled = false;
      });
      debugPrint("Viaje reiniciado y sensores encendidos");
    }
  }

  void _publishMqttMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('Publisher envía: $message a $topic');
  }

  // Función para hablar el mensaje mediante TTS
  Future<void> _speak(String message) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(message);
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
                    center: vehiclePosition ?? origen,
                    zoom: 14,
                    maxZoom: 18,
                    interactiveFlags:
                        InteractiveFlag.all & ~InteractiveFlag.rotate,
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
                          builder: (context) => const Icon(Icons.location_on,
                              color: Colors.green, size: 30),
                        ),
                        Marker(
                          point: destino!,
                          width: 40,
                          height: 40,
                          builder: (context) => const Icon(Icons.location_on,
                              color: Colors.red, size: 30),
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
                  top: _sensorPanelTop,
                  left: _sensorPanelLeft,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      if (!mounted) return;
                      setState(() {
                        _sensorPanelTop += details.delta.dy;
                        _sensorPanelLeft += details.delta.dx;
                      });
                    },
                    child: _buildSensorPanel(),
                  ),
                ),
                if (alertMessage.isNotEmpty)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              alertMessage,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                alertMessage = "";
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSensorPanel() {
    const double circleSize = 30.0;
    const double fontSize = 18.0;

    // Para la barra de temperatura, se extiende el rango:
    // 1 grado menos que el límite inferior y 2 grados más que el límite superior.
    final double extendedTempMin = tempMin - 1.0;
    final double extendedTempMax = tempMax + 2.0;
    final int tempDivisions = (extendedTempMax - extendedTempMin) > 0
        ? (extendedTempMax - extendedTempMin).toInt()
        : 1;

    // Para la humedad se utiliza el rango definido
    final double displayHumMin =
        currentHumidity < humMin ? currentHumidity : humMin;
    final double displayHumMax =
        currentHumidity > humMax ? currentHumidity : humMax;
    final int humDivisions = (displayHumMax - displayHumMin) > 0
        ? (displayHumMax - displayHumMin).toInt()
        : 1;

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
              offset: const Offset(2, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sensores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Temperatura',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: [
              SizedBox(
                height: circleSize,
                width: circleSize,
                child: CircularProgressIndicator(
                  value: (currentTemperature - extendedTempMin) /
                      (extendedTempMax - extendedTempMin),
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currentTemperature.toStringAsFixed(2)}°',
                style: const TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Slider(
            value: currentTemperature,
            min: extendedTempMin,
            max: extendedTempMax,
            divisions: tempDivisions,
            label: currentTemperature.toStringAsFixed(2),
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                currentTemperature = value;
              });
            },
            onChangeEnd: (value) {
              _publishMqttMessage(
                'logix/adjustment',
                json.encode({"new_temp": value}),
              );
              // Borramos la alerta tras el ajuste de temperatura
              if (alertMessage.isNotEmpty) {
                setState(() {
                  alertMessage = "";
                });
              }
            },
          ),
          const SizedBox(height: 8),
          const Text('Humedad',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: [
              SizedBox(
                height: circleSize,
                width: circleSize,
                child: CircularProgressIndicator(
                  value: (currentHumidity - displayHumMin) /
                      (displayHumMax - displayHumMin),
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currentHumidity.toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          Slider(
            value: currentHumidity,
            min: displayHumMin,
            max: displayHumMax,
            divisions: humDivisions,
            label: currentHumidity.toStringAsFixed(0),
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                currentHumidity = value;
              });
            },
          ),
          const SizedBox(height: 16),
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
                debugPrint("Iniciando viaje: Publicando comando: $message");
                _publishMqttMessage('logix/gps/command', message);

                String ttsMessage =
                    "Viaje iniciado. La temperatura actual es de ${currentTemperature.toStringAsFixed(2)} grados y la humedad es de ${currentHumidity.toStringAsFixed(0)} por ciento.";
                if (currentTemperature < tempMin || currentTemperature > tempMax) {
                  ttsMessage += " Atención, la temperatura está fuera del rango permitido.";
                }
                if (currentHumidity < humMin || currentHumidity > humMax) {
                  ttsMessage += " Atención, la humedad está fuera del rango permitido.";
                }
                _speak(ttsMessage);
              } else {
                debugPrint("Las coordenadas aún no están disponibles");
              }
            },
            child: const Text("Iniciar viaje"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _toggleTrip,
            style: ElevatedButton.styleFrom(iconColor: Colors.redAccent),
            child: Text(_isCancelled ? "Reiniciar viaje" : "Cancelar viaje"),
          ),
        ],
      ),
    );
  }
}
