import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EntregarPaquete extends StatefulWidget {
  const EntregarPaquete({super.key});

  @override
  State<EntregarPaquete> createState() => _EntregarPaqueteState();
}

class _EntregarPaqueteState extends State<EntregarPaquete> {
  final TextEditingController _pinController = TextEditingController();
  final int entregaId = 1;

  final String entregaQuery = """
    query ObtenerEntrega(\$id: ID!) {
      entrega(id: \$id) {
        id
        estado
        fechaEntrega
        pin
      }
    }
  """;

  final String finalizarEntregaMutation = """
    mutation FinalizarEntrega(\$entregaId: ID!, \$pin: String!, \$estado: String!) {
      finalizarEntrega(entregaId: \$entregaId, pin: \$pin, estado: \$estado) {
        entrega {
          id
          estado
          fechaEntrega
        }
        error
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega en curso'),
        backgroundColor: primaryBlue,
        centerTitle: true,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(entregaQuery),
          variables: {"id": entregaId},
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Center(child: Text('Error al cargar: ${result.exception.toString()}'));
          }
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final entrega = result.data!['entrega'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Glass-style Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Entrega ID: ${entrega['id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('Estado: ${entrega['estado']}'),
                        Text('Fecha de Entrega: ${entrega['fechaEntrega']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Ingresar PIN para validar entrega:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'PIN',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Mutation(
                    options: MutationOptions(
                      document: gql(finalizarEntregaMutation),
                      onCompleted: (dynamic resultData) {
                        final error = resultData?['finalizarEntrega']['error'];
                        if (error == null) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('¡Éxito!'),
                              content: const Text('Entrega finalizada correctamente.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cierra el diálogo
                                    Navigator.pop(context); // Regresa a la lista
                                  },
                                  child: const Text('Aceptar'),
                                )
                              ],
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                        }
                      },
                    ),
                    builder: (runMutation, mutationResult) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                        onPressed: () {
                          final pin = _pinController.text.trim();
                          if (pin.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, ingresa el PIN')));
                            return;
                          }

                          runMutation({
                            'entregaId': entregaId,
                            'pin': pin,
                            'estado': 'Entregada',
                          });
                        },
                        child: mutationResult?.isLoading ?? false
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Finalizar entrega'),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}