package com.kopinusantara.pos.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import com.kopinusantara.pos.model.Order;
import com.kopinusantara.pos.model.OrderItem;
import com.kopinusantara.pos.model.OrderRequest;
import com.kopinusantara.pos.util.DB;

public class OrderDao {
    public static final int TAX_PERCENT = 0;
    private static final List<String> TYPES = Arrays.asList("DINE_IN", "TAKE_AWAY", "OJOL");
    private static final List<String> PAYMENTS = Arrays.asList("TUNAI", "QRIS", "DEBIT", "TRANSFER");

    private static final String SELECT =
            "SELECT o.*, u.full_name AS cashier_name FROM orders o LEFT JOIN users u ON u.id = o.user_id ";

    /** Pajak 10% dibulatkan; dipakai sama persis di sisi browser (pos.js). */
    public static int taxOf(int taxable) {
        return (taxable * TAX_PERCENT + 50) / 100;
    }

    // ------------------------------------------------------------------
    //  Membuat pesanan (transaksi: cek stok, kurangi stok, simpan)
    // ------------------------------------------------------------------
    public Order create(OrderRequest r, int userId) throws SQLException, OrderException {
        if (r == null || r.items == null || r.items.isEmpty()) throw new OrderException("Keranjang masih kosong.");
        if (!TYPES.contains(r.orderType)) throw new OrderException("Tipe order tidak valid.");
        if (!PAYMENTS.contains(r.paymentMethod)) throw new OrderException("Metode pembayaran tidak valid.");

        List<OrderRequest.Line> lines = new ArrayList<>(r.items);
        for (OrderRequest.Line l : lines) {
            if (l.qty < 1 || l.qty > 999) throw new OrderException("Jumlah item tidak valid.");
        }
        // urutkan agar penguncian baris konsisten (hindari deadlock)
        lines.sort(Comparator.comparingInt(l -> l.menuId));

        try (Connection c = DB.getConnection()) {
            c.setAutoCommit(false);
            try {
                List<OrderItem> items = new ArrayList<>();
                int subtotal = 0;
                for (OrderRequest.Line l : lines) {
                    String name;
                    int price;
                    try (PreparedStatement ps = c.prepareStatement(
                            "SELECT name, price, stock, active FROM menu_items WHERE id = ? FOR UPDATE")) {
                        ps.setInt(1, l.menuId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next() || !rs.getBoolean("active")) {
                                throw new OrderException("Menu tidak ditemukan atau sudah dinonaktifkan.");
                            }
                            name = rs.getString("name");
                            price = rs.getInt("price");
                            if (rs.getInt("stock") < l.qty) {
                                throw new OrderException("Stok \"" + name + "\" tidak cukup (sisa " + rs.getInt("stock") + ").");
                            }
                        }
                    }
                    try (PreparedStatement ps = c.prepareStatement("UPDATE menu_items SET stock = stock - ? WHERE id = ?")) {
                        ps.setInt(1, l.qty);
                        ps.setInt(2, l.menuId);
                        ps.executeUpdate();
                    }
                    OrderItem it = new OrderItem();
                    it.setMenuItemId(l.menuId);
                    it.setItemName(name);
                    it.setUnitPrice(price);
                    it.setQty(l.qty);
                    it.setNote(clip(l.note, 150));
                    it.setLineTotal(price * l.qty);
                    items.add(it);
                    subtotal += it.getLineTotal();
                }

                int discount = Math.max(0, Math.min(r.discount, subtotal));
                int tax = taxOf(subtotal - discount);
                int total = subtotal - discount + tax;

                int cash;
                int change;
                if ("TUNAI".equals(r.paymentMethod)) {
                    if (r.cashReceived < total) throw new OrderException("Uang diterima kurang dari total pembayaran.");
                    cash = r.cashReceived;
                    change = cash - total;
                } else {
                    cash = total;
                    change = 0;
                }

                Order o = new Order();
                o.setOrderType(r.orderType);
                o.setTableNo("DINE_IN".equals(r.orderType) ? clip(r.tableNo, 10) : "");
                o.setCustomerName(clip(r.customerName, 100));
                o.setNote(clip(r.note, 255));
                o.setSubtotal(subtotal);
                o.setDiscount(discount);
                o.setTax(tax);
                o.setTotal(total);
                o.setPaymentMethod(r.paymentMethod);
                o.setCashReceived(cash);
                o.setChangeAmount(change);
                o.setStatus("DIPROSES");
                o.setItems(items);

                String ins = "INSERT INTO orders (order_type, table_no, customer_name, note, subtotal, discount, tax, total, "
                        + "payment_method, cash_received, change_amount, status, user_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,'DIPROSES',?)";
                int orderId;
                try (PreparedStatement ps = c.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, o.getOrderType());
                    ps.setString(2, o.getTableNo());
                    ps.setString(3, o.getCustomerName());
                    ps.setString(4, o.getNote());
                    ps.setInt(5, subtotal);
                    ps.setInt(6, discount);
                    ps.setInt(7, tax);
                    ps.setInt(8, total);
                    ps.setString(9, o.getPaymentMethod());
                    ps.setInt(10, cash);
                    ps.setInt(11, change);
                    ps.setInt(12, userId);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        orderId = keys.getInt(1);
                    }
                }
                String orderNo = "KP-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMM"))
                        + "-" + String.format("%04d", orderId);
                try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET order_no = ? WHERE id = ?")) {
                    ps.setString(1, orderNo);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO order_items (order_id, menu_item_id, item_name, unit_price, qty, note, line_total) VALUES (?,?,?,?,?,?,?)")) {
                    for (OrderItem it : items) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, it.getMenuItemId());
                        ps.setString(3, it.getItemName());
                        ps.setInt(4, it.getUnitPrice());
                        ps.setInt(5, it.getQty());
                        ps.setString(6, it.getNote());
                        ps.setInt(7, it.getLineTotal());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                c.commit();
                o.setId(orderId);
                o.setOrderNo(orderNo);
                o.setCreatedAt(LocalDateTime.now());
                return o;
            } catch (SQLException | OrderException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }

    private static String clip(String s, int max) {
        if (s == null) return "";
        s = s.trim();
        return s.length() > max ? s.substring(0, max) : s;
    }

    // ------------------------------------------------------------------
    //  Membaca pesanan
    // ------------------------------------------------------------------
    public Order find(int id) throws SQLException {
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(SELECT + "WHERE o.id = ?")) {
            ps.setInt(1, id);
            List<Order> list = readOrders(c, ps);
            return list.isEmpty() ? null : list.get(0);
        }
    }

    /** Pesanan yang masih berjalan (Diproses / Siap), yang paling lama di atas. */
    public List<Order> listActive() throws SQLException {
        return list(SELECT + "WHERE o.status IN ('DIPROSES','SIAP') ORDER BY o.created_at ASC, o.id ASC");
    }

    /** Pesanan selesai hari ini (maks. 30 terbaru). */
    public List<Order> listDoneToday() throws SQLException {
        return list(SELECT + "WHERE o.status = 'SELESAI' AND DATE(o.created_at) = CURDATE() "
                + "ORDER BY o.updated_at DESC, o.id DESC LIMIT 30");
    }

    private List<Order> list(String sql) throws SQLException {
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            return readOrders(c, ps);
        }
    }

    private List<Order> readOrders(Connection c, PreparedStatement ps) throws SQLException {
        List<Order> list = new ArrayList<>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setOrderNo(rs.getString("order_no"));
                o.setOrderType(rs.getString("order_type"));
                o.setTableNo(rs.getString("table_no"));
                o.setCustomerName(rs.getString("customer_name"));
                o.setNote(rs.getString("note"));
                o.setSubtotal(rs.getInt("subtotal"));
                o.setDiscount(rs.getInt("discount"));
                o.setTax(rs.getInt("tax"));
                o.setTotal(rs.getInt("total"));
                o.setPaymentMethod(rs.getString("payment_method"));
                o.setCashReceived(rs.getInt("cash_received"));
                o.setChangeAmount(rs.getInt("change_amount"));
                o.setStatus(rs.getString("status"));
                o.setCashierName(rs.getString("cashier_name"));
                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) o.setCreatedAt(ts.toLocalDateTime());
                list.add(o);
            }
        }
        try (PreparedStatement ps2 = c.prepareStatement("SELECT * FROM order_items WHERE order_id = ? ORDER BY id")) {
            for (Order o : list) {
                ps2.setInt(1, o.getId());
                try (ResultSet rs = ps2.executeQuery()) {
                    while (rs.next()) {
                        OrderItem it = new OrderItem();
                        it.setId(rs.getInt("id"));
                        it.setMenuItemId(rs.getInt("menu_item_id"));
                        it.setItemName(rs.getString("item_name"));
                        it.setUnitPrice(rs.getInt("unit_price"));
                        it.setQty(rs.getInt("qty"));
                        it.setNote(rs.getString("note"));
                        it.setLineTotal(rs.getInt("line_total"));
                        o.getItems().add(it);
                    }
                }
            }
        }
        return list;
    }

    /** Jumlah pesanan yang masih berjalan (untuk badge di menu atas). */
    public int countActive() throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM orders WHERE status IN ('DIPROSES','SIAP')");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    /** @return {jumlah transaksi, total penjualan} hari ini, tidak termasuk yang dibatalkan. */
    public long[] todaySummary() throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     "SELECT COUNT(*), COALESCE(SUM(total), 0) FROM orders WHERE status <> 'BATAL' AND DATE(created_at) = CURDATE()");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return new long[]{rs.getLong(1), rs.getLong(2)};
        }
    }

    // ------------------------------------------------------------------
    //  Mengubah status: DIPROSES -> SIAP -> SELESAI, atau BATAL (stok dikembalikan)
    // ------------------------------------------------------------------
    public void updateStatus(int id, String newStatus) throws SQLException, OrderException {
        try (Connection c = DB.getConnection()) {
            c.setAutoCommit(false);
            try {
                String current;
                try (PreparedStatement ps = c.prepareStatement("SELECT status FROM orders WHERE id = ? FOR UPDATE")) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new OrderException("Pesanan tidak ditemukan.");
                        current = rs.getString(1);
                    }
                }
                boolean ok = ("DIPROSES".equals(current) && "SIAP".equals(newStatus))
                        || ("SIAP".equals(current) && "SELESAI".equals(newStatus))
                        || (("DIPROSES".equals(current) || "SIAP".equals(current)) && "BATAL".equals(newStatus));
                if (!ok) throw new OrderException("Perubahan status dari " + current + " ke " + newStatus + " tidak diizinkan.");

                if ("BATAL".equals(newStatus)) {
                    try (PreparedStatement ps = c.prepareStatement(
                            "UPDATE menu_items m JOIN order_items i ON i.menu_item_id = m.id "
                                    + "SET m.stock = m.stock + i.qty WHERE i.order_id = ?")) {
                        ps.setInt(1, id);
                        ps.executeUpdate();
                    }
                }
                try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status = ? WHERE id = ?")) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, id);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (SQLException | OrderException | RuntimeException e) {
                c.rollback();
                throw e;
            }
        }
    }
}
