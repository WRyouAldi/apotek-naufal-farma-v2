(function(){
'use strict';
(function(){
  const wrap=document.querySelector('.wrap');
  if(!wrap || document.getElementById('nfHome')) return;

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
  if(nodes.search)tx.appendChild(nodes.search);
  if(nodes.results)tx.appendChild(nodes.results);
  if(nodes.cartAnchor)tx.appendChild(nodes.cartAnchor);
  if(nodes.cart)tx.appendChild(nodes.cart);

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

  // Rebuild the existing navigation instead of creating a second navigation bar.
  if(nodes.bottom){
    nodes.bottom.innerHTML=
      '<button type="button" data-page="home"><span>⌂</span><b>Beranda</b></button>'+
      '<button type="button" data-page="price" aria-label="Cek Harga: pencarian produk dan stok"><span>⌕</span><b>Cek Harga</b></button>'+
      '<button type="button" data-page="transaction" aria-label="Kasir: keranjang dan pembayaran"><span>▣</span><b>Kasir</b></button>'+
      '<button type="button" data-page="items"><span>▤</span><b>Daftar Item</b></button>'+
      '<button type="button" data-page="sync"><span>↻</span><b>Sync Data</b></button>'+
      '<button type="button" data-page="report"><span>▥</span><b>Laporan</b></button>';
    nodes.bottom.classList.add('nf-glass-nav');
    nodes.bottom.querySelectorAll('button').forEach(b=>b.addEventListener('click',()=>window.nfGo(b.dataset.page)));
  }

  wrap.innerHTML='';
  wrap.append(home,price,tx,out,report,items,sync);

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

  const map={home:'nfHome',price:'nfPrice',transaction:'nfTransaction',out:'nfOut',report:'nfReport',items:'nfItems',sync:'nfSync'};
  window.nfGo=function(page){
    if(!map[page])page='home';
    Object.entries(map).forEach(([key,id])=>{
      const el=document.getElementById(id);
      if(el)el.classList.toggle('nf-active',key===page);
    });
    if(nodes.bottom)nodes.bottom.querySelectorAll('button').forEach(b=>b.classList.toggle('active',b.dataset.page===page));
    window.scrollTo({top:0,behavior:'smooth'});
    if(page==='price')setTimeout(()=>document.getElementById('q')?.focus(),120);
    if(page==='items')window.nfCrudRefresh?.();
    if(page==='sync')window.nfCloudSyncInit?.();
    if(page==='report')window.nfReportRefresh?.();
  };

  window.focusSearch=function(scan){
    window.nfGo('price');
    setTimeout(()=>{
      if(scan && window.Android?.scanBarcode){try{window.Android.scanBarcode();}catch(e){}}
      else document.getElementById('q')?.focus();
    },140);
  };
  window.focusCart=function(){window.nfGo('transaction')};
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
  window.nfGo('home');
})();
})();