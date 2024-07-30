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
      firstName: json['nombres'] ?? 'N/A',
      lastName: json['apellidos'] ?? 'N/A',
      email: json['correo'] ?? 'N/A',
      message: json['mensaje'] ?? 'N/A',
      date: json['fecha_ingreso'] ?? 'N/A',
      senderName: json['usuario_quien_envia'] ?? 'N/A',
    );
  }
}
