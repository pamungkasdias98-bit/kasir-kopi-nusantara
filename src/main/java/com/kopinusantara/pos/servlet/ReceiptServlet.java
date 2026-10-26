package com.kopinusantara.pos.servlet;

import com.kopinusantara.pos.dao.OrderDao;
import com.kopinusantara.pos.model.Order;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Struk siap cetak (lebar 80mm). Tambahkan ?print=1 agar dialog cetak langsung terbuka. */
@WebServlet("/receipt")
public class ReceiptServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Order o = new OrderDao().find(Integer.parseInt(req.getParameter("id")));
            if (o == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            req.setAttribute("order", o);
            req.setAttribute("autoPrint", "1".equals(req.getParameter("print")));
            req.getRequestDispatcher("/WEB-INF/jsp/receipt.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
