class ResponseAPi {
  bool? success;
  String? message;
  String? name;
  String? lastname;
  String? token;
  int? perfil;

  ResponseAPi({this.success, this.message, this.name, this.lastname, this.token, this.perfil});

  factory ResponseAPi.fromJson(Map<String, dynamic> json) {
    return ResponseAPi(
      success: json['success'],
      message: json['message'],
      name: json['name'],
      lastname: json['lastname'],
      token: json['token'],
      perfil: json['perfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'name': name,
      'lastname': lastname,
      'token': token,
      'perfil': perfil,
    };
  }
}
