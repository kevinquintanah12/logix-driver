import 'package:flutter/material.dart';

class PaquetesAsignados extends StatefulWidget {
  const PaquetesAsignados({Key? key}) : super(key: key);

  @override
  State<PaquetesAsignados> createState() => _PaquetesAsignadosState();
}

class _PaquetesAsignadosState extends State<PaquetesAsignados>
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
        title: const Text('Paquetes'),
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
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar paquete...',
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
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
              'PRÓXIMO PAQUETE',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPackageCard(
              title: 'Paquete — 11:03 AM',
              address: 'Calle Principal, 525, Ciudad',
              info: 'ID: 109 | 120 mins | PKG9392',
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
        return _buildPackageCard(
          title: 'Paquete entregado — ${index + 1}',
          address: 'Dirección X, Ciudad',
          info: 'ID: ${index + 100} | 90 mins | PKG900${index + 1}',
        );
      },
    );
  }

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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B3C5D),
                ),
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