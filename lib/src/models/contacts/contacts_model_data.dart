class Contact {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? message;
  String? date;
  String? senderName;

  Contact({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.message,
    this.date,
    this.senderName,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      firstName: json['nombres'],
      lastName: json['apellidos'],
      email: json['correo'],
      message: json['mensaje'],
      date: json['fecha_ingreso'],
      senderName: json['usuario_ingreso'], // Asegúrate de que esta clave coincide con el backend
    );
  }
}
