
const String readProductosQuery = r'''
  query ReadProductos {
    links(search: "*") {
      id
      url
      description
      precio
      modelo
      marca {
        
        description
      }
      linea {
        
        description
      }
      claveunidad {
        id
      }
      codigobarras
      codigosat {
        id
      }
      descuento
      existencias
      noidentificacion
      retencionieps
      retencionisr
      retencioniva
      stockmax
      stockmin
      trasladoieps
      trasladoiva
    }
  }

     
''';
