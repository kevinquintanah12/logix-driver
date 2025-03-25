import 'package:graphql_flutter/graphql_flutter.dart';

// Definir la mutación GraphQL con `Int!`
const String deleteProductoMutation = """
mutation DeleteProducto(\$idprod: Int!, \$status: Int!) {
  deleteLink(idprod: \$idprod, status: \$status) {
    id
    status
    postedBy {
      username
    }
  }
}
""";

// Clase para la mutación
class DeleteProductoMutation {
  final GraphQLClient client;

  DeleteProductoMutation({required this.client});

  Future<Map<String, dynamic>> deleteProducto(int idprod, int status) async {
    // Validar ID y status
    if (idprod <= 0) {
      throw Exception("El ID del producto debe ser un entero positivo.");
    }

    final options = MutationOptions(
      document: gql(deleteProductoMutation),
      variables: <String, dynamic>{
        'idprod': idprod,
        'status': status,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      throw Exception('Error en la mutación: ${result.exception.toString()}');
    }

    return result.data!;
  }
}
