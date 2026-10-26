package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.UserDao;
import com.kopinusantara.pos.model.User;
import com.kopinusantara.pos.util.Flash;
import com.kopinusantara.pos.util.Passwords;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Ganti password akun yang sedang login. */
@WebServlet("/password")
public class PasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("nav", "pw");
        req.getRequestDispatcher("/WEB-INF/jsp/password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User me = (User) req.getSession().getAttribute("user");
        String oldPw = nz(req.getParameter("oldPassword"));
        String newPw = nz(req.getParameter("newPassword"));
        String confirm = nz(req.getParameter("confirmPassword"));
        String error = null;
        try {
            UserDao dao = new UserDao();
            User db = dao.findActiveByUsername(me.getUsername());
            if (db == null || !Passwords.verify(oldPw, db.getPasswordHash())) error = "Password lama salah.";
            else if (newPw.length() < 6) error = "Password baru minimal 6 karakter.";
            else if (!newPw.equals(confirm)) error = "Konfirmasi password tidak cocok.";
            else dao.updatePassword(me.getId(), Passwords.hash(newPw));
        } catch (SQLException | RuntimeException e) {
            log("Gagal ganti password", e);
            error = "Gagal menyimpan ke database.";
        }
        if (error != null) {
            req.setAttribute("error", error);
            req.setAttribute("nav", "pw");
            req.getRequestDispatcher("/WEB-INF/jsp/password.jsp").forward(req, resp);
            return;
        }
        Flash.ok(req.getSession(), "Password berhasil diganti.");
        resp.sendRedirect(req.getContextPath() + "/pos");
    }

    private static String nz(String s) { return s == null ? "" : s; }
}
