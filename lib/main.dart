import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'cloud_catalog_sync.dart';
import 'models.dart';
import 'pos_database.dart';

/// Single source of truth for the locked Pearl Crystal / Charcoal Silver palette.
/// Keep screen components theme-aware; avoid introducing local color variants.
abstract final class DsheVisualTokens {
  // Pearl Crystal
  static const pearlBackground = Color(0xFFF1F3F6);
  static const pearlSurface = Color(0xFFFFFFFF);
  static const pearlSurfaceTint = Color(0xFFE8EDF2);
  static const pearlBorder = Color(0xFFD6DCE3);
  static const pearlSecondaryText = Color(0xFF5C6570);
  static const pearlText = Color(0xFF20252B);
  static const pearlAccent = Color(0xFF7D9CA5);
  // Accessible action/text color; pearlAccent remains the locked decorative glass accent.
  static const pearlPrimary = Color(0xFF405A63);

  // Charcoal Silver
  static const charcoalBackground = Color(0xFF111317);
  static const charcoalSurface = Color(0xFF20242A);
  static const charcoalRaised = Color(0xFF2A3038);
  static const charcoalBorder = Color(0xFF454D57);
  static const charcoalSecondaryText = Color(0xFFB9C1CB);
  static const charcoalText = Color(0xFFF1F3F6);
  static const silverAccent = Color(0xFFAAB5C2);
  static const statusError = Color(0xFFB3261E);
  static const statusErrorDark = Color(0xFFFFB4AB);
  static const statusUnknown = Color(0xFF5C6570);
  static const statusUnknownDark = Color(0xFFB9C1CB);

  // Shared glass treatment
  static const glassTint = Color(0xFFE8EDF2);
  static const glassHighlight = Color(0xFFFFFFFF);
  static const glassDarkTint = Color(0xFF2A3038);
  static const glassDarkHighlight = Color(0xFF20242A);
  static const iconLight = Color(0xFF53616D);
  static const iconDark = Color(0xFFE1E7EE);
  static const iconLightAccent = Color(0xFF7D9CA5);
  static const iconDarkAccent = Color(0xFFAAB5C2);
  static const radiusCard = 22.0;
  static const radiusControl = 18.0;
  static const radiusCapsule = 36.0;
  static const blurPanel = 14.0;
  static const blurNavigation = 18.0;
}

void main() => runApp(const DsheFarmaApp());

String rupiah(int value) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);

class DsheFarmaApp extends StatefulWidget {
  const DsheFarmaApp({super.key});
  @override State<DsheFarmaApp> createState() => _DsheFarmaAppState();
}
class _DsheFarmaAppState extends State<DsheFarmaApp> {
  ThemeMode mode = ThemeMode.light;
  @override Widget build(BuildContext context) => MaterialApp(
    title: "Apotek D'she Farma", debugShowCheckedModeBanner: false, themeMode: mode,
    theme: _theme(false), darkTheme: _theme(true),
    home: PosShell(
      isDark: mode == ThemeMode.dark,
      toggleTheme: () => setState(() {
        mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      }),
    ),
  );
  ThemeData _theme(bool dark) {
    const pearlAccent = DsheVisualTokens.pearlAccent;
    const silverAccent = DsheVisualTokens.silverAccent;
    final scheme = ColorScheme.fromSeed(
      seedColor: dark ? silverAccent : pearlAccent,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: dark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface,
    ).copyWith(
      primary: dark ? silverAccent : DsheVisualTokens.pearlPrimary,
      onPrimary: dark ? DsheVisualTokens.charcoalBackground : DsheVisualTokens.pearlSurface,
      secondary: dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText,
      surface: dark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface,
      onSurface: dark ? DsheVisualTokens.charcoalText : DsheVisualTokens.pearlText,
      outline: dark ? DsheVisualTokens.charcoalBorder : DsheVisualTokens.pearlBorder,
      error: dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError,
      onError: dark ? DsheVisualTokens.charcoalBackground : DsheVisualTokens.pearlSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      iconTheme: IconThemeData(color: dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText, size: 22),
      listTileTheme: ListTileThemeData(iconColor: dark ? DsheVisualTokens.silverAccent : DsheVisualTokens.pearlAccent, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsheVisualTokens.radiusControl)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsheVisualTokens.radiusControl)))),
      scaffoldBackgroundColor: dark ? DsheVisualTokens.charcoalBackground : DsheVisualTokens.pearlBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: (dark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface).withValues(alpha: 0.72),
        foregroundColor: dark ? DsheVisualTokens.charcoalText : DsheVisualTokens.pearlText,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsheVisualTokens.radiusCard),
          side: BorderSide(color: dark ? DsheVisualTokens.charcoalBorder : DsheVisualTokens.pearlBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? DsheVisualTokens.charcoalRaised : DsheVisualTokens.pearlSurface.withValues(alpha: 0.92),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DsheVisualTokens.radiusControl), borderSide: BorderSide(color: scheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsheVisualTokens.radiusControl), borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.85))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(DsheVisualTokens.radiusControl), borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}


