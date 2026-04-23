import '../database.dart';
import '../models/usuario.dart';

class AuthRepository {
  Future<Usuario?> login(String username, String password) async {
    final db = await AppDatabase.instance.database;
    final hash = AppDatabase.hashPassword(password);
    final rows = await db.query(
      'usuarios',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hash],
    );
    if (rows.isEmpty) return null;
    return Usuario.fromMap(rows.first);
  }

  Future<List<Usuario>> getAllUsuarios() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('usuarios', orderBy: 'username');
    return rows.map(Usuario.fromMap).toList();
  }

  Future<void> createUsuario({
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await AppDatabase.instance.database;
    final hash = AppDatabase.hashPassword(password);
    await db.insert('usuarios', {
      'username': username,
      'password_hash': hash,
      'role': role,
    });
  }

  Future<void> deleteUsuario(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }
}
