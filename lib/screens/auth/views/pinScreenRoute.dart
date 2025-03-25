import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController pinController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
  }

  Future<void> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    if (storedPin == pin) {
      // Acceder a la aplicación
      Navigator.pushNamed(context, entryPointScreenRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Ingrese un PIN',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String pin = pinController.text;
                await savePin(pin);
                Navigator.pushNamed(context,
                    entryPointScreenRoute); // Navegar a la pantalla principal
              },
              child: const Text('Guardar PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
