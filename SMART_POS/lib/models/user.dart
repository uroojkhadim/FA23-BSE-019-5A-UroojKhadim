class User {
  final int? id;
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String role; // 'admin', 'cashier', 'manager'
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.role = 'cashier',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phone: map['phone'],
      role: map['role'] ?? 'cashier',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? name,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}