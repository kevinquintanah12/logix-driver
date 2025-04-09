import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/query/paquetes_query.dart';  // Asegúrate de que las consultas estén bien definidas

class PaquetesAsignados extends StatefulWidget {
  const PaquetesAsignados({super.key});

  @override
  State<PaquetesAsignados> createState() => _PaquetesAsignadosState();
}

class _PaquetesAsignadosState extends State<PaquetesAsignados>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool onDuty = true;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para obtener el token JWT almacenado
  Future<String?> _getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Paquetes'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return Column(
            children: [
              _buildTopSection(isDesktop),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Aquí usas las consultas para los paquetes 'por entregar' y 'entregados'
                    _buildPackageList(queryPorEntregar, isDesktop),  // Consulta por entregar
                    _buildPackageList(queryEntregadas, isDesktop),  // Consulta entregadas
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopSection(bool isDesktop) {
    const Color primaryBlue = Color(0xFF0B3C5D);
    return Container(
      color: primaryBlue,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar paquete...',
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.white),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Disponible',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      activeColor: Colors.white,
                      activeTrackColor: Colors.lightBlueAccent,
                      value: onDuty,
                      onChanged: (value) {
                        setState(() {
                          onDuty = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Por Hacer'),
                    Tab(text: 'Completado'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método para construir la lista de paquetes con las consultas GraphQL
  Widget _buildPackageList(String query, bool isDesktop) {
    return FutureBuilder<String?>(
      future: _getAuthToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final String? token = snapshot.data;
        if (token == null) {
          return const Center(child: Text("⚠️ Error: No se encontró el token de autenticación."));
        }

        return Query(
          options: QueryOptions(
            document: gql(query),
            context: const Context().withEntry(
              HttpLinkHeaders(
                headers: {"Authorization": "Bearer $token"},
              ),
            ),
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (result.hasException) {
              return Center(child: Text("Error: ${result.exception.toString()}"));
            }

            final List entregas = result.data?['entregasPorEstado'] ?? [];

            if (entregas.isEmpty) {
              return const Center(child: Text("No hay paquetes disponibles."));
            }

            return ListView.builder(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              itemCount: entregas.length,
              itemBuilder: (context, index) {
                final entrega = entregas[index];
                final paquete = entrega['paquete'] ?? {};
                final destinatario = entrega['destinatario'] ?? {};

                return _buildPackageCard(
                  title: '${paquete['producto']['id'] ?? 'Sin ID'} — ${entrega['fechaEntrega'] ?? 'Fecha desconocida'}',
                  address: '${destinatario['latitud'] ?? 'Latitud desconocida'}, ${destinatario['longitud'] ?? 'Longitud desconocida'}',
                  info: 'ID: ${entrega['id'] ?? 'Desconocido'} | Estado: ${entrega['estado'] ?? 'Sin estado'}',
                );
              },
            );
          },
        );
      },
    );
  }

  // Método para construir las tarjetas de los paquetes
  Widget _buildPackageCard({
    required String title,
    required String address,
    required String info,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              info,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B3C5D)),
                onPressed: () {
                  Navigator.pushNamed(context, '/entregarPaquete');
                },
                child: const Text('Entregar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
