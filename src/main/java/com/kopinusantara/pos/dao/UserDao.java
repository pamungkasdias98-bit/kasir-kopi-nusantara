package com.kopinusantara.pos.dao;

import com.kopinusantara.pos.model.User;
import com.kopinusantara.pos.util.DB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDao {

    public User findActiveByUsername(String username) throws SQLException {
        String sql = "SELECT id, username, password_hash, full_name, role FROM users WHERE username = ? AND active = 1";
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setPasswordHash(rs.getString("password_hash"));
                u.setFullName(rs.getString("full_name"));
                u.setRole(rs.getString("role"));
                return u;
            }
        }
    }

    public int count() throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT COUNT(*) FROM users");
             ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    public void create(String username, String passwordHash, String fullName, String role) throws SQLException {
        String sql = "INSERT INTO users (username, password_hash, full_name, role) VALUES (?,?,?,?)";
        try (Connection c = DB.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, role);
            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String passwordHash) throws SQLException {
        try (Connection c = DB.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE users SET password_hash = ? WHERE id = ?")) {
            ps.setString(1, passwordHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
