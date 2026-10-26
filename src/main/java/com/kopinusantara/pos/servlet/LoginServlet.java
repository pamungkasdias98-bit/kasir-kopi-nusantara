package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.UserDao;
import com.kopinusantara.pos.model.User;
import com.kopinusantara.pos.util.Passwords;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/pos");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username") == null ? "" : req.getParameter("username").trim();
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");
        try {
            User u = new UserDao().findActiveByUsername(username);
            if (u != null && Passwords.verify(password, u.getPasswordHash())) {
                HttpSession old = req.getSession(false);
                if (old != null) old.invalidate();           // cegah session fixation
                HttpSession s = req.getSession(true);
                s.setAttribute("user", u);
                s.setMaxInactiveInterval(8 * 60 * 60);
                resp.sendRedirect(req.getContextPath() + "/pos");
                return;
            }
            req.setAttribute("error", "Username atau password salah.");
        } catch (SQLException | RuntimeException e) {
            log("Login gagal karena database", e);
            req.setAttribute("error", "Tidak dapat terhubung ke database. Pastikan MySQL di XAMPP sudah Start.");
        }
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
    }
}
