<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Ganti Password"/>
<%@ include file="/WEB-INF/jspf/header.jspf" %>
<c:set var="inputCls" value="w-full bg-surface-container-low px-3 py-2.5 rounded-lg focus:outline-none focus:bg-surface-container-lowest focus:shadow-[0_0_0_2px_#ffb559]"/>
<div class="w-full px-gutter-desktop py-space-lg flex justify-center">
  <form method="post" action="${ctx}/password" class="w-full max-w-md bg-surface-container-lowest rounded-xl shadow-sm p-space-xl flex flex-col gap-space-md">
    <h1 class="font-headline-md text-headline-md text-primary">Ganti Password</h1>
    <p class="text-on-surface-variant">Akun: <b><c:out value="${sessionScope.user.username}"/></b></p>
    <c:if test="${not empty error}"><div class="bg-error-container text-on-error-container rounded-lg px-3 py-2"><c:out value="${error}"/></div></c:if>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Password lama</span><input name="oldPassword" type="password" required autocomplete="current-password" class="${inputCls}"></label>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Password baru (min. 6 karakter)</span><input name="newPassword" type="password" required minlength="6" autocomplete="new-password" class="${inputCls}"></label>
    <label class="flex flex-col gap-1"><span class="font-label-sm text-label-sm uppercase text-on-surface-variant font-bold">Ulangi password baru</span><input name="confirmPassword" type="password" required minlength="6" autocomplete="new-password" class="${inputCls}"></label>
    <button class="w-full py-3 rounded-xl bg-tertiary-container hover:bg-tertiary text-on-tertiary font-title-lg font-bold">Simpan Password</button>
  </form>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
