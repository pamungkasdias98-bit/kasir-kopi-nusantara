<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Kasir"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="flex flex-col w-full">
<div class="w-full px-gutter-desktop py-space-md flex flex-col lg:flex-row gap-space-lg items-start">

  <%-- ============ PANEL KIRI: KATALOG MENU ============ --%>
  <div class="w-full lg:w-[63%] xl:w-[65%] flex flex-col gap-space-md">
    <div class="bg-surface-container-lowest p-space-md rounded-xl shadow-sm flex flex-col gap-space-sm">
      <div class="flex items-center gap-space-sm w-full">
        <div class="relative flex-1 flex items-center">
          <span class="material-symbols-outlined absolute left-space-md text-on-surface-variant pointer-events-none text-[20px]">search</span>
          <input id="menuSearchInput" type="text" autocomplete="off"
                 placeholder="Cari menu (kopi susu, tubruk, toast, roti bakar, v60...)"
                 class="w-full bg-surface-container-low pl-10 pr-space-md py-space-sm rounded-lg font-body-md text-body-md text-on-surface placeholder:text-on-surface-variant focus:outline-none focus:bg-surface-container-lowest focus:shadow-[0_0_0_2px_#ffb559] transition-all">
          <span class="absolute right-space-md text-on-surface-variant font-code-badge text-code-badge bg-surface-container px-1.5 py-0.5 rounded">Ctrl+K</span>
        </div>
      </div>

      <div class="flex flex-wrap items-center justify-between gap-space-sm pt-space-xs">
        <div class="flex flex-wrap items-center gap-space-xs">
          <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider mr-1">Tipe Order:</span>
          <button type="button" data-type="DINE_IN" class="order-type-btn px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 transition-all"><span class="material-symbols-outlined text-[16px]">table_restaurant</span><span>Dine In / Meja</span></button>
          <button type="button" data-type="TAKE_AWAY" class="order-type-btn px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 transition-all"><span class="material-symbols-outlined text-[16px]">shopping_bag</span><span>Take Away</span></button>
          <button type="button" data-type="OJOL" class="order-type-btn px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5 transition-all"><span class="material-symbols-outlined text-[16px]">delivery_dining</span><span>Ojol (Go/Grab/Shopee)</span></button>
        </div>
      </div>

      <div class="flex items-center gap-space-xs overflow-x-auto pt-space-xs pb-1">
        <button type="button" data-cat="all" class="cat-pill whitespace-nowrap px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5">✨ Semua Menu</button>
        <c:forEach var="cat" items="${categories}">
          <button type="button" data-cat="${cat.id}" class="cat-pill whitespace-nowrap px-space-md py-1.5 rounded-lg font-body-md text-body-md flex items-center gap-1.5"><c:out value="${cat.icon} ${cat.name}"/></button>
        </c:forEach>
      </div>
    </div>

    <div id="menuGrid" class="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-space-md">
      <c:forEach var="m" items="${menuItems}">
        <div class="menu-card group relative bg-surface-container-lowest rounded-xl p-space-sm flex flex-col justify-between shadow-sm hover:shadow-md transition-all cursor-pointer select-none"
             data-id="${m.id}" data-cat="${m.categoryId}" data-price="${m.price}" data-stock="${m.stock}"
             data-name="<c:out value='${m.name}'/>" data-note="<c:out value='${m.defaultNote}'/>"
             data-search="<c:out value='${fn:toLowerCase(m.name)} ${fn:toLowerCase(m.description)} ${fn:toLowerCase(m.categoryName)}'/>">
          <div class="relative w-full h-32 rounded-lg overflow-hidden bg-surface-container mb-space-xs flex items-center justify-center">
            <span class="material-symbols-outlined text-[40px] text-outline-variant absolute">coffee</span>
            <c:if test="${not empty m.imageUrl}">
              <img class="relative w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" loading="lazy"
                   alt="<c:out value='${m.name}'/>" src="<c:out value='${m.imageUrl}'/>" onerror="this.remove()">
            </c:if>
            <c:if test="${not empty m.badge}">
              <div class="absolute top-2 left-2 bg-secondary text-on-secondary px-2 py-0.5 rounded-full font-code-badge text-code-badge shadow-sm"><c:out value="${m.badge}"/></div>
            </c:if>
            <div class="stock-badge absolute bottom-2 right-2 bg-surface-container-lowest/90 backdrop-blur-sm text-tertiary font-label-sm text-label-sm px-2 py-0.5 rounded-md font-semibold"></div>
          </div>
          <div class="flex flex-col flex-1 justify-between">
            <div>
              <h3 class="font-title-lg text-title-lg text-primary line-clamp-1 font-bold group-hover:text-secondary transition-colors"><c:out value="${m.name}"/></h3>
              <p class="font-body-md text-body-md text-on-surface-variant line-clamp-1"><c:out value="${m.description}"/></p>
            </div>
            <div class="flex items-center justify-between pt-space-sm mt-space-xs">
              <span class="font-label-currency text-label-currency text-primary">Rp <fmt:formatNumber value="${m.price}" pattern="#,##0"/></span>
              <span class="w-8 h-8 rounded-lg bg-surface-container-high group-hover:bg-primary group-hover:text-on-primary text-primary flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px]">add</span></span>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
    <div id="menuEmpty" class="hidden text-center text-on-surface-variant py-10">
      <span class="material-symbols-outlined text-[40px]">search_off</span>
      <p>Menu tidak ditemukan.</p>
    </div>
    <c:if test="${empty menuItems}">
      <div class="text-center text-on-surface-variant py-10">Belum ada menu aktif. Admin dapat menambahkannya di <b>Dashboard Menu</b>.</div>
    </c:if>
  </div>

  <%-- ============ PANEL KANAN: KERANJANG & PEMBAYARAN ============ --%>
  <div class="w-full lg:w-[37%] xl:w-[35%] flex flex-col gap-space-md lg:sticky lg:top-24">
    <div class="bg-surface-container-lowest rounded-xl shadow-sm p-space-md flex flex-col gap-space-md">
      <div class="flex flex-col gap-space-xs">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-space-xs">
            <span class="material-symbols-outlined text-primary text-[22px]">receipt_long</span>
            <span class="font-label-currency text-label-currency text-primary">Pesanan Baru</span>
          </div>
          <span id="typeChip" class="bg-tertiary-container text-tertiary-fixed font-code-badge text-code-badge px-2.5 py-1 rounded-md font-bold uppercase tracking-wider">Dine In</span>
          <button type="button" id="btnHoldList" class="flex items-center gap-1 bg-surface-container-low hover:bg-surface-container-high text-primary px-2 py-1 rounded-md font-label-sm text-label-sm font-semibold transition-colors border border-surface-variant" title="Bill yang ditahan">
            <span class="material-symbols-outlined text-[16px]">pause_circle</span>Ditahan (<span id="holdCount">0</span>)
          </button>
        </div>
        <div class="flex gap-space-xs mt-space-xs">
          <div class="relative flex-1">
            <span class="material-symbols-outlined absolute left-space-sm top-2 text-on-surface-variant text-[18px]">person</span>
            <input id="customerInput" type="text" maxlength="100" placeholder="Nama Pelanggan (opsional)"
                   class="w-full bg-surface-container-low pl-8 pr-space-md py-1.5 rounded-lg font-body-md text-body-md text-on-surface focus:outline-none focus:bg-surface-container-lowest focus:shadow-[0_0_0_2px_#ffb559] transition-all">
          </div>
          <input id="tableInput" type="text" maxlength="10" placeholder="No. Meja"
                 class="w-24 bg-surface-container-low px-space-md py-1.5 rounded-lg font-body-md text-body-md text-on-surface focus:outline-none focus:bg-surface-container-lowest focus:shadow-[0_0_0_2px_#ffb559] transition-all">
        </div>
      </div>

      <div class="flex flex-col gap-space-sm max-h-[300px] overflow-y-auto pr-1" id="cartItemList"></div>
      <div id="cartEmpty" class="text-center text-on-surface-variant py-6">
        <span class="material-symbols-outlined text-[36px]">shopping_cart</span>
        <p>Keranjang kosong. Klik menu untuk menambah.</p>
      </div>

      <div class="flex items-center gap-space-xs pt-1">
        <button type="button" id="btnDiscount" class="flex-1 py-1.5 px-space-sm bg-surface-container-low hover:bg-surface-container text-on-surface-variant rounded-lg font-body-md flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[16px]">percent</span><span>Tambah Diskon / Promo</span> <span class="font-code-badge text-code-badge">F4</span></button>
        <button type="button" id="btnNote" class="py-1.5 px-space-sm bg-surface-container-low hover:bg-surface-container text-on-surface-variant rounded-lg font-body-md flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[16px]">edit_note</span><span>Catatan Bill</span></button>
      </div>

      <div class="bg-surface-container-low p-space-md rounded-xl flex flex-col gap-space-xs">
        <div class="flex justify-between font-body-md text-on-surface-variant">
          <span id="sumLabel">Subtotal (0 Menu, 0 Item)</span>
          <span class="font-label-currency text-body-lg text-on-surface font-semibold" id="cartSubtotal">Rp 0</span>
        </div>
        <div style="display:none">
          <span>Pajak Restoran PB1 (10%)</span>
          <span class="font-label-currency text-body-lg text-on-surface" id="cartTax">Rp 0</span>
        </div>
        <div class="flex justify-between font-body-md text-on-surface-variant">
          <span>Diskon</span>
          <span class="font-label-currency text-body-lg text-tertiary-container font-semibold" id="cartDiscount">-Rp 0</span>
        </div>
        <div class="h-px bg-surface-variant my-1"></div>
        <div class="flex justify-between items-baseline pt-1">
          <div class="flex flex-col">
            <span class="font-label-sm text-label-sm uppercase font-bold text-on-surface-variant tracking-wider">Total Pembayaran</span>
            <span class="font-label-sm text-label-sm text-secondary font-medium">Sudah termasuk pajak</span>
          </div>
          <span class="font-label-currency-lg text-label-currency-lg text-primary font-bold" id="cartTotal">Rp 0</span>
        </div>
      </div>

      <div class="flex flex-col gap-space-xs">
        <span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Metode Pembayaran:</span>
        <div class="grid grid-cols-2 gap-space-xs">
          <button type="button" data-pay="TUNAI" class="pay-method-btn px-space-sm py-2 rounded-lg font-body-md flex items-center justify-center gap-1.5"><span class="material-symbols-outlined text-[18px]">payments</span><span>Tunai (Cash)</span></button>
          <button type="button" data-pay="QRIS" class="pay-method-btn px-space-sm py-2 rounded-lg font-body-md flex items-center justify-center gap-1.5"><span class="material-symbols-outlined text-[18px]">qr_code_2</span><span>QRIS / GoPay</span></button>
          <button type="button" data-pay="DEBIT" class="pay-method-btn px-space-sm py-2 rounded-lg font-body-md flex items-center justify-center gap-1.5"><span class="material-symbols-outlined text-[18px]">credit_card</span><span>Debit / EDC</span></button>
          <button type="button" data-pay="TRANSFER" class="pay-method-btn px-space-sm py-2 rounded-lg font-body-md flex items-center justify-center gap-1.5"><span class="material-symbols-outlined text-[18px]">account_balance</span><span>Transfer Bank</span></button>
        </div>
      </div>

      <div id="cashPanel" class="bg-surface-container p-space-md rounded-xl flex flex-col gap-space-sm">
        <div class="flex items-center justify-between">
          <span class="font-label-sm text-label-sm font-bold text-on-surface">Pecahan Cepat (Quick Cash):</span>
          <span class="font-code-badge text-code-badge text-secondary font-medium">Klik untuk isi otomatis</span>
        </div>
        <div id="quickCash" class="grid grid-cols-4 gap-space-xs"></div>
        <div class="grid grid-cols-2 gap-space-md pt-space-xs items-center">
          <div class="flex flex-col">
            <label for="cashReceivedInput" class="font-label-sm text-label-sm text-on-surface-variant font-semibold mb-1">Uang Diterima:</label>
            <div class="relative flex items-center">
              <span class="absolute left-2.5 font-label-currency text-body-md text-on-surface-variant">Rp</span>
              <input id="cashReceivedInput" type="text" inputmode="numeric" autocomplete="off" placeholder="Uang pas"
                     class="w-full bg-surface-container-lowest pl-9 pr-space-sm py-1.5 rounded-lg font-label-currency text-title-lg text-primary font-bold focus:outline-none focus:ring-2 focus:ring-secondary">
            </div>
          </div>
          <div class="flex flex-col">
            <span class="font-label-sm text-label-sm text-on-surface-variant font-semibold mb-1">Kembalian:</span>
            <div class="bg-surface-container-lowest px-space-sm py-1.5 rounded-lg flex items-center">
              <span class="font-label-currency text-title-lg text-tertiary-container font-bold" id="cashChangeDisplay">Rp 0</span>
            </div>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-space-xs pt-1">
        <button type="button" id="btnCheckout" class="w-full py-3.5 px-space-lg rounded-xl bg-tertiary-container hover:bg-tertiary text-on-tertiary font-title-lg text-title-lg font-bold shadow-md hover:shadow-lg active:translate-y-[1px] transition-all flex items-center justify-between disabled:opacity-50 disabled:cursor-not-allowed">
          <div class="flex items-center gap-space-xs"><span class="material-symbols-outlined text-[24px]">point_of_sale</span><span>Bayar &amp; Cetak Struk</span></div>
          <div class="flex items-center gap-space-xs"><span class="bg-tertiary-fixed text-on-tertiary-fixed px-2 py-0.5 rounded text-code-badge font-code-badge font-bold">F9</span><span class="material-symbols-outlined text-[20px]">chevron_right</span></div>
        </button>
        <div class="grid grid-cols-2 gap-space-xs mt-1">
          <button type="button" id="btnHold" class="py-2.5 px-space-sm rounded-lg bg-surface-container-low hover:bg-surface-container-high text-on-surface font-body-md font-semibold flex items-center justify-center gap-1.5 transition-colors"><span class="material-symbols-outlined text-[18px] text-secondary">pause_circle</span><span>Hold / Simpan Bill</span></button>
          <button type="button" id="btnClear" class="py-2.5 px-space-sm rounded-lg bg-surface-container-low hover:bg-error-container hover:text-error text-on-surface-variant font-body-md font-semibold flex items-center justify-center gap-1.5 transition-colors"><span class="material-symbols-outlined text-[18px]">cancel</span><span>Batalkan Pesanan</span></button>
        </div>
      </div>
    </div>

    <div class="bg-surface-container-lowest p-space-md rounded-xl flex items-center justify-between font-label-sm text-label-sm text-on-surface-variant">
      <div class="flex items-center gap-space-xs">
        <span class="material-symbols-outlined text-secondary text-[18px]">tips_and_updates</span>
        <span>Tekan <strong class="font-code-badge text-code-badge text-primary">F4</strong> untuk diskon kilat • <strong class="font-code-badge text-code-badge text-primary">F9</strong> untuk bayar</span>
      </div>
      <span class="font-code-badge text-code-badge bg-surface-container px-2 py-0.5 rounded text-tertiary-container font-bold">POS OK</span>
    </div>
  </div>
