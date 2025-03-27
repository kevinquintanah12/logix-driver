
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shop/components/dot_indicators.dart';


/// Consulta para verificar si el chofer ya tiene un PIN configurado.
/// Se asume que el campo 'pin' existe en el tipo de chofer.
String choferQueryOnBoarding = """
query {
  choferAutenticado {
    id
    nombre
    apellidos
    rfc
    pin
  }
}
""";

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  late List<Onbord> _onbordData;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _onbordData = _generateRandomOnboardData();
    // Verificar el token cuando se inicia la pantalla
  }

  List<Onbord> _generateRandomOnboardData() {
    List<Onbord> data = [
      Onbord(
        image: "assets/Illustration/maintenance.png",
        imageDarkTheme: "assets/Illustration/maintenance.png",
        title: "Verifica presión de llantas",
        description: "antes de viajar para seguridad",
      ),
      Onbord(
        image: "assets/Illustration/driver.png",
        imageDarkTheme: "assets/Illustration/driver.png",
        title: "Descansa cada 2 horas",
        description: "para conducir con alerta",
      ),
      Onbord(
        image: "assets/Illustration/truck.png",
        imageDarkTheme: "assets/Illustration/truck.png",
        title: "Respeta los límites de velocidad",
        description: "evita multas y accidentes.",
      ),
      Onbord(
        image: "assets/Illustration/notificacion.png",
        imageDarkTheme: "assets/Illustration/notificacion.png",
        title: "Atiende advertencias del vehículo",
        description: "para prevenir sanciones",
      ),
      Onbord(
        image: "assets/Illustration/documentacion.png",
        imageDarkTheme: "assets/Illustration/documentacion.png",
        title: "Documentación del camión en regla",
        description: "verifica antes de salir",
      ),
      Onbord(
        image: "assets/Illustration/packagehuman.png",
        imageDarkTheme: "assets/Illustration/packagehuman.png",
        title: "Revisa sellado de paquetes",
        description: "para evitar daños en ruta",
      ),
      Onbord(
        image: "assets/Illustration/package2.png",
        imageDarkTheme: "assets/Illustration/package2.png",
        title: "Etiqueta los paquetes",
        description: "con datos clave para su localización",
      ),
      Onbord(
        image: "assets/Illustration/termometros.png",
        imageDarkTheme: "assets/Illustration/termometros.png",
        title: "Controla temperatura",
        description: "de carga sensible durante el transporte.",
      ),
      Onbord(
        image: "assets/Illustration/package.png",
        imageDarkTheme: "assets/Illustration/package.png",
        title: "Mantén cadena de frío",
        description: "para alimentso refrigerados",
      ),
    ];
    data.shuffle(Random());
    return data;
  }

   // Método para verificar si ya existe un token y si el chofer tiene un PIN configurado
  Future<void> _checkForToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      // Si existe token, verificar si el chofer tiene un PIN configurado
      _checkChoferPinStatus();
    }
  }

  // Método para verificar el estado del PIN del chofer
  Future<void> _checkChoferPinStatus() async {
    final client = GraphQLProvider.of(context).value;
    final QueryOptions options = QueryOptions(
      document: gql(choferQueryOnBoarding),
    );
    final QueryResult result = await client.query(options);

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos del chofer: ${result.exception.toString()}')),
      );
      return;
    }

    final chofer = result.data?['choferAutenticado'];
    if (chofer != null) {
      final pin = chofer['pin'];
      if (pin != null) {
        // Si el PIN ya está configurado, navegar a la pantalla de ingreso (EnterPinScreen)
        Navigator.pushReplacementNamed(context, pinEnterScreenRoute);
      } else {
        // Si el PIN es null, se redirige a la pantalla para configurarlo (PinScreen)
        Navigator.pushReplacementNamed(context, pinScreenRoute);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    const commonTextStyle = TextStyle(fontSize: 26);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onbordData.length,
            onPageChanged: (value) {
              setState(() {
                _pageIndex = value;
              });
            },
            itemBuilder: (context, index) {
              final currentData = _onbordData[index];
              return Column(
                children: [
                  // Image
                  SizedBox(
                    height: screenHeight * 0.65, // 50% de la altura
                    width: screenWidth, // Ancho completo
                    child: Image.asset(
                      (Theme.of(context).brightness == Brightness.dark &&
                              currentData.imageDarkTheme != null)
                          ? currentData.imageDarkTheme!
                          : currentData.image,
                      fit: BoxFit.cover, // Importante para ocupar todo el espacio
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          // Contenedor para el título
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            currentData.title,
                            textAlign: TextAlign.center,
                            style: commonTextStyle.copyWith(
                                fontWeight: FontWeight.bold, color: blackColor),
                          ),
                        ),
                        Container(
                          // Contenedor para la descripción
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            currentData.description,
                            textAlign: TextAlign.center,
                            style: commonTextStyle.copyWith(color: blackColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Indicadores
          Positioned(
            left: 0,
            right: 0,
            bottom: screenHeight * 0.15, // Ajusta este valor según necesidad
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onbordData.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DotIndicator(
                    isActive: index == _pageIndex,
                    size: 150, // Tamaño aumentado
                    activeColor: const Color(0xFF6D49AA),
                    inActiveColor: Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),

          // Skip Button
          Positioned(
            left: 20,
            bottom: 30,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFCECECE), // Color de fondo gris
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 20), // Añadir padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                await _checkChoferPinStatus();  // Ejecutar consulta antes de redirigir
                Navigator.pushNamed(context, logInScreenRoute);
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1, // Elimina espacio adicional
                ),
              ),
            ),
          ),

          // Next Button
          Positioned(
            right: 20,
            bottom: 30,
            child: SizedBox(
              height: 60,
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Elimina padding interno por defecto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  if (_pageIndex < _onbordData.length - 1) {
                    _pageController.nextPage(
                        curve: Curves.ease, duration: defaultDuration);
                  } else {
                    await _checkChoferPinStatus();  // Ejecutar consulta al terminar
                    Navigator.pushNamed(context, logInScreenRoute);
                  }
                },
                child: Center(
                  // Widget Center adicional para garantizar alineación
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -2), // Sube 1 pixel el texto
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1, // Elimina espacio adicional
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Transform.translate(
                        offset: const Offset(0, -2), // Sube 1 pixel el ícono
                        child: const Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Onbord {
  final String image, title, description;
  final String? imageDarkTheme;

  Onbord({
    required this.image,
    required this.title,
    this.description = "",
    this.imageDarkTheme,
  });
}