import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'pos_database.dart';

class CloudSyncReport {
  const CloudSyncReport({required this.rowsRead, required this.inserted, required this.updated, required this.skipped, required this.negativeStock, required this.source});
  final int rowsRead, inserted, updated, skipped, negativeStock;
  final String source;
}

class CloudCatalogSync {
  CloudCatalogSync._();
  static const csvUrl = 'https://raw.githubusercontent.com/WRyouAldi/apotek-naufal-farma/main/cloud/xReport2.csv';
  static const timeout = Duration(seconds: 25);

  static Future<CloudSyncReport> sync({PosDatabase? database}) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.getUrl(Uri.parse(csvUrl)).timeout(timeout);
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Cloud mengembalikan HTTP ${response.statusCode}. Data lokal tidak diubah.');
      }
      final body = await response.transform(utf8.decoder).join().timeout(timeout);
      if (body.trim().isEmpty) throw const FormatException('CSV cloud kosong. Data lokal tidak diubah.');
      final rows = _parseCsv(body);
      final headerIndex = rows.indexWhere((row) => row.any((v) => _norm(v) == 'kode item') && row.any((v) => _norm(v) == 'nama item'));
      if (headerIndex < 0) throw const FormatException('Header Kode Item/Nama Item tidak ditemukan. Data lokal tidak diubah.');
      final headers = rows[headerIndex].map(_norm).toList();
      int col(List<String> names) => headers.indexWhere(names.map(_norm).toSet().contains);
      final codeCol = col(['Kode Item', 'Kode', 'Code']);
      final barcodeCol = col(['Kode Barcode', 'Barcode']);
      final nameCol = col(['Nama Item', 'Nama', 'Name']);
      final stockCol = col(['Stok', 'Stock']);
      final priceCol = col(['Harga Jual', 'Harga', 'Price']);
      if (nameCol < 0 || priceCol < 0 || codeCol < 0) {
        throw const FormatException('Kolom kode, nama, atau harga jual tidak lengkap. Data lokal tidak diubah.');
      }

      final parsed = <Map<String, Object?>>[];
      var skipped = 0, negativeStock = 0;
      for (final row in rows.skip(headerIndex + 1)) {
        if (row.every((v) => v.trim().isEmpty)) continue;
        String value(int index) => index >= 0 && index < row.length ? row[index].trim() : '';
        final name = value(nameCol);
        final code = value(codeCol);
        if (name.isEmpty || code.isEmpty) { skipped++; continue; }
        final price = _number(value(priceCol));
        if (price == null || price < 0) { skipped++; continue; }
        final rawStock = stockCol < 0 ? null : _number(value(stockCol));
        final stockKnown = rawStock != null && rawStock >= 0;
        if (rawStock != null && rawStock < 0) negativeStock++;
        parsed.add({
          'name': name, 'code': code, 'barcode': value(barcodeCol),
          'price': price, 'stock': stockKnown ? rawStock : 0,
          'stock_known': stockKnown ? 1 : 0,
        });
      }
      if (parsed.isEmpty) throw const FormatException('Tidak ada baris produk valid. Data lokal tidak diubah.');
      // Guard against accidentally importing a truncated CSV.
      if (parsed.length < 1000) throw FormatException('Hanya ${parsed.length} produk valid; batas aman minimal 1.000. Data lokal tidak diubah.');

      final db = await (database ?? PosDatabase.instance).db;
      var inserted = 0, updated = 0;
      await db.transaction((txn) async {
        for (final item in parsed) {
          final existing = await txn.query('products', columns: ['id'], where: 'code = ?', whereArgs: [item['code']], limit: 1);
          if (existing.isEmpty) {
            await txn.insert('products', item);
            inserted++;
          } else {
            await txn.update('products', item, where: 'id = ?', whereArgs: [existing.first['id']]);
            updated++;
          }
        }
      });
      return CloudSyncReport(rowsRead: parsed.length, inserted: inserted, updated: updated, skipped: skipped, negativeStock: negativeStock, source: csvUrl);
    } finally {
      client.close(force: true);
    }
  }

  static String _norm(String value) => value.replaceAll('\uFEFF', '').trim().toLowerCase().replaceAll(RegExp(r'\\s+'), ' ');

  static int? _number(String value) {
    var s = value.trim();
    if (s.isEmpty) return null;
    s = s.replaceAll('Rp', '').replaceAll('rp', '').replaceAll(' ', '');
    // Source CSV uses dots as Indonesian thousands separators (e.g. 13.000).
    s = s.replaceAll('.', '').replaceAll(',', '');
    return int.tryParse(s);
  }

  static List<List<String>> _parseCsv(String source) {
    final text = source.replaceFirst('\uFEFF', '');
    final sample = text.split(RegExp(r'\r?\n')).take(30).join('\n');
    final delimiter = (sample.split(';').length > sample.split(',').length) ? ';' : ',';
    final rows = <List<String>>[];
    var row = <String>[], cell = StringBuffer(), quoted = false;
    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '"') {
        if (quoted && i + 1 < text.length && text[i + 1] == '"') {
          cell.write('"'); i++;
        } else {
          quoted = !quoted;
        }
      } else if (c == delimiter && !quoted) {
        row.add(cell.toString()); cell = StringBuffer();
      } else if ((c == '\n' || c == '\r') && !quoted) {
        if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        row.add(cell.toString());
        if (row.any((v) => v.trim().isNotEmpty)) rows.add(row);
        row = <String>[]; cell = StringBuffer();
      } else {
        cell.write(c);
      }
    }
    row.add(cell.toString());
    if (row.any((v) => v.trim().isNotEmpty)) rows.add(row);
    return rows;
  }
}
