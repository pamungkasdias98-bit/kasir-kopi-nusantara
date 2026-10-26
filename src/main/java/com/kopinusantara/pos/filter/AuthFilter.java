package com.kopinusantara.pos.filter;

import com.kopinusantara.pos.dao.OrderDao;
import com.kopinusantara.pos.model.User;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/** Memastikan UTF-8, wajib login, dan membatasi halaman admin. */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");

        String path = req.getRequestURI().substring(req.getContextPath().length());
        boolean isPublic = path.startsWith("/assets/") || path.equals("/login") || path.equals("/favicon.ico");

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (!isPublic && user == null) {
            if (path.startsWith("/api/")) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }
        if (path.startsWith("/menu-admin") && (user == null || !user.isAdmin())) {
            res.sendRedirect(req.getContextPath() + "/pos");
            return;
        }

        // badge jumlah pesanan aktif di menu atas
        if (user != null && "GET".equals(req.getMethod()) && !path.startsWith("/api/")) {
            try {
                req.setAttribute("activeOrders", new OrderDao().countActive());
            } catch (SQLException e) {
                req.setAttribute("activeOrders", 0);
            }
        }
        chain.doFilter(request, response);
    }
}
