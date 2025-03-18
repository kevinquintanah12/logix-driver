import 'package:shop/models/actidad_model.dart';

class RutaDetail {
  final int iddetail;
  final String nombre;
  final int idcategoria;
  final int idclasificacion;
  final String audio;
  final List <ActidadModel> actividades; //Que sea tipo ArrayList


  RutaDetail({
    required this.iddetail,
    required this.nombre,
    required this.idcategoria,
    required this.idclasificacion,
    required this.audio,
    required this.actividades,

  });


// Pasar viaje, N-puntos,


  factory RutaDetail.fromJson(Map<String, dynamic> json) {
    return RutaDetail(
      iddetail: json['iddetail'],
      nombre: json['nombre'],
      idcategoria: json['categoria'],
      idclasificacion: json['idOrigen'],
      audio: json['idDestino'],
      actividades: json['actividades']
    );
  }
}

