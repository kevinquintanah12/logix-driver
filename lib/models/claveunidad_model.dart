class ClaveUnidad {
  final int id; // El campo id
  

  ClaveUnidad({
    required this.id, 
  
  });

  factory ClaveUnidad.fromJson(Map<String, dynamic> json) {
    return ClaveUnidad(
        id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0, 
     
    );
  }
}
