import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/dot_indicators.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'dart:math';

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
  }

  List<Onbord> _generateRandomOnboardData() {
    List<Onbord> data = [
      Onbord(
        image: "assets/Illustration/maintenance.png",
        imageDarkTheme: "assets/Illustration/maintenance.png",
        title: "Verifica la presión de las llantas",
        description:
            "Recuerda siempre verificar la presión de tus llantas antes de iniciar tu ruta. ¡La seguridad es lo primero!",
      ),
      Onbord(
        image: "assets/Illustration/driver.png",
        imageDarkTheme: "assets/Illustration/driver.png",
        title: "Descansa cada 2 horas",
        description:
            "No olvides descansar cada 2 horas. Conducir descansado es crucial para tu seguridad y la de los demás.",
      ),
      Onbord(
        image: "assets/Illustration/truck.png",
        imageDarkTheme: "assets/Illustration/truck.png",
        title: "Respeta los límites de velocidad",
        description:
            "Mantén tu velocidad dentro de los límites establecidos para evitar multas y garantizar tu seguridad.",
      ),
      Onbord(
        image: "assets/Illustration/asustado.png",
        imageDarkTheme: "assets/Illustration/asustado.png",
        title: "Atiende las advertencias",
        description: "Si no atiendes las advertencias de temperatura o notificaciones, podrías ser sancionado.",
      ),
      Onbord(
        image: "assets/Illustration/documentacion.png",
        imageDarkTheme: "assets/Illustration/documentacion.png",
        title: "Documentación en regla",
        description:
            "Asegúrate de tener todos los documentos del camión en orden antes de salir a la carretera.",
      ),
      Onbord(
        image: "assets/Illustration/packagehuman.png",
        imageDarkTheme: "assets/Illustration/packagehuman.png",
        title: "Revisa los paquetes antes de transportarlos",
        description:
            "Revisa que el paquete esté bien sellado antes de transportarlo para evitar que se dañe.",
      ),
      Onbord(
        image: "assets/Illustration/package2.png",
        imageDarkTheme: "assets/Illustration/package2.png",
        title: "Etiqueta correctamente los paquetes",
        description:
            "Asegúrate de que los paquetes estén correctamente etiquetados para facilitar su localización.",
      ),
      Onbord(
        image: "assets/Illustration/termometros.png",
        imageDarkTheme: "assets/Illustration/termometros.png",
        title: "Cuidado con la temperatura",
        description:
            "Si los paquetes requieren control de temperatura, etiquétalos y transpórtalos con precaución.",
      ),
      Onbord(
        image: "assets/Illustration/paquete.png",
        imageDarkTheme: "assets/Illustration/paquete.png",
        title: "Temperatura adecuada para alimentos",
        description:
            "Mantén la temperatura en un ambiente adecuado para evitar daños a alimentos refrigerados.",
      ),
    ];
    data.shuffle(Random());
    return data;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: PageView.builder(
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
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            (Theme.of(context).brightness == Brightness.dark &&
                                    currentData.imageDarkTheme != null)
                                ? currentData.imageDarkTheme!
                                : currentData.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                currentData.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: defaultPadding),
                              Text(
                                currentData.description,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _onbordData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: defaultPadding / 4),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex < _onbordData.length - 1) {
                          _pageController.nextPage(
                              curve: Curves.ease, duration: defaultDuration);
                        } else {
                          Navigator.pushNamed(context, logInScreenRoute);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/Arrow - Right.svg",
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
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