// models/user.dart

class User {
  final String username;
  final String role; // 'adminuser' atau 'regularuser'

  User({required this.username, required this.role});
}

// Contoh pengguna
final User regularUser = User(username: 'user123', role: 'regularuser');
final User adminUser = User(username: 'admin123', role: 'adminuser');
