class ActidadModel {
  final String fecha;
  final String hora;
  final int idactividad;
  final int idproducto;
  final int cantidad;
  final int idunidadmedida;


  ActidadModel({
    required this.fecha,
    required this.hora,
    required this.idactividad,
    required this.idproducto,
    required this.cantidad,
    required this.idunidadmedida
  });


// Pasar viaje, N-puntos,


  factory ActidadModel.fromJson(Map<String, dynamic> json) {
    return ActidadModel(
      fecha: json['fecha'],
      hora: json['hora'],
      idactividad: json['idactividad'],
      idproducto: json['idproducto'],
      cantidad: json['cantidad'],
      idunidadmedida: json['idunidadmedida'],
    );
  }
}

