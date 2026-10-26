package com.kopinusantara.pos.dao;

import com.kopinusantara.pos.model.Category;
import com.kopinusantara.pos.util.DB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDao {

    public List<Category> listAll() throws SQLException {
        String sql = "SELECT c.id, c.name, c.icon, c.sort_order, COUNT(m.id) AS item_count "
                + "FROM categories c LEFT JOIN menu_items m ON m.category_id = c.id "
                + "GROUP BY c.id, c.name, c.icon, c.sort_order ORDER BY c.sort_order, c.id";
        List<Category> list = new ArrayList<>();
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getInt("id"));
                cat.setName(rs.getString("name"));
                cat.setIcon(rs.getString("icon"));
                cat.setSortOrder(rs.getInt("sort_order"));
                cat.setItemCount(rs.getInt("item_count"));
                list.add(cat);
            }
        }
        return list;
    }

    public void add(String name, String icon) throws SQLException {
        try (Connection c = DB.getConnection()) {
            int next;
            try (PreparedStatement ps = c.prepareStatement("SELECT COALESCE(MAX(sort_order), 0) + 1 FROM categories");
                 ResultSet rs = ps.executeQuery()) {
                rs.next();
                next = rs.getInt(1);
            }
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO categories (name, icon, sort_order) VALUES (?, ?, ?)")) {
                ps.setString(1, name);
                ps.setString(2, icon);
                ps.setInt(3, next);
                ps.executeUpdate();
            }
        }
    }

    /** @return true jika terhapus; false jika kategori masih berisi menu. */
    public boolean deleteIfEmpty(int id) throws SQLException {
        String sql = "DELETE FROM categories WHERE id = ? AND NOT EXISTS (SELECT 1 FROM menu_items WHERE category_id = ?)";
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }
}