/// Brand mark for D'she Farma: a custom D monogram with a pharmacy cross,
/// finished in the Pearl Crystal / Charcoal Silver visual language.
class DsheFarmaLogo extends StatelessWidget {
  const DsheFarmaLogo({super.key, this.size = 48, required this.isDark});
  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final edge = isDark ? DsheVisualTokens.charcoalBorder : DsheVisualTokens.pearlSurface;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.31),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [DsheVisualTokens.charcoalRaised, DsheVisualTokens.charcoalSurface, DsheVisualTokens.charcoalBackground]
              : [DsheVisualTokens.pearlSurface, DsheVisualTokens.pearlSurfaceTint, DsheVisualTokens.pearlBackground],
        ),
        border: Border.all(color: edge.withValues(alpha: isDark ? 0.52 : 0.92), width: 1.1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08), blurRadius: size * 0.22, offset: Offset(0, size * 0.08)),
          BoxShadow(color: (isDark ? DsheVisualTokens.silverAccent : DsheVisualTokens.pearlSurface).withValues(alpha: 0.42), blurRadius: size * 0.12, offset: Offset(-size * 0.03, -size * 0.03)),
        ],
      ),
      child: CustomPaint(painter: _DsheMarkPainter(isDark: isDark)),
    );
  }
}

class _DsheMarkPainter extends CustomPainter {
  const _DsheMarkPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 42;
    canvas.save();
    canvas.scale(scale);
    final ink = isDark ? DsheVisualTokens.iconDark : DsheVisualTokens.iconLight;
    final accent = isDark ? DsheVisualTokens.iconDarkAccent : DsheVisualTokens.iconLightAccent;

    // Geometric D monogram, deliberately drawn rather than using a stock icon.
    final d = Path()
      ..moveTo(10, 9)
      ..lineTo(17, 9)
      ..cubicTo(25, 9, 29, 13.5, 29, 21)
      ..cubicTo(29, 28.5, 25, 33, 17, 33)
      ..lineTo(10, 33)
      ..close();
    canvas.drawPath(d, Paint()..color = ink.withValues(alpha: 0.10)..style = PaintingStyle.fill);
    canvas.drawPath(d, Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round);

    // Small crystal facet gives the mark its pearl/glass signature.
    final facet = Path()
      ..moveTo(14, 12)
      ..lineTo(17, 12)
      ..cubicTo(23, 12, 26, 15.4, 26, 21)
      ..cubicTo(26, 26.6, 23, 30, 17, 30)
      ..lineTo(14, 30)
      ..close();
    canvas.drawPath(facet, Paint()..color = accent.withValues(alpha: 0.16)..style = PaintingStyle.fill);

    // Pharmacy cross set in a compact, rounded glass badge.
    final badge = RRect.fromRectAndRadius(const Rect.fromLTWH(24, 5, 13, 13), const Radius.circular(4));
    canvas.drawRRect(badge, Paint()..color = accent);
    final crossPaint = Paint()..color = isDark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(29.2, 7.5, 2.6, 8), const Radius.circular(1.1)), crossPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26.5, 10.2, 8, 2.6), const Radius.circular(1.1)), crossPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DsheMarkPainter oldDelegate) => oldDelegate.isDark != isDark;
}

