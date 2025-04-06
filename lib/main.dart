import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // Importación de GraphQL
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

// Función para obtener el token JWT
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

// Función para configurar el cliente GraphQL
Future<ValueNotifier<GraphQLClient>> getClient() async {
  final token = await getToken();
  final HttpLink httpLink = HttpLink(
    "https://logix-ioz0.onrender.com/graphql/",
    defaultHeaders: {
      'Authorization': token != null
          ? 'JWT $token'
          : '', // Agregar el token JWT si está disponible
    },
  );

  final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    ),
  );

  return client;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Eliminar const en el GlobalKey
  final GlobalKey<_GraphQLProviderState> _clientKey =
      GlobalKey<_GraphQLProviderState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ValueNotifier<GraphQLClient>>(
      future: getClient(), // Obtener el cliente con el token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
              home:
                  Center(child: CircularProgressIndicator())); // Eliminar const
        }

        if (snapshot.hasError) {
          return MaterialApp(
              home: Center(
                  child:
                      Text('Error al obtener el cliente'))); // Eliminar const
        }

        final client = snapshot.data;

        return GraphQLProvider(
          key: _clientKey, // Asignamos la clave global
          client: client!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Truck GPS',
            theme: AppTheme.lightTheme(context),
            themeMode: ThemeMode.dark,
            onGenerateRoute: router.generateRoute,
            initialRoute: RouteConstants.splashScreenRoute,
          ),
        );
      },
    );
  }
}

// Widget de GraphQLProvider con estado
class _GraphQLProviderState extends State<GraphQLProvider> {
  late ValueNotifier<GraphQLClient> _client;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  Future<void> _initializeClient() async {
    final client = await getClient();
    setState(() {
      _client = client;
    });
  }

  Future<void> refreshClient() async {
    final newClient = await getClient();
    setState(() {
      _client.value = newClient.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: _client,
      child: widget.child,
    );
  }
}

void updateGraphQLClient(BuildContext context) async {
  final _GraphQLProviderState? state =
      context.findAncestorStateOfType<_GraphQLProviderState>();

  if (state != null) {
    await state.refreshClient();
    print("Cliente GraphQL actualizado correctamente.");
  } else {
    print("Error: No se pudo encontrar GraphQLProvider.");
  }
}
