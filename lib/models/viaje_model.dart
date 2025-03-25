class Viaje {
  //String folio = '';
  //String fechainicio = '';
  //String fechafin = '';
  int idOperador= 0;
  int idtransportista = 0;
  int idremolque = 0;
  int iddolly = 0;
  //int idvehiculo = 0;

  Viaje({
    //required this.folio,
    //required this.fechainicio,
    //this.fechafin,
    this.idOperador = 0,
    this.idtransportista = 0,
    this.iddolly = 0,
    this.idremolque = 0,
    
    //this.idvehiculo = 0
  });


  //setters
  set Idoperador(int value){
    idOperador = value;
  }
  set Idtransportista(int value){
    idtransportista = value;
  }
  set Idremolque(int value){
    idremolque = value;
  }
  set Iddolly(int value){
    iddolly = value;
  }
  //set Idvehiculo(int value){
  //  idvehiculo = value;
  //}

  //getters
  int get Idoperador => idOperador;
  int get Idtransportista => idtransportista;
  int get Idremolque => idremolque;
  int get Iddolly => iddolly;
  //int get Idvehiculo => idvehiculo;



// Pasar viaje, N-puntos,


  factory Viaje.fromJson(Map<String, dynamic> json) {
    return Viaje(
      //folio: json['folio'],
      //fechainicio: json['fechainicio'],
      //fechafin: json['fechafin'],
      idOperador: json['idOperador'],
      idtransportista: json['IdTransportista'],
      iddolly: json['IdDolly'],
      idremolque: json['IdRemolque'],
      //idvehiculo: json['IdVehiculo']
    );
  }
}

class Marca {
  final String description;

  Marca({required this.description});

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(description: json['description']);
  }
}

class Linea {
  final String description;

  Linea({required this.description});

  factory Linea.fromJson(Map<String, dynamic> json) {
    return Linea(description: json['description']);
  }
}
