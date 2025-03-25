class CodigoSat {
  final int id; // El campo id
  

  CodigoSat({
    required this.id, 
  
  });

  factory CodigoSat.fromJson(Map<String , dynamic> json) {
    return CodigoSat(
        id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0, 
     
    );
  }
}
