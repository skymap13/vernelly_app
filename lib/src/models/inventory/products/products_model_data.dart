class Product {
  int? id;
  String? nombre;
  int? idCategoria;
  String? codigox;
  String? observacion;
  double? precio;
  String? estado;

  Product({
    this.id,
    this.nombre,
    this.idCategoria,
    this.codigox,
    this.observacion,
    this.precio,
    this.estado,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      idCategoria: json['id_categoria'],
      codigox: json['codigox'],
      observacion: json['observacion'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'id_categoria': idCategoria,
      'codigox': codigox,
      'observacion': observacion,
      'precio': precio,
      'estado': estado,
    };
  }

  Product copyWith({
    int? id,
    String? nombre,
    int? idCategoria,
    String? codigox,
    String? observacion,
    double? precio,
    String? estado,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      idCategoria: idCategoria ?? this.idCategoria,
      codigox: codigox ?? this.codigox,
      observacion: observacion ?? this.observacion,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
    );
  }
}
