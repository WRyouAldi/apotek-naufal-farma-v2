class Product {
  const Product({required this.id, required this.name, required this.code, required this.price, required this.stock, this.barcode = ''});
  final int? id;
  final String name, code, barcode;
  final int price, stock;
  factory Product.fromMap(Map<String, Object?> map) => Product(id: map['id'] as int?, name: map['name'] as String, code: map['code'] as String? ?? '', barcode: map['barcode'] as String? ?? '', price: (map['price'] as num).toInt(), stock: (map['stock'] as num).toInt());
  Map<String, Object?> toMap() => {'id': id, 'name': name.trim(), 'code': code.trim(), 'barcode': barcode.trim(), 'price': price, 'stock': stock};
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
