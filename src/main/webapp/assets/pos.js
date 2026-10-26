/* Kopi Nusantara POS - logika halaman kasir (keranjang, diskon, pembayaran, checkout). */
(function () {
  'use strict';

  var CTX = document.body.getAttribute('data-ctx') || '';
  var HOLD_KEY = 'kn_hold_bills';

  var $ = function (id) { return document.getElementById(id); };
  var rp = function (n) { return 'Rp ' + Number(n).toLocaleString('id-ID'); };

  var ACTIVE_TYPE = 'order-type-btn px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 transition-all bg-tertiary-container text-tertiary-fixed font-semibold shadow-sm';
  var IDLE_TYPE = 'order-type-btn px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 transition-all bg-surface-container-low text-on-surface-variant hover:text-on-surface';
  var ACTIVE_CAT = 'cat-pill whitespace-nowrap px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 bg-primary text-on-primary font-semibold shadow-sm';
  var IDLE_CAT = 'cat-pill whitespace-nowrap px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high transition-colors';
  var ACTIVE_PAY = 'pay-method-btn px-space-sm py-2 rounded-lg font-body-md font-bold bg-primary text-on-primary shadow-sm flex items-center justify-center gap-1.5';
  var IDLE_PAY = 'pay-method-btn px-space-sm py-2 rounded-lg font-body-md font-medium bg-surface-container-low text-on-surface hover:bg-surface-container flex items-center justify-center gap-1.5 transition-colors';

  var TYPE_LABEL = { DINE_IN: 'Dine In', TAKE_AWAY: 'Take Away', OJOL: 'Ojol' };

  var state = {
    type: 'DINE_IN', pay: 'TUNAI', cat: 'all', q: '',
    cart: [],              // {id, name, price, qty, note}
    discKind: 'nominal',   // 'nominal' | 'percent'
    discValue: 0,
    billNote: '',
    cash: null,            // null = uang pas
    busy: false
  };

  var cards = Array.prototype.slice.call(document.querySelectorAll('.menu-card'));
  var cardById = {};
  cards.forEach(function (c) { cardById[c.getAttribute('data-id')] = c; });

  // ---------------------------------------------------------------- helpers
  function stockOf(id) { var c = cardById[id]; return c ? parseInt(c.getAttribute('data-stock'), 10) || 0 : 0; }

  function setStock(id, v) {
    var c = cardById[id];
    if (!c) return;
    c.setAttribute('data-stock', String(Math.max(0, v)));
    refreshCard(c);
  }

  function refreshCard(c) {
    var s = parseInt(c.getAttribute('data-stock'), 10) || 0;
    var b = c.querySelector('.stock-badge');
    if (b) {
      b.textContent = s <= 0 ? 'Stok Habis' : (s <= 5 ? 'Sisa ' + s : 'Stok: ' + s);
      b.className = 'stock-badge absolute bottom-2 right-2 backdrop-blur-sm font-label-sm text-label-sm px-2 py-0.5 rounded-md font-semibold ' +
        (s <= 0 ? 'bg-error-container text-on-error-container' : (s <= 5 ? 'bg-[#FFF3E0] text-[#B25E00]' : 'bg-surface-container-lowest/90 text-tertiary'));
    }
    c.style.opacity = s <= 0 ? '0.45' : '';
    c.style.cursor = s <= 0 ? 'not-allowed' : '';
  }

  function toast(title, msg, isError) {
    var t = $('toast');
    $('toastTitle').textContent = title;
    $('toastMsg').textContent = msg || '';
    $('toastIcon').textContent = isError ? 'error' : 'receipt';
    t.classList.toggle('bg-error', !!isError);
    t.classList.toggle('bg-tertiary', !isError);
    t.classList.remove('opacity-0', 'pointer-events-none', 'translate-y-4');
    t.classList.add('opacity-100', 'translate-y-0');
    clearTimeout(toast.timer);
    toast.timer = setTimeout(hideToast, isError ? 5000 : 4000);
  }
  function hideToast() {
    var t = $('toast');
    t.classList.add('opacity-0', 'pointer-events-none', 'translate-y-4');
    t.classList.remove('opacity-100', 'translate-y-0');
  }

  // ---------------------------------------------------------------- perhitungan
  function totals() {
    var sub = 0, qty = 0;
    state.cart.forEach(function (i) { sub += i.price * i.qty; qty += i.qty; });
    var disc = state.discKind === 'percent'
      ? Math.round(sub * state.discValue / 100)
      : state.discValue;
    disc = Math.max(0, Math.min(disc, sub));
    var tax = Math.floor(((sub - disc) * 10 + 50) / 100);      // sama dengan OrderDao.taxOf
    return { sub: sub, qty: qty, menus: state.cart.length, disc: disc, tax: tax, total: sub - disc + tax };
  }

  // ---------------------------------------------------------------- keranjang
  function addItem(id) {
    var c = cardById[id];
    if (!c) return;
    var stock = stockOf(id);
    if (stock <= 0) { toast('Stok habis', c.getAttribute('data-name') + ' sedang kosong.', true); return; }
    var line = state.cart.filter(function (i) { return i.id === id; })[0];
    if (line) {
      if (line.qty >= stock) { toast('Stok terbatas', 'Sisa stok ' + c.getAttribute('data-name') + ': ' + stock, true); return; }
      line.qty++;
    } else {
      state.cart.push({ id: id, name: c.getAttribute('data-name'), price: parseInt(c.getAttribute('data-price'), 10),
                        qty: 1, note: c.getAttribute('data-note') || '' });
    }
    render();
  }

  function changeQty(id, d) {
    var line = state.cart.filter(function (i) { return i.id === id; })[0];
    if (!line) return;
    if (d > 0 && line.qty >= stockOf(id)) { toast('Stok terbatas', 'Sisa stok: ' + stockOf(id), true); return; }
    line.qty += d;
    if (line.qty <= 0) removeItem(id); else render();
  }

  function removeItem(id) {
    state.cart = state.cart.filter(function (i) { return i.id !== id; });
    render();
  }

  function editNote(id) {
    var line = state.cart.filter(function (i) { return i.id === id; })[0];
    if (!line) return;
    var v = prompt('Catatan untuk ' + line.name + ':', line.note);
    if (v !== null) { line.note = v.trim().slice(0, 150); render(); }
  }

  function clearAll(keepCustomer) {
    state.cart = []; state.discKind = 'nominal'; state.discValue = 0; state.billNote = ''; state.cash = null;
    $('cashReceivedInput').value = '';
    if (!keepCustomer) { $('customerInput').value = ''; $('tableInput').value = ''; }
    render();
  }

  // ---------------------------------------------------------------- render
  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text !== undefined) e.textContent = text;
    return e;
  }

  function render() {
    var list = $('cartItemList');
    list.textContent = '';
    state.cart.forEach(function (i) {
      var row = el('div', 'cart-item bg-surface-container-low p-space-sm rounded-lg flex flex-col gap-space-xs transition-colors hover:bg-surface-container');
      var top = el('div', 'flex items-start justify-between gap-space-xs');
      var left = el('div', 'flex flex-col flex-1 min-w-0');
      left.appendChild(el('span', 'font-body-lg text-body-lg text-primary font-bold truncate', i.name));
      var note = el('button', 'text-left font-body-md text-body-md text-on-surface-variant italic hover:text-secondary', i.note ? '• ' + i.note : '+ tambah catatan');
      note.type = 'button';
      note.addEventListener('click', function () { editNote(i.id); });
      left.appendChild(note);
      top.appendChild(left);
      top.appendChild(el('span', 'font-label-currency text-label-currency text-primary whitespace-nowrap', rp(i.price * i.qty)));
      row.appendChild(top);

      var bottom = el('div', 'flex items-center justify-between pt-1');
      bottom.appendChild(el('span', 'font-code-badge text-code-badge text-on-surface-variant', '@ ' + rp(i.price)));
      var ctl = el('div', 'flex items-center gap-space-xs');
      var minus = el('button', 'w-6 h-6 rounded bg-surface-container-highest hover:bg-primary hover:text-on-primary flex items-center justify-center font-bold transition-colors', '-');
      var plus = el('button', 'w-6 h-6 rounded bg-surface-container-highest hover:bg-primary hover:text-on-primary flex items-center justify-center font-bold transition-colors', '+');
      var del = el('button', 'w-6 h-6 rounded text-error hover:bg-error-container flex items-center justify-center ml-1 transition-colors');
      var ic = el('span', 'material-symbols-outlined text-[16px]', 'delete');
      del.appendChild(ic);
      minus.type = plus.type = del.type = 'button';
      del.title = 'Hapus menu';
      minus.addEventListener('click', function () { changeQty(i.id, -1); });
      plus.addEventListener('click', function () { changeQty(i.id, 1); });
      del.addEventListener('click', function () { removeItem(i.id); });
      ctl.appendChild(minus);
      ctl.appendChild(el('span', 'font-label-currency text-title-lg font-bold px-2', String(i.qty)));
      ctl.appendChild(plus);
      ctl.appendChild(del);
      bottom.appendChild(ctl);
      row.appendChild(bottom);
      list.appendChild(row);
    });
    $('cartEmpty').classList.toggle('hidden', state.cart.length > 0);

    var t = totals();
    $('sumLabel').textContent = 'Subtotal (' + t.menus + ' Menu, ' + t.qty + ' Item)';
    $('cartSubtotal').textContent = rp(t.sub);
    $('cartTax').textContent = rp(t.tax);
    $('cartDiscount').textContent = '-' + rp(t.disc);
    $('cartTotal').textContent = rp(t.total);
    $('btnCheckout').disabled = state.cart.length === 0 || state.busy;

    renderQuickCash(t.total);
    renderChange(t.total);

    $('typeChip').textContent = TYPE_LABEL[state.type];
    $('tableInput').classList.toggle('hidden', state.type !== 'DINE_IN');
  }

  function renderQuickCash(total) {
    var box = $('quickCash');
    box.textContent = '';
    var opts = [];
    if (total > 0) {
      opts.push({ label: 'Uang Pas', v: null });
      [5000, 10000, 50000, 100000].forEach(function (step) {
        var v = Math.ceil(total / step) * step;
        if (v > total && opts.every(function (o) { return o.v !== v; })) opts.push({ label: Number(v).toLocaleString('id-ID'), v: v });
      });
      if (opts.length < 4 && opts.every(function (o) { return o.v !== 200000; }) && total < 200000) opts.push({ label: '200.000', v: 200000 });
    }
    opts.slice(0, 4).forEach(function (o) {
      var b = el('button', 'py-1.5 bg-surface-container-lowest hover:bg-secondary-fixed text-primary rounded-lg font-code-badge text-code-badge font-bold text-center transition-colors shadow-xs', o.label);
      b.type = 'button';
      b.addEventListener('click', function () {
        state.cash = o.v;
        $('cashReceivedInput').value = o.v === null ? '' : Number(o.v).toLocaleString('id-ID');
        render();
      });
      box.appendChild(b);
    });
  }

  function renderChange(total) {
    var out = $('cashChangeDisplay');
    var received = state.cash === null ? total : state.cash;
    var change = received - total;
    if (state.cart.length === 0) { out.textContent = 'Rp 0'; out.className = 'font-label-currency text-title-lg text-tertiary-container font-bold'; return; }
    if (change < 0) {
      out.textContent = 'Kurang ' + rp(-change);
      out.className = 'font-label-currency text-title-lg text-error font-bold';
    } else {
      out.textContent = rp(change);
      out.className = 'font-label-currency text-title-lg text-tertiary-container font-bold';
    }
  }

  // ---------------------------------------------------------------- filter menu
  function applyFilter() {
    var shown = 0;
    cards.forEach(function (c) {
      var okCat = state.cat === 'all' || c.getAttribute('data-cat') === state.cat;
      var okQ = !state.q || c.getAttribute('data-search').indexOf(state.q) > -1;
      var vis = okCat && okQ;
      c.classList.toggle('hidden', !vis);
      if (vis) shown++;
    });
    $('menuEmpty').classList.toggle('hidden', shown > 0 || cards.length === 0);
  }

  // ---------------------------------------------------------------- hold bill
  function loadHold() { try { return JSON.parse(localStorage.getItem(HOLD_KEY)) || []; } catch (e) { return []; } }
  function saveHold(list) { try { localStorage.setItem(HOLD_KEY, JSON.stringify(list)); } catch (e) { /* abaikan */ } updateHoldCount(); }
  function updateHoldCount() { $('holdCount').textContent = String(loadHold().length); }

  function holdBill() {
    if (!state.cart.length) { toast('Keranjang kosong', 'Tidak ada yang bisa ditahan.', true); return; }
    var list = loadHold();
    list.push({ t: Date.now(), cart: state.cart, type: state.type, customer: $('customerInput').value,
                table: $('tableInput').value, discKind: state.discKind, discValue: state.discValue, billNote: state.billNote });
    saveHold(list);
    clearAll(false);
    toast('Bill ditahan', 'Buka tombol "Ditahan" untuk melanjutkan.');
  }

  function openHoldList() {
    var box = $('holdList');
    box.textContent = '';
    var list = loadHold();
    if (!list.length) box.appendChild(el('p', 'text-on-surface-variant text-center py-6', 'Tidak ada bill yang ditahan.'));
    list.forEach(function (h, idx) {
      var row = el('div', 'bg-surface-container-low rounded-lg p-space-sm flex items-center justify-between gap-space-sm');
      var info = el('div', 'flex flex-col min-w-0');
      var n = 0; h.cart.forEach(function (i) { n += i.qty; });
      info.appendChild(el('span', 'font-body-lg font-bold text-primary truncate', (h.customer || 'Tanpa nama') + ' • ' + TYPE_LABEL[h.type]));
      info.appendChild(el('span', 'font-label-sm text-label-sm text-on-surface-variant', n + ' item • ' + new Date(h.t).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' })));
      row.appendChild(info);
      var acts = el('div', 'flex gap-space-xs');
      var go = el('button', 'px-3 py-1.5 rounded-lg bg-tertiary-container text-on-tertiary font-semibold', 'Lanjutkan');
      var rm = el('button', 'px-3 py-1.5 rounded-lg bg-surface-container-high hover:bg-error-container hover:text-error font-semibold', 'Hapus');
      go.type = rm.type = 'button';
      go.addEventListener('click', function () { resumeBill(idx); });
      rm.addEventListener('click', function () { var l = loadHold(); l.splice(idx, 1); saveHold(l); openHoldList(); });
      acts.appendChild(go); acts.appendChild(rm);
      row.appendChild(acts);
      box.appendChild(row);
    });
    $('holdModal').classList.remove('hidden');
  }

  function resumeBill(idx) {
    if (state.cart.length && !confirm('Keranjang saat ini akan diganti. Lanjutkan?')) return;
    var list = loadHold();
    var h = list.splice(idx, 1)[0];
    if (!h) return;
    saveHold(list);
    state.cart = (h.cart || []).filter(function (i) { return cardById[i.id]; });
    state.discKind = h.discKind; state.discValue = h.discValue; state.billNote = h.billNote || '';
    $('customerInput').value = h.customer || '';
    $('tableInput').value = h.table || '';
    setType(h.type);
    $('holdModal').classList.add('hidden');
    render();
  }

  // ---------------------------------------------------------------- diskon & catatan
  function askDiscount() {
    var cur = state.discValue ? (state.discKind === 'percent' ? state.discValue + '%' : String(state.discValue)) : '';
    var v = prompt('Diskon: isi angka untuk Rupiah (mis. 5000) atau akhiri dengan % (mis. 10%).\nKosongkan untuk menghapus diskon.', cur);
    if (v === null) return;
    v = v.trim();
    if (v === '') { state.discKind = 'nominal'; state.discValue = 0; render(); return; }
    var pct = v.slice(-1) === '%';
    var n = parseInt(v.replace(/[^0-9]/g, ''), 10);
    if (isNaN(n) || n < 0 || (pct && n > 100)) { toast('Diskon tidak valid', 'Contoh: 5000 atau 10%', true); return; }
    state.discKind = pct ? 'percent' : 'nominal';
    state.discValue = n;
    render();
  }

  function askBillNote() {
    var v = prompt('Catatan bill:', state.billNote);
    if (v !== null) state.billNote = v.trim().slice(0, 255);
  }

  // ---------------------------------------------------------------- tipe order & pembayaran
  function setType(t) {
    state.type = t;
    Array.prototype.forEach.call(document.querySelectorAll('.order-type-btn'), function (b) {
      b.className = b.getAttribute('data-type') === t ? ACTIVE_TYPE : IDLE_TYPE;
    });
    render();
  }

  function setPay(p) {
    state.pay = p;
    Array.prototype.forEach.call(document.querySelectorAll('.pay-method-btn'), function (b) {
      b.className = b.getAttribute('data-pay') === p ? ACTIVE_PAY : IDLE_PAY;
    });
    $('cashPanel').classList.toggle('hidden', p !== 'TUNAI');
    render();
  }

  function setCat(c) {
    state.cat = c;
    Array.prototype.forEach.call(document.querySelectorAll('.cat-pill'), function (b) {
      b.className = b.getAttribute('data-cat') === c ? ACTIVE_CAT : IDLE_CAT;
    });
    applyFilter();
  }

  // ---------------------------------------------------------------- checkout
  function printReceipt(orderId) {
    var f = document.createElement('iframe');
    f.style.cssText = 'position:fixed;width:0;height:0;border:0;right:0;bottom:0;';
    f.src = CTX + '/receipt?id=' + orderId + '&print=1';
    document.body.appendChild(f);
    setTimeout(function () { f.remove(); }, 60000);
  }

  function checkout() {
    if (state.busy) return;
    if (!state.cart.length) { toast('Keranjang kosong', 'Pilih menu terlebih dahulu.', true); return; }
    var t = totals();
    var cash = state.pay === 'TUNAI' ? (state.cash === null ? t.total : state.cash) : t.total;
    if (state.pay === 'TUNAI' && cash < t.total) { toast('Uang kurang', 'Uang diterima kurang dari total pembayaran.', true); return; }

    var payload = {
      orderType: state.type,
      tableNo: state.type === 'DINE_IN' ? $('tableInput').value.trim() : '',
      customerName: $('customerInput').value.trim(),
      note: state.billNote,
      paymentMethod: state.pay,
      cashReceived: cash,
      discount: t.disc,
      items: state.cart.map(function (i) { return { menuId: parseInt(i.id, 10), qty: i.qty, note: i.note }; })
    };
    var sold = state.cart.map(function (i) { return { id: i.id, qty: i.qty }; });

    state.busy = true; render();
    fetch(CTX + '/api/orders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify(payload)
    }).then(function (r) {
      return r.json().catch(function () { return { ok: false, message: 'Respons server tidak dikenali (sesi habis? coba muat ulang halaman).' }; });
    }).then(function (res) {
      state.busy = false;
      if (!res.ok) { render(); toast('Gagal menyimpan', res.message || 'Terjadi kesalahan.', true); return; }
      sold.forEach(function (s) { setStock(s.id, stockOf(s.id) - s.qty); });
      var badge = $('navActiveBadge');
      if (badge) { badge.textContent = String((parseInt(badge.textContent, 10) || 0) + 1); badge.classList.remove('hidden'); }
      var msg = 'Struk #' + res.orderNo + ' dikirim ke printer.' + (res.change > 0 ? ' Kembalian ' + rp(res.change) + '.' : '');
      clearAll(false);
      toast('Pembayaran Sukses!', msg);
      printReceipt(res.orderId);
    }).catch(function () {
      state.busy = false; render();
      toast('Koneksi gagal', 'Tidak dapat menghubungi server.', true);
    });
  }

  // ---------------------------------------------------------------- event
  cards.forEach(function (c) {
    refreshCard(c);
    c.addEventListener('click', function () { addItem(c.getAttribute('data-id')); });
  });
  Array.prototype.forEach.call(document.querySelectorAll('.order-type-btn'), function (b) {
    b.addEventListener('click', function () { setType(b.getAttribute('data-type')); });
  });
  Array.prototype.forEach.call(document.querySelectorAll('.pay-method-btn'), function (b) {
    b.addEventListener('click', function () { setPay(b.getAttribute('data-pay')); });
  });
  Array.prototype.forEach.call(document.querySelectorAll('.cat-pill'), function (b) {
    b.addEventListener('click', function () { setCat(b.getAttribute('data-cat')); });
  });

  $('menuSearchInput').addEventListener('input', function (e) { state.q = e.target.value.trim().toLowerCase(); applyFilter(); });
  $('cashReceivedInput').addEventListener('input', function (e) {
    var digits = e.target.value.replace(/[^0-9]/g, '');
    state.cash = digits === '' ? null : parseInt(digits, 10);
    e.target.value = digits === '' ? '' : Number(digits).toLocaleString('id-ID');
    renderChange(totals().total);
  });
  $('btnDiscount').addEventListener('click', askDiscount);
  $('btnNote').addEventListener('click', askBillNote);
  $('btnCheckout').addEventListener('click', checkout);
  $('btnHold').addEventListener('click', holdBill);
  $('btnHoldList').addEventListener('click', openHoldList);
  $('holdClose').addEventListener('click', function () { $('holdModal').classList.add('hidden'); });
  $('toastClose').addEventListener('click', hideToast);
  $('btnClear').addEventListener('click', function () {
    if (!state.cart.length || confirm('Batalkan pesanan yang sedang dibuat?')) clearAll(false);
  });

  window.addEventListener('keydown', function (e) {
    if (e.key === 'F9') { e.preventDefault(); checkout(); }
    else if (e.key === 'F4') { e.preventDefault(); askDiscount(); }
    else if ((e.ctrlKey || e.metaKey) && (e.key === 'k' || e.key === 'K')) { e.preventDefault(); $('menuSearchInput').focus(); }
  });

  setType('DINE_IN');
  setPay('TUNAI');
  setCat('all');
  updateHoldCount();
  render();
})();
