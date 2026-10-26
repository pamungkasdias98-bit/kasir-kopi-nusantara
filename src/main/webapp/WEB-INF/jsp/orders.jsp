<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Status Pesanan"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="w-full px-gutter-desktop py-space-md flex flex-col gap-space-lg">
  <div class="flex flex-wrap items-center justify-between gap-space-md">
    <div>
      <h1 class="font-headline-lg text-headline-lg text-primary">Status Pesanan</h1>
      <p class="text-on-surface-variant">Antrean bar &amp; dapur. Halaman ini menyegarkan diri tiap 30 detik.</p>
    </div>
    <div class="flex gap-space-md">
      <div class="bg-surface-container-lowest rounded-xl shadow-sm px-space-lg py-space-sm">
        <div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Transaksi hari ini</div>
        <div class="font-label-currency text-label-currency text-primary">${todayCount}</div>
      </div>
      <div class="bg-surface-container-lowest rounded-xl shadow-sm px-space-lg py-space-sm">
        <div class="font-label-sm text-label-sm text-on-surface-variant uppercase">Penjualan hari ini</div>
        <div class="font-label-currency text-label-currency text-primary">Rp <fmt:formatNumber value="${todayTotal}" pattern="#,##0"/></div>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-space-lg items-start">
    <section class="flex flex-col gap-space-md">
      <h2 class="font-title-lg text-title-lg text-primary flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-secondary animate-pulse"></span>Sedang Diproses
        <span class="bg-secondary-container text-on-secondary-container font-code-badge text-code-badge px-2 py-0.5 rounded-full">${fn:length(proses)}</span>
      </h2>
      <c:forEach var="o" items="${proses}"><%@ include file="/WEB-INF/jspf/order-card.jspf" %></c:forEach>
      <c:if test="${empty proses}"><p class="text-on-surface-variant bg-surface-container-lowest rounded-xl p-space-lg text-center">Tidak ada pesanan.</p></c:if>
    </section>

    <section class="flex flex-col gap-space-md">
      <h2 class="font-title-lg text-title-lg text-primary flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-tertiary-container"></span>Siap Diantar / Diambil
        <span class="bg-tertiary-fixed text-on-tertiary-fixed font-code-badge text-code-badge px-2 py-0.5 rounded-full">${fn:length(siap)}</span>
      </h2>
      <c:forEach var="o" items="${siap}"><%@ include file="/WEB-INF/jspf/order-card.jspf" %></c:forEach>
      <c:if test="${empty siap}"><p class="text-on-surface-variant bg-surface-container-lowest rounded-xl p-space-lg text-center">Tidak ada pesanan.</p></c:if>
    </section>

    <section class="flex flex-col gap-space-md">
      <h2 class="font-title-lg text-title-lg text-primary flex items-center gap-2">
        <span class="w-2.5 h-2.5 rounded-full bg-outline"></span>Selesai Hari Ini
        <span class="bg-surface-container-high text-on-surface-variant font-code-badge text-code-badge px-2 py-0.5 rounded-full">${fn:length(selesai)}</span>
      </h2>
      <c:forEach var="o" items="${selesai}"><%@ include file="/WEB-INF/jspf/order-card.jspf" %></c:forEach>
      <c:if test="${empty selesai}"><p class="text-on-surface-variant bg-surface-container-lowest rounded-xl p-space-lg text-center">Belum ada.</p></c:if>
    </section>
  </div>
</div>
<script>setTimeout(function () { location.reload(); }, 30000);</script>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
