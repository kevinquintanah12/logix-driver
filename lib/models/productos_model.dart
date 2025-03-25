import 'claveunidad_model.dart'; // Asegúrate de importar la clase ClaveUnidad
import 'codigosat_model.dart'; // Asegúrate de importar la clase CodigoSat
import 'linea_model.dart'; // Asegúrate de importar la clase CodigoSat
import 'marca_model.dart'; // Asegúrate de importar la clase CodigoSat


class Producto {
  final String id; // El campo id
  final String idprod; // El campo idprod
  final String description;
  final double precio;
  final MarcaModel marca;
  final LineaModel linea;
  final int status; // El campo status
  final ClaveUnidad claveunidad; // Cambiado a ClaveUnidad
  final String codigobarras;
  final CodigoSat codigosat; // Cambiado a CodigoSat
  final double descuento;
  final double existencias;
  final String modelo;
  final String noidentificacion;
  final double retencionieps;
  final double retencionisr;
  final double retencioniva;
  final double stockmax;
  final double stockmin;
  final double trasladoieps;
  final double trasladoiva;
  final String url;

  Producto({
    required this.id, 
    required this.idprod, 
    required this.description,
    required this.precio,
    required this.marca,
    required this.linea,
    required this.status,
    required this.claveunidad, // Asegúrate de pasar un objeto ClaveUnidad
    required this.codigobarras,
    required this.codigosat, // Asegúrate de pasar un objeto CodigoSat
    required this.descuento,
    required this.existencias,
    required this.modelo,
    required this.noidentificacion,
    required this.retencionieps,
    required this.retencionisr,
    required this.retencioniva,
    required this.stockmax,
    required this.stockmin,
    required this.trasladoieps,
    required this.trasladoiva,
    required this.url,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? '',
      idprod: json['idprod'] ?? '',
      description: json['description'] ?? 'Sin descripción',
      precio: (json['precio'] != null) ? json['precio'].toDouble() : 0.0,
      marca: json['marca'] is Map<String, dynamic> // Validar si es un objeto
          ? MarcaModel.fromJson(json['marca'])
          : MarcaModel(id: 0, description: json['marca']?.toString() ?? 'Sin marca'),
      linea: json['linea'] is Map<String, dynamic> // Validar si es un objeto
          ? LineaModel.fromJson(json['linea'])
          : LineaModel(id: 0, description: json['linea']?.toString() ?? 'Sin línea'),
      status: json['status'] ?? 1,
      claveunidad: ClaveUnidad.fromJson(json['claveunidad'] ?? {}), // Crear instancia de ClaveUnidad
      codigobarras: json['codigobarras'] ?? '',
      codigosat: CodigoSat.fromJson(json['codigosat'] ?? {}), // Crear instancia de CodigoSat
      descuento: (json['descuento'] != null) ? json['descuento'].toDouble() : 0.0,
      existencias: (json['existencias'] != null) ? json['existencias'].toDouble() : 0.0,
      modelo: json['modelo'] ?? '',
      noidentificacion: json['noidentificacion'] ?? '',
      retencionieps: (json['retencionieps'] != null) ? json['retencionieps'].toDouble() : 0.0,
      retencionisr: (json['retencionisr'] != null) ? json['retencionisr'].toDouble() : 0.0,
      retencioniva: (json['retencioniva'] != null) ? json['retencioniva'].toDouble() : 0.0,
      stockmax: (json['stockmax'] != null) ? json['stockmax'].toDouble() : 0.0,
      stockmin: (json['stockmin'] != null) ? json['stockmin'].toDouble() : 0.0,
      trasladoieps: (json['trasladoieps'] != null) ? json['trasladoieps'].toDouble() : 0.0,
      trasladoiva: (json['trasladoiva'] != null) ? json['trasladoiva'].toDouble() : 0.0,
      url: json['url'] ?? '',
    );
  }
}
