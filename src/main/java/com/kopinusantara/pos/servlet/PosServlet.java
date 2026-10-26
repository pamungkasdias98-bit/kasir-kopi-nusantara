package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.CategoryDao;
import com.kopinusantara.pos.dao.MenuDao;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Halaman "Dashboard Pemesanan" (kasir). */
@WebServlet("/pos")
public class PosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("menuItems", new MenuDao().listActive());
            req.setAttribute("categories", new CategoryDao().listAll());
        } catch (SQLException e) {
            throw new ServletException("Gagal membaca menu dari database", e);
        }
        req.setAttribute("nav", "pos");
        req.getRequestDispatcher("/WEB-INF/jsp/pos.jsp").forward(req, resp);
    }
}