class PosShell extends StatefulWidget {
  const PosShell({super.key, required this.isDark, required this.toggleTheme});
  final bool isDark; final VoidCallback toggleTheme;
  @override State<PosShell> createState() => _PosShellState();
}
class _PosShellState extends State<PosShell> {
  int selected = 1;
  final db = PosDatabase.instance;
  static const labels = ['Kasir','Cek Harga','Lainnya'];
  static const icons = [Icons.point_of_sale_rounded,Icons.price_check_rounded,Icons.more_horiz_rounded];
  @override Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final pages = [
      CashierPage(db: db),
      PriceCheckPage(db: db),
      const MorePage(),
    ];
    return Scaffold(
      appBar: AppBar(titleSpacing: 16, flexibleSpace: ClipRect(child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: (widget.isDark ? DsheVisualTokens.charcoalSurface : DsheVisualTokens.pearlSurface).withValues(alpha: 0.76)))), title: Row(children: [
        DsheFarmaLogo(size: 42, isDark: widget.isDark),
        const SizedBox(width:10), const Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("Apotek D'she Farma",maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),Text('POINT OF SALE',style:TextStyle(fontSize:10,letterSpacing:1.4))]))
      ]), actions:[IconButton(tooltip:'Ganti tema',onPressed:widget.toggleTheme,icon:Icon(widget.isDark?Icons.light_mode_rounded:Icons.dark_mode_rounded))]),
      body: Row(children:[
        if(wide) NavigationRail(selectedIndex:selected,onDestinationSelected:(i)=>setState(()=>selected=i),labelType:NavigationRailLabelType.all,destinations:List.generate(labels.length,(i)=>NavigationRailDestination(icon:Icon(icons[i]),label:Text(labels[i])))),
        Expanded(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1000),child:IndexedStack(index:selected,children:pages))))
      ]),
      bottomNavigationBar: wide ? null : SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DsheVisualTokens.radiusCapsule),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: DsheVisualTokens.blurNavigation, sigmaY: DsheVisualTokens.blurNavigation),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: (widget.isDark
                      ? DsheVisualTokens.charcoalRaised
                      : DsheVisualTokens.pearlSurfaceTint).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: widget.isDark
                        ? DsheVisualTokens.charcoalBorder.withValues(alpha: 0.9)
                        : DsheVisualTokens.pearlSurface.withValues(alpha: 0.96),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.24 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: NavigationBar(
                  height: 68,
                  backgroundColor: Colors.transparent,
                  indicatorColor: widget.isDark
                      ? DsheVisualTokens.charcoalBorder
                      : DsheVisualTokens.pearlSurface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: selected,
                  onDestinationSelected: (i) => setState(() => selected = i),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: List.generate(
                    labels.length,
                    (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.blur = DsheVisualTokens.blurPanel, this.radius = DsheVisualTokens.radiusCard});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [DsheVisualTokens.glassDarkTint.withValues(alpha: 0.84), DsheVisualTokens.glassDarkHighlight.withValues(alpha: 0.94)]
                  : [DsheVisualTokens.pearlSurface.withValues(alpha: 0.94), DsheVisualTokens.glassTint.withValues(alpha: 0.86)],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: dark ? DsheVisualTokens.charcoalBorder.withValues(alpha: 0.95) : DsheVisualTokens.pearlBorder.withValues(alpha: 0.9), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.18 : 0.045), blurRadius: 20, offset: const Offset(0, 7))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.db, required this.openCashier});
  final PosDatabase db;
  final VoidCallback openCashier;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [DsheVisualTokens.charcoalSurface, DsheVisualTokens.charcoalBackground]
              : [DsheVisualTokens.pearlSurface, DsheVisualTokens.pearlBackground],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async { await db.productCount(); await db.transactionCountToday(); },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            GlassPanel(
              blur: 20,
              radius: 28,
              padding: const EdgeInsets.all(22),
              child: Stack(
                children: [
                  Positioned(right: -16, top: -24, child: Container(
                    width: 132, height: 132,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: DsheVisualTokens.silverAccent.withValues(alpha: dark ? 0.12 : 0.20)),
                  )),
                  Positioned(right: 18, top: 12, child: DsheFarmaLogo(size: 76, isDark: dark)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: DsheVisualTokens.silverAccent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(30)),
                        child: Text('APOTEK • POS MOBILE', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, letterSpacing: 1.3, fontSize: 10)),
                      ),
                      const SizedBox(height: 18),
                      Text('Halo, selamat datang.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: muted)),
                      const SizedBox(height: 5),
                      Text("Apotek D'she Farma", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      Text('Semua kebutuhan kasir dan persediaan dalam satu tempat.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted, height: 1.4)),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: openCashier,
                          icon: const Icon(Icons.point_of_sale_rounded),
                          label: const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text('Buka kasir')),
                          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9), size: 20),
            ]),
            const SizedBox(height: 12),
            FutureBuilder<List<int>>(
              future: Future.wait([db.transactionCountToday(), db.productCount()]),
              builder: (context, s) {
                final values = s.hasData ? s.data! : const <int>[];
                return Row(children: [
                  Expanded(child: MetricCard(label: 'Transaksi hari ini', value: values.isNotEmpty ? values[0].toString() : (s.hasError ? '!' : '—'), icon: Icons.receipt_long_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: MetricCard(label: 'Jumlah barang', value: values.length > 1 ? values[1].toString() : (s.hasError ? '!' : '—'), icon: Icons.inventory_2_rounded)),
                ]);
              },
            ),
            const SizedBox(height: 18),
            GlassPanel(
              blur: 12,
              radius: 22,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: DsheVisualTokens.silverAccent.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.shield_rounded, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Pemeriksaan data', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text('Data produk lama belum otomatis diimpor. Verifikasi katalog dan stok sebelum digunakan untuk transaksi nyata.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, height: 1.4)),
                ])),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => GlassPanel(
    blur: 14,
    radius: 22,
    padding: const EdgeInsets.all(15),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 21)),
      const SizedBox(height: 14),
      AnimatedSwitcher(duration: const Duration(milliseconds: 280), transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(animation), child: child)), child: Text(value, key: ValueKey(value), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5))),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText)),
    ]),
  );
}

