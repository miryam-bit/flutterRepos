class User {
  final int id;
  final String name;
  final String email;
  final String? role; // Role might be useful, make it nullable

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0, // Handle potential null or incorrect type
      name: json['name'] as String? ?? 'Unknown User',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
} 