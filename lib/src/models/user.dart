import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String? id;
  String? nombre;
  String? apellido;
  String? celular;
  String? correo;
  String? direccion;
  String? observacion;
  String? estado;
  String? sessionToken;

  User({
    this.id,
    this.nombre,
    this.apellido,
    this.celular,
    this.correo,
    this.direccion,
    this.observacion,
    this.estado,
    this.sessionToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    nombre: json["nombre"],
    apellido: json["apellido"],
    celular: json["celular"],
    correo: json["correo"],
    direccion: json["direccion"],
    observacion: json["observacion"],
    estado: json["estado"],
    sessionToken: json["session_token"], // Asegúrate de que este campo coincida con el que estás usando
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "apellido": apellido,
    "celular": celular,
    "correo": correo,
    "direccion": direccion,
    "observacion": observacion,
    "estado": estado,
    "session_token": sessionToken,
  };
}
