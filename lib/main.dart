import 'package:flutter/material.dart';

void main() => runApp(const DsheFarmaApp());

class DsheFarmaApp extends StatefulWidget {
  const DsheFarmaApp({super.key});

  @override
  State<DsheFarmaApp> createState() => _DsheFarmaAppState();
}

class _DsheFarmaAppState extends State<DsheFarmaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Apotek D'she Farma",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: PosShell(
        onToggleTheme: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        }),
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    const green = Color(0xFF78CDB5);
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF398C76),
      brightness: brightness,
      surface: dark ? const Color(0xFF24282E) : const Color(0xFFF5F6F8),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF191C21) : const Color(0xFFF2F4F7),
      appBarTheme: AppBarTheme(
        backgroundColor:
            dark ? const Color(0xFF20242A) : const Color(0xFFF8F9FB),
        foregroundColor: dark ? const Color(0xFFF3F5F7) : const Color(0xFF202833),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF262B31) : const Color(0xFFFCFCFD),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: dark ? const Color(0xFF484F59) : const Color(0xFFE2E6EC),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1D2025) : Colors.white,
        hintStyle: TextStyle(color: dark ? const Color(0xFFADB5C0) : const Color(0xFF7E8794)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? const Color(0xFF535963) : const Color(0xFFDDE2E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dark ? const Color(0xFF535963) : const Color(0xFFDDE2E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: green, width: 1.6),
        ),
      ),
    );
  }
}

class PosShell extends StatefulWidget {
  const PosShell({super.key, required this.onToggleTheme, required this.isDark});

  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<PosShell> createState() => _PosShellState();
}

class _PosShellState extends State<PosShell> {
  int _selected = 0;
  static const _destinations = <({String label, IconData icon})>[
    (label: 'Beranda', icon: Icons.grid_view_rounded),
    (label: 'Kasir', icon: Icons.point_of_sale_rounded),
    (label: 'Barang', icon: Icons.inventory_2_outlined),
    (label: 'Riwayat', icon: Icons.receipt_long_rounded),
    (label: 'Laporan', icon: Icons.bar_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final pages = <Widget>[
      _HomePage(onOpenCashier: () => setState(() => _selected = 1)),
      const _CashierPage(),
      const _PlaceholderPage(
        icon: Icons.inventory_2_outlined,
        title: 'Manajemen Barang',
        detail: 'Data barang akan dihubungkan ke sumber data aplikasi pada tahap integrasi.',
      ),
      const _PlaceholderPage(
        icon: Icons.receipt_long_rounded,
        title: 'Riwayat Transaksi',
        detail: 'Riwayat transaksi akan ditampilkan setelah integrasi penyimpanan dan checkout.',
      ),
      const _PlaceholderPage(
        icon: Icons.bar_chart_rounded,
        title: 'Laporan',
        detail: 'Laporan akan menggunakan data transaksi nyata, bukan data contoh.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFBFE9DC), Color(0xFFE7EDF3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF246B5B)),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Apotek D'she Farma", maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('POINT OF SALE', style: TextStyle(fontSize: 10, letterSpacing: 1.4)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Gunakan tema terang' : 'Gunakan tema gelap',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selected,
              onDestinationSelected: (i) => setState(() => _selected = i),
              labelType: NavigationRailLabelType.all,
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_selected),
                    child: pages[_selected],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (i) => setState(() => _selected = i),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.icon),
                        label: d.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onOpenCashier});
  final VoidCallback onOpenCashier;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('APOTEK • POS MOBILE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Color(0xFF65B99F))),
                const SizedBox(height: 10),
                Text('Selamat datang 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                Text('Kelola penjualan dan persediaan dari satu tempat.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onOpenCashier,
                  icon: const Icon(Icons.point_of_sale_rounded),
                  label: const Text('Buka kasir'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(child: _InfoCard(icon: Icons.shopping_bag_outlined, label: 'Transaksi hari ini', value: '—')),
            SizedBox(width: 10),
            Expanded(child: _InfoCard(icon: Icons.inventory_2_outlined, label: 'Jumlah barang', value: '—')),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF65B99F)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data statistik belum dihubungkan. Angka tidak ditampilkan sebagai data nyata sebelum integrasi selesai.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF65B99F)),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}

class _CashierPage extends StatefulWidget {
  const _CashierPage();

  @override
  State<_CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<_CashierPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text('Kasir', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('Cari barang melalui nama, kode, atau barcode.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Ketik nama / kode barang…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: 'Bersihkan pencarian',
              onPressed: () => setState(_search.clear),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        const _PlaceholderPage(
          icon: Icons.inventory_2_outlined,
          title: 'Data barang belum terhubung',
          detail: 'Pencarian dan pemilihan barang akan diaktifkan setelah model data dan penyimpanan POS lama dipindahkan. Checkout tidak diaktifkan agar tidak membuat transaksi palsu.',
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan barcode — menunggu integrasi kamera'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.qr_code_2_rounded),
          label: const Text('Pembayaran QRIS tersedia di alur checkout setelah integrasi'),
        ),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Icon(icon, size: 38, color: const Color(0xFF65B99F)),
                  const SizedBox(height: 14),
                  Text(title, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(detail, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      );
}
