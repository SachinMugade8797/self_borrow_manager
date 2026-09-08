import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/transaction_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('borrow_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        client_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        due_date TEXT,
        is_settled INTEGER DEFAULT 0,
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');
  }


  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getAllClients() async {
    final db = await database;
    final result = await db.query('clients', orderBy: 'name ASC');
    return result.map((e) => Client.fromMap(e)).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'client_id = ?', whereArgs: [id]);
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(TransactionEntry tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap());
  }

  Future<List<TransactionEntry>> getAllTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => TransactionEntry.fromMap(e)).toList();
  }

  Future<List<TransactionEntry>> getTransactionsByClient(int clientId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
    return result.map((e) => TransactionEntry.fromMap(e)).toList();
  }

  Future<int> settleTransaction(int id) async {
    final db = await database;
    return await db.update(
      'transactions',
      {'is_settled': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }


  Future<Map<String, double>> getSummary() async {
    final db = await database;

    final gaveResult = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type='gave' AND is_settled=0",
    );
    final receivedResult = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type='received' AND is_settled=0",
    );

    double gave = (gaveResult.first['total'] as num).toDouble();
    double received = (receivedResult.first['total'] as num).toDouble();

    return {
      'gave': gave,
      'received': received,
      'balance': gave - received,
    };
  }

  Future<List<TransactionEntry>> getPendingReminders() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.query(
      'transactions',
      where: "due_date IS NOT NULL AND due_date <= ? AND is_settled = 0",
      whereArgs: [today],
      orderBy: 'due_date ASC',
    );
    return result.map((e) => TransactionEntry.fromMap(e)).toList();
  }
}