class CashierPage extends StatefulWidget {
  const CashierPage({super.key,required this.db}); final PosDatabase db;
  @override State<CashierPage> createState()=>_CashierPageState();
}
class _CashierPageState extends State<CashierPage> {
  final search=TextEditingController(); final cash=TextEditingController();
  List<Product> results=[]; final Map<int,CartLine> cart={}; bool loading=false;
  String status='Ketik nama/kode/barcode, lalu pilih barang untuk memasukkannya ke daftar.';
  int get total=>cart.values.fold(0,(s,l)=>s+l.subtotal);
  @override void initState(){super.initState();_search('');}
  @override void dispose(){search.dispose();cash.dispose();super.dispose();}
  Future<void> _search(String q) async {setState(()=>loading=true);try{final list=await widget.db.searchProducts(q);if(mounted)setState(()=>results=list);}catch(e){if(mounted)setState(()=>status='Gagal membaca barang: $e');}finally{if(mounted)setState(()=>loading=false);}}
  void _add(Product p) {
    if (p.id == null) return;
    if (!p.stockKnown) {
      setState(() => status = 'Stok ${p.name} belum terverifikasi. Sinkronkan/perbarui stok sebelum transaksi.');
      return;
    }
    if (p.stock <= 0) {
      setState(() => status = 'Stok ${p.name} habis. Barang tidak ditambahkan.');
      return;
    }
    final current = cart[p.id!]?.quantity ?? 0;
    if (current >= p.stock) {
      setState(() => status = 'Jumlah ${p.name} melebihi stok tersedia (${p.stock}).');
      return;
    }
    setState(() {
      cart[p.id!] = CartLine(product: p, quantity: current + 1);
      status = '${p.name} ditambahkan ke daftar.';
    });
  }
  Future<void> _scan() async {final code=await Navigator.of(context).push<String>(MaterialPageRoute(builder:(_)=>const BarcodePage()));if(code==null||!mounted)return;search.text=code;final p=await widget.db.findByBarcode(code);if(p!=null){_add(p);}else{await _search(code);setState(()=>status='Barcode tidak ditemukan. Periksa data barang.');}}
  Future<void> _checkout() async {
    if(cart.isEmpty){setState(()=>status='Keranjang masih kosong.');return;}
    final payment=await showDialog<_PaymentChoice>(context:context,builder:(ctx)=>_PaymentDialog(total:total));
    if(payment==null)return;
    try{final id=await widget.db.checkout(lines:cart.values.toList(),paid:payment.paid,paymentMethod:payment.method);if(!mounted)return;setState((){cart.clear();cash.clear();status='Transaksi #$id berhasil disimpan. Kembalian: ${rupiah(payment.paid-total)}';});await _search(search.text);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(status)));}catch(e){if(mounted)setState(()=>status='Transaksi gagal: $e');}
  }
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kasir', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8)),
              const SizedBox(height: 5),
              Text('Cari barang, masukkan ke daftar, lalu selesaikan pembayaran.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted, height: 1.35)),
            ])),
            const SizedBox(width: 10),
            DsheFarmaLogo(size: 48, isDark: dark),
          ],
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(
            controller: search,
            onChanged: _search,
            onSubmitted: (v) async { final p = await widget.db.findByBarcode(v); if (p != null) _add(p); },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Nama barang, kode, atau barcode',
              suffixIcon: search.text.isEmpty ? null : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () { search.clear(); _search(''); setState(() {}); },
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          )),
          const SizedBox(width: 10),
          SizedBox(height: 54, width: 54, child: FilledButton.tonal(
            onPressed: _scan,
            style: FilledButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            child: const Icon(Icons.document_scanner_rounded),
          )),
        ]),
        if (loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator(minHeight: 2)),
        if (search.text.isNotEmpty || results.isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: results.isEmpty
                ? Padding(padding: const EdgeInsets.all(18), child: Text('Barang tidak ditemukan. Periksa kata kunci atau tambahkan barang melalui menu Barang.', style: TextStyle(color: muted)))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.65)),
                    itemBuilder: (ctx, i) {
                      final p = results[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text('${p.code} • ${p.stockKnown ? 'Stok ${p.stock}' : 'Stok belum terverifikasi'}', style: TextStyle(color: muted, fontSize: 12))),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(rupiah(p.price), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                          const SizedBox(height: 4),
                          Icon(Icons.add_circle_outline_rounded, size: 19, color: muted),
                        ]),
                        onTap: () => _add(p),
                      );
                    },
                  ),
          ),
        ],
        const SizedBox(height: 20),
        GlassPanel(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Daftar belanja', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.4))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text('${cart.length} item', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 14),
            if (cart.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(color: (dark ? DsheVisualTokens.charcoalBackground : DsheVisualTokens.pearlSurfaceTint).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  Icon(Icons.shopping_basket_outlined, size: 32, color: muted),
                  const SizedBox(height: 8),
                  Text('Belum ada barang', style: TextStyle(fontWeight: FontWeight.w800, color: muted)),
                  const SizedBox(height: 4),
                  Text('Cari atau scan barcode untuk mulai transaksi.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 13)),
                ]),
              )
            else
              ...cart.values.map((l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.medication_outlined, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${rupiah(l.product.price)} × ${l.quantity}', style: TextStyle(color: muted, fontSize: 12)),
                  ])),
                  IconButton(tooltip: 'Kurangi jumlah', onPressed: () => setState(() { if (l.quantity > 1) { cart[l.product.id!] = CartLine(product: l.product, quantity: l.quantity - 1); } else { cart.remove(l.product.id!); } }), icon: const Icon(Icons.remove_circle_outline_rounded)),
                  Text('${l.quantity}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(tooltip: 'Tambah jumlah', onPressed: l.quantity >= l.product.stock ? null : () => setState(() => cart[l.product.id!] = CartLine(product: l.product, quantity: l.quantity + 1)), icon: const Icon(Icons.add_circle_outline_rounded)),
                ]),
              )),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.65)),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: Text('TOTAL PEMBAYARAN', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6))),
              Text(rupiah(total), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.6)),
            ]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(
              onPressed: cart.isEmpty ? null : _checkout,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Lanjut pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
            )),
            const SizedBox(height: 10),
            Text(status, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, height: 1.35)),
          ]),
        ),
      ],
    );
  }
}

