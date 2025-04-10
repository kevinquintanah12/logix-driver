import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final Color primaryBlue = const Color(0xFF0B3C5D);
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  // Diálogo para cambiar PIN usando GraphQL
  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Cambiar PIN"),
            content: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _oldPinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "PIN Actual",
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Nuevo PIN",
                        ),
                      ),
                    ],
                  ),
            actions: _isLoading
                ? []
                : [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _oldPinController.clear();
                        _newPinController.clear();
                      },
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue),
                      onPressed: () => _updatePin(context, setState),
                      child: const Text("Guardar"),
                    ),
                  ],
          );
        });
      },
    );
  }

  // Método para ejecutar la mutación de actualización de PIN
  Future<void> _updatePin(BuildContext context, StateSetter setState) async {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;

    if (oldPin.isEmpty || newPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, complete todos los campos")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final GraphQLClient client = GraphQLProvider.of(context).value;

      // Imprimir los valores que estamos usando para la mutación
      print('\n=== INTENTO DE ACTUALIZACIÓN DE PIN ===');
      print('oldPin: $oldPin, newPin: $newPin');

      // Esta es la consulta exacta que proporcionaste en el formato raw
      const String mutationString = '''
        mutation {
            updateChoferPin(pin: "%newpin%") {
              chofer {
                id
                nombre
                pin
              }
            }
          }''';

      // Reemplazamos manualmente los valores para depurar
      final String actualMutation = mutationString
          .replaceAll('%oldpin%', oldPin)
          .replaceAll('%newpin%', newPin);

      print('\n=== MUTACIÓN EXACTA QUE SE ENVÍA ===');
      print(actualMutation);

      final MutationOptions options = MutationOptions(
        document: gql(actualMutation),
        // No variables, ya que estamos usando la mutación exacta
        onCompleted: (dynamic resultData) {
          setState(() {
            _isLoading = false;
          });

          print('\n=== RESPUESTA DE LA MUTACIÓN ===');
          print('$resultData');

          if (resultData != null && resultData['updateChoferPin'] != null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("PIN actualizado exitosamente")),
            );
            _oldPinController.clear();
            _newPinController.clear();
          } else {
            print('Error: La respuesta no contiene datos de updateChoferPin');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error al actualizar el PIN")),
            );
          }
        },
        onError: (error) {
          print('\n=== ERROR EN LA MUTACIÓN DE GRAPHQL ===');
          print('Error completo: ${error.toString()}');

          if (error?.graphqlErrors != null && error!.graphqlErrors.isNotEmpty) {
            print(
                'GraphQL Errors: ${error.graphqlErrors.map((e) => e.message).join(', ')}');
          }

          if (error?.linkException != null) {
            print('Link Exception: ${error?.linkException.toString()}');
          }

          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Error: ${error.toString().substring(0, error.toString().length > 100 ? 100 : error.toString().length)}")),
          );
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        print('\n=== ERROR DETECTADO EN EL RESULTADO DE LA MUTACIÓN ===');
        print('${result.exception.toString()}');
      }
    } catch (e) {
      print('\n=== ERROR INESPERADO AL ACTUALIZAR PIN ===');
      print('Error: ${e.toString()}');
      print('Stacktrace:');
      print('${StackTrace.current}');

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Error: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}")),
      );
    }
  }

  // Diálogo para cambiar contraseña
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cambiar Contraseña"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Nueva Contraseña",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Confirmar Contraseña",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _passwordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                if (_passwordController.text ==
                    _confirmPasswordController.text) {
                  // Implementar lógica para cambiar contraseña
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Contraseña cambiada exitosamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Las contraseñas no coinciden")),
                  );
                }
                _passwordController.clear();
                _confirmPasswordController.clear();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Método para actualizar datos personales (navegar a otra pantalla)
  void _actualizarDatosPersonales() {
    // Navegar a la pantalla de edición de datos personales
    Navigator.pushNamed(context, '/editarPerfil');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: primaryBlue,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Cambiar PIN"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePinDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text("Cambiar Contraseña"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Actualizar Datos Personales"),
            trailing: const Icon(Icons.chevron_right),
            onTap: _actualizarDatosPersonales,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Cerrar Sesión"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}