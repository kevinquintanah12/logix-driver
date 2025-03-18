import 'package:shop/models/ruta_detail.dart';

class Ruta {
  final int idruta;
  final String description;
  final int idorigen;
  final int iddestino ;
  final List<RutaDetail> puntos;

  Ruta({
    required this.idruta,
    required this.description,
    required this.idorigen,
    required this.iddestino,
    required this.puntos,
  });


// Pasar viaje, N-puntos,


  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      idruta: json['idRuta'],
      description: json['Descripcion'],
      idorigen: json['idOrigen'],
      iddestino: json['idDestino'],
      puntos: json['puntos'],
    );
  }
}

