import '../database.dart';
import '../models/rack.dart';

class RackRepository {
  Future<List<Rack>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('racks', orderBy: 'nombre');
    return rows.map(Rack.fromMap).toList();
  }

  Future<Rack?> getById(int id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('racks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Rack.fromMap(rows.first);
  }

  Future<int> create(String nombre) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('racks', {'nombre': nombre});
  }

  Future<void> update(Rack rack) async {
    final db = await AppDatabase.instance.database;
    await db.update('racks', rack.toMap(), where: 'id = ?', whereArgs: [rack.id]);
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('racks', where: 'id = ?', whereArgs: [id]);
  }
}