class _PaymentChoice {const _PaymentChoice(this.paid,this.method);final int paid;final String method;}
class _PaymentDialog extends StatefulWidget {const _PaymentDialog({required this.total});final int total;@override State<_PaymentDialog> createState()=>_PaymentDialogState();}
class _PaymentDialogState extends State<_PaymentDialog>{
  final controller=TextEditingController();String method='Tunai';String? error;
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Pembayaran'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Total: ${rupiah(widget.total)}',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:12),
    DropdownButtonFormField<String>(initialValue:method,items:const [DropdownMenuItem(value:'Tunai',child:Text('Tunai')),DropdownMenuItem(value:'Non-tunai',child:Text('Non-tunai / Transfer'))],onChanged:(v)=>setState(()=>method=v??'Tunai'),decoration:const InputDecoration(labelText:'Metode pembayaran')),
    const SizedBox(height:10),TextField(controller:controller,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Jumlah dibayar (Rp)',hintText:'Masukkan nominal')),
    if(error!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(error!,style:TextStyle(color: Theme.of(context).brightness == Brightness.dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError)))
  ]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),FilledButton(onPressed:(){final paid=int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'),''));if(paid==null||paid<widget.total){setState(()=>error='Nominal harus sama dengan atau lebih dari total.');return;}Navigator.pop(context,_PaymentChoice(paid,method));},child:const Text('Simpan transaksi'))]);
}

class BarcodePage extends StatefulWidget {const BarcodePage({super.key});@override State<BarcodePage> createState()=>_BarcodePageState();}
class _BarcodePageState extends State<BarcodePage>{bool done=false;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Scan barcode')),body:Column(children:[
  const Padding(padding:EdgeInsets.all(14),child:Text('Arahkan kamera ke barcode barang. Pastikan izin kamera diberikan.')),
  Expanded(child:MobileScanner(onDetect:(capture){if(done)return;final code=capture.barcodes.firstOrNull?.rawValue;if(code!=null&&code.isNotEmpty){done=true;Navigator.pop(context,code);}},errorBuilder:(context,error)=>Center(child:Padding(padding:const EdgeInsets.all(20),child:Text('Kamera tidak tersedia: ${error.errorCode.name}. Periksa izin kamera perangkat.')))))
]));}

