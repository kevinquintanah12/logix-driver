class LineaModel {
  final int id; // El campo id
  final String description; // El campo description

  LineaModel({
    required this.id,
    required this.description, // Campo requerido en el constructor
  });

  factory LineaModel.fromJson(Map<String, dynamic> json) {
    return LineaModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      description: json['description'] != null ? json['description'].toString() : '', // Manejo de null para description
    );
  }
}
