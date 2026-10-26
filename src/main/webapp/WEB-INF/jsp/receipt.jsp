<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="id_ID"/>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Struk <c:out value="${order.orderNo}"/></title>
<style>
  * { box-sizing: border-box; }
  body { font-family: 'Courier New', monospace; font-size: 12px; width: 72mm; margin: 0 auto; padding: 4mm 2mm; color: #000; }
  h1 { font-size: 15px; text-align: center; margin: 0; }
  .c { text-align: center; }
  .row { display: flex; justify-content: space-between; gap: 8px; }
  hr { border: 0; border-top: 1px dashed #000; margin: 6px 0; }
  .item { margin: 3px 0; }
  .note { font-style: italic; padding-left: 8px; }
  .big { font-size: 14px; font-weight: bold; }
  .btns { margin-top: 12px; text-align: center; }
  .btns button { padding: 6px 14px; font-size: 13px; }
  @media print { .btns { display: none; } @page { margin: 0; } }
</style>
</head>
<body>
  <h1>KOPI NUSANTARA</h1>
  <div class="c">Warung Kopi &amp; Camilan</div>
  <hr>
  <div class="row"><span>No</span><span><c:out value="${order.orderNo}"/></span></div>
  <div class="row"><span>Tanggal</span><span><c:out value="${order.createdAtText}"/></span></div>
  <div class="row"><span>Kasir</span><span><c:out value="${order.cashierName}"/></span></div>
  <div class="row"><span>Tipe</span><span><c:out value="${order.typeLabel}"/><c:if test="${not empty order.tableNo}"> / Meja <c:out value="${order.tableNo}"/></c:if></span></div>
  <c:if test="${not empty order.customerName}"><div class="row"><span>Pelanggan</span><span><c:out value="${order.customerName}"/></span></div></c:if>
  <hr>
  <c:forEach var="it" items="${order.items}">
    <div class="item">
      <div><c:out value="${it.itemName}"/></div>
      <div class="row"><span>&nbsp;&nbsp;${it.qty} x <fmt:formatNumber value="${it.unitPrice}" pattern="#,##0"/></span><span><fmt:formatNumber value="${it.lineTotal}" pattern="#,##0"/></span></div>
      <c:if test="${not empty it.note}"><div class="note">* <c:out value="${it.note}"/></div></c:if>
    </div>
  </c:forEach>
  <hr>
  <div class="row"><span>Subtotal</span><span><fmt:formatNumber value="${order.subtotal}" pattern="#,##0"/></span></div>
  <c:if test="${order.discount > 0}"><div class="row"><span>Diskon</span><span>-<fmt:formatNumber value="${order.discount}" pattern="#,##0"/></span></div></c:if>
  <div class="row"><span> </span><span><fmt:formatNumber value="${order.tax}" pattern="#,##0"/></span></div>
  <div class="row big"><span>TOTAL</span><span>Rp <fmt:formatNumber value="${order.total}" pattern="#,##0"/></span></div>
  <hr>
  <div class="row"><span>Bayar (<c:out value="${order.paymentLabel}"/>)</span><span><fmt:formatNumber value="${order.cashReceived}" pattern="#,##0"/></span></div>
  <div class="row"><span>Kembali</span><span><fmt:formatNumber value="${order.changeAmount}" pattern="#,##0"/></span></div>
  <c:if test="${not empty order.note}"><hr><div>Catatan: <c:out value="${order.note}"/></div></c:if>
  <hr>
  <div class="c">Terima kasih &amp; selamat menikmati!</div>
  <div class="btns"><button onclick="window.print()">Cetak</button> <button onclick="window.close()">Tutup</button></div>
  <c:if test="${autoPrint}"><script>window.addEventListener('load', function () { window.focus(); window.print(); });</script></c:if>
</body>
</html>
