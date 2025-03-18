import 'package:flutter/cupertino.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Perfil'),
      ),
      child: Center(
        child: Text(
          'Página de Perfil',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