class PriceCheckPage extends StatefulWidget {
  const PriceCheckPage({super.key, required this.db});
  final PosDatabase db;
  @override State<PriceCheckPage> createState() => _PriceCheckPageState();
}

class _PriceCheckPageState extends State<PriceCheckPage> {
  final controller = TextEditingController();
  List<Product> results = [];
  bool loading = false;
  String? error;
  int requestVersion = 0;

  @override void dispose() { controller.dispose(); super.dispose(); }

  Future<void> _search(String query) async {
    final q = query.trim();
    final version = ++requestVersion;
    if (q.isEmpty) {
      setState(() { results = []; loading = false; error = null; });
      return;
    }
    setState(() { loading = true; error = null; });
    try {
      final found = await widget.db.searchProducts(q);
      final count = found.isEmpty ? await widget.db.productCount() : -1;
      if (!mounted || version != requestVersion) return;
      setState(() {
        results = found;
        loading = false;
        if (found.isEmpty && count == 0) error = 'Katalog produk belum diimpor ke aplikasi ini.';
      });
    } catch (e) {
      if (!mounted || version != requestVersion) return;
      setState(() { error = 'Data harga gagal dibaca. Coba lagi.'; results = []; loading = false; });
    }
  }

  Future<void> _scan() async {
    final code = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const BarcodePage()));
    if (!mounted || code == null || code.trim().isEmpty) return;
    final value = code.trim();
    controller.text = value;
    final version = ++requestVersion;
    setState(() { loading = true; error = null; results = []; });
    try {
      final exact = await widget.db.findByBarcode(value);
      final found = exact == null ? await widget.db.searchProducts(value) : <Product>[exact];
      final count = found.isEmpty ? await widget.db.productCount() : -1;
      if (!mounted || version != requestVersion) return;
      setState(() {
        results = found;
        loading = false;
        if (found.isEmpty) error = count == 0 ? 'Katalog produk belum diimpor ke aplikasi ini.' : 'Barcode tidak ditemukan di katalog.';
      });
    } catch (_) {
      if (!mounted || version != requestVersion) return;
      setState(() { loading = false; error = 'Gagal membaca hasil scan. Coba pindai kembali.'; });
    }
  }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? DsheVisualTokens.charcoalSecondaryText : DsheVisualTokens.pearlSecondaryText;
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: dark ? [DsheVisualTokens.charcoalSurface, DsheVisualTokens.charcoalBackground] : [DsheVisualTokens.pearlSurface, DsheVisualTokens.pearlBackground])),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('Cek Harga', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('Cari nama, kode, atau scan barcode untuk melihat harga dan stok.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted)),
          const SizedBox(height: 18),
          GlassPanel(blur: 18, radius: 24, child: Row(children: [
            Expanded(child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onChanged: _search,
              onSubmitted: _search,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Nama barang / kode / barcode', border: InputBorder.none, filled: false),
            )),
            const SizedBox(width: 6),
            IconButton.filledTonal(tooltip: 'Scan barcode', onPressed: _scan, icon: const Icon(Icons.qr_code_scanner_rounded)),
          ])),
          const SizedBox(height: 12),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          if (error != null) GlassPanel(child: Row(children: [Icon(Icons.error_outline_rounded, color: Theme.of(context).brightness == Brightness.dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError), const SizedBox(width: 10), Expanded(child: Text(error!)), TextButton(onPressed: () => _search(controller.text), child: const Text('Coba lagi'))])),
          if (controller.text.trim().isEmpty && !loading)
            GlassPanel(blur: 12, child: Column(children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(22)), child: Icon(Icons.price_check_rounded, size: 32, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 12),
              const Text('Harga barang, langsung terlihat', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Mulai ketik nama atau scan barcode. Daftar barang tidak ditampilkan sebelum pencarian.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, height: 1.4)),
            ])),
          if (controller.text.trim().isNotEmpty && !loading && error == null && results.isEmpty)
            GlassPanel(child: Column(children: [
              const Icon(Icons.search_off_rounded, size: 36),
              const SizedBox(height: 8),
              const Text('Barang tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Periksa ejaan atau coba kode/barcode lain.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
            ])),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(children: [Expanded(child: Text('Hasil pencarian', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), Text('${results.length} hasil', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted))]),
            const SizedBox(height: 10),
            ...results.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassPanel(blur: 12, radius: 20, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.medication_rounded, color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Kode: ${p.code.isEmpty ? '—' : p.code}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
                    if (p.barcode.isNotEmpty) Text('Barcode: ${p.barcode}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
                  ])),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: dark ? 0.13 : 0.11), borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('HARGA JUAL', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2, color: muted, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(rupiah(p.price), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary))),
                    ])),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: !p.stockKnown ? (dark ? DsheVisualTokens.statusUnknownDark : DsheVisualTokens.statusUnknown).withValues(alpha: 0.13) : (p.stock > 0 ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16) : (dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError).withValues(alpha: 0.12)), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(!p.stockKnown ? 'STOK BELUM ADA' : (p.stock > 0 ? 'TERSEDIA' : 'HABIS'), style: TextStyle(fontSize: 10, letterSpacing: 0.4, fontWeight: FontWeight.w900, color: !p.stockKnown ? muted : (p.stock > 0 ? Theme.of(context).colorScheme.primary : (dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError)))),
                      Text(p.stockKnown ? 'Stok ${p.stock}' : 'Stok —', style: TextStyle(fontWeight: FontWeight.w800, color: !p.stockKnown ? muted : (p.stock > 0 ? null : (dark ? DsheVisualTokens.statusErrorDark : DsheVisualTokens.statusError)))),
                    ])),
                  ]),
                ),
              ])),
            )),
            if (results.length >= 100) Padding(padding: const EdgeInsets.all(8), child: Text('Menampilkan 100 hasil pertama. Tambahkan kata kunci yang lebih spesifik.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted))),
          ],
        ],
      ),
    );
  }
}

