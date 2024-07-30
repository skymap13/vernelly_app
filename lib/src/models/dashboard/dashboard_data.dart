class DashboardData {
  int? cantProductos;
  int? cantCarritos;
  int? cantPedidos;
  List<Venta>? infoVentas;
  List<Ingreso>? ingresos;

  DashboardData({this.cantProductos, this.cantCarritos, this.cantPedidos, this.infoVentas, this.ingresos});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      cantProductos: json['cant_productos'],
      cantCarritos: json['cant_carritos'],
      cantPedidos: json['cant_pedidos'],
      infoVentas: json['info_ventas'] != null
          ? (json['info_ventas'] as List).map((i) => Venta.fromJson(i)).toList()
          : null,
      ingresos: json['ingresos'] != null
          ? (json['ingresos'] as List).map((i) => Ingreso.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cant_productos': cantProductos,
      'cant_carritos': cantCarritos,
      'cant_pedidos': cantPedidos,
      'info_ventas': infoVentas?.map((i) => i.toJson()).toList(),
      'ingresos': ingresos?.map((i) => i.toJson()).toList(),
    };
  }
}

class Venta {
  String? mes;
  String? result; // Cambiado a String

  Venta({this.mes, this.result});

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      mes: json['mes'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'result': result,
    };
  }
}

class Ingreso {
  String? mes;
  String? result; // Cambiado a String

  Ingreso({this.mes, this.result});

  factory Ingreso.fromJson(Map<String, dynamic> json) {
    return Ingreso(
      mes: json['mes'],
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'result': result,
    };
  }
}
