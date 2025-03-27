import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mutación para obtener el token (login)
String loginPostMutation = """
mutation TokenAuth(\$username: String!, \$password: String!) {
  tokenAuth(
    username: \$username
    password: \$password
  ) {
    token
  }
}
""";

/// Consulta para verificar si el chofer ya tiene un PIN configurado.
/// Se asume que el campo 'pin' existe en el tipo de chofer.
String choferQuery = """
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


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos de username y contraseña
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // Controla el estado de carga

  // Guardar el token en SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obtener el token desde SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Método para verificar si ya existe un PIN en el chofer
  Future<void> checkChoferPinStatus() async {
    final client = GraphQLProvider.of(context).value;
    final QueryOptions options = QueryOptions(
      document: gql(choferQuery),
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

  // Verificar si ya existe token para saltar el login (opcional)
  Future<void> checkForToken() async {
    final token = await getToken();
    if (token != null) {
      print('Token guardado: $token');
      // Al tener token, verificamos si ya existe el PIN configurado
      checkChoferPinStatus();
    } else {
      print('No hay token guardado');
    }
  }

  @override
  void initState() {
    super.initState();
    // Verificar el token al iniciar la pantalla
    checkForToken();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(25, 80, 25, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Bienvenido a Logix!",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 500,
                    child: Text(
                      "Accede a tu cuenta y garantiza el éxito de cada entrega.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: "Correo electrónico",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor ingrese su correo electrónico";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outlined, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor ingrese su contraseña";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Acción para olvidó contraseña
                            },
                            child: const Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(
                                color: Color(0xFF6D49AA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Mutation(
                          options: MutationOptions(
                            document: gql(loginPostMutation),
                            onCompleted: (dynamic resultData) async {
                              setState(() {
                                isLoading = false; // Detener el indicador de carga
                              });

                              if (resultData != null &&
                                  resultData['tokenAuth'] != null &&
                                  resultData['tokenAuth']['token'] != null) {
                                final token = resultData['tokenAuth']['token'];
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login exitoso."),
                                  ),
                                );
                                // Guardar el token en SharedPreferences
                                await saveToken(token);
                                print('Token: $token');
                                // Verificar si el chofer ya tiene PIN configurado
                                checkChoferPinStatus();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error: respuesta inválida del servidor"),
                                  ),
                                );
                              }
                            },
                            onError: (error) {
                              setState(() {
                                isLoading = false; // Detener el indicador de carga en caso de error
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error en el login: ${error?.graphqlErrors.isNotEmpty == true ? error!.graphqlErrors[0].message : "Desconocido"}",
                                  ),
                                ),
                              );
                            },
                          ),
                          builder: (RunMutation runMutation, QueryResult? result) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8353D4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true; // Mostrar el indicador de carga
                                    });

                                    runMutation({
                                      'username': usernameController.text,
                                      'password': passwordController.text,
                                    });
                                  }
                                },
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "INGRESAR",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Navegar a pantalla de registro
                },
                child: RichText(
                  text: const TextSpan(
                    text: "¿No tienes cuenta? ",
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Regístrate aquí",
                        style: TextStyle(
                          color: Color(0xFF6D49AA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