class MorePage extends StatefulWidget {
  const MorePage({super.key});
  @override State<MorePage> createState() => _MorePageState();
}
class _MorePageState extends State<MorePage> {
  bool syncing = false;
  String? syncStatus;
  Future<void> _sync() async {
    setState(() { syncing = true; syncStatus = null; });
    try {
      final report = await CloudCatalogSync.sync();
      if (!mounted) return;
      setState(() => syncStatus = 'Sinkronisasi selesai: ${report.rowsRead} produk diproses, ${report.inserted} baru, ${report.updated} diperbarui, ${report.skipped} dilewati. ${report.negativeStock} produk memiliki stok negatif dari sumber dan ditandai belum terverifikasi.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Katalog cloud berhasil disinkronkan.')));
    } catch (e) {
      if (!mounted) return;
      setState(() => syncStatus = 'Sinkronisasi gagal. Data lokal tidak diganti: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sinkronisasi gagal. Data lokal dipertahankan.')));
    } finally {
      if (mounted) setState(() => syncing = false);
    }
  }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Lainnya', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
    const SizedBox(height: 12),
    Card(child: ListTile(leading: const Icon(Icons.cloud_sync_rounded), title: const Text('Sinkronisasi database cloud'), subtitle: const Text('Ambil katalog terbaru dari CSV GitHub'), trailing: syncing ? const SizedBox(width: 22,height: 22,child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync_rounded), onTap: syncing ? null : _sync)),
    if (syncStatus != null) Padding(padding: const EdgeInsets.only(top: 8,bottom: 8), child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(syncStatus!)))),
    Card(child: ListTile(leading: const Icon(Icons.grid_view_rounded), title: const Text('Beranda'), subtitle: const Text('Ringkasan aktivitas apotek'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomePage(db: PosDatabase.instance, openCashier: () => Navigator.of(context).pop()))))),
    Card(child: ListTile(leading: const Icon(Icons.inventory_2_rounded), title: const Text('Manajemen barang'), subtitle: const Text('Cari, tambah, dan edit katalog'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductsPage(db: PosDatabase.instance))))),
    Card(child: ListTile(leading: const Icon(Icons.receipt_long_rounded), title: const Text('Riwayat transaksi'), subtitle: const Text('Lihat transaksi yang tersimpan'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistoryPage(db: PosDatabase.instance))))),
    Card(child: ListTile(leading: const Icon(Icons.bar_chart_rounded), title: const Text('Laporan'), subtitle: const Text('Ringkasan transaksi'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsPage())))),
  ]);
}

