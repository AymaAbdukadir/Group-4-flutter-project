class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo': photo,
    };
  }

  bool get isAdmin => role == 'admin';
}
