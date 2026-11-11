import 'package:flutter_test/flutter_test.dart';
import 'package:dshe_farma_pos/models.dart';
void main() {
  group('POS models', () {
    test('subtotal uses integer rupiah arithmetic', () {
      const product = Product(id: 1, name: 'Vitamin', code: 'V1', price: 12500, stock: 8);
      expect(const CartLine(product: product, quantity: 3).subtotal, 37500);
    });
    test('product map preserves barcode and stock', () {
      final product = Product.fromMap({'id': 7, 'name': 'Obat', 'code': 'OB7', 'barcode': '899123', 'price': 5000, 'stock': 12});
      expect(product.barcode, '899123'); expect(product.stock, 12); expect(product.toMap()['price'], 5000);
    });
  });
}
