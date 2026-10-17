(function(){
'use strict';
(function(){
  const wrap=document.querySelector('.wrap');
  if(!wrap || document.getElementById('nfHome')) return;

  const legacyPayment=document.getElementById('pembayaranMandiri');
  const welcome=wrap.querySelector('.welcome-card');
  const stats=wrap.querySelector('.stats-grid');
  const quick=wrap.querySelector('.quick-section');
  const legacyStatus=Array.from(wrap.querySelectorAll('.small')).find(e=>/produk offline/i.test(e.textContent||''));
  if(!welcome||!stats||!quick) return;

  const nodes={
    search:document.getElementById('searchArea'),
    results:document.getElementById('results'),
    cartAnchor:document.getElementById('cartAnchor'),
    cart:document.querySelector('.cart'),
    report:document.getElementById('laporanSection'),
    bottom:document.getElementById('bottomNavV15')
  };

  const make=(id,title,desc)=>{
    const p=document.createElement('section');
    p.id=id; p.className='nf-page';
    const head=document.createElement('div'); head.className='nf-page-head';
    head.innerHTML='<button type="button" class="nf-back" data-back>‹</button><div><h2>'+title+'</h2><p>'+desc+'</p></div>';
    head.querySelector('[data-back]').onclick=()=>window.nfGo('home');
    p.appendChild(head);
    wrap.appendChild(p);
    return p;
  };

  const home=document.createElement('section'); home.id='nfHome'; home.className='nf-page';
  home.append(welcome,stats,quick);
  if(legacyStatus) home.appendChild(legacyStatus);

  const more=document.createElement('div'); more.className='nf-more-link';
  more.innerHTML='<div class="nf-home-tools-title"><b>DATABASE & SINKRONISASI</b><small>Kelola item lokal dan perbarui data perangkat</small></div><div class="nf-home-tools"><button type="button" data-open-items><span>▤</span><b>Daftar Item</b><small>Tambah, edit, import CSV</small></button><button type="button" data-open-sync><span>↻</span><b>Sync Data</b><small>Perbarui dari cloud</small></button></div>';
  home.insertBefore(more,quick);

  const price=make('nfPrice','Cek Harga','Pencarian produk, informasi harga, dan stok — tanpa proses pembayaran.');
  const priceIntro=document.createElement('div'); priceIntro.className='nf-page-intro';
  priceIntro.textContent='Cari nama, kode, atau barcode untuk melihat harga dan stok. Halaman ini hanya untuk pengecekan; tidak menambahkan produk ke keranjang.';
  price.appendChild(priceIntro);
  const lookup=document.createElement('div'); lookup.className='nf-price-lookup';
  lookup.innerHTML='<div class="nf-price-search"><span aria-hidden="true">⌕</span><input id="nfPriceQuery" type="search" placeholder="Nama obat, kode, barcode…" autocomplete="off" aria-label="Cari harga dan stok"><button type="button" id="nfPriceClear" aria-label="Hapus pencarian">×</button></div><div id="nfPriceResults" aria-live="polite"><div class="nf-price-empty">Ketik nama atau kode produk untuk mulai mencari.</div></div>';
  price.appendChild(lookup);

  const tx=make('nfTransaction','Kasir','Keranjang penjualan, kuantitas, dan pembayaran.');
  const txIntro=document.createElement('div');txIntro.className='nf-page-intro';
  txIntro.textContent='Pilih produk dari pencarian kasir untuk memasukkannya ke keranjang. Cek Harga tetap terpisah dan tidak mengubah transaksi.';
  tx.appendChild(txIntro);

  // Transaction workspace: clear flow, scanner entry point, cart summary, checkout.
  if(!document.getElementById('nfTransactionPolishStyle')){
    const style=document.createElement('style');style.id='nfTransactionPolishStyle';
    style.textContent=`
      #nfTransaction .nf-tx-tools{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin:12px 0}
      #nfTransaction .nf-tx-tools button{min-width:0;min-height:100px;border-radius:17px;padding:13px;text-align:left;display:grid;grid-template-columns:36px 1fr;grid-template-rows:auto auto;align-content:center;column-gap:9px;row-gap:4px;box-shadow:0 5px 16px rgba(20,70,58,.08)}
      #nfTransaction .nf-tx-tools button span{grid-row:1/3;width:36px;height:36px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:21px;background:#ffffff30}
      #nfTransaction .nf-tx-tools button b{align-self:end;font-size:13px;line-height:1.2}
      #nfTransaction .nf-tx-tools button small{align-self:start;font-size:10px;line-height:1.3;opacity:.85}
      #nfTransaction .nf-tx-primary{background:linear-gradient(135deg,#0b8a69,#08765b);color:#fff}
      #nfTransaction .nf-tx-secondary{background:#fff;color:#19322c;border:1px solid #dce9e4}
      #nfTransaction .nf-tx-secondary span{background:#e8f7f2!important;color:#0b8064}
      #nfTransaction .nf-tx-summary{display:grid;grid-template-columns:1fr 1fr;gap:9px;margin:0 0 12px}
      #nfTransaction .nf-tx-summary>div{padding:12px;border-radius:14px;background:#fff;border:1px solid #e2ebe7}
      #nfTransaction .nf-tx-summary small{display:block;color:#71807b;font-size:10px;margin-bottom:5px}
      #nfTransaction .nf-tx-summary b{display:block;font-size:13px;color:#19322c}
      #nfTransaction #searchArea{margin-top:10px}
      #nfTransaction #nfScanBarcode{min-width:78px;white-space:nowrap}
      #nfTransaction .cart{margin-bottom:18px}
      @media(max-width:360px){#nfTransaction .nf-tx-tools{grid-template-columns:1fr}#nfTransaction .nf-tx-tools button{min-height:78px}}
    `;
    document.head.appendChild(style);
  }
  const txTools=document.createElement('div');
  txTools.className='nf-tx-tools';
  txTools.innerHTML='<button type="button" id="nfTxScan" class="nf-tx-primary"><span>▦</span><b>Scan Barcode</b><small>Pindai produk untuk transaksi</small></button><button type="button" id="nfTxShowQris" class="nf-tx-secondary"><span>▧</span><b>Tampilkan QRIS</b><small>Pembayaran merchant terpisah</small></button>';
  tx.appendChild(txTools);
  const txSummary=document.createElement('div');
  txSummary.className='nf-tx-summary';
  txSummary.innerHTML='<div><small>Status transaksi</small><b id="nfTxState">Siap menerima item</b></div><div><small>Item di keranjang</small><b id="nfTxCount">0 item</b></div>';
  tx.appendChild(txSummary);
  if(nodes.search)tx.appendChild(nodes.search);
  if(nodes.results)tx.appendChild(nodes.results);
  if(nodes.cartAnchor)tx.appendChild(nodes.cartAnchor);
  if(nodes.cart)tx.appendChild(nodes.cart);

  const paymentPage=make('nfPayment','QRIS','Pembayaran QRIS mandiri — tidak perlu membuka Kasir.');
  const paymentIntro=document.createElement('div');paymentIntro.className='nf-page-intro';
  paymentIntro.textContent='Gunakan halaman ini untuk menampilkan QRIS merchant dan memeriksa pembayaran di DANA Bisnis. Membuka QRIS tidak membuat transaksi penjualan dan tidak mengubah stok.';
  paymentPage.appendChild(paymentIntro);
  if(legacyPayment){
    legacyPayment.style.display='block';
    paymentPage.appendChild(legacyPayment);
    const qrisFrame=legacyPayment.querySelector('.payment-qris-frame');
    if(qrisFrame){
      qrisFrame.innerHTML='<div class="nf-qris-image-wrap"><img id="nfOfficialQrisImage" src="images/qris-apotek-naufal.jpg" alt="QRIS resmi Apotek Naufal Farma" loading="eager"><button type="button" id="nfQrisZoom" class="nf-qris-zoom">⤢ Perbesar QRIS</button></div>';
      const qrisImg=qrisFrame.querySelector('#nfOfficialQrisImage');
      qrisImg.style.cssText='display:block;width:100%;max-width:420px;height:auto;max-height:62vh;object-fit:contain;margin:0 auto;border-radius:12px;background:#fff';
      const qrisWrap=qrisFrame.querySelector('.nf-qris-image-wrap');
      qrisWrap.style.cssText='display:flex;flex-direction:column;align-items:center;gap:12px;padding:12px;background:#fff;border-radius:16px;border:1px solid #e2ebe7';
      const zoom=qrisFrame.querySelector('#nfQrisZoom');
      zoom.style.cssText='width:100%;max-width:420px;min-height:44px;font-weight:700';
      zoom.addEventListener('click',()=>{
        let modal=document.getElementById('nfQrisZoomModal');
        if(!modal){
          modal=document.createElement('div');modal.id='nfQrisZoomModal';
          modal.style.cssText='position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.88);display:flex;align-items:center;justify-content:center;padding:18px';
          modal.innerHTML='<button type="button" aria-label="Tutup QRIS" style="position:absolute;right:18px;top:18px;font-size:28px;width:48px;height:48px;background:#fff;color:#17312b">×</button><img alt="QRIS resmi Apotek Naufal Farma diperbesar" style="display:block;max-width:100%;max-height:86vh;object-fit:contain;background:#fff;border-radius:12px">';
          modal.querySelector('img').src=qrisImg.src;
          modal.querySelector('button').addEventListener('click',()=>modal.remove());
          modal.addEventListener('click',e=>{if(e.target===modal)modal.remove()});
          document.body.appendChild(modal);
        }
      });
      qrisImg.addEventListener('error',()=>{qrisFrame.innerHTML='<div role="alert" style="padding:16px;color:#a22">QRIS belum dapat dimuat. Periksa file images/qris-apotek-naufal.jpg pada aset aplikasi.</div>'});
    }
  }
  const paymentActions=document.createElement('div');paymentActions.className='nf-payment-actions';
  paymentActions.innerHTML='<div class="nf-payment-note"><b>Verifikasi pembayaran</b><p>Pastikan nominal dan status berhasil pada aplikasi DANA Bisnis sebelum menyatakan pembayaran diterima. Tampilan QRIS saja bukan bukti pembayaran.</p></div><button type="button" id="nfPaymentRefresh">↻ Periksa instruksi pembayaran</button>';
  paymentPage.appendChild(paymentActions);
  paymentActions.querySelector('#nfPaymentRefresh').addEventListener('click',()=>{window.nfPaymentOpen?.();paymentActions.querySelector('.nf-payment-note').classList.add('nf-note-pulse');setTimeout(()=>paymentActions.querySelector('.nf-payment-note')?.classList.remove('nf-note-pulse'),500)});
  const morePage=make('nfMore','Lainnya','Riwayat, laporan, produk, dan sinkronisasi.');
  const moreGrid=document.createElement('div');moreGrid.className='nf-more-grid';
  moreGrid.innerHTML='<button type="button" data-more="report"><span>▥</span><b>Laporan</b><small>Ringkasan penjualan</small></button><button type="button" data-more="items"><span>▤</span><b>Produk</b><small>Daftar dan kelola item</small></button><button type="button" data-more="sync"><span>↻</span><b>Sync Data</b><small>Perbarui database</small></button><button type="button" data-more="out"><span>⇥</span><b>Barang Keluar</b><small>Pencatatan barang keluar</small></button>';
  morePage.appendChild(moreGrid);
  moreGrid.querySelectorAll('[data-more]').forEach(b=>b.addEventListener('click',()=>window.nfGo(b.dataset.more)));
  const out=make('nfOut','Barang Keluar','Pencatatan barang keluar menggunakan Harga Beli.');
  const report=make('nfReport','Laporan','Ringkasan penjualan, detail transaksi, dan ekspor.');
  if(nodes.report)report.appendChild(nodes.report);

  const items=make('nfItems','Daftar Item','Kelola database produk secara offline.');
  const host=document.createElement('div'); host.id='nfItemsHost'; host.className='nf-crud-host'; items.appendChild(host);
  const sync=make('nfSync','Sync Data','Sinkronkan database item dari sumber cloud.');
  const syncIntro=document.createElement('div'); syncIntro.className='nf-page-intro';
  syncIntro.textContent='Gunakan tombol sinkronisasi di bawah untuk memperbarui database item pada perangkat ini.';
  sync.appendChild(syncIntro);
  const syncHost=document.createElement('div'); syncHost.id='nfSyncHost'; syncHost.className='nf-sync-host'; sync.appendChild(syncHost);
  setTimeout(()=>window.nfCrudInit?.(),0);

  // Independent read-only price lookup: this page never invokes cart handlers.
  const priceQuery=document.getElementById('nfPriceQuery');
  const priceResults=document.getElementById('nfPriceResults');
  const priceClear=document.getElementById('nfPriceClear');
  let priceTimer=0;
  const priceEsc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const priceRupiah=n=>'Rp '+(Number(n)||0).toLocaleString('id-ID');
  function priceLookup(q){
    q=String(q||'').trim().toLowerCase();
    if(!priceResults)return;
    if(!q){priceResults.innerHTML='<div class="nf-price-empty">Ketik nama atau kode produk untuk mulai mencari.</div>';return}
    let list=[];
    try{
      if(window.Android&&typeof window.Android.listProducts==='function'){
        const raw=window.Android.listProducts(q,100);
        list=typeof raw==='string'?JSON.parse(raw):raw;
      }else if(Array.isArray(window.ITEMS)){
        list=window.ITEMS.filter(p=>[p.name,p.nama,p.code,p.barcode,p.brand,p.jenis].some(v=>String(v??'').toLowerCase().includes(q))).slice(0,100);
      }
    }catch(e){list=[]}
    if(!Array.isArray(list)||!list.length){priceResults.innerHTML='<div class="nf-price-empty">Produk tidak ditemukan. Periksa kata kunci atau database produk.</div>';return}
    priceResults.innerHTML=list.map(p=>{
      const name=p.name??p.nama??p.item_name??'Produk tanpa nama';
      const code=p.code??p.kode??p.barcode??'—';
      const unit=p.unit??p.satuan??p.pack??'—';
      const stock=p.stock??p.stok??p.qty??p.quantity;
      const sell=p.sellPrice??p.sell_price??p.hargaJual??p.harga_jual??p.price??p.harga??0;
      return '<article class="nf-price-result"><div class="nf-price-result-top"><div class="nf-price-product"><b>'+priceEsc(name)+'</b><small>'+priceEsc(code)+'</small></div><strong>'+priceRupiah(sell)+'</strong></div><div class="nf-price-result-meta"><span>Satuan: '+priceEsc(unit)+'</span><span>Stok: '+(stock===undefined?'—':priceEsc(stock))+'</span></div></article>';
    }).join('');
  }
  priceQuery?.addEventListener('input',()=>{clearTimeout(priceTimer);priceTimer=setTimeout(()=>priceLookup(priceQuery.value),120)});
  priceClear?.addEventListener('click',()=>{priceQuery.value='';priceLookup('');priceQuery.focus()});

  // Route scanner results according to the active destination. Scanning from
  // Cek Harga must remain read-only; cashier scans keep the legacy cart flow.
  const legacyBarcodeHandler=window.onNativeBarcodeScanned;
  window.onNativeBarcodeScanned=function(code){
    if(document.getElementById('nfPrice')?.classList.contains('nf-active')){
      const value=String(code??'').trim();
      if(!value||!priceQuery)return;
      priceQuery.value=value;
      priceLookup(value);
      return;
    }
    if(typeof legacyBarcodeHandler==='function')return legacyBarcodeHandler(code);
  };

  // Rebuild the existing navigation instead of creating a second navigation bar.
  if(nodes.bottom){
    nodes.bottom.innerHTML=
      '<button type="button" data-page="transaction" aria-label="Kasir"><span>▣</span><b>Kasir</b></button>'+
      '<button type="button" data-page="payment" aria-label="QRIS merchant"><span>▦</span><b>QRIS</b></button>'+
      '<button type="button" data-page="price" aria-label="Cek harga dan stok"><span>⌕</span><b>Cek Harga</b></button>'+
      '<button type="button" data-page="more" aria-label="Menu lainnya"><span>☷</span><b>Lainnya</b></button>';
    nodes.bottom.classList.add('nf-glass-nav');
    nodes.bottom.querySelectorAll('button').forEach(b=>b.addEventListener('click',()=>window.nfGo(b.dataset.page)));
  }

  wrap.innerHTML='';
  wrap.append(home,price,tx,paymentPage,morePage,out,report,items,sync);

  // Keep dynamically created Barang Keluar inside its own page.
  const relocate=()=>{
    const el=document.getElementById('barangKeluarSection');
    if(el && el.parentNode!==out) out.appendChild(el);
  };
  const observer=new MutationObserver(relocate);
  observer.observe(document.body,{childList:true,subtree:true});
  relocate();
  setTimeout(relocate,100);
  setTimeout(relocate,500);

  const map={home:'nfHome',price:'nfPrice',transaction:'nfTransaction',payment:'nfPayment',more:'nfMore',out:'nfOut',report:'nfReport',items:'nfItems',sync:'nfSync'};
  window.nfGo=function(page){
    if(!map[page])page='home';
    Object.entries(map).forEach(([key,id])=>{
      const el=document.getElementById(id);
      if(el)el.classList.toggle('nf-active',key===page);
    });
    if(nodes.bottom)nodes.bottom.querySelectorAll('button').forEach(b=>b.classList.toggle('active',b.dataset.page===page));
    window.scrollTo({top:0,behavior:'smooth'});
    if(page==='price')setTimeout(()=>document.getElementById('nfPriceQuery')?.focus(),120);
    if(page==='items')window.nfCrudRefresh?.();
    if(page==='sync')window.nfCloudSyncInit?.();
    if(page==='report')window.nfReportRefresh?.();
    if(page==='payment')window.nfPaymentOpen?.();
  };

  const cashierSearch=nodes.search?.querySelector('.search');
  function launchNativeScan(){
    if(window.Android&&typeof window.Android.scanBarcode==='function'){
      try{window.Android.scanBarcode();}catch(e){alert('Pemindai tidak dapat dibuka. Periksa izin kamera aplikasi.');}
    }else{
      const q=document.getElementById('q');
      if(q){q.focus();q.placeholder='Masukkan kode produk secara manual…';}
      alert('Pemindai kamera tersedia di APK Android. Di browser, masukkan kode secara manual.');
    }
  }
  if(cashierSearch&&!document.getElementById('nfScanBarcode')){
    const scanButton=document.createElement('button');scanButton.type='button';scanButton.id='nfScanBarcode';scanButton.className='nf-scan-button';scanButton.textContent='▦ Scan';
    cashierSearch.appendChild(scanButton);
    scanButton.addEventListener('click',launchNativeScan);
  }
  document.getElementById('nfTxScan')?.addEventListener('click',launchNativeScan);
  document.getElementById('nfTxShowQris')?.addEventListener('click',()=>window.nfGo('payment'));
  const txCount=document.getElementById('nfTxCount');
  const txState=document.getElementById('nfTxState');
  const txCart=document.querySelector('.cart');
  const syncTxSummary=()=>{
    const count=txCart?.querySelector('#count')?.textContent?.trim()||'0 item';
    if(txCount)txCount.textContent=count;
    if(txState)txState.textContent=/^0\s*item/i.test(count)?'Siap menerima item':'Item siap diperiksa';
  };
  if(txCart){
    new MutationObserver(syncTxSummary).observe(txCart,{childList:true,subtree:true,characterData:true});
    syncTxSummary();
  }
  window.nfPaymentOpen=function(){if(legacyPayment)legacyPayment.style.display='block';};
  window.focusPayment=function(){window.nfGo('payment')};
  window.focusSearch=function(scan){
    window.nfGo(scan?'transaction':'price');
    setTimeout(()=>{
      if(scan && window.Android?.scanBarcode){try{window.Android.scanBarcode();}catch(e){}}
      else document.getElementById(scan?'q':'nfPriceQuery')?.focus();
    },140);
  };
  window.focusCart=function(){window.nfGo('transaction')};
  window.focusPayment=function(){window.nfGo('payment')};
  window.focusReport=function(){window.nfGo('report')};
  window.focusOut=function(){window.nfGo('out')};
  window.focusItems=function(){window.nfGo('items')};
  window.focusSync=function(){window.nfGo('sync')};
  more.querySelector('[data-open-items]').onclick=window.focusItems;
  more.querySelector('[data-open-sync]').onclick=function(){window.nfGo('sync')};

  // Remove legacy bottom navigation and menu hooks that could scroll instead of navigating.
  document.querySelectorAll('#bottomNavV15 button').forEach(b=>{
    b.onclick=null;
  });


  // UI-only interaction polish: page entrance, touch feedback and clear focus states.
  const motionQuery=window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)');
  const reduceMotion=()=>!!(motionQuery&&motionQuery.matches);
  document.querySelectorAll('.quick-btn,.nf-home-tools button').forEach(btn=>{
    btn.addEventListener('click',()=>{
      btn.classList.add('nf-tapped');
      window.setTimeout(()=>btn.classList.remove('nf-tapped'),220);
    },{passive:true});
  });
  const navLabel=nodes.bottom&&nodes.bottom.querySelector('[data-page="transaction"]');
  if(navLabel)navLabel.setAttribute('aria-label','Kasir: keranjang dan pembayaran');
  const originalGo=window.nfGo;
  window.nfGo=function(page){
    originalGo(page);
    const active=document.getElementById(map[page]||map.home);
    if(active&&!reduceMotion()){
      active.classList.remove('nf-page-enter');
      void active.offsetWidth;
      active.classList.add('nf-page-enter');
    }
  };
  // POS mobile opens directly on the cashier screen; the dashboard remains available in the last nav slot.
  window.nfGo('transaction');
})();
})();