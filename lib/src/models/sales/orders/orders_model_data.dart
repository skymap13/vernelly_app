class Order {
  int? id;
  String? userName;
  String? date;
  double? total;

  Order({this.id, this.userName, this.date, this.total});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userName: json['nombre_usuario'],
      date: json['fecha_ingreso'],
      total: double.tryParse(json['total'].toString()),  // Conversión a double
    );
  }
}

class OrderDetail {
  int? id;
  String? productName;
  double? price;
  int? quantity;

  OrderDetail({this.id, this.productName, this.price, this.quantity});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      productName: json['nombre_producto'],
      price: double.tryParse(json['precio'].toString()),  // Conversión a double
      quantity: json['cantidad'],
    );
  }
}
