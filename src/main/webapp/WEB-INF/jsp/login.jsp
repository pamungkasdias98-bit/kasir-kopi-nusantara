<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="pageTitle" value="Masuk"/>
<%@ include file="/WEB-INF/jspf/head.jspf" %>
<body class="bg-surface font-body-md text-on-surface antialiased min-h-screen flex items-center justify-center p-4">
  <form method="post" action="${pageContext.request.contextPath}/login"
        class="w-full max-w-sm bg-surface-container-lowest rounded-xl shadow-md p-space-2xl flex flex-col gap-space-lg">
    <div class="flex flex-col items-center gap-2">
      <div class="w-14 h-14 rounded-xl bg-primary-container text-secondary-container flex items-center justify-center">
        <span class="material-symbols-outlined text-[32px]">local_cafe</span>
      </div>
      <h1 class="font-headline-md text-headline-md text-primary">Kopi Nusantara</h1>
      <p class="font-label-sm text-label-sm text-on-surface-variant">Sistem Kasir &amp; POS Warung Kopi</p>
    </div>
    <c:if test="${not empty error}">
      <div class="bg-error-container text-on-error-container rounded-lg px-3 py-2 font-body-md"><c:out value="${error}"/></div>
    </c:if>
    <label class="flex flex-col gap-1">
      <span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Username</span>
      <input name="username" value="<c:out value='${username}'/>" required autofocus autocomplete="username"
             class="bg-surface-container-low rounded-lg px-3 py-2.5 focus:outline-none focus:shadow-[0_0_0_2px_#ffb559]">
    </label>
    <label class="flex flex-col gap-1">
      <span class="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Password</span>
      <input name="password" type="password" required autocomplete="current-password"
             class="bg-surface-container-low rounded-lg px-3 py-2.5 focus:outline-none focus:shadow-[0_0_0_2px_#ffb559]">
    </label>
    <button type="submit" class="w-full py-3 rounded-xl bg-tertiary-container hover:bg-tertiary text-on-tertiary font-title-lg font-bold shadow-md active:translate-y-[1px] transition-all">Masuk</button>
  </form>
</body>
</html>
