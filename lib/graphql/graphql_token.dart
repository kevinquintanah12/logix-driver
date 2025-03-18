import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Recuperar el token desde SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Crear un cliente de GraphQL con el header Authorization JWT
  Future<GraphQLClient> getGraphQLClient() async {
    final token = await getToken();

    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'JWT $token' : '', // Agregar el token en el header Authorization
    );

    final HttpLink httpLink = HttpLink(''); // Aquí debes configurarlo en main.dart, por lo que lo dejamos vacío

    final Link link = authLink.concat(httpLink);

    final client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    return client;
  }
}
