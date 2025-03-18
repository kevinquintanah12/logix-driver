import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart'; // Importando las rutas constantes

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Animation? animation, delayedAnimation, muchDelayAnimation, transfor, fadeAnimation;
  AnimationController? animationController;

  // Definir colores directamente aquí en lugar de importarlos
  final Color primaryColor = Colors.blue; // o cualquier color que quieras usar

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Curves.fastOutSlowIn
    ));

    transfor = BorderRadiusTween(
        begin: BorderRadius.circular(125.0),
        end: BorderRadius.circular(0.0)).animate(
        CurvedAnimation(parent: animationController!, curve: Curves.ease)
    );
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController!);
    animationController!.forward();

    // Cambiar la navegación a la pantalla de Onboarding
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushNamedAndRemoveUntil(RouteConstants.onbordingScreenRoute, (Route<dynamic> route) => false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext? context, Widget? child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(color: primaryColor), // Usando el color directamente aquí
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //     flex: 1,
                  //     child: Center(
                  //         child: FadeTransition(
                  //             opacity: fadeAnimation!,
                  //             child: Image.asset("assets/image/logo.png", height: 100.0)
                  //         ),
                  //     ),
                  // ),
                ],
              ),
            ),
          );
        }
    );
  }
}
