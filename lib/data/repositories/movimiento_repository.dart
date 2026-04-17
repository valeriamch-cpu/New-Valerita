import '../database.dart';
import '../models/movimiento.dart';

class MovimientoRepository {
  Future<int> getStock(int cajaId, String sku) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(delta), 0) as stock FROM movimientos WHERE caja_id = ? AND sku = ?',
      [cajaId, sku],
    );
    return (result.first['stock'] as int?) ?? 0;
  }

  Future<Map<String, int>> getStockByCaja(int cajaId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      'SELECT sku, SUM(delta) as stock FROM movimientos WHERE caja_id = ? GROUP BY sku HAVING SUM(delta) > 0',
      [cajaId],
    );
    final result = <String, int>{};
    for (final row in rows) {
      result[row['sku'] as String] = (row['stock'] as int?) ?? 0;
    }
    return result;
  }

  Future<Map<int, int>> getStockBySku(String sku) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      'SELECT caja_id, SUM(delta) as stock FROM movimientos WHERE sku = ? GROUP BY caja_id HAVING SUM(delta) > 0',
      [sku],
    );
    final result = <int, int>{};
    for (final row in rows) {
      result[row['caja_id'] as int] = (row['stock'] as int?) ?? 0;
    }
    return result;
  }

  Future<void> registrarMovimiento(Movimiento movimiento) async {
    final db = await AppDatabase.instance.database;
    final currentStock = await getStock(movimiento.cajaId, movimiento.sku);
    if (currentStock + movimiento.delta < 0) {
      throw Exception('Stock insuficiente: stock actual $currentStock, delta ${movimiento.delta}');
    }
    await db.transaction((txn) async {
      await txn.insert('movimientos', movimiento.toMap());
      await txn.insert('outbox', {
        'movimiento_uuid': movimiento.uuid,
        'created_at': DateTime.now().toIso8601String(),
        'sent': 0,
      });
    });
  }

  Future<List<Map<String, dynamic>>> getMovimientosByCaja(int cajaId) async {
    final db = await AppDatabase.instance.database;
    return await db.rawQuery('''
      SELECT m.*, p.nombre as producto_nombre, u.username
      FROM movimientos m
      JOIN productos p ON m.sku = p.sku
      JOIN usuarios u ON m.user_id = u.id
      WHERE m.caja_id = ?
      ORDER BY m.timestamp DESC
    ''', [cajaId]);
  }

  Future<List<Map<String, dynamic>>> getMovimientosBySku(String sku) async {
    final db = await AppDatabase.instance.database;
    return await db.rawQuery('''
      SELECT m.*, c.nombre as caja_nombre, u.username
      FROM movimientos m
      JOIN cajas c ON m.caja_id = c.id
      JOIN usuarios u ON m.user_id = u.id
      WHERE m.sku = ?
      ORDER BY m.timestamp DESC
    ''', [sku]);
  }

  Future<List<Map<String, dynamic>>> getPendingOutbox() async {
    final db = await AppDatabase.instance.database;
    return await db.query('outbox', where: 'sent = 0', orderBy: 'created_at');
  }
}
