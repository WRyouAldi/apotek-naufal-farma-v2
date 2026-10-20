import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class PosDatabase {
  PosDatabase._();
  static final PosDatabase instance = PosDatabase._();
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'dshe_farma_pos.db');
    _db = await openDatabase(path, version: 1,
      onConfigure: (d) async => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, version) async {
        await d.execute('CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, code TEXT NOT NULL DEFAULT "", barcode TEXT NOT NULL DEFAULT "", price INTEGER NOT NULL CHECK(price >= 0), stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0))');
        await d.execute('CREATE INDEX idx_products_name ON products(name)');
        await d.execute('CREATE INDEX idx_products_code ON products(code)');
        await d.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
        await d.execute('CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, created_at TEXT NOT NULL, total INTEGER NOT NULL, paid INTEGER NOT NULL, change_amount INTEGER NOT NULL, payment_method TEXT NOT NULL)');
        await d.execute('CREATE TABLE transaction_items(id INTEGER PRIMARY KEY AUTOINCREMENT, transaction_id INTEGER NOT NULL, product_id INTEGER NOT NULL, product_name TEXT NOT NULL, quantity INTEGER NOT NULL CHECK(quantity > 0), unit_price INTEGER NOT NULL, subtotal INTEGER NOT NULL, FOREIGN KEY(transaction_id) REFERENCES transactions(id), FOREIGN KEY(product_id) REFERENCES products(id))');
      });
    return _db!;
  }
  Future<List<Product>> searchProducts(String query) async {
    final database = await db; final q = query.trim();
    final rows = q.isEmpty ? await database.query('products', orderBy: 'name COLLATE NOCASE', limit: 100) : await database.query('products', where: 'name LIKE ? OR code LIKE ? OR barcode LIKE ?', whereArgs: ['%$q%', '%$q%', '%$q%'], orderBy: 'name COLLATE NOCASE', limit: 100);
    return rows.map(Product.fromMap).toList();
  }
  Future<Product?> findByBarcode(String value) async {
    final rows = await (await db).query('products', where: 'barcode = ? OR code = ?', whereArgs: [value.trim(), value.trim()], limit: 1);
    return rows.isEmpty ? null : Product.fromMap(rows.first);
  }
  Future<void> saveProduct(Product product) async {
    if (product.name.trim().isEmpty) throw ArgumentError('Nama barang wajib diisi.');
    if (product.price < 0 || product.stock < 0) throw ArgumentError('Harga dan stok tidak boleh negatif.');
    final database = await db; final values = product.toMap()..remove('id');
    if (product.id == null) { await database.insert('products', values); } else { await database.update('products', values, where: 'id = ?', whereArgs: [product.id]); }
  }
  Future<int> productCount() async => Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
  Future<List<PosTransaction>> recentTransactions() async {
    final rows = await (await db).query('transactions', orderBy: 'id DESC', limit: 100);
    return rows.map((r) => PosTransaction(id: r['id'] as int, createdAt: r['created_at'] as String, total: r['total'] as int, paid: r['paid'] as int, change: r['change_amount'] as int, paymentMethod: r['payment_method'] as String)).toList();
  }
  Future<int> transactionCountToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM transactions WHERE substr(created_at,1,10) = ?', [today])) ?? 0;
  }
  Future<int> checkout({required List<CartLine> lines, required int paid, required String paymentMethod}) async {
    if (lines.isEmpty) throw StateError('Keranjang masih kosong.');
    final total = lines.fold<int>(0, (sum, item) => sum + item.subtotal);
    if (paid < total) throw StateError('Pembayaran kurang dari total transaksi.');
    final database = await db;
    return database.transaction<int>((txn) async {
      for (final item in lines) {
        final id = item.product.id;
        if (id == null) throw StateError('Barang belum tersimpan di database.');
        final changed = await txn.rawUpdate('UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?', [item.quantity, id, item.quantity]);
        if (changed != 1) throw StateError('Stok barang tidak mencukupi: ' + item.product.name);
      }
      final txId = await txn.insert('transactions', {'created_at': DateTime.now().toIso8601String(), 'total': total, 'paid': paid, 'change_amount': paid - total, 'payment_method': paymentMethod});
      for (final item in lines) {
        await txn.insert('transaction_items', {'transaction_id': txId, 'product_id': item.product.id, 'product_name': item.product.name, 'quantity': item.quantity, 'unit_price': item.product.price, 'subtotal': item.subtotal});
      }
      return txId;
    });
  }
}
