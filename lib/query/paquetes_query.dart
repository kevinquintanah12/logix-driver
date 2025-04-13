const String queryPorEntregar = """
  query {
    entregasPorEstado(estado: "por entregar") {
      id
      paquete {
        id
        producto {
          id
          destinatario {
        		nombre
        		latitud
        		longitud
      		}
      	}
      }
      estado
      fechaEntrega
    }
  }
""";


const String queryEntregadas = """
  query {
    entregasPorEstado(estado: "entregados") {
      id
      paquete {
        id
        producto {
          id
          destinatario {
        		nombre
        		latitud
        		longitud
      		}
      	}
      }
      estado
      fechaEntrega
    }
  }
""";