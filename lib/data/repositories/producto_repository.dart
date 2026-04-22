import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../models/producto.dart';

class ProductoRepository {
  Future<List<Producto>> search({String? query}) async {
    final db = await AppDatabase.instance.database;
    if (query == null || query.isEmpty) {
      final rows = await db.query('productos', orderBy: 'nombre');
      return rows.map(Producto.fromMap).toList();
    }
    final q = '%$query%';
    final rows = await db.query(
      'productos',
      where: 'sku LIKE ? OR barcode LIKE ? OR nombre LIKE ? OR marca LIKE ?',
      whereArgs: [q, q, q, q],
      orderBy: 'nombre',
    );
    return rows.map(Producto.fromMap).toList();
  }

  Future<Producto?> getBySku(String sku) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('productos', where: 'sku = ?', whereArgs: [sku]);
    if (rows.isEmpty) return null;
    return Producto.fromMap(rows.first);
  }

  Future<Producto?> getByBarcode(String barcode) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('productos', where: 'barcode = ?', whereArgs: [barcode]);
    if (rows.isEmpty) return null;
    return Producto.fromMap(rows.first);
  }

  Future<int> upsert(Producto producto) async {
    final db = await AppDatabase.instance.database;
    final existing = await getBySku(producto.sku);
    if (existing != null) {
      await db.update(
        'productos',
        producto.toMap(),
        where: 'sku = ?',
        whereArgs: [producto.sku],
      );
      return existing.id!;
    } else {
      return await db.insert('productos', producto.toMap());
    }
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> importFromCsv(List<Map<String, dynamic>> rows) async {
    final db = await AppDatabase.instance.database;
    int count = 0;
    final batch = db.batch();
    for (final row in rows) {
      final nombre = (row['nombre'] ?? row['Nombre'] ?? '').toString().trim();
      final marca = (row['marca'] ?? row['Marca'] ?? '').toString().trim();
      final barcode = (row['codigo_barra'] ?? row['Codigo_Barra'] ?? row['codigo_barras'] ?? '').toString().trim();
      final sku = (row['sku'] ?? row['SKU'] ?? row['Sku'] ?? '').toString().trim();
      if (sku.isEmpty || nombre.isEmpty) continue;
      batch.insert(
        'productos',
        {
          'sku': sku,
          'barcode': barcode.isEmpty ? null : barcode,
          'nombre': nombre,
          'marca': marca.isEmpty ? null : marca,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;
    }
    await batch.commit(noResult: true);
    return count;
  }
}
