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
  // Compact Operational Hero: useful actions first, without consuming cashier workspace.
  welcome.classList.add('nf-operational-hero');
  welcome.setAttribute('aria-label',"Ringkasan operasional Apotek D'she Farma");
  welcome.innerHTML=`<div class="nf-hero-copy"><span class="nf-hero-eyebrow"><i></i> OPERATIONAL OVERVIEW</span><h2>Apotek D'she Farma</h2><p>Kelola penjualan, cek produk, dan mulai pemindaian dengan cepat.</p><div class="nf-hero-actions"><button type="button" class="nf-hero-primary" data-hero-cashier><span>▣</span> Buka Kasir</button><button type="button" class="nf-hero-scan" data-hero-scan><span>▦</span> Scan Barcode</button></div></div><div class="nf-hero-orb" aria-label="Logo D\u0027she Farma"><img src="logo_dshe_farma.svg" alt="D\u0027she Farma" style="width:100%;height:100%;object-fit:cover;border-radius:inherit"></div>`;
  home.append(welcome,stats,quick);
  welcome.querySelector('[data-hero-cashier]').addEventListener('click',()=>window.nfGo('transaction'));
  welcome.querySelector('[data-hero-scan]').addEventListener('click',()=>window.focusSearch(true));
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
  if(!document.getElementById('nfVisualPolishV6')){
    const style=document.createElement('style');style.id='nfVisualPolishV6';
    style.textContent=`
      .nf-page{max-width:760px;margin:0 auto;padding:12px 12px calc(100px + env(safe-area-inset-bottom));color:#172f29}
      .nf-page-head{display:flex;align-items:center;gap:12px;padding:10px 2px 16px;margin-bottom:8px}
      .nf-page-head h2{font-size:clamp(21px,5vw,27px);letter-spacing:-.55px;font-weight:850;margin:0;color:#17362d}
      .nf-page-head p{font-size:12px;line-height:1.5;color:#71817b;margin:4px 0 0}
      .nf-back{width:42px;height:42px;flex:0 0 42px;border-radius:14px;background:rgba(255,255,255,.88);border:1px solid #dfe9e4;color:#174b3d;font-size:26px;box-shadow:0 4px 14px rgba(18,65,49,.07)}
      .nf-page-intro{font-size:12px;line-height:1.65;color:#65766f;background:linear-gradient(135deg,#f1f8f4,#fff);border:1px solid #e1ece6;border-radius:15px;padding:13px 14px;margin:0 0 14px}
      .nf-price-lookup,.nf-crud-host,.nf-sync-host{border:1px solid #e2ebe6;border-radius:19px;background:rgba(255,255,255,.94);padding:12px;box-shadow:0 8px 24px rgba(21,67,51,.045)}
      .nf-price-search{display:flex;align-items:center;gap:8px;padding:5px 6px 5px 12px;border:1px solid #d9e6df;border-radius:15px;background:#f8fbf9;min-height:52px}
      .nf-price-search input{flex:1;min-width:0;border:0!important;outline:none!important;background:transparent!important;box-shadow:none!important;font-size:14px}
      .nf-price-search button{width:36px;height:36px;border-radius:11px;background:#e7f1ec;color:#315a4b;font-size:21px}
      .nf-price-result{padding:14px;border:1px solid #e5eee9;border-radius:15px;background:#fff;margin-top:10px;box-shadow:0 3px 10px rgba(20,60,45,.035)}
      .nf-price-result-top{display:flex;align-items:flex-start;justify-content:space-between;gap:12px}
      .nf-price-product b{font-size:14px;line-height:1.4;color:#203b31}
      .nf-price-product small{display:block;margin-top:5px;color:#82918a;font-size:11px}
      .nf-price-result-top strong{color:#087b5d;font-size:14px;white-space:nowrap}
      .nf-price-result-meta{display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;color:#687970;font-size:11px;margin-top:12px;padding-top:10px;border-top:1px solid #edf2ef}
      .nf-price-empty{padding:24px 12px;text-align:center;color:#7c8b84;font-size:12px;line-height:1.6}
      .nf-scan-button{min-height:42px;border-radius:12px!important;padding:0 12px!important;background:#087f62!important;color:#fff!important;font-weight:800!important;box-shadow:0 4px 12px rgba(8,127,98,.18)}
      .nf-tx-primary,.nf-tx-secondary{transition:transform .15s ease,box-shadow .15s ease}
      .nf-tx-primary:active,.nf-tx-secondary:active,.nf-scan-button:active{transform:scale(.98)}
      .nf-tx-summary>div{box-shadow:0 4px 13px rgba(20,60,45,.035)}
      #nfTransaction .search{display:flex;align-items:center;gap:8px;padding:5px;border:1px solid #dce8e2;border-radius:16px;background:#fff;box-shadow:0 5px 17px rgba(20,60,45,.045)}
      #nfTransaction .search input{min-width:0;flex:1;border:0!important;box-shadow:none!important;background:transparent!important}
      #nfTransaction .cart{padding:15px;border-radius:20px;border:1px solid #e0eae5;box-shadow:0 8px 22px rgba(20,60,45,.055)}
      #nfTransaction .cart>.row{padding-bottom:10px;border-bottom:1px solid #edf2ef}
      #nfPayment .payment-hub{border-radius:20px;overflow:hidden}
      .nf-more-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px}
      .nf-more-grid button{min-height:112px;border-radius:17px!important;text-align:left!important;padding:15px!important;background:#fff!important;border:1px solid #e0eae5!important;color:#1b3d30!important;box-shadow:0 5px 15px rgba(20,60,45,.04)}
      .nf-more-grid button span{display:block;font-size:23px;color:#078260;margin-bottom:8px}
      .nf-more-grid button b,.nf-more-grid button small{display:block}
      .nf-more-grid button small{font-size:11px;color:#74847c;margin-top:5px}
      .nf-glass-nav{backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);background:rgba(249,252,250,.92)!important;border:1px solid rgba(211,228,219,.9)!important;box-shadow:0 -8px 28px rgba(18,57,43,.09)!important;padding-bottom:calc(9px + env(safe-area-inset-bottom))!important}
      .nf-glass-nav button{min-height:50px;border-radius:13px;transition:background .15s ease}
      .nf-glass-nav button.active{background:#e4f4ec;color:#087b5d}
      .nf-glass-nav button.active span{color:#087b5d}
      @media(min-width:700px){.nf-page{padding-left:20px;padding-right:20px}.nf-page-intro{font-size:13px}}
      @media(prefers-reduced-motion:reduce){.nf-tx-primary,.nf-tx-secondary,.nf-scan-button{transition:none}}
    `;
    document.head.appendChild(style);
  }
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
  txTools.innerHTML='<button type="button" id="nfTxShowQris" class="nf-tx-secondary"><span>▧</span><b>Tampilkan QRIS</b><small>Pembayaran merchant terpisah — verifikasi melalui DANA Bisnis</small></button>';
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

  // One native scanner, routed to whichever product-search feature is active.
  // Price lookup remains read-only; cashier retains the original add-to-cart flow.
  const legacyBarcodeHandler=window.onNativeBarcodeScanned;
  function setSearchValue(input,value){
    if(!input)return false;
    input.value=value;
    input.dispatchEvent(new Event('input',{bubbles:true}));
    input.dispatchEvent(new Event('change',{bubbles:true}));
    input.focus();
    return true;
  }
  window.onNativeBarcodeScanned=function(code){
    const value=String(code??'').trim();
    if(!value)return;
    if(document.getElementById('nfPrice')?.classList.contains('nf-active')){
      setSearchValue(priceQuery,value);priceLookup(value);return;
    }
    if(document.getElementById('nfItems')?.classList.contains('nf-active')){
      const input=document.getElementById('nfCrudSearch');
      if(setSearchValue(input,value))return;
    }
    if(document.getElementById('nfOut')?.classList.contains('nf-active')){
      const input=document.getElementById('bkSearch');
      if(setSearchValue(input,value))return;
    }
    if(document.getElementById('nfTransaction')?.classList.contains('nf-active')){
      // Cashier scan must feed the qty-before-input workflow, not the legacy catalogue renderer.
      if(typeof window.nfPrepareScannedProduct==='function'){window.nfPrepareScannedProduct(value);return;}
      setSearchValue(document.getElementById('q'),value);return;
    }
    // If another product search is focused, use it as a safe fallback.
    const active=document.activeElement;
    if(active&&active.matches('input[type="search"],input[placeholder*="barcode" i],input[placeholder*="kode" i]')){
      setSearchValue(active,value);return;
    }
    setSearchValue(document.getElementById('q'),value);
  };
  function attachScanButton(input,buttonId,label){
    if(!input||document.getElementById(buttonId))return;
    const host=input.closest('.search')||input.parentElement;
    if(!host)return;
    const button=document.createElement('button');
    button.type='button';button.id=buttonId;button.className='nf-scan-button';
    button.textContent='▦ Scan';
    button.setAttribute('aria-label',label||'Scan barcode');
    button.addEventListener('click',launchNativeScan);
    host.appendChild(button);
  }

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
  // Add a scan action beside every searchable product input.
  attachScanButton(priceQuery,'nfPriceScanBarcode','Scan barcode untuk cek harga');
  // CRUD and stock-out search fields are rendered dynamically, so attach on entry and mutations.
  function attachAllSearchScanners(){
    attachScanButton(document.getElementById('nfCrudSearch'),'nfCrudScanBarcode','Scan barcode untuk mencari item');
    attachScanButton(document.getElementById('bkSearch'),'nfOutScanBarcode','Scan barcode untuk mencari barang keluar');
  }
  attachAllSearchScanners();
  const scanAttachObserver=new MutationObserver(attachAllSearchScanners);
  scanAttachObserver.observe(wrap,{childList:true,subtree:true});
  items.addEventListener('click',()=>setTimeout(attachAllSearchScanners,80));
  out.addEventListener('click',()=>setTimeout(attachAllSearchScanners,80));
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
  // Simplified cashier flow: set Qty once, then type+Enter or scan to add immediately.
  const cashierInput=document.getElementById('q');
  const txResultList=document.getElementById('results');
  if(txResultList){txResultList.setAttribute('aria-live','polite');txResultList.style.display='none';}
  if(cashierInput && !cashierInput.dataset.nfListInputBound){
    cashierInput.dataset.nfListInputBound='1';
    cashierInput.placeholder='Ketik kode/nama barang lalu Enter, atau Scan';
    const panel=document.createElement('div');
    panel.id='nfInputControls';
    panel.style.cssText='display:flex;align-items:end;gap:8px;margin-top:8px';
    panel.innerHTML='<label style="flex:1;display:block;font-size:11px;font-weight:700;color:#65766f">Qty<input id="nfInputQty" type="number" min="1" max="9999" step="1" inputmode="numeric" value="1" aria-label="Jumlah barang" style="display:block;width:100%;height:42px;margin-top:5px;padding:8px 10px;border:1px solid #d9e6df;border-radius:11px;background:#fff;font-size:15px"></label><span style="flex:2;font-size:11px;line-height:1.45;color:#71817b;padding-bottom:8px">Scan barcode = langsung masuk. Ketik manual = tekan Enter.</span>';
    const hint=document.createElement('div');hint.id='nfInputHint';hint.className='small';hint.setAttribute('aria-live','polite');hint.style.cssText='padding:6px 4px 0;color:#71817b;font-size:11px;line-height:1.45';hint.textContent='Mulai ketik nama/kode barang, atau scan barcode.';
    const searchArea=document.getElementById('searchArea');if(searchArea)searchArea.append(panel,hint);
    const qtyInput=panel.querySelector('#nfInputQty');
    let pendingProduct=null;
    const addProduct=(product)=>{
      const qty=Number(qtyInput.value);
      if(!Number.isInteger(qty)||qty<1||qty>9999){hint.textContent='Qty harus bilangan bulat 1–9999.';qtyInput.focus();return false;}
      if(!product){hint.textContent='Pilih produk dari saran terlebih dahulu.';return false;}
      product={...product,price:Number(product.price??product.sellPrice??product.sell_price??product.hargaJual??product.harga_jual??0)};
      if(!(product.price>0)){hint.textContent='Harga barang belum diatur untuk produk ini.';return false;}
      const existing=cart.find(c=>c.code===product.code&&c.name===product.name&&c.price===product.price);
      if(existing)existing.qty+=qty;else cart.push({...product,qty});
      renderCart();hint.textContent='✓ '+product.name+' × '+qty+' ditambahkan.';
      pendingProduct=null;cashierInput.value='';qtyInput.value='1';document.getElementById('nfInputChoices')?.remove();if(autoBox){autoBox.style.display='none';autoBox.innerHTML='';}
      if(txResultList)txResultList.innerHTML='';
      cashierInput.focus();return true;
    };
    const findProduct=(raw,showChoices=true)=>{
      const term=String(raw||'').trim().toLocaleLowerCase('id-ID');if(!term)return null;
      const scored=ITEMS.map(x=>{
        const code=String(x.code||'').trim().toLocaleLowerCase('id-ID'),barcode=String(x.barcode||'').trim().toLocaleLowerCase('id-ID'),name=String(x.name||'').trim().toLocaleLowerCase('id-ID');
        const text=code+' '+barcode+' '+name+' '+String(x.jenis||'').toLocaleLowerCase('id-ID');let score=0;
        if(code===term)score=10000;else if(barcode===term)score=12000;else if(name===term)score=9000;
        else for(const t of term.split(/\\s+/).filter(Boolean)){if(code.includes(t))score+=40;if(barcode.includes(t))score+=60;if(name.includes(t))score+=20;if(text.includes(t))score+=5;}
        return{x,score};
      }).filter(v=>v.score>0).sort((a,b)=>b.score-a.score);
      const exact=scored.find(v=>String(v.x.code||'').trim().toLocaleLowerCase('id-ID')===term||String(v.x.barcode||'').trim().toLocaleLowerCase('id-ID')===term);
      if(exact)return exact.x;
      const exactNames=scored.filter(v=>String(v.x.name||'').trim().toLocaleLowerCase('id-ID')===term);
      if(exactNames.length===1)return exactNames[0].x;
      // Never auto-add a fuzzy match from manual typing: require an exact code/barcode/name.
      // Ambiguous or partial names must be selected explicitly from the suggestions.
      const prefixNames=ITEMS.filter(x=>String(x.name||'').trim().toLocaleLowerCase('id-ID').startsWith(term)&&Number(x.price)>0);
      if(prefixNames.length===1 && showChoices===false)return prefixNames[0];
      if(scored.length>0&&showChoices){
        hint.textContent='Pilih produk yang benar:';
        let choices=document.getElementById('nfInputChoices');
        if(!choices){choices=document.createElement('div');choices.id='nfInputChoices';choices.style.cssText='display:grid;gap:6px;margin-top:8px';hint.parentElement.appendChild(choices);}
        choices.innerHTML=scored.slice(0,5).map((v,i)=>'<button type="button" data-choice="'+i+'" style="display:flex;justify-content:space-between;gap:8px;align-items:center;text-align:left;padding:9px 10px;border:1px solid #dce8e2;border-radius:10px;background:#fff;color:#24453a"><span><b style="display:block;font-size:12px">'+String(v.x.name||'Barang').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))+'</b><small style="font-size:10px;color:#71817b">'+String(v.x.code||'').replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]))+'</small></span><b style="white-space:nowrap;font-size:12px">'+(typeof rupiah==='function'?rupiah(v.x.price):v.x.price)+'</b></button>').join('');
        Array.from(choices.querySelectorAll('[data-choice]')).forEach(btn=>btn.addEventListener('click',()=>addProduct(scored[Number(btn.dataset.choice)]?.x)));
      }else if(!scored.length)hint.textContent='Barang tidak ditemukan. Coba kode/barcode.';
      return null;
    };
    // Live autocomplete: show compact product suggestions while the cashier types.
    let autoBox=document.getElementById('nfAutocomplete');
    if(!autoBox){
      autoBox=document.createElement('div');autoBox.id='nfAutocomplete';autoBox.setAttribute('role','listbox');autoBox.setAttribute('aria-label','Saran produk');
      autoBox.style.cssText='display:none;position:relative;z-index:30;margin-top:6px;border:1px solid #dce8e2;border-radius:14px;background:rgba(255,255,255,.98);box-shadow:0 12px 28px rgba(25,67,52,.12);overflow:hidden';
      const controls=document.getElementById('nfInputControls');
      if(controls)controls.insertAdjacentElement('afterend',autoBox);else cashierInput.insertAdjacentElement('afterend',autoBox);
    }
    const escapeAuto=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    const updateAutocomplete=()=>{
      const term=String(cashierInput.value||'').trim().toLocaleLowerCase('id-ID');
      document.getElementById('nfInputChoices')?.remove();
      if(term.length<1){autoBox.style.display='none';autoBox.innerHTML='';hint.textContent='Mulai ketik nama/kode barang, atau scan barcode.';return;}
      const tokens=term.split(/\s+/).filter(Boolean);
      const matches=ITEMS.map(x=>{
        const name=String(x.name||'').trim(),code=String(x.code||'').trim(),barcode=String(x.barcode||'').trim();
        const n=name.toLocaleLowerCase('id-ID'),c=code.toLocaleLowerCase('id-ID'),b=barcode.toLocaleLowerCase('id-ID');
        let score=0;
        if(c===term||b===term)score=12000;else if(n===term)score=10000;else if(n.startsWith(term))score=8000;else if(c.startsWith(term)||b.startsWith(term))score=7000;
        else if(tokens.every(t=>n.includes(t)||c.includes(t)||b.includes(t)))score=5000+tokens.reduce((s,t)=>s+(n.includes(t)?100:0)+(c.includes(t)?80:0)+(b.includes(t)?120:0),0);
        return{x,score};
      }).filter(v=>v.score>0).sort((a,b)=>b.score-a.score||String(a.x.name).localeCompare(String(b.x.name),'id'));
      if(!matches.length){autoBox.style.display='block';autoBox.innerHTML='<div style="padding:12px;color:#71817b;font-size:12px">Barang tidak ditemukan.</div>';hint.textContent='Periksa ejaan, kode, atau barcode.';return;}
      autoBox.style.display='block';
      autoBox.innerHTML=matches.slice(0,6).map((v,i)=>'<button type="button" role="option" data-auto="'+i+'" style="width:100%;display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 12px;text-align:left;border-radius:0;border-bottom:1px solid #edf2ef;background:#fff;color:#24453a"><span style="min-width:0;flex:1"><b style="display:block;font-size:12px;line-height:1.35">'+escapeAuto(v.x.name||'Barang')+'</b><small style="display:block;margin-top:3px;font-size:10px;color:#71817b">'+escapeAuto(v.x.code||v.x.barcode||'Tanpa kode')+'</small></span><b style="font-size:12px;white-space:nowrap;color:#087b5d">'+(typeof rupiah==='function'?rupiah(v.x.price??v.x.sellPrice??v.x.sell_price??v.x.hargaJual??v.x.harga_jual??0):escapeAuto(v.x.price??v.x.sellPrice??v.x.sell_price??v.x.hargaJual??v.x.harga_jual??0))+'</b></button>').join('');
      Array.from(autoBox.querySelectorAll('[data-auto]')).forEach(btn=>btn.addEventListener('click',()=>{const chosen=matches[Number(btn.dataset.auto)]?.x;if(chosen)addProduct(chosen);}));
      hint.textContent=matches.length+' produk cocok — ketuk pilihan untuk memasukkan.';
    };
    cashierInput.addEventListener('input',()=>{pendingProduct=null;updateAutocomplete();});

    cashierInput.addEventListener('keydown',event=>{
      if(event.key!=='Enter')return;event.preventDefault();
      const product=pendingProduct||findProduct(cashierInput.value);
      if(product)addProduct(product);
    });
    window.nfPrepareScannedProduct=function(code){
      cashierInput.value=String(code||'').trim();
      const product=findProduct(cashierInput.value,false);
      if(product)addProduct(product);
      else if(cashierInput.value)hint.textContent='Barcode '+cashierInput.value+' tidak ditemukan. Ketik nama/kode untuk mencari manual.';
    };
  }
  // Keep the entered-items list readable as rows on mobile, without replacing existing cart logic.
  if(!document.getElementById('nfInputListStyle')){
    const listStyle=document.createElement('style');listStyle.id='nfInputListStyle';
    listStyle.textContent=`
      #nfTransaction .cart .itemline{display:grid;grid-template-columns:minmax(0,1fr);gap:5px;padding:12px 0;border-bottom:1px solid #e7eeea}
      #nfTransaction .cart .itemline .name{font-size:13px;line-height:1.4}
      #nfTransaction .cart .itemline .small{font-size:12px;line-height:1.5}
      #nfTransaction .cart .itemline .qty{display:flex;align-items:center;gap:8px;margin-top:5px}
      #nfTransaction .cart .itemline .qty button{min-width:38px;min-height:36px;border-radius:10px}
      #nfTransaction .cart #cart{max-height:none;overflow:visible}
    `;
    document.head.appendChild(listStyle);
  }
  // Compact POS list layout: replace tall product cards visually with dense rows.
  if(!document.getElementById('nfCompactInputListV1')){
    const compact=document.createElement('style');compact.id='nfCompactInputListV1';
    compact.textContent=`
      /* Search results: dense, spreadsheet-like list for large catalogues. */
      #nfTransaction #results{margin:8px 0 14px}
      #nfTransaction #results>.card{margin:0!important;padding:9px 10px!important;border:0!important;border-bottom:1px solid #e3ebe7!important;border-radius:0!important;box-shadow:none!important;background:transparent!important}
      #nfTransaction #results>.card:first-child{border-top:1px solid #e3ebe7!important}
      #nfTransaction #results>.card .row{align-items:center!important;gap:8px!important}
      #nfTransaction #results .code{font-size:10px!important;margin-bottom:2px}
      #nfTransaction #results .name{font-size:12px!important;line-height:1.25!important}
      #nfTransaction #results .meta{font-size:10px!important;margin-top:2px!important}
      #nfTransaction #results .price{font-size:12px!important}
      #nfTransaction #results button{font-size:11px!important;padding:7px 9px!important;min-height:32px!important;border-radius:9px!important;margin-top:4px!important;white-space:nowrap}
      /* Remove the large QRIS promotional card from the item-input workflow. QRIS remains in its own tab. */
      #nfTransaction .nf-tx-tools{display:none!important}
      #nfTransaction .nf-tx-summary{margin:0 0 8px!important}
      #nfTransaction .nf-tx-summary>div{padding:8px 10px!important;border-radius:12px!important}
      #nfTransaction .nf-tx-summary small{font-size:9px!important;margin-bottom:3px!important}
      #nfTransaction .nf-tx-summary b{font-size:11px!important}
      /* Entered items: dense table-like rows instead of large item cards. */
      #nfTransaction .cart{padding:10px!important;margin-top:8px!important}
      #nfTransaction .cart>.row{padding-bottom:8px!important;margin-bottom:2px!important}
      #nfTransaction .cart .itemline{display:grid!important;grid-template-columns:minmax(0,1fr) auto!important;align-items:center!important;column-gap:8px!important;row-gap:3px!important;padding:8px 0!important;border-bottom:1px solid #e6eeea!important}
      #nfTransaction .cart .itemline .name{grid-column:1!important;font-size:12px!important;line-height:1.25!important;margin:0!important}
      #nfTransaction .cart .itemline .small{grid-column:1!important;font-size:10px!important;line-height:1.35!important;margin:0!important}
      #nfTransaction .cart .itemline .qty{grid-column:2!important;grid-row:1/3!important;gap:4px!important;margin:0!important;align-self:center!important}
      #nfTransaction .cart .itemline .qty button{min-width:30px!important;min-height:30px!important;padding:3px 8px!important;border-radius:8px!important}
      #nfTransaction .cart .itemline .qty span{min-width:20px!important;font-size:12px!important}
      #nfTransaction .cart .total{font-size:18px!important;margin-top:8px!important}
      #nfTransaction .cart .actions{gap:6px!important;margin-top:8px!important}
      #nfTransaction .cart .actions button{font-size:12px!important;padding:9px 8px!important;min-height:38px!important}
      #nfTransaction .search-card{padding:8px!important;margin-bottom:8px!important}
      #nfTransaction .search input{height:44px!important;font-size:13px!important}
      #nfTransaction #nfScanBarcode{height:44px!important;min-width:62px!important;font-size:12px!important}
      @media(max-width:380px){
        #nfTransaction #results>.card{padding:8px 7px!important}
        #nfTransaction #results .name{font-size:11px!important}
        #nfTransaction #results .price{font-size:11px!important}
        #nfTransaction .cart .itemline .qty button{min-width:27px!important}
      }
    `;
    document.head.appendChild(compact);
  }

  // Persistent cashier input list: keep the item list directly under the scanner input,
  // and present cart rows in report-like columns without changing transaction logic.
  const txResults=document.getElementById('results');
  const txCartCard=document.querySelector('#nfTransaction .cart');
  if(txResults && txCartCard && txResults.parentElement===txCartCard.parentElement){
    txResults.parentElement.insertBefore(txCartCard,txResults);
  }
  if(txCartCard && !document.getElementById('nfInputTableStyleV2')){
    const tableStyle=document.createElement('style');tableStyle.id='nfInputTableStyleV2';
    tableStyle.textContent=`
      #nfTransaction .cart{margin:10px 0 12px!important;padding:12px!important}
      #nfTransaction .cart>.row{display:flex!important;align-items:center!important;justify-content:space-between!important}
      #nfTransaction .cart>.row b{font-size:15px!important}
      #nfTransaction .cart .nf-input-table-head{display:grid;grid-template-columns:minmax(0,1fr) 38px minmax(60px,76px) minmax(66px,82px);gap:5px;padding:8px 0;border-bottom:1px solid #dce8e2;color:#73837b;font-size:10px;font-weight:800}
      #nfTransaction .cart .nf-input-table-head span:not(:first-child){text-align:right}
      #nfTransaction .cart .itemline.nf-table-row{display:grid!important;grid-template-columns:minmax(0,1fr) 38px minmax(60px,76px) minmax(66px,82px)!important;align-items:center!important;gap:5px!important;padding:10px 0!important;border-bottom:1px solid #e7eeea!important}
      #nfTransaction .cart .nf-table-product{min-width:0;grid-column:1;grid-row:1/3}
      #nfTransaction .cart .nf-table-product .name{font-size:11px!important;line-height:1.35!important;overflow-wrap:anywhere}
      #nfTransaction .cart .nf-table-product .small{display:none!important}
      #nfTransaction .cart .nf-table-qty{grid-column:2;grid-row:1/3;display:flex!important;align-items:center;justify-content:center!important;gap:0!important;min-width:0}
      #nfTransaction .cart .nf-table-qty button{display:none!important}
      #nfTransaction .cart .nf-table-qty span{display:inline-block;min-width:0!important;width:100%;text-align:center;font-size:12px;font-weight:800;color:#24483c}
      #nfTransaction .cart .nf-table-price,#nfTransaction .cart .nf-table-subtotal{min-width:0;overflow-wrap:anywhere}
      #nfTransaction .cart .nf-table-price,#nfTransaction .cart .nf-table-subtotal{font-size:10px;font-weight:700;text-align:right;white-space:nowrap;color:#42675a}
      #nfTransaction .cart .nf-table-price{grid-column:3;grid-row:1/3}
      #nfTransaction .cart .nf-table-subtotal{grid-column:4;grid-row:1/3;color:#087b5d}
      #nfTransaction .cart .total{font-size:18px!important}
      #nfTransaction #results>.card{padding:8px 9px!important}
      #nfTransaction #results .name{font-size:12px!important}
      @media(max-width:390px){
        #nfTransaction .cart .nf-input-table-head,#nfTransaction .cart .itemline.nf-table-row{grid-template-columns:minmax(0,1fr) 32px minmax(52px,1fr) minmax(58px,1fr)!important;gap:4px!important}
        #nfTransaction .cart .nf-table-product .name{font-size:10px!important}
        #nfTransaction .cart .nf-table-price,#nfTransaction .cart .nf-table-subtotal{font-size:9px!important;white-space:normal!important}
        #nfTransaction .cart .nf-input-table-head{font-size:9px!important}
      }
    `;
    document.head.appendChild(tableStyle);
  }
  const enhanceInputTable=()=>{
    if(!txCartCard)return;
    const cartList=txCartCard.querySelector('#cart');
    if(!cartList)return;
    let head=txCartCard.querySelector('.nf-input-table-head');
    const rows=Array.from(cartList.querySelectorAll('.itemline'));
    if(rows.length && !head){
      head=document.createElement('div');head.className='nf-input-table-head';
      head.innerHTML='<span>Barang</span><span>Qty</span><span>Harga</span><span>Subtotal</span>';
      cartList.parentElement.insertBefore(head,cartList);
    }
    rows.forEach(row=>{
      if(row.dataset.nfTableReady==='1')return;
      const name=row.querySelector('.name');
      const small=row.querySelector('.small');
      const qty=row.querySelector('.qty');
      if(!name||!small||!qty)return;
      const matches=(small.textContent||'').match(/(.+?)\\s*[×x]\\s*(\\d+)\\s*=\\s*(.+)/i);
      const price=matches?matches[1].trim():'—';
      const subtotal=matches?matches[3].trim():'—';
      const product=document.createElement('div');product.className='nf-table-product';
      name.parentElement.insertBefore(product,name);product.appendChild(name);
      product.appendChild(small);
      const priceCell=document.createElement('div');priceCell.className='nf-table-price';priceCell.textContent=price;
      const subtotalCell=document.createElement('div');subtotalCell.className='nf-table-subtotal';subtotalCell.textContent=subtotal;
      qty.classList.add('nf-table-qty');
      row.append(product,qty,priceCell,subtotalCell);
      row.classList.add('nf-table-row');row.dataset.nfTableReady='1';
    });
    if(!rows.length && head)head.remove();
  };
  if(txCartCard){
    new MutationObserver(enhanceInputTable).observe(txCartCard,{childList:true,subtree:true,characterData:true});
    enhanceInputTable();
  }

  // Input-only cashier mode: hide the catalogue list at all times; the entered-items table stays visible.
  if(txResults)txResults.style.display='none';
  const txSearchInput=document.getElementById('q');
  if(txSearchInput)txSearchInput.setAttribute('aria-label','Ketik kode/nama atau scan barcode untuk memasukkan barang');
  window.nfGo('transaction');
})();
})();