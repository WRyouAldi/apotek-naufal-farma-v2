import 'package:flutter_test/flutter_test.dart';
import 'package:dshe_farma_pos/models.dart';

void main() {
  group('POS models', () {
    test('subtotal uses integer rupiah arithmetic', () {
      const product = Product(id: 1, name: 'Vitamin', code: 'V1', price: 12500, stock: 8);
      expect(const CartLine(product: product, quantity: 3).subtotal, 37500);
    });

    test('product map preserves barcode and stock certainty', () {
      final product = Product.fromMap({
        'id': 7, 'name': 'Obat', 'code': 'OB7', 'barcode': '899123',
        'price': 5000, 'stock': 0, 'stock_known': 0, 'cost_price': 2500,
        'category': 'Obat', 'supplier': 'Supplier A',
      });
      expect(product.barcode, '899123');
      expect(product.stock, 0);
      expect(product.stockKnown, isFalse);
      expect(product.costPrice, 2500);
      expect(product.category, 'Obat');
      expect(product.supplier, 'Supplier A');
      expect(product.toMap()['stock_known'], 0);
    });

    test('product model round-trips all supported metadata', () {
      const product = Product(
        id: 9, name: 'Vitamin C', code: 'VC9', barcode: '899999',
        price: 7000, stock: 20, stockKnown: true, category: 'Vitamin',
        brand: 'Brand X', unit: 'tablet', costPrice: 4000, minStock: 5,
        rack: 'A2', supplier: 'Supplier B', notes: 'Keep dry',
      );
      final restored = Product.fromMap(product.toMap());
      expect(restored.name, product.name);
      expect(restored.code, product.code);
      expect(restored.barcode, product.barcode);
      expect(restored.price, product.price);
      expect(restored.stockKnown, product.stockKnown);
      expect(restored.category, product.category);
      expect(restored.brand, product.brand);
      expect(restored.unit, product.unit);
      expect(restored.costPrice, product.costPrice);
      expect(restored.minStock, product.minStock);
      expect(restored.rack, product.rack);
      expect(restored.supplier, product.supplier);
      expect(restored.notes, product.notes);
    });

    test('duplicate cart lines are mathematically combinable', () {
      const product = Product(id: 1, name: 'Vitamin', code: 'V1', price: 12500, stock: 8);
      const lines = [
        CartLine(product: product, quantity: 2),
        CartLine(product: product, quantity: 3),
      ];
      expect(lines.fold<int>(0, (sum, line) => sum + line.subtotal), 62500);
      expect(lines.fold<int>(0, (sum, line) => sum + line.quantity), 5);
    });
  });
}
