import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart'; // Asegúrate de definir logInScreenRoute

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final Color primaryBlue = const Color(0xFF0B3C5D);
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Método para cerrar sesión
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  // Diálogo para cambiar PIN
  void _showChangePinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cambiar PIN"),
          content: TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Nuevo PIN",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pinController.clear();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                // Implementar lógica para guardar el nuevo PIN
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("PIN cambiado a: ${_pinController.text}")),
                );
                _pinController.clear();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
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
                if (_passwordController.text == _confirmPasswordController.text) {
                  // Implementar lógica para cambiar contraseña
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contraseña cambiada exitosamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Las contraseñas no coinciden")),
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
