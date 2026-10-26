package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.CategoryDao;
import com.kopinusantara.pos.dao.MenuDao;
import com.kopinusantara.pos.model.MenuItem;
import com.kopinusantara.pos.util.Flash;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/** Halaman "Dashboard Menu" (khusus ADMIN, dijaga AuthFilter). */
@WebServlet("/menu-admin")
public class MenuAdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("items", new MenuDao().listAll());
            req.setAttribute("categories", new CategoryDao().listAll());
        } catch (SQLException e) {
            throw new ServletException("Gagal membaca menu", e);
        }
        req.setAttribute("nav", "menu");
        req.getRequestDispatcher("/WEB-INF/jsp/menu-admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession();
        String action = req.getParameter("action") == null ? "" : req.getParameter("action");
        try {
            MenuDao menu = new MenuDao();
            switch (action) {
                case "save": {
                    MenuItem m = new MenuItem();
                    m.setId(intParam(req, "id"));
                    m.setCategoryId(intParam(req, "categoryId"));
                    m.setName(text(req, "name", 120));
                    m.setDescription(text(req, "description", 255));
                    m.setPrice(intParam(req, "price"));
                    m.setStock(intParam(req, "stock"));
                    m.setBadge(text(req, "badge", 30));
                    m.setDefaultNote(text(req, "defaultNote", 150));
                    m.setImageUrl(text(req, "imageUrl", 1000));
                    m.setActive(req.getParameter("active") != null);
                    if (m.getName().isEmpty() || m.getPrice() < 0 || m.getStock() < 0 || m.getCategoryId() <= 0) {
                        Flash.error(s, "Data menu tidak valid (nama wajib diisi, harga/stok tidak boleh negatif).");
                    } else {
                        menu.save(m);
                        Flash.ok(s, "Menu \"" + m.getName() + "\" disimpan.");
                    }
                    break;
                }
                case "toggle":
                    menu.setActive(intParam(req, "id"), "1".equals(req.getParameter("active")));
                    Flash.ok(s, "Status menu diperbarui.");
                    break;
                case "delete":
                    menu.delete(intParam(req, "id"));
                    Flash.ok(s, "Menu dihapus.");
                    break;
                case "addCategory": {
                    String name = text(req, "name", 80);
                    if (name.isEmpty()) {
                        Flash.error(s, "Nama kategori wajib diisi.");
                    } else {
                        new CategoryDao().add(name, text(req, "icon", 16));
                        Flash.ok(s, "Kategori ditambahkan.");
                    }
                    break;
                }
                case "deleteCategory":
                    if (new CategoryDao().deleteIfEmpty(intParam(req, "id"))) Flash.ok(s, "Kategori dihapus.");
                    else Flash.error(s, "Kategori tidak bisa dihapus karena masih berisi menu.");
                    break;
                default:
                    Flash.error(s, "Aksi tidak dikenal.");
            }
        } catch (SQLException | RuntimeException e) {
            log("Gagal menyimpan menu", e);
            Flash.error(s, "Gagal menyimpan ke database.");
        }
        resp.sendRedirect(req.getContextPath() + "/menu-admin");
    }

    private static int intParam(HttpServletRequest req, String name) {
        try {
            return Integer.parseInt(req.getParameter(name).trim());
        } catch (RuntimeException e) {
            return 0;
        }
    }

    private static String text(HttpServletRequest req, String name, int max) {
        String v = req.getParameter(name);
        if (v == null) return "";
        v = v.trim();
        return v.length() > max ? v.substring(0, max) : v;
    }
}
