final String marcaQuery = """
  query {
    marcas(search: "*") {
      id
      description
    }
  }
""";
