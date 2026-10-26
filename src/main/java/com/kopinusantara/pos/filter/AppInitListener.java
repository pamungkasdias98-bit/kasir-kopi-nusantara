package com.kopinusantara.pos.filter;

import com.kopinusantara.pos.dao.UserDao;
import com.kopinusantara.pos.util.Passwords;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/** Saat aplikasi start: cek database dan buat akun awal bila tabel users masih kosong. */
@WebListener
public class AppInitListener implements ServletContextListener {
    private static final Logger LOG = Logger.getLogger(AppInitListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            UserDao dao = new UserDao();
            if (dao.count() == 0) {
                dao.create("admin", Passwords.hash("admin123"), "Administrator", "ADMIN");
                dao.create("kasir", Passwords.hash("kasir123"), "Rina (Barista Kasir)", "KASIR");
                LOG.info("Akun awal dibuat: admin/admin123 dan kasir/kasir123 (segera ganti password).");
            }
            LOG.info("Koneksi database OK.");
        } catch (SQLException | RuntimeException e) {
            LOG.log(Level.SEVERE, "Tidak bisa terhubung ke database. Pastikan MySQL di XAMPP sudah Start, "
                    + "database kopi_nusantara sudah di-import, dan db.properties benar.", e);
        }
    }
}
