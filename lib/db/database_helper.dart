import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'spending_tracker.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _categoriesTable = 'categories';
  static const String _expensesTable = 'expenses';

  // Category table columns
  static const String colCategoryId = 'id';
  static const String colCategoryName = 'name';

  // Expense table columns
  static const String colExpenseId = 'id';
  static const String colExpenseCategoryId = 'categoryId';
  static const String colExpenseName = 'name';
  static const String colExpenseAmount = 'amount';
  static const String colExpenseDate = 'date';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE $_categoriesTable(
        $colCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCategoryName TEXT NOT NULL UNIQUE
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE $_expensesTable(
        $colExpenseId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colExpenseCategoryId INTEGER NOT NULL,
        $colExpenseName TEXT NOT NULL,
        $colExpenseAmount REAL NOT NULL,
        $colExpenseDate TEXT NOT NULL,
        FOREIGN KEY ($colExpenseCategoryId) REFERENCES $_categoriesTable($colCategoryId) ON DELETE CASCADE
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      'Food',
      'Clothing',
      'Hotel Stays',
      'Traveling',
      'Payment to Friend',
      'Bills Payment',
    ];

    for (var categoryName in defaultCategories) {
      await db.insert(_categoriesTable, {'name': categoryName});
    }
  }

  // --- Category Operations ---

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(_categoriesTable, category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_categoriesTable);
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      _categoriesTable,
      category.toMap(),
      where: '$colCategoryId = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      _categoriesTable,
      where: '$colCategoryId = ?',
      whereArgs: [id],
    );
  }

  // --- Expense Operations ---

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(_expensesTable, expense.toMap());
  }

  Future<List<Expense>> getExpensesByCategoryId(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _expensesTable,
      where: '$colExpenseCategoryId = ?',
      whereArgs: [categoryId],
      orderBy: '$colExpenseDate DESC', // Order by date, newest first
    );
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_expensesTable);
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      _expensesTable,
      expense.toMap(),
      where: '$colExpenseId = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      _expensesTable,
      where: '$colExpenseId = ?',
      whereArgs: [id],
    );
  }
}