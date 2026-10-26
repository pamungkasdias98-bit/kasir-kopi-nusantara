<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Dashboard Menu"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<c:set var="inputCls" value="w-full bg-surface-container-low px-3 py-2 rounded-lg focus:outline-none focus:bg-surface-container-lowest focus:shadow-[0_0_0_2px_#ffb559]"/>

<div class="w-full px-gutter-desktop py-space-md flex flex-col gap-space-lg">
  <div class="flex flex-wrap items-center justify-between gap-space-md">
    <div>
      <h1 class="font-headline-lg text-headline-lg text-primary">Dashboard Menu</h1>
      <p class="text-on-surface-variant">Kelola menu, harga, stok, dan kategori. Perubahan langsung tampil di halaman kasir.</p>
    </div>
    <button type="button" id="btnAdd" class="px-5 py-2.5 rounded-xl bg-tertiary-container hover:bg-tertiary text-on-tertiary font-bold shadow-md flex items-center gap-2">
      <span class="material-symbols-outlined">add</span>Tambah Menu
    </button>
  </div>

  <div class="bg-surface-container-lowest rounded-xl shadow-sm overflow-x-auto">
    <table class="w-full text-left">
      <thead class="bg-surface-container-low font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant">
        <tr><th class="p-3">Menu</th><th class="p-3">Kategori</th><th class="p-3 text-right">Harga</th><th class="p-3 text-right">Stok</th><th class="p-3">Status</th><th class="p-3 text-right">Aksi</th></tr>
      </thead>
      <tbody>
        <c:forEach var="m" items="${items}">
          <tr class="border-t border-surface-variant ${m.active ? '' : 'opacity-60'}"
              data-id="${m.id}" data-category="${m.categoryId}" data-price="${m.price}" data-stock="${m.stock}" data-active="${m.active}"
              data-name="<c:out value='${m.name}'/>" data-desc="<c:out value='${m.description}'/>" data-badge="<c:out value='${m.badge}'/>"
              data-note="<c:out value='${m.defaultNote}'/>" data-image="<c:out value='${m.imageUrl}'/>">
            <td class="p-3">
              <div class="flex items-center gap-3">
                <div class="relative w-12 h-12 rounded-lg bg-surface-container overflow-hidden flex items-center justify-center shrink-0">
                  <span class="material-symbols-outlined text-outline-variant absolute">coffee</span>
                  <c:if test="${not empty m.imageUrl}"><img src="<c:out value='${m.imageUrl}'/>" alt="" loading="lazy" class="relative w-full h-full object-cover" onerror="this.remove()"></c:if>
                </div>
                <div class="min-w-0">
                  <div class="font-body-lg font-bold text-primary"><c:out value="${m.name}"/>
                    <c:if test="${not empty m.badge}"><span class="ml-1 bg-secondary text-on-secondary px-2 py-0.5 rounded-full font-code-badge text-code-badge"><c:out value="${m.badge}"/></span></c:if>
                  </div>
                  <div class="text-on-surface-variant truncate max-w-xs"><c:out value="${m.description}"/></div>
                </div>
              </div>
            </td>
            <td class="p-3"><c:out value="${m.categoryName}"/></td>
            <td class="p-3 text-right font-label-currency text-body-lg">Rp <fmt:formatNumber value="${m.price}" pattern="#,##0"/></td>
            <td class="p-3 text-right font-label-currency text-body-lg ${m.stock <= 5 ? 'text-error' : ''}">${m.stock}</td>
            <td class="p-3">
              <form method="post" action="${ctx}/menu-admin">
                <input type="hidden" name="action" value="toggle"><input type="hidden" name="id" value="${m.id}">
                <input type="hidden" name="active" value="${m.active ? 0 : 1}">
                <button class="px-3 py-1 rounded-full font-code-badge text-code-badge font-bold ${m.active ? 'bg-tertiary-fixed text-on-tertiary-fixed' : 'bg-surface-container-high text-on-surface-variant'}" title="Klik untuk ${m.active ? 'nonaktifkan' : 'aktifkan'}">${m.active ? 'AKTIF' : 'NONAKTIF'}</button>
              </form>
            </td>
            <td class="p-3">
              <div class="flex justify-end gap-1">
                <button type="button" class="btn-edit w-9 h-9 rounded-lg bg-surface-container-low hover:bg-surface-container-high flex items-center justify-center" title="Ubah"><span class="material-symbols-outlined text-[20px]">edit</span></button>
                <form method="post" action="${ctx}/menu-admin" onsubmit="return confirm('Hapus menu ini? Riwayat pesanan lama tetap tersimpan.');">
                  <input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="${m.id}">
                  <button class="w-9 h-9 rounded-lg bg-surface-container-low hover:bg-error-container hover:text-error flex items-center justify-center" title="Hapus"><span class="material-symbols-outlined text-[20px]">delete</span></button>
                </form>
              </div>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty items}"><tr><td colspan="6" class="p-8 text-center text-on-surface-variant">Belum ada menu. Klik "Tambah Menu".</td></tr></c:if>
      </tbody>
    </table>
  </div>

  <div class="bg-surface-container-lowest rounded-xl shadow-sm p-space-lg flex flex-col gap-space-md">
    <h2 class="font-title-lg text-title-lg text-primary">Kategori</h2>
    <div class="flex flex-wrap gap-space-sm">
      <c:forEach var="cat" items="${categories}">
        <form method="post" action="${ctx}/menu-admin" class="flex items-center gap-2 bg-surface-container-low rounded-lg pl-3 pr-1 py-1" onsubmit="return confirm('Hapus kategori ini?');">
          <input type="hidden" name="action" value="deleteCategory"><input type="hidden" name="id" value="${cat.id}">
          <span><c:out value="${cat.icon} ${cat.name}"/> <span class="text-on-surface-variant">(${cat.itemCount})</span></span>
          <button class="w-7 h-7 rounded hover:bg-error-container hover:text-error flex items-center justify-center" title="Hapus kategori (hanya jika kosong)"><span class="material-symbols-outlined text-[16px]">close</span></button>
        </form>
      </c:forEach>
    </div>
    <form method="post" action="${ctx}/menu-admin" class="flex flex-wrap gap-space-sm items-end">
      <input type="hidden" name="action" value="addCategory">
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Ikon (emoji)</span><input name="icon" maxlength="8" placeholder="🍰" class="${inputCls} w-24"></label>
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Nama kategori</span><input name="name" maxlength="80" required placeholder="Dessert" class="${inputCls} w-64"></label>
      <button class="px-4 py-2 rounded-lg bg-primary-container text-on-primary font-bold">Tambah Kategori</button>
    </form>
  </div>
</div>

<%-- Modal tambah / ubah menu --%>
<div id="menuModal" class="hidden fixed inset-0 z-50 bg-[rgba(43,38,37,0.45)] backdrop-blur-[4px] flex items-center justify-center p-4 overflow-y-auto">
  <form method="post" action="${ctx}/menu-admin" class="bg-surface-container-lowest rounded-2xl shadow-2xl w-full max-w-xl p-space-xl flex flex-col gap-space-md my-auto">
    <input type="hidden" name="action" value="save">
    <input type="hidden" name="id" id="fId" value="0">
    <div class="flex items-center justify-between">
      <h2 id="modalTitle" class="font-headline-md text-headline-md text-primary">Tambah Menu</h2>
      <button type="button" id="modalClose" class="w-8 h-8 rounded-lg hover:bg-surface-container-high flex items-center justify-center"><span class="material-symbols-outlined">close</span></button>
    </div>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Nama menu</span><input id="fName" name="name" maxlength="120" required class="${inputCls}"></label>
    <div class="grid grid-cols-2 gap-space-md">
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Kategori</span>
        <select id="fCategory" name="categoryId" required class="${inputCls}">
          <c:forEach var="cat" items="${categories}"><option value="${cat.id}"><c:out value="${cat.icon} ${cat.name}"/></option></c:forEach>
        </select></label>
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Label (opsional)</span><input id="fBadge" name="badge" maxlength="30" placeholder="Best Seller" class="${inputCls}"></label>
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Harga (Rp)</span><input id="fPrice" name="price" type="number" min="0" step="500" required class="${inputCls}"></label>
      <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Stok</span><input id="fStock" name="stock" type="number" min="0" required class="${inputCls}"></label>
    </div>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Deskripsi singkat</span><input id="fDesc" name="description" maxlength="255" class="${inputCls}"></label>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Catatan bawaan di struk</span><input id="fNote" name="defaultNote" maxlength="150" placeholder="Less ice, normal sweet" class="${inputCls}"></label>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">URL gambar (opsional)</span><input id="fImage" name="imageUrl" maxlength="1000" placeholder="https://..." class="${inputCls}"></label>
    <label class="flex items-center gap-2"><input id="fActive" name="active" type="checkbox" checked class="w-4 h-4"><span>Tampilkan di halaman kasir</span></label>
    <div class="flex justify-end gap-space-sm pt-2">
      <button type="button" id="modalCancel" class="px-4 py-2 rounded-lg bg-surface-container-high font-semibold">Batal</button>
      <button class="px-5 py-2 rounded-lg bg-tertiary-container hover:bg-tertiary text-on-tertiary font-bold">Simpan</button>
    </div>
  </form>
</div>

<script>
  (function () {
    var modal = document.getElementById('menuModal');
    function $(id) { return document.getElementById(id); }
    function open(t, d) {
      $('modalTitle').textContent = t;
      d = d || {};
      $('fId').value = d.id || 0;
      $('fName').value = d.name || '';
      if (d.category) $('fCategory').value = d.category; else $('fCategory').selectedIndex = 0;
      $('fBadge').value = d.badge || '';
      $('fPrice').value = d.price || '';
      $('fStock').value = d.stock || (d.id ? 0 : '');
      $('fDesc').value = d.desc || '';
      $('fNote').value = d.note || '';
      $('fImage').value = d.image || '';
      $('fActive').checked = d.active !== false;
      modal.classList.remove('hidden');
      $('fName').focus();
    }
    function close() { modal.classList.add('hidden'); }
    $('btnAdd').addEventListener('click', function () { open('Tambah Menu'); });
    $('modalClose').addEventListener('click', close);
    $('modalCancel').addEventListener('click', close);
    Array.prototype.forEach.call(document.querySelectorAll('.btn-edit'), function (b) {
      b.addEventListener('click', function () {
        var r = b.closest('tr');
        open('Ubah Menu', {
          id: r.dataset.id, name: r.dataset.name, category: r.dataset.category, badge: r.dataset.badge,
          price: r.dataset.price, stock: r.dataset.stock, desc: r.dataset.desc, note: r.dataset.note,
          image: r.dataset.image, active: r.dataset.active === 'true'
        });
      });
    });
  })();
</script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
