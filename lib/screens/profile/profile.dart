import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart'; // Asegúrate de tener la constante loginScreenRoute definida
import 'package:shop/constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Método para cerrar sesión: elimina el token y navega al login
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // Navegar a la pantalla de login y eliminar el historial
    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Perfil'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text("Cerrar Sesión"),
          onPressed: () async {
            await _logout(context);
          },
        ),
      ),
      child: const Center(
        child: Text(
          'Página de Perfil',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