class ProductsPage extends StatefulWidget {const ProductsPage({super.key,required this.db});final PosDatabase db;@override State<ProductsPage> createState()=>_ProductsPageState();}
class _ProductsPageState extends State<ProductsPage>{
  final search=TextEditingController();List<Product> items=[];@override void initState(){super.initState();_load();}@override void dispose(){search.dispose();super.dispose();}
  Future<void> _load()async{final r=await widget.db.searchProducts(search.text);if(mounted)setState(()=>items=r);}
  Future<void> _edit([Product? p])async{final name=TextEditingController(text:p?.name??'');final code=TextEditingController(text:p?.code??'');final barcode=TextEditingController(text:p?.barcode??'');final price=TextEditingController(text:p?.price.toString()??'');final stock=TextEditingController(text:p?.stock.toString()??'');final form=GlobalKey<FormState>();
    final save=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(title:Text(p==null?'Tambah barang':'Edit barang'),content:Form(key:form,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextFormField(controller:name,decoration:const InputDecoration(labelText:'Nama barang'),validator:(v)=>v==null||v.trim().isEmpty?'Wajib diisi':null),
      TextFormField(controller:code,decoration:const InputDecoration(labelText:'Kode barang')),
      TextFormField(controller:barcode,decoration:const InputDecoration(labelText:'Barcode')),
      TextFormField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Harga jual (Rp)'),validator:(v)=>int.tryParse(v??'')==null?'Masukkan angka valid':null),
      TextFormField(controller:stock,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Stok'),validator:(v)=>int.tryParse(v??'')==null?'Masukkan angka valid':null),
    ]))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Batal')),FilledButton(onPressed:()=>Navigator.pop(ctx,form.currentState!.validate()),child:const Text('Simpan'))]));
    if(save==true){await widget.db.saveProduct(Product(id:p?.id,name:name.text,code:code.text,barcode:barcode.text,price:int.parse(price.text),stock:int.parse(stock.text)));await _load();}
    for(final c in [name,code,barcode,price,stock]){c.dispose();}
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(14),children:[
    Row(children:[Expanded(child:Text('Manajemen barang',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),IconButton.filled(onPressed:()=>_edit(),icon:const Icon(Icons.add_rounded))]),
    const SizedBox(height:10),TextField(controller:search,onChanged:(_)=>_load(),decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Cari nama, kode, barcode')),
    const SizedBox(height:10),Text('${items.length} hasil (maks. 100 ditampilkan)',style:Theme.of(context).textTheme.bodySmall),
    ...items.map((p)=>Card(child:ListTile(title:Text(p.name),subtitle:Text('${p.code} • ${p.barcode.isEmpty?'Tanpa barcode':p.barcode} • Stok ${p.stock}'),trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(rupiah(p.price),style:const TextStyle(fontWeight:FontWeight.w800)),const Icon(Icons.edit_rounded,size:16)]),onTap:()=>_edit(p)))),
  ]);
}

class HistoryPage extends StatefulWidget {const HistoryPage({super.key,required this.db});final PosDatabase db;@override State<HistoryPage> createState()=>_HistoryPageState();}
class _HistoryPageState extends State<HistoryPage>{@override Widget build(BuildContext context)=>FutureBuilder<List<PosTransaction>>(future:widget.db.recentTransactions(),builder:(ctx,s)=>ListView(padding:const EdgeInsets.all(14),children:[
  Text('Riwayat transaksi',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
  if(s.hasError)Text('Gagal membaca riwayat: ${s.error}') else if(!s.hasData)const Center(child:CircularProgressIndicator()) else if(s.data!.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(22),child:Text('Belum ada transaksi tersimpan.'))) else ...s.data!.map((t)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.receipt_long_rounded)),title:Text('Transaksi #${t.id}'),subtitle:Text('${t.createdAt.replaceFirst('T',' ').split('.').first} • ${t.paymentMethod}'),trailing:Text(rupiah(t.total),style:const TextStyle(fontWeight:FontWeight.w800)))))
]));}
class ReportsPage extends StatelessWidget {const ReportsPage({super.key});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[Text('Laporan',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('Ringkasan laporan akan tersedia setelah migrasi data lama dan verifikasi perhitungan selesai. Gunakan menu Riwayat untuk memeriksa transaksi Flutter yang tersimpan.')))]);}
