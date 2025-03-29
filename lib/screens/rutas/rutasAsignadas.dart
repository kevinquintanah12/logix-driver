import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RutasAsignadas extends StatefulWidget {
  const RutasAsignadas({Key? key}) : super(key: key);

  @override
  State<RutasAsignadas> createState() => _RutasAsignadasState();
}

class _RutasAsignadasState extends State<RutasAsignadas>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool onDuty = true;

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

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);
    const Color tabUnselectedColor = Colors.grey;
    const Color tabSelectedColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Orders'),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return Column(
            children: [
              Container(
                color: primaryBlue,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Disponible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 18 : 16,
                            ),
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
                        indicatorColor: tabSelectedColor,
                        labelColor: tabSelectedColor,
                        unselectedLabelColor: tabUnselectedColor,
                        tabs: const [
                          Tab(text: 'Por Hacer'),
                          Tab(text: 'Completado'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildToDoList(isDesktop),
                    _buildCompletedList(isDesktop),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/rutasMap');
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.map, color: Colors.white),
      ),
    );
  }

  Widget _buildToDoList(bool isDesktop) {
    return FutureBuilder(
      future: fetchRutasPorEstado('por hacer'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || (snapshot.data as List).isEmpty) {
          return const Center(child: Text('No hay rutas designadas'));
        }

        final rutas = snapshot.data as List;

        return Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final ruta = rutas[index];
              return _buildOrderCard(
                title: 'Delivery — ${ruta['fechaInicio']}',
                address: ruta['vehiculo']['modelo'],
                info:
                    'Stop: ${ruta['id']} | ${ruta['distancia']} mins | ${ruta['conductor']['nombre']}',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(bool isDesktop) {
    return FutureBuilder(
      future: fetchRutasPorEstado('completada'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || (snapshot.data as List).isEmpty) {
          return const Center(child: Text('No hay rutas designadas'));
        }

        final rutas = snapshot.data as List;

        return Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final ruta = rutas[index];
              return _buildOrderCard(
                title: 'Delivery completado — ${ruta['fechaFin']}',
                address: ruta['vehiculo']['modelo'],
                info:
                    'Stop: ${ruta['id']} | ${ruta['distancia']} mins | ${ruta['conductor']['nombre']}',
              );
            },
          ),
        );
      },
    );
  }

  Future<List> fetchRutasPorEstado(String estado) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    final String query = '''
      query {
        rutasPorEstado(estado: "$estado") {
          id
          distancia
          prioridad
          estado
          fechaInicio
          fechaFin
          conductor {
            id
            nombre
          }
          vehiculo {
            id
            modelo
          }
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {},
      ),
    );

    if (result.hasException) {
      throw Exception('Error al obtener rutas: ${result.exception}');
    }

    return result.data?['rutasPorEstado'] ?? [];
  }

  Widget _buildOrderCard({
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.pushNamed(context, '/rutasDetallada');
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              address,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              info,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
