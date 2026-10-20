import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'models.dart';
import 'pos_database.dart';

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
    const green = Color(0xFF398C76);
    final scheme = ColorScheme.fromSeed(seedColor: green, brightness: dark ? Brightness.dark : Brightness.light, surface: dark ? const Color(0xFF24282E) : const Color(0xFFFCFCFD));
    return ThemeData(useMaterial3: true, colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF17191D) : const Color(0xFFF2F4F7),
      appBarTheme: AppBarTheme(backgroundColor: (dark ? const Color(0xFF22252A) : const Color(0xFFF8F9FB)).withValues(alpha: 0.72), foregroundColor: dark ? const Color(0xFFF2F4F7) : const Color(0xFF202833), elevation: 0),
      cardTheme: CardThemeData(color: dark ? const Color(0xFF292D33) : Colors.white, elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: dark ? const Color(0xFF484F59) : const Color(0xFFE2E6EC)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: dark ? const Color(0xFF1D2025) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
    );
  }
}

class PosShell extends StatefulWidget {
  const PosShell({super.key, required this.isDark, required this.toggleTheme});
  final bool isDark; final VoidCallback toggleTheme;
  @override State<PosShell> createState() => _PosShellState();
}
class _PosShellState extends State<PosShell> {
  int selected = 0;
  final db = PosDatabase.instance;
  static const labels = ['Beranda','Kasir','Barang','Riwayat','Laporan'];
  static const icons = [Icons.grid_view_rounded,Icons.point_of_sale_rounded,Icons.inventory_2_outlined,Icons.receipt_long_rounded,Icons.bar_chart_rounded];
  @override Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final pages = [
      HomePage(db: db, openCashier: () => setState(() => selected = 1)),
      CashierPage(db: db),
      ProductsPage(db: db),
      HistoryPage(db: db),
      const ReportsPage(),
    ];
    return Scaffold(
      appBar: AppBar(titleSpacing: 16, flexibleSpace: ClipRect(child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: (widget.isDark ? const Color(0xFF22252A) : const Color(0xFFF8F9FB)).withValues(alpha: 0.62)))), title: Row(children: [
        Container(width: 42,height: 42,decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),gradient: const LinearGradient(colors:[Color(0xFFBFE9DC),Color(0xFFE7EDF3)])),child: const Icon(Icons.local_pharmacy_rounded,color:Color(0xFF246B5B))),
        const SizedBox(width:10), const Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("Apotek D'she Farma",maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontWeight:FontWeight.w800,fontSize:17)),Text('POINT OF SALE',style:TextStyle(fontSize:10,letterSpacing:1.4))]))
      ]), actions:[IconButton(tooltip:'Ganti tema',onPressed:widget.toggleTheme,icon:Icon(widget.isDark?Icons.light_mode_rounded:Icons.dark_mode_rounded))]),
      body: Row(children:[
        if(wide) NavigationRail(selectedIndex:selected,onDestinationSelected:(i)=>setState(()=>selected=i),labelType:NavigationRailLabelType.all,destinations:List.generate(labels.length,(i)=>NavigationRailDestination(icon:Icon(icons[i]),label:Text(labels[i])))),
        Expanded(child:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:1000),child:IndexedStack(index:selected,children:pages))))
      ]),
      bottomNavigationBar:wide?null:ClipRect(child:BackdropFilter(filter:ui.ImageFilter.blur(sigmaX:24,sigmaY:24),child:Container(decoration:BoxDecoration(color:(widget.isDark?const Color(0xFF17191D):const Color(0xFFF8FAFC)).withValues(alpha:0.70),border:Border(top:BorderSide(color:widget.isDark?const Color(0xFF484F59):const Color(0xFFDDE4E9)))),child:NavigationBar(backgroundColor:Colors.transparent,elevation:0,selectedIndex:selected,onDestinationSelected:(i)=>setState(()=>selected=i),labelBehavior:NavigationDestinationLabelBehavior.alwaysShow,destinations:List.generate(labels.length,(i)=>NavigationDestination(icon:Icon(icons[i]),label:labels[i])))))),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key,required this.db,required this.openCashier});
  final PosDatabase db; final VoidCallback openCashier;
  @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:()=>Future<void>.delayed(const Duration(milliseconds:200)),child:ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('APOTEK • POS MOBILE',style:TextStyle(color:Color(0xFF65B99F),fontWeight:FontWeight.w800,letterSpacing:1.5,fontSize:10)),
      const SizedBox(height:10),Text('Selamat datang 👋',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:6),const Text('Kelola penjualan dan persediaan dari satu tempat.'),
      const SizedBox(height:18),FilledButton.icon(onPressed:openCashier,icon:const Icon(Icons.point_of_sale_rounded),label:const Text('Buka kasir'))
    ]))),
    const SizedBox(height:12),FutureBuilder<List<int>>(future:Future.wait([db.transactionCountToday(),db.productCount()]),builder:(context,s)=>Row(children:[
      Expanded(child:MetricCard(label:'Transaksi hari ini',value:s.hasData?' ${s.data![0]}':'—',icon:Icons.receipt_long_rounded)),
      const SizedBox(width:10),Expanded(child:MetricCard(label:'Jumlah barang',value:s.hasData?' ${s.data![1]}':'—',icon:Icons.inventory_2_outlined))
    ])),
    const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(14),child:Row(children:[Icon(Icons.info_outline_rounded,color:Color(0xFF65B99F)),SizedBox(width:10),Expanded(child:Text('Data produk lama belum otomatis diimpor. Impor/migrasi dataset perlu diverifikasi sebelum dipakai untuk transaksi nyata.'))])))
  ]));
}
class MetricCard extends StatelessWidget {
  const MetricCard({super.key,required this.label,required this.value,required this.icon});
  final String label,value; final IconData icon;
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:const Color(0xFF65B99F)),const SizedBox(height:10),Text(value,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),Text(label,style:Theme.of(context).textTheme.bodySmall)])));
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
  void _add(Product p){if(p.id==null)return;setState((){final old=cart[p.id!];if(old!=null){cart[p.id!]=CartLine(product:p,quantity:old.quantity+1);}else{cart[p.id!]=CartLine(product:p,quantity:1);}status='${p.name} ditambahkan ke daftar.';});}
  Future<void> _scan() async {final code=await Navigator.of(context).push<String>(MaterialPageRoute(builder:(_)=>const BarcodePage()));if(code==null||!mounted)return;search.text=code;final p=await widget.db.findByBarcode(code);if(p!=null){_add(p);}else{await _search(code);setState(()=>status='Barcode tidak ditemukan. Periksa data barang.');}}
  Future<void> _checkout() async {
    if(cart.isEmpty){setState(()=>status='Keranjang masih kosong.');return;}
    final payment=await showDialog<_PaymentChoice>(context:context,builder:(ctx)=>_PaymentDialog(total:total));
    if(payment==null)return;
    try{final id=await widget.db.checkout(lines:cart.values.toList(),paid:payment.paid,paymentMethod:payment.method);if(!mounted)return;setState((){cart.clear();cash.clear();status='Transaksi #$id berhasil disimpan. Kembalian: ${rupiah(payment.paid-total)}';});await _search(search.text);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(status)));}catch(e){if(mounted)setState(()=>status='Transaksi gagal: $e');}
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(14),children:[
    Text('Kasir',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
    const SizedBox(height:4),Text('Input barang → daftar item → periksa total → checkout.',style:Theme.of(context).textTheme.bodySmall),
    const SizedBox(height:12),Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(14),child:BackdropFilter(filter:ui.ImageFilter.blur(sigmaX:8,sigmaY:8),child:TextField(controller:search,onChanged:_search,onSubmitted:(v)async{final p=await widget.db.findByBarcode(v);if(p!=null)_add(p);},decoration:const InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:'Ketik nama, kode, atau barcode'))))),const SizedBox(width:8),IconButton.filledTonal(tooltip:'Scan barcode',onPressed:_scan,icon:const Icon(Icons.qr_code_scanner_rounded))]),
    const SizedBox(height:8),if(loading)const LinearProgressIndicator(),
    if(search.text.isNotEmpty||results.isNotEmpty)Card(child:ConstrainedBox(constraints:const BoxConstraints(maxHeight:220),child:results.isEmpty?const Padding(padding:EdgeInsets.all(14),child:Text('Barang tidak ditemukan. Tambahkan data di menu Barang.')):ListView.separated(shrinkWrap:true,itemCount:results.length,itemBuilder:(ctx,i){final p=results[i];return ListTile(dense:true,title:Text(p.name,maxLines:2,overflow:TextOverflow.ellipsis),subtitle:Text('${p.code} • Stok ${p.stock}'),trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(rupiah(p.price),style:const TextStyle(fontWeight:FontWeight.w800)),const Icon(Icons.add_circle_outline,size:18)]),onTap:()=>_add(p));},separatorBuilder:(_,__)=>const Divider(height:1)))),
    const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Expanded(child:Text('Daftar input',style:TextStyle(fontWeight:FontWeight.w800,fontSize:17))),Text('${cart.length} item')]),
      const SizedBox(height:8),if(cart.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:18),child:Center(child:Text('Belum ada barang. Cari atau scan barcode.'))) else ...cart.values.map((l)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(l.product.name,style:const TextStyle(fontWeight:FontWeight.w700)),Text('${rupiah(l.product.price)} × ${l.quantity}',style:Theme.of(context).textTheme.bodySmall)])),
        IconButton(onPressed:()=>setState(()=>cart[l.product.id!]=CartLine(product:l.product,quantity:l.quantity>1?l.quantity-1:1)),icon:const Icon(Icons.remove_circle_outline)),
        SizedBox(width:25,child:Text('${l.quantity}',textAlign:TextAlign.center)),
        IconButton(onPressed:()=>setState(()=>cart[l.product.id!]=CartLine(product:l.product,quantity:l.quantity+1)),icon:const Icon(Icons.add_circle_outline)),
        Text(rupiah(l.subtotal),style:const TextStyle(fontWeight:FontWeight.w800))
      ]))),
      const Divider(),Row(children:[const Expanded(child:Text('TOTAL',style:TextStyle(fontWeight:FontWeight.w800))),Text(rupiah(total),style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w900))]),
      const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:cart.isEmpty?null:_checkout,icon:const Icon(Icons.check_circle_outline),label:const Text('Lanjut pembayaran'))),
      const SizedBox(height:8),Text(status,style:Theme.of(context).textTheme.bodySmall)
    ])))
  ]);
}

