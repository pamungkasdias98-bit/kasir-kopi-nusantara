package com.kopinusantara.pos.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.kopinusantara.pos.dao.OrderDao;
import com.kopinusantara.pos.dao.OrderException;
import com.kopinusantara.pos.model.Order;
import com.kopinusantara.pos.model.OrderRequest;
import com.kopinusantara.pos.model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Endpoint JSON yang dipanggil tombol "Bayar & Cetak Struk". */
@WebServlet("/api/orders")
public class OrderApiServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, Object> out = new LinkedHashMap<>();
        try {
            OrderRequest body = gson.fromJson(req.getReader(), OrderRequest.class);
            User user = (User) req.getSession().getAttribute("user");
            Order o = new OrderDao().create(body, user.getId());
            out.put("ok", true);
            out.put("orderId", o.getId());
            out.put("orderNo", o.getOrderNo());
            out.put("total", o.getTotal());
            out.put("change", o.getChangeAmount());
        } catch (OrderException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("ok", false);
            out.put("message", e.getMessage());
        } catch (JsonSyntaxException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("ok", false);
            out.put("message", "Data pesanan tidak valid.");
        } catch (SQLException | RuntimeException e) {
            log("Gagal menyimpan pesanan", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.put("ok", false);
            out.put("message", "Gagal menyimpan ke database. Periksa MySQL XAMPP.");
        }
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(gson.toJson(out));
    }
}
