import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GraphQLClient> initGraphQLClient() async {
  // Recuperar el token de SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');

  // Crear un AuthLink para agregar el encabezado de autorización
  final AuthLink authLink = AuthLink(
    getToken: () async => token != null ? 'Bearer $token' : null,
  );

  // HTTP Link para conectarse al servidor
  final HttpLink httpLink = HttpLink('https://tu-servidor-graphql.com/graphql');

  // Combinar los enlaces
  final Link link = authLink.concat(httpLink);

  // Crear el cliente
  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}
