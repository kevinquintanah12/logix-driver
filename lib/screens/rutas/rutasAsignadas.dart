import 'package:flutter/material.dart';

class RutasAsignadas extends StatefulWidget {
  const RutasAsignadas({Key? key}) : super(key: key);

  @override
  State<RutasAsignadas> createState() => _RutasAsignadasState();
}

class _RutasAsignadasState extends State<RutasAsignadas> with SingleTickerProviderStateMixin {
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEXT STOP',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildOrderCard(
              title: 'Delivery — 11:03 AM',
              address: 'Main Street, 525, Boston',
              info: 'Stop: 109 | 120 mins | ORD9392',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedList(bool isDesktop) {
    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildOrderCard(
          title: 'Delivery completado — ${index + 1}',
          address: 'Dirección X, Ciudad',
          info: 'Stop: ${index + 100} | 90 mins | ORD900${index + 1}',
        );
      },
    );
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
            // Fila que contiene el título y el icono de detalles.
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
