import 'package:flutter/cupertino.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Dashboard'),
      ),
      child: Center(
        child: Text(
          'Página de Dashboard',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
