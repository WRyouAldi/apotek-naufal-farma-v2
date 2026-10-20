import 'package:flutter_test/flutter_test.dart';
import 'package:dshe_farma_pos/main.dart';

void main() {
  testWidgets('renders D\'she Farma branding and primary cashier action', (tester) async {
    await tester.pumpWidget(const DsheFarmaApp());
    expect(find.text("D'she Farma"), findsOneWidget);
    expect(find.text('Buka Kasir'), findsOneWidget);
    expect(find.text('Database produksi belum terhubung'), findsOneWidget);
  });

  testWidgets('bottom navigation opens cashier module placeholder', (tester) async {
    await tester.pumpWidget(const DsheFarmaApp());
    await tester.tap(find.text('Kasir').last);
    await tester.pumpAndSettle();
    expect(find.text('Pencarian dan scan barcode, jumlah, keranjang, dan pembayaran.'), findsOneWidget);
    expect(find.text('Belum diaktifkan di fondasi Flutter; jangan gunakan layar ini untuk transaksi nyata.'), findsOneWidget);
  });
}
