import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../constants.dart';
import '../../../route/route_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Mutación para el registro de un nuevo usuario
  String createUserMutation = """
mutation CreateUser(\$email : String!,  \$password : String!, \$username : String!) {
  createUser(
    email: \$email
    password: \$password
    username: \$username
  ) {
    user {
      id
      email
      username
    }
  }
}
""";

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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 90,
                      color: Colors.white,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "¡Regístrate ahora!",
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
                      // ignore: deprecated_member_use
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
                      "¡Vamos a comenzar!",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "Por favor, ingrese datos válidos para completar su registro.",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: "Correo Electrónico",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese un correo válido.";
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return "Ingrese un correo electrónico válido.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: "Nombre de Usuario",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, ingrese un nombre de usuario.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: defaultPadding),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "La contraseña debe tener al menos 6 caracteres.";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        Checkbox(
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          value: _agreeToTerms,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "Estoy de acuerdo con los",
                              style: const TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushNamed(
                                          context, termsOfServicesScreenRoute);
                                    },
                                  text: " términos de servicio ",
                                  style: const TextStyle(
                                    color: Color(0xFF0067B1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: "y la política de privacidad.",
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    Mutation(
                      options: MutationOptions(
                        document: gql(createUserMutation),
                        onCompleted: (dynamic resultData) async {
                          setState(() {
                            _isLoading = false;
                          });

                          if (resultData != null &&
                              resultData['createUser'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Registro exitoso. Por favor, inicia sesión con tus credenciales.',
                                ),
                              ),
                            );

                            // Redirige a la pantalla de inicio de sesión
                            Navigator.pushNamed(context, logInScreenRoute);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error en la respuesta del servidor.'),
                              ),
                            );
                          }
                        },
                        onError: (error) {
                          setState(() {
                            _isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error?.graphqlErrors.isNotEmpty == true
                                    ? error!.graphqlErrors[0].message
                                    : 'Error desconocido',
                              ),
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
                            if (_formKey.currentState!.validate() &&
                                _agreeToTerms) {
                              setState(() {
                                _isLoading = true;
                              });
                              runMutation({
                                'email': _emailController.text,
                                'username': _usernameController.text,
                                'password': _passwordController.text,
                              });
                            } else if (!_agreeToTerms) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Debes aceptar los términos de servicio.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Registrarse",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes una cuenta?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, logInScreenRoute);
                          },
                          child: const Text(
                            "Inicia Sesión",
                            style: TextStyle(color: Color(0xFF0067B1)),
                          ),
                        )
                      ],
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
