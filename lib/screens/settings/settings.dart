import 'package:flutter/cupertino.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Configuración'),
      ),
      child: Center(
        child: Text(
          'Página de Configuración',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
