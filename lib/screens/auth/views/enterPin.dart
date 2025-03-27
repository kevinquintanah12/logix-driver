import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:shop/route/route_constants.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({Key? key}) : super(key: key);

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final TextEditingController _pinController = TextEditingController();

  /// Compara el PIN ingresado con el PIN almacenado localmente.
  Future<void> verifyPin(String enteredPin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    if (storedPin != null && storedPin == enteredPin) {
      // Si el PIN es correcto, navega a la pantalla principal.
      Navigator.pushNamed(context, entryPointScreenRoute);
    } else {
      // Si el PIN es incorrecto, muestra un error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definir un tema de PIN que imite el estilo iOS.
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    // Opcional: tema para estados enfocados y error.
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingrese su PIN'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido, ingresa tu PIN',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            Pinput(
              length: 4,
              controller: _pinController,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              // Si deseas aplicar un tema de error, puedes controlarlo manualmente.
              // errorPinTheme: errorPinTheme,
              onCompleted: (pin) {
                verifyPin(pin);
              },
            ),
          ],
        ),
      ),
    );
  }
}