class _PaymentChoice {const _PaymentChoice(this.paid,this.method);final int paid;final String method;}
class _PaymentDialog extends StatefulWidget {const _PaymentDialog({required this.total});final int total;@override State<_PaymentDialog> createState()=>_PaymentDialogState();}
class _PaymentDialogState extends State<_PaymentDialog>{
  final controller=TextEditingController();String method='Tunai';String? error;
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(title:const Text('Pembayaran'),content:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Total: ${rupiah(widget.total)}',style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(height:12),
    DropdownButtonFormField<String>(initialValue:method,items:const [DropdownMenuItem(value:'Tunai',child:Text('Tunai')),DropdownMenuItem(value:'Non-tunai',child:Text('Non-tunai / QRIS'))],onChanged:(v)=>setState(()=>method=v??'Tunai'),decoration:const InputDecoration(labelText:'Metode pembayaran')),
    const SizedBox(height:10),TextField(controller:controller,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Jumlah dibayar (Rp)',hintText:'Masukkan nominal')),
    if(error!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(error!,style:const TextStyle(color:Colors.red)))
  ]),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Batal')),FilledButton(onPressed:(){final paid=int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'),''));if(paid==null||paid<widget.total){setState(()=>error='Nominal harus sama dengan atau lebih dari total.');return;}Navigator.pop(context,_PaymentChoice(paid,method));},child:const Text('Simpan transaksi'))]);
}

