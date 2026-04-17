import '../database.dart';
import '../models/caja.dart';

class CajaRepository {
  Future<List<Caja>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT c.*, r.nombre as rack_nombre
      FROM cajas c
      LEFT JOIN racks r ON c.rack_id = r.id
      ORDER BY c.nombre
    ''');
    return rows.map(Caja.fromMap).toList();
  }

  Future<Caja?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT c.*, r.nombre as rack_nombre
      FROM cajas c
      LEFT JOIN racks r ON c.rack_id = r.id
      WHERE c.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return Caja.fromMap(rows.first);
  }

  Future<Caja?> getByNombre(String nombre) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('cajas', where: 'nombre = ?', whereArgs: [nombre]);
    if (rows.isEmpty) return null;
    return Caja.fromMap(rows.first);
  }

  Future<int> create(String nombre, {int? rackId}) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('cajas', {'nombre': nombre, 'rack_id': rackId});
  }

  Future<void> update(Caja caja) async {
    final db = await AppDatabase.instance.database;
    await db.update('cajas', caja.toMap(), where: 'id = ?', whereArgs: [caja.id]);
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('cajas', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Caja>> getByRack(int rackId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('cajas', where: 'rack_id = ?', whereArgs: [rackId]);
    return rows.map(Caja.fromMap).toList();
  }
}
