package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.OrderDao;
import com.kopinusantara.pos.dao.OrderException;
import com.kopinusantara.pos.util.Flash;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Halaman "Status Pesanan": antrean dapur/bar. */
@WebServlet("/orders")
public class OrdersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            OrderDao dao = new OrderDao();
            java.util.List<com.kopinusantara.pos.model.Order> active = dao.listActive();
            java.util.List<com.kopinusantara.pos.model.Order> proses = new java.util.ArrayList<>();
            java.util.List<com.kopinusantara.pos.model.Order> siap = new java.util.ArrayList<>();
            for (com.kopinusantara.pos.model.Order o : active) {
                if ("SIAP".equals(o.getStatus())) siap.add(o); else proses.add(o);
            }
            req.setAttribute("proses", proses);
            req.setAttribute("siap", siap);
            req.setAttribute("selesai", dao.listDoneToday());
            long[] sum = dao.todaySummary();
            req.setAttribute("todayCount", sum[0]);
            req.setAttribute("todayTotal", sum[1]);
        } catch (SQLException e) {
            throw new ServletException("Gagal membaca pesanan", e);
        }
        req.setAttribute("nav", "orders");
        req.getRequestDispatcher("/WEB-INF/jsp/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String status = req.getParameter("status");
            new OrderDao().updateStatus(id, status);
            Flash.ok(req.getSession(), "Status pesanan diperbarui" + ("BATAL".equals(status) ? " (stok dikembalikan)." : "."));
        } catch (OrderException e) {
            Flash.error(req.getSession(), e.getMessage());
        } catch (NumberFormatException | SQLException e) {
            log("Gagal ubah status", e);
            Flash.error(req.getSession(), "Gagal memperbarui status pesanan.");
        }
        resp.sendRedirect(req.getContextPath() + "/orders");
    }
}
