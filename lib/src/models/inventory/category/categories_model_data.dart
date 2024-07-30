class Category {
  int? id;
  String? name;
  String? observation;
  String? status;

  Category({this.id, this.name, this.observation, this.status});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['nombre'],
      observation: json['observacion'],
      status: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'observacion': observation,
      'estado': status,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? observation,
    String? status,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      observation: observation ?? this.observation,
      status: status ?? this.status,
    );
  }
}
