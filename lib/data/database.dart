import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bodega.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'operador'
      )
    ''');
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sku TEXT NOT NULL UNIQUE,
        barcode TEXT,
        nombre TEXT NOT NULL,
        marca TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE racks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE cajas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        rack_id INTEGER REFERENCES racks(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        device_id TEXT NOT NULL,
        user_id INTEGER NOT NULL REFERENCES usuarios(id),
        timestamp TEXT NOT NULL,
        sku TEXT NOT NULL REFERENCES productos(sku),
        caja_id INTEGER NOT NULL REFERENCES cajas(id),
        delta INTEGER NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movimiento_uuid TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        sent INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Seed admin user
    final adminHash = sha256.convert(utf8.encode('admin123')).toString();
    await db.insert('usuarios', {
      'username': 'admin',
      'password_hash': adminHash,
      'role': 'admin',
    });
  }

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
