import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de que este archivo tenga la configuración de Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

/// Función para obtener el token JWT almacenado en SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

/// Función para configurar y retornar el cliente GraphQL
Future<ValueNotifier<GraphQLClient>> getClient() async {
  final token = await getToken();
  final HttpLink httpLink = HttpLink(
    "https://logix-ioz0.onrender.com/graphql/",
    defaultHeaders: {
      'Authorization': token != null ? 'JWT $token' : '',
    },
  );

  final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: httpLink,
    ),
  );

  return client;
}

/// Configuración de notificaciones push con Firebase Cloud Messaging
Future<void> setupPushNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicitar permisos para notificaciones (especialmente en iOS y macOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permisos para notificaciones concedidos.');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('Permisos para notificaciones denegados.');
  }

  // Obtener el token FCM para el dispositivo
  String? fcmToken = await messaging.getToken();
  print('FCM Token: $fcmToken');

  // Escuchar mensajes cuando la app está en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Mensaje recibido en foreground: ${message.notification!.title}');
      // Puedes implementar lógica adicional para mostrar una notificación local o actualizar la UI.
    }
  });

  // Escuchar mensajes cuando la app se abre desde el background al tocar una notificación
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('La app fue abierta desde una notificación: ${message.notification!.title}');
      // Por ejemplo, navega a una pantalla específica.
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase con la configuración específica de cada plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Configura notificaciones push
  await setupPushNotifications();
  runApp(MyApp());
}

/// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  MyApp({super.key});

  // GlobalKey para acceder al estado del GraphQLProvider y actualizar el cliente si es necesario
  final GlobalKey<_GraphQLProviderState> _clientKey =
      GlobalKey<_GraphQLProviderState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ValueNotifier<GraphQLClient>>(
      future: getClient(), // Se obtiene el cliente configurado con el token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Center(child: Text('Error al obtener el cliente')),
          );
        }

        final client = snapshot.data;
        return GraphQLProvider(
          key: _clientKey, // Se asigna la clave global
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

/// Widget con estado para el GraphQLProvider que permite refrescar el cliente
class _GraphQLProviderState extends State<GraphQLProvider> {
  late ValueNotifier<GraphQLClient> _client;

  @override
  void initState() {
    super.initState();
    _initializeClient();
  }

  /// Inicializa el cliente GraphQL y lo asigna al estado
  Future<void> _initializeClient() async {
    final client = await getClient();
    setState(() {
      _client = client;
    });
  }

  /// Función para actualizar el cliente GraphQL (por ejemplo, al recibir un nuevo token)
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

/// Función auxiliar para actualizar el cliente GraphQL desde cualquier parte de la aplicación
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
