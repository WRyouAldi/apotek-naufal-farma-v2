class Product {
  const Product({
    required this.id, required this.name, required this.code, required this.price,
    required this.stock, this.barcode = '', this.stockKnown = true,
    this.category = '', this.brand = '', this.unit = '', this.costPrice = 0,
    this.minStock = 0, this.rack = '', this.supplier = '', this.notes = '',
  });
  final int? id;
  final String name, code, barcode;
  final int price, stock;
  final bool stockKnown;
  final String category, brand, unit, rack, supplier, notes;
  final int costPrice, minStock;

  factory Product.fromMap(Map<String, Object?> map) => Product(
    id: map['id'] as int?,
    name: map['name'] as String,
    code: map['code'] as String? ?? '',
    barcode: map['barcode'] as String? ?? '',
    price: (map['price'] as num).toInt(),
    stock: (map['stock'] as num?)?.toInt() ?? 0,
    stockKnown: (map['stock_known'] as num?)?.toInt() != 0,
    category: map['category'] as String? ?? '',
    brand: map['brand'] as String? ?? '',
    unit: map['unit'] as String? ?? '',
    costPrice: (map['cost_price'] as num?)?.toInt() ?? 0,
    minStock: (map['min_stock'] as num?)?.toInt() ?? 0,
    rack: map['rack'] as String? ?? '',
    supplier: map['supplier'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
  );

  Map<String, Object?> toMap() => {
    'id': id, 'name': name.trim(), 'code': code.trim(), 'barcode': barcode.trim(),
    'price': price, 'stock': stock, 'stock_known': stockKnown ? 1 : 0,
    'category': category.trim(), 'brand': brand.trim(), 'unit': unit.trim(),
    'cost_price': costPrice, 'min_stock': minStock, 'rack': rack.trim(),
    'supplier': supplier.trim(), 'notes': notes.trim(),
  };
}
class CartLine {
  const CartLine({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  int get subtotal => product.price * quantity;
}
class PosTransaction {
  const PosTransaction({required this.id, required this.createdAt, required this.total, required this.paid, required this.change, required this.paymentMethod});
  final int id;
  final String createdAt, paymentMethod;
  final int total, paid, change;
}
