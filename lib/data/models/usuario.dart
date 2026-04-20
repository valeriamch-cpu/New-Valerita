class Usuario {
  final int? id;
  final String username;
  final String passwordHash;
  final String role;

  const Usuario({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';

  @override
  String toString() => 'Usuario(id: $id, username: $username, role: $role)';
}
