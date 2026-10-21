import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
    _db = await openDatabase(path, version: 3,
      onConfigure: (d) async => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, version) async {
        await d.execute('CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, code TEXT NOT NULL DEFAULT "", barcode TEXT NOT NULL DEFAULT "", price INTEGER NOT NULL CHECK(price >= 0), stock INTEGER NOT NULL DEFAULT 0 CHECK(stock >= 0), stock_known INTEGER NOT NULL DEFAULT 1)');

        await d.execute('ALTER TABLE products ADD COLUMN category TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN brand TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN unit TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN cost_price INTEGER NOT NULL DEFAULT 0');
        await d.execute('ALTER TABLE products ADD COLUMN min_stock INTEGER NOT NULL DEFAULT 0');
        await d.execute('ALTER TABLE products ADD COLUMN rack TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN supplier TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN notes TEXT NOT NULL DEFAULT ""');
        await d.execute('CREATE INDEX idx_products_name ON products(name)');
        await d.execute('CREATE INDEX idx_products_code ON products(code)');
        await d.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
        await d.execute('CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, created_at TEXT NOT NULL, total INTEGER NOT NULL, paid INTEGER NOT NULL, change_amount INTEGER NOT NULL, payment_method TEXT NOT NULL)');
        await d.execute('CREATE TABLE transaction_items(id INTEGER PRIMARY KEY AUTOINCREMENT, transaction_id INTEGER NOT NULL, product_id INTEGER NOT NULL, product_name TEXT NOT NULL, quantity INTEGER NOT NULL CHECK(quantity > 0), unit_price INTEGER NOT NULL, subtotal INTEGER NOT NULL, FOREIGN KEY(transaction_id) REFERENCES transactions(id), FOREIGN KEY(product_id) REFERENCES products(id))');
      },
      onUpgrade: (d, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await d.execute('ALTER TABLE products ADD COLUMN stock_known INTEGER NOT NULL DEFAULT 1');
        }
        if (oldVersion < 3) {
        await d.execute('ALTER TABLE products ADD COLUMN category TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN brand TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN unit TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN cost_price INTEGER NOT NULL DEFAULT 0');
        await d.execute('ALTER TABLE products ADD COLUMN min_stock INTEGER NOT NULL DEFAULT 0');
        await d.execute('ALTER TABLE products ADD COLUMN rack TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN supplier TEXT NOT NULL DEFAULT ""');
        await d.execute('ALTER TABLE products ADD COLUMN notes TEXT NOT NULL DEFAULT ""');
        }
      });
    await _seedLegacyCatalog(_db!);
    return _db!;
  }
  Future<void> _seedLegacyCatalog(Database database) async {
    final count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
    if (count > 0) return;
    final raw = await rootBundle.loadString('assets/products.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    await database.transaction((txn) async {
      final batch = txn.batch();
      for (final row in decoded) {
        final item = row as Map<String, dynamic>;
        final name = (item['name'] ?? '').toString().trim();
        if (name.isEmpty) continue;
        batch.insert('products', {
          'name': name,
          'code': (item['code'] ?? '').toString(),
          'barcode': (item['barcode'] ?? '').toString(),
          'price': (item['price'] as num?)?.toInt() ?? 0,
          'stock': 0,
          'stock_known': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    });
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
    final name = product.name.trim();
    final code = product.code.trim();
    final barcode = product.barcode.trim();
    if (name.isEmpty) throw ArgumentError('Nama barang wajib diisi.');
    if (code.isEmpty) throw ArgumentError('Kode barang wajib diisi.');
    if (product.price < 0 || product.stock < 0 || product.costPrice < 0 || product.minStock < 0) {
      throw ArgumentError('Harga, harga beli, stok, dan stok minimum tidak boleh negatif.');
    }
    final database = await db;
    final codeMatches = await database.query(
      'products', columns: ['id'], where: 'UPPER(TRIM(code)) = ?',
      whereArgs: [code.toUpperCase()],
    );
    if (codeMatches.any((row) => row['id'] != product.id)) {
      throw ArgumentError('Kode barang sudah digunakan produk lain.');
    }
    if (barcode.isNotEmpty) {
      final barcodeMatches = await database.query(
        'products', columns: ['id'], where: 'TRIM(barcode) = ?',
        whereArgs: [barcode],
      );
      if (barcodeMatches.any((row) => row['id'] != product.id)) {
        throw ArgumentError('Barcode sudah digunakan produk lain.');
      }
    }
    final values = product.toMap()
      ..remove('id')
      ..['name'] = name
      ..['code'] = code
      ..['barcode'] = barcode;
    if (product.id == null) {
      await database.insert('products', values);
    } else {
      final changed = await database.update('products', values, where: 'id = ?', whereArgs: [product.id]);
      if (changed != 1) throw StateError('Produk tidak ditemukan; perubahan tidak disimpan.');
    }
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
    if (paid < 0) throw StateError('Nominal pembayaran tidak valid.');
    if (paymentMethod.trim().isEmpty) throw StateError('Metode pembayaran wajib dipilih.');

    // Combine repeated lines so stock and transaction totals use one canonical row per product.
    final quantities = <int, int>{};
    for (final line in lines) {
      final id = line.product.id;
      if (id == null) throw StateError('Barang belum tersimpan di database.');
      if (line.quantity <= 0) throw StateError('Jumlah barang harus lebih dari nol.');
      quantities[id] = (quantities[id] ?? 0) + line.quantity;
    }

    final database = await db;
    return database.transaction<int>((txn) async {
      final canonicalLines = <({int id, String name, int price, int quantity, int subtotal})>[];
      var total = 0;
      for (final entry in quantities.entries) {
        final rows = await txn.query(
          'products',
          columns: ['id', 'name', 'price', 'stock', 'stock_known'],
          where: 'id = ?',
          whereArgs: [entry.key],
          limit: 1,
        );
        if (rows.isEmpty) throw StateError('Barang tidak ditemukan. Muat ulang keranjang.');
        final product = rows.first;
        final name = product['name'] as String;
        final price = product['price'] as int;
        final stock = product['stock'] as int;
        final stockKnown = (product['stock_known'] as int) == 1;
        final quantity = entry.value;
        if (!stockKnown) throw StateError('Stok belum terverifikasi: $name. Transaksi diblokir.');
        if (stock < quantity) throw StateError('Stok barang tidak mencukupi: $name');
        final subtotal = price * quantity;
        total += subtotal;
        canonicalLines.add((id: entry.key, name: name, price: price, quantity: quantity, subtotal: subtotal));
      }
      if (paid < total) throw StateError('Pembayaran kurang dari total transaksi.');

      // Conditional updates protect against stale stock. Any failure rolls back the whole sale.
      for (final line in canonicalLines) {
        final changed = await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ? AND stock_known = 1 AND stock >= ?',
          [line.quantity, line.id, line.quantity],
        );
        if (changed != 1) throw StateError('Stok berubah saat transaksi: ${line.name}. Silakan ulangi.');
      }
      final txId = await txn.insert('transactions', {
        'created_at': DateTime.now().toIso8601String(),
        'total': total,
        'paid': paid,
        'change_amount': paid - total,
        'payment_method': paymentMethod.trim(),
      });
      for (final line in canonicalLines) {
        await txn.insert('transaction_items', {
          'transaction_id': txId,
          'product_id': line.id,
          'product_name': line.name,
          'quantity': line.quantity,
          'unit_price': line.price,
          'subtotal': line.subtotal,
        });
      }
      return txId;
    });
  }
}
