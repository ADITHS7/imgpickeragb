class User {
  final int id;
  String name;
  String? imagePath;

  User({required this.id, required this.name, this.imagePath});

  User copyWith({int? id, String? name, String? imagePath}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imagePath': imagePath};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
    );
  }
}
