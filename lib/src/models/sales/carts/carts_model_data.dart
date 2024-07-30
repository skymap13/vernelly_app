class Cart {
  int? id;
  String? userName;
  String? date;
  String? status;

  Cart({
    this.id,
    this.userName,
    this.date,
    this.status,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userName: json['nombre_usuario'],
      date: json['fecha_ingreso'],
      status: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_usuario': userName,
      'fecha_ingreso': date,
      'estado': status,
    };
  }
}

class CartDetail {
  int? id;
  String? productName;
  int? quantity;

  CartDetail({
    this.id,
    this.productName,
    this.quantity,
  });

  factory CartDetail.fromJson(Map<String, dynamic> json) {
    return CartDetail(
      id: json['id'],
      productName: json['nombre_producto'],
      quantity: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_producto': productName,
      'cantidad': quantity,
    };
  }
}
