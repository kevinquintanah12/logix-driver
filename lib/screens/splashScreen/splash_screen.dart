import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color _primaryColor = const Color(0xFF6D49AA); // Color morado intenso
  final Color _accentColor = Colors.white;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, RouteConstants.onbordingScreenRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logix',
              style: TextStyle(
                color: _accentColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: _primaryColor,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, RouteConstants.onbordingScreenRoute);
              },
              child: const Text('Comenzar'),
            )
          ],
        ),
      ),
    );
  }
}