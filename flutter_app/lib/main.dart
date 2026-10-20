import 'package:flutter/material.dart';

void main() => runApp(const DsheFarmaApp());

const _mint = Color(0xFF79D5B7);
const _lightBg = Color(0xFFF2F4F7);
const _darkBg = Color(0xFF191C21);
const _darkCard = Color(0xFF292D33);
const _darkBorder = Color(0xFF454C56);

class DsheFarmaApp extends StatefulWidget {
  const DsheFarmaApp({super.key});

  @override
  State<DsheFarmaApp> createState() => _DsheFarmaAppState();
}

class _DsheFarmaAppState extends State<DsheFarmaApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() => setState(() {
        _themeMode = _themeMode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Apotek D'she Farma",
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: DsheShell(
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _mint,
      brightness: brightness,
      primary: dark ? _mint : const Color(0xFF167A63),
      surface: dark ? _darkCard : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? _darkBg : _lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? _darkBg : _lightBg,
        foregroundColor: dark ? const Color(0xFFF2F4F7) : const Color(0xFF202833),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? _darkCard : Colors.white.withValues(alpha: .88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: dark ? _darkBorder : const Color(0xFFE2E7ED)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1D2025) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: dark ? _darkBorder : const Color(0xFFDCE2E9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: dark ? _darkBorder : const Color(0xFFDCE2E9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? _darkCard : Colors.white,
        indicatorColor: _mint.withValues(alpha: dark ? .18 : .22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            )),
      ),
    );
  }
}

class DsheShell extends StatefulWidget {
  const DsheShell({super.key, required this.onToggleTheme, required this.isDark});
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<DsheShell> createState() => _DsheShellState();
}

class _DsheShellState extends State<DsheShell> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Beranda'),
    NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'Kasir'),
    NavigationDestination(icon: Icon(Icons.search_rounded), selectedIcon: Icon(Icons.manage_search), label: 'Cek Harga'),
    NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view), label: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Dashboard(onCashier: () => setState(() => _index = 1), onToggleTheme: widget.onToggleTheme, isDark: widget.isDark),
      const _ModulePlaceholder(title: 'Kasir', subtitle: 'Pencarian dan scan barcode, jumlah, keranjang, dan pembayaran.'),
      const _ModulePlaceholder(title: 'Cek Harga', subtitle: 'Pencarian produk dan harga dari database aplikasi.'),
      const _ModulePlaceholder(title: 'Menu Operasional', subtitle: 'Barang keluar, daftar item, stok opname, sinkronisasi, dan laporan.'),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: _destinations,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.onCashier, required this.onToggleTheme, required this.isDark});
  final VoidCallback onCashier;
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFF2F4F7) : const Color(0xFF202833);
    final muted = dark ? const Color(0xFFC1C7D0) : const Color(0xFF66717F);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          sliver: SliverList.list(children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFDDE5E8)]),
                ),
                child: const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF167A63), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("D'she Farma", maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, height: 1.1, fontWeight: FontWeight.w900, letterSpacing: -.5, color: fg)),
                const SizedBox(height: 5),
                Text('APOTEK • POS MOBILE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: muted)),
              ])),
              IconButton(
                tooltip: isDark ? 'Aktifkan mode terang' : 'Aktifkan Dark Pearl',
                onPressed: onToggleTheme,
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              ),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: dark ? _darkBorder : Colors.white),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: dark
                      ? const [Color(0xFF303840), Color(0xFF24282E)]
                      : const [Color(0xFFFFFFFF), Color(0xFFE3EEEB)],
                ),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .12 : .04), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _Eyebrow(text: 'PEARL CRYSTAL • POS MOBILE'),
                const SizedBox(height: 12),
                Text('Operasional lebih ringkas.', style: TextStyle(fontSize: 25, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.7, color: fg)),
                const SizedBox(height: 8),
                Text('Akses kasir dan pencarian produk dari satu tempat.', style: TextStyle(fontSize: 14, height: 1.5, color: muted)),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(
                  onPressed: onCashier,
                  icon: const Icon(Icons.point_of_sale_rounded),
                  label: const Text('Buka Kasir', style: TextStyle(fontWeight: FontWeight.w800)),
                )),
              ]),
            ),
            const SizedBox(height: 20),
            Text('Pintasan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: fg)),
            const SizedBox(height: 12),
            const _IntegrationNotice(),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Shortcut(icon: Icons.qr_code_scanner_rounded, title: 'Scan Barcode', note: 'Butuh integrasi kamera')),
              const SizedBox(width: 12),
              Expanded(child: _Shortcut(icon: Icons.inventory_2_outlined, title: 'Stok & Item', note: 'Modul berikutnya')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Shortcut(icon: Icons.sync_rounded, title: 'Sinkronisasi', note: 'Modul berikutnya')),
              const SizedBox(width: 12),
              Expanded(child: _Shortcut(icon: Icons.receipt_long_outlined, title: 'Laporan', note: 'Modul berikutnya')),
            ]),
            const SizedBox(height: 18),
            Text('Migrasi Flutter bertahap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 5),
            Text('Tampilan ini adalah fondasi Flutter. Fitur transaksi dan database belum dialihkan; aplikasi produksi lama tetap dipertahankan sampai pengujian kesetaraan selesai.',
                style: TextStyle(fontSize: 12, height: 1.55, color: muted)),
          ]),
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF188B70), shape: BoxShape.circle)),
    const SizedBox(width: 7),
    Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: Color(0xFF188B70))),
  ]);
}

class _IntegrationNotice extends StatelessWidget {
  const _IntegrationNotice();
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline_rounded, color: dark ? _mint : const Color(0xFF167A63)),
        const SizedBox(width: 11),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Database produksi belum terhubung', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          SizedBox(height: 4),
          Text('Integrasi database 4.348 produk dan penyimpanan transaksi harus selesai sebelum build Flutter digunakan untuk operasional.', style: TextStyle(fontSize: 12, height: 1.45)),
        ])),
      ]),
    ));
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.title, required this.note});
  final IconData icon;
  final String title;
  final String note;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 13),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(note, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]),
  ));
}

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Card(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.construction_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 12),
          const Text('Belum diaktifkan di fondasi Flutter; jangan gunakan layar ini untuk transaksi nyata.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ]),
      )),
    ),
  );
}
