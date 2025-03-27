import 'package:flutter/material.dart';

class EntregarPaquete extends StatefulWidget {
  const EntregarPaquete({Key? key}) : super(key: key);

  @override
  State<EntregarPaquete> createState() => _EntregarPaqueteState();
}

class _EntregarPaqueteState extends State<EntregarPaquete> {
  final TextEditingController _pinController = TextEditingController();

  // Datos de ejemplo
  final String paquete = 'Paquete PKG9392';
  final String destinatario = 'Juan Pérez';
  final String fechaEntrega = '2025-03-27';
  final String estado = 'Pendiente';

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0B3C5D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Entregar Paquete'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paquete,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Destinatario: $destinatario', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Fecha de Entrega: $fechaEntrega', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Estado: $estado', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                onPressed: () {
                  Navigator.pushNamed(context, '/verRuta');
                },
                child: const Text('Ver Ruta'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ingresar PIN para validar entrega:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                  onPressed: () {
                    final pin = _pinController.text;
                    if (pin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingresa el PIN')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Entrega validada con PIN: $pin')),
                      );
                    }
                  },
                  child: const Text('Validar Entrega'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