class BarcodePage extends StatefulWidget {const BarcodePage({super.key});@override State<BarcodePage> createState()=>_BarcodePageState();}
class _BarcodePageState extends State<BarcodePage>{bool done=false;@override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Scan barcode')),body:Column(children:[
  const Padding(padding:EdgeInsets.all(14),child:Text('Arahkan kamera ke barcode barang. Pastikan izin kamera diberikan.')),
  Expanded(child:MobileScanner(onDetect:(capture){if(done)return;final code=capture.barcodes.firstOrNull?.rawValue;if(code!=null&&code.isNotEmpty){done=true;Navigator.pop(context,code);}},errorBuilder:(context,error)=>Center(child:Padding(padding:const EdgeInsets.all(20),child:Text('Kamera tidak tersedia: ${error.errorCode.name}. Periksa izin kamera perangkat.')))))
]));}

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
    Row(children:[Expanded(child:Text('Manajemen barang',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800))),IconButton.filled(onPressed:()=>_edit(),icon:const Icon(Icons.add))]),
    const SizedBox(height:10),TextField(controller:search,onChanged:(_)=>_load(),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Cari nama, kode, barcode')),
    const SizedBox(height:10),Text('${items.length} hasil (maks. 100 ditampilkan)',style:Theme.of(context).textTheme.bodySmall),
    ...items.map((p)=>Card(child:ListTile(title:Text(p.name),subtitle:Text('${p.code} • ${p.barcode.isEmpty?'Tanpa barcode':p.barcode} • Stok ${p.stock}'),trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(rupiah(p.price),style:const TextStyle(fontWeight:FontWeight.w800)),const Icon(Icons.edit_outlined,size:16)]),onTap:()=>_edit(p)))),
  ]);
}

class HistoryPage extends StatefulWidget {const HistoryPage({super.key,required this.db});final PosDatabase db;@override State<HistoryPage> createState()=>_HistoryPageState();}
class _HistoryPageState extends State<HistoryPage>{@override Widget build(BuildContext context)=>FutureBuilder<List<PosTransaction>>(future:widget.db.recentTransactions(),builder:(ctx,s)=>ListView(padding:const EdgeInsets.all(14),children:[
  Text('Riwayat transaksi',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),
  if(s.hasError)Text('Gagal membaca riwayat: ${s.error}') else if(!s.hasData)const Center(child:CircularProgressIndicator()) else if(s.data!.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(22),child:Text('Belum ada transaksi tersimpan.'))) else ...s.data!.map((t)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.receipt_long)),title:Text('Transaksi #${t.id}'),subtitle:Text('${t.createdAt.replaceFirst('T',' ').split('.').first} • ${t.paymentMethod}'),trailing:Text(rupiah(t.total),style:const TextStyle(fontWeight:FontWeight.w800)))))
]));}
class ReportsPage extends StatelessWidget {const ReportsPage({super.key});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[Text('Laporan',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('Ringkasan laporan akan tersedia setelah migrasi data lama dan verifikasi perhitungan selesai. Gunakan menu Riwayat untuk memeriksa transaksi Flutter yang tersimpan.')))]);}
