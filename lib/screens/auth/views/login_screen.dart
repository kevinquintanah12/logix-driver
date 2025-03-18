import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/MyAppState.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Verificar si el token está guardado
  Future<void> verifyToken() async {
    final token = await getToken();
    if (token == null) {
      print('No hay token guardado');
    } else {
      print('Token guardado: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00AEEF), Color(0xFF0067B1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.35,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      size: 90,
                      color: Colors.white,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Bienvenido!!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inicia Sesión con tu cuenta!",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "Ingresa tu nombre de usuario y contraseña",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: "Nombre de usuario",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor ingrese su nombre de usuario";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor ingrese su contraseña";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Mutation(
                      options: MutationOptions(
                        document: gql(loginPostMutation),
                        onCompleted: (dynamic resultData) async {
                          if (resultData != null &&
                              resultData['tokenAuth'] != null &&
                              resultData['tokenAuth']['token'] != null) {
                            final token = resultData['tokenAuth']['token'];
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login exitoso."),
                              ),
                            );

                            // Guardar el token
                            await saveToken(token);

                            // Imprimir el token en la terminal
                            print('Token: $token');

                            // Navegar a la pantalla principal
                            Navigator.pushNamed(context, entryPointScreenRoute);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error: respuesta inválida del servidor"),
                              ),
                            );
                          }
                        },
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Error en el login: ${error?.graphqlErrors.isNotEmpty == true ? error!.graphqlErrors[0].message : "Desconocido"}"),
                            ),
                          );
                        },
                      ),
                      builder: (RunMutation runMutation, QueryResult? result) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0067B1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 30,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              runMutation({
                                'username': usernameController.text,
                                'password': passwordController.text,
                              });
                            }
                          },
                          child: const Center(
                            child: Text(
                              "Iniciar Sesión",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
