package com.kopinusantara.pos.dao;

import com.kopinusantara.pos.model.MenuItem;
import com.kopinusantara.pos.util.DB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class MenuDao {
    private static final String SELECT =
            "SELECT m.id, m.category_id, c.name AS category_name, m.name, m.description, m.price, m.stock, "
          + "m.badge, m.default_note, m.image_url, m.active "
          + "FROM menu_items m JOIN categories c ON c.id = m.category_id ";

    /** Menu yang tampil di halaman kasir (aktif saja). */
    public List<MenuItem> listActive() throws SQLException {
        return query(SELECT + "WHERE m.active = 1 ORDER BY c.sort_order, m.id");
    }

    /** Semua menu, untuk halaman Dashboard Menu. */
    public List<MenuItem> listAll() throws SQLException {
        return query(SELECT + "ORDER BY c.sort_order, m.id");
    }

    private List<MenuItem> query(String sql) throws SQLException {
        List<MenuItem> list = new ArrayList<>();
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    private MenuItem map(ResultSet rs) throws SQLException {
        MenuItem m = new MenuItem();
        m.setId(rs.getInt("id"));
        m.setCategoryId(rs.getInt("category_id"));
        m.setCategoryName(rs.getString("category_name"));
        m.setName(rs.getString("name"));
        m.setDescription(rs.getString("description"));
        m.setPrice(rs.getInt("price"));
        m.setStock(rs.getInt("stock"));
        m.setBadge(rs.getString("badge"));
        m.setDefaultNote(rs.getString("default_note"));
        m.setImageUrl(rs.getString("image_url"));
        m.setActive(rs.getBoolean("active"));
        return m;
    }

    /** Insert jika id == 0, selain itu update. */
    public void save(MenuItem m) throws SQLException {
        boolean isNew = m.getId() == 0;
        String sql = isNew
                ? "INSERT INTO menu_items (category_id, name, description, price, stock, badge, default_note, image_url, active) VALUES (?,?,?,?,?,?,?,?,?)"
                : "UPDATE menu_items SET category_id=?, name=?, description=?, price=?, stock=?, badge=?, default_note=?, image_url=?, active=? WHERE id=?";
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, m.getCategoryId());
            ps.setString(2, m.getName());
            ps.setString(3, m.getDescription());
            ps.setInt(4, m.getPrice());
            ps.setInt(5, m.getStock());
            if (m.getBadge() == null || m.getBadge().isEmpty()) ps.setNull(6, Types.VARCHAR);
            else ps.setString(6, m.getBadge());
            ps.setString(7, m.getDefaultNote());
            ps.setString(8, m.getImageUrl());
            ps.setBoolean(9, m.isActive());
            if (!isNew) ps.setInt(10, m.getId());
            ps.executeUpdate();
        }
    }

    public void setActive(int id, boolean active) throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE menu_items SET active = ? WHERE id = ?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("DELETE FROM menu_items WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
