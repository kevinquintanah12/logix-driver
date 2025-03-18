class MarcaModel  {
  final int id; // El campo id
  final String description; // El campo description

  MarcaModel({
    required this.id,
    required this.description, // Campo requerido en el constructor
  });

  factory MarcaModel.fromJson(Map<String, dynamic> json) {
    return MarcaModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      description: json['description'] != null ? json['description'].toString() : '', // Manejo de null para description
    );
  }
}
