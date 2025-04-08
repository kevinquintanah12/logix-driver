import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart'; // Importación de GraphQL
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

Future<ValueNotifier<GraphQLClient>> getClient() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  print("🛠️ Token en getClient(): $token");

  final HttpLink httpLink = HttpLink(
    "https://logix-ioz0.onrender.com/graphql/",
    defaultHeaders: {
      'Authorization': token != null ? 'JWT $token' : '',
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario si usas SharedPreferences antes de runApp
  runApp(const MyApp());
}

// Widget principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GraphQLWrapper(); // Usas tu widget personalizado aquí
  }
}

class GraphQLWrapper extends StatefulWidget {
  const GraphQLWrapper({super.key});

  @override
  State<GraphQLWrapper> createState() => _GraphQLProviderState();
}

class _GraphQLProviderState extends State<GraphQLWrapper> {
  ValueNotifier<GraphQLClient>? _client;

  @override
  void initState() {
    super.initState();
    getClient().then((client) {
      setState(() {
        _client = client;
      });
    });
  }

  void refreshClient() async {
    final newClient = await getClient();
    setState(() {
      _client = newClient;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return const MaterialApp(home: Center(child: CircularProgressIndicator()));
    }

    return GraphQLProvider(
      client: _client!,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Truck GPS',
        theme: AppTheme.lightTheme(context),
        themeMode: ThemeMode.dark,
        onGenerateRoute: router.generateRoute,
        initialRoute: RouteConstants.splashScreenRoute,
      ),
    );
  }
}

// Llamar a esto desde cualquier parte para actualizar el token
void updateGraphQLClient(BuildContext context) {
  final _GraphQLProviderState? state =
      context.findAncestorStateOfType<_GraphQLProviderState>();
  state?.refreshClient();
}


/*
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
    _client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: GraphQLCache(),
        link: HttpLink(
          'https://adsoftsito-api.onrender.com/graphql/',
          defaultHeaders: {
            'Authorization':
                'JWT ${getToken()}', // Aquí puedes obtener el token al inicio
          },
        ),
      ),
    );
  }

  void refreshClient() async {
    final newClient = await getClient();
    _client.value = newClient.value;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: _client,
      child: widget.child,
    );
  }
}

// Método para actualizar el cliente desde otra pantalla
void updateGraphQLClient(BuildContext context) {
  final _GraphQLProviderState? state =
      context.findAncestorStateOfType<_GraphQLProviderState>();
  state?.refreshClient();
}*/