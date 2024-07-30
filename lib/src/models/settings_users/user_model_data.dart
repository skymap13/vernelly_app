class User {
  int? id;
  String? nombre;
  String? apellido;
  String? celular;
  String? correo;
  String? direccion;
  String? observacion;
  String? estado;
  int? idPerfil; // Nuevo campo

  User({
    this.id,
    this.nombre,
    this.apellido,
    this.celular,
    this.correo,
    this.direccion,
    this.observacion,
    this.estado,
    this.idPerfil, // Nuevo campo
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? json['id'] as int : null,
      nombre: json['nombre'] ?? 'Nombre no disponible',
      apellido: json['apellido'] ?? '',
      celular: json['celular'] ?? '',
      correo: json['correo'] ?? 'Email no disponible',
      direccion: json['direccion'] ?? '',
      observacion: json['observacion'] ?? '',
      estado: json['estado'] ?? '',
      idPerfil: json['id_perfil'] != null ? json['id_perfil'] as int : null, // Nuevo campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'celular': celular,
      'correo': correo,
      'direccion': direccion,
      'observacion': observacion,
      'estado': estado,
      'id_perfil': idPerfil, // Nuevo campo
    };
  }

  User copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? celular,
    String? correo,
    String? direccion,
    String? observacion,
    String? estado,
    int? idPerfil, // Nuevo campo
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      celular: celular ?? this.celular,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      observacion: observacion ?? this.observacion,
      estado: estado ?? this.estado,
      idPerfil: idPerfil ?? this.idPerfil, // Nuevo campo
    );
  }
}
