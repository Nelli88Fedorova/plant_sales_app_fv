// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  // Паттерн Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Инициализация БД с версией 2 и поддержкой обновления
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'plant_sales.db');
    return await openDatabase(
      path,
      version: 2, // увеличиваем версию!
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Создание таблицы с новыми полями
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        composition TEXT,
        manufacturer TEXT,
        package TEXT,
        consumption_rate TEXT,
        price REAL
      )
    ''');
  }

  // Миграция для старых баз данных (добавляем недостающие колонки)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN composition TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN manufacturer TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN package TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN consumption_rate TEXT');
      // Опционально: можно удалить старое поле description, если оно есть
      // но это необязательно — лучше просто оставить как есть
    }
  }

  // --- CRUD Операции ---

  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertProducts(List<Product> products) async {
    Database db = await database;
    Batch batch = db.batch();
    for (var product in products) {
      batch.insert('products', product.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteAllProducts() async {
    Database db = await database;
    await db.delete('products');
  }
}