package com.kopinusantara.pos.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** Pembuat koneksi JDBC ke database XAMPP. Konfigurasi dibaca dari db.properties. */
public final class DB {
    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DB.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) throw new IllegalStateException("db.properties tidak ditemukan");
            PROPS.load(in);
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DB() {}

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                PROPS.getProperty("db.url"),
                PROPS.getProperty("db.user"),
                PROPS.getProperty("db.password", ""));
    }
}