</div>
</div>

<%-- Daftar bill yang ditahan --%>
<div id="holdModal" class="hidden fixed inset-0 z-50 bg-[rgba(43,38,37,0.45)] backdrop-blur-[4px] flex items-center justify-center p-4">
  <div class="bg-surface-container-lowest rounded-2xl shadow-2xl w-full max-w-md p-space-xl flex flex-col gap-space-md">
    <div class="flex items-center justify-between">
      <h2 class="font-headline-md text-headline-md text-primary">Bill Ditahan</h2>
      <button type="button" id="holdClose" class="w-8 h-8 rounded-lg hover:bg-surface-container-high flex items-center justify-center"><span class="material-symbols-outlined">close</span></button>
    </div>
    <div id="holdList" class="flex flex-col gap-space-sm max-h-[50vh] overflow-y-auto"></div>
    <p class="font-label-sm text-label-sm text-on-surface-variant">Bill ditahan disimpan di browser perangkat ini dan belum mengurangi stok.</p>
  </div>
</div>

<%-- Notifikasi --%>
<div id="toast" class="fixed bottom-6 right-6 max-w-md text-on-tertiary p-space-md rounded-xl shadow-2xl transition-all duration-300 opacity-0 pointer-events-none translate-y-4 z-50 flex items-center gap-space-md bg-tertiary">
  <div class="w-10 h-10 rounded-full bg-tertiary-container flex items-center justify-center text-tertiary-fixed shrink-0"><span id="toastIcon" class="material-symbols-outlined text-[24px]">receipt</span></div>
  <div class="flex flex-col flex-1">
    <span id="toastTitle" class="font-title-lg text-title-lg font-bold text-white"></span>
    <span id="toastMsg" class="font-body-md text-body-md text-tertiary-fixed-dim"></span>
  </div>
  <button type="button" id="toastClose" class="text-tertiary-fixed hover:text-white p-1"><span class="material-symbols-outlined text-[20px]">close</span></button>
</div>

<script src="${ctx}/assets/pos.js?v=1"></script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
