import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/route/route_constants.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController pinController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Mutación para guardar el PIN
  final String savePinMutation = """
    mutation SetChoferPin(\$pin: String!) {
      setChoferPin(pin: \$pin) {
        chofer {
          id
          nombre
        }
      }
    }
  """;

  // Mutación para guardar el token FCM
  final String guardarTokenMutation = """
    mutation GuardarTokenFCM(\$token: String!) {
      guardarTokenFcm(token: \$token) {
        ok
      }
    }
  """;

  /// Ejecuta la mutación con el PIN ingresado.
  Future<void> _onSavePin(RunMutation runMutation) async {
    final String pin = pinController.text.trim();

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El PIN no puede estar vacío")),
      );
      return;
    }

    // Ejecuta la mutación pasando el PIN como variable.
    runMutation({'pin': pin});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 20),
            Mutation(
              options: MutationOptions(
                document: gql(savePinMutation),
                // Se ejecuta cuando la mutación finaliza exitosamente.
                onCompleted: (dynamic resultData) async {
                  // Se obtiene el cliente GraphQL para llamar a la siguiente mutación.
                  final client = GraphQLProvider.of(context).value;

                  // Ejecutar la mutación para guardar el token FCM.
                  final MutationOptions fcmOptions = MutationOptions(
                    document: gql(guardarTokenMutation),
                    variables: {'token': "mi_token_fcm_de_ejemplo"},
                  );
                  final fcmResult = await client.mutate(fcmOptions);

                  if (fcmResult.hasException) {
                    print("❌ Error en la mutación de guardarTokenFcm: ${fcmResult.exception.toString()}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al guardar token FCM: ${fcmResult.exception.toString()}"),
                      ),
                    );
                    return;
                  } else {
                    print("✅ Token FCM guardado: ${fcmResult.data}");
                  }

                  // Guarda localmente el PIN luego de una respuesta exitosa.
                  await _storage.write(key: 'user_pin', value: pinController.text);
                  Navigator.pushNamed(context, entryPointScreenRoute);
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${error.toString()}")),
                  );
                },
              ),
              builder: (RunMutation runMutation, QueryResult? result) {
                return ElevatedButton(
                  onPressed: () => _onSavePin(runMutation),
                  child: const Text('Guardar PIN'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
