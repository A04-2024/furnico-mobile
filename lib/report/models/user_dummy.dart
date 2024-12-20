// lib/report/models/user_dummy.dart

class User {
  final int id;
  final String username;
  final String role; // 'admin' atau 'user'

  User({
    required this.id,
    required this.username,
    required this.role,
  });

  // Factory constructor untuk membuat instance User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
    );
  }

  // Method untuk mengonversi instance User menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}

// Contoh pengguna
final User regularUser = User(
  id: 1, // ID untuk pengguna reguler
  username: 'user123',
  role: 'regularuser',
);

final User adminUser = User(
  id: 2, // ID untuk admin pengguna
  username: 'admin123',
  role: 'adminuser',
);
