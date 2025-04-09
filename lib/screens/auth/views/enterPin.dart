import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  final TextEditingController _pinController = TextEditingController();

  // Definir la consulta GraphQL para verificar el PIN
  final String checkPinQuery = """
    query CheckPin(\$pin: String!) {
      checkPin(pin: \$pin)
    }
  """;

  /// Método para verificar si ya existe un token y guardarlo en `FlutterSecureStorage`
  Future<void> _checkForToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      print("📥 Guardando token en FlutterSecureStorage...");
      await _storage.write(key: 'auth_token', value: token);
      print("✅ Token guardado correctamente.");
    } else {
      print("⚠️ No se encontró un token en SharedPreferences.");
    }
  }

  /// Realiza la consulta GraphQL para verificar si el PIN ingresado es correcto
  Future<void> verifyPin(String enteredPin) async {
    print("🔹 PIN ingresado: $enteredPin");

    final token = await _storage.read(key: 'auth_token');
    print("🔹 Token recuperado: $token");

    if (token == null) {
      print("⚠️ No se encontró un token. Redirigiendo al login...");
      Navigator.pushNamed(context, logInScreenRoute);
      return;
    }

    final client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
      document: gql(checkPinQuery),
      variables: {"pin": enteredPin},
    );

    final result = await client.query(options);

    if (result.hasException) {
      print("❌ Error en la consulta: ${result.exception.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.exception.toString()}')),
      );
      return;
    }

    print("✅ Respuesta del servidor: ${result.data}");

    final bool? isValid = result.data?['checkPin'];
    print("🔍 ¿Es válido el PIN? $isValid");

    if (isValid == true) {
      print("✅ PIN correcto. Redirigiendo...");
      await _storage.write(key: 'user_pin', value: enteredPin);
      Navigator.pushNamed(context, entryPointScreenRoute);
    } else {
      print("❌ PIN incorrecto. Mostrando mensaje de error.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN incorrecto')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForToken(); // Verifica y guarda el token al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
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