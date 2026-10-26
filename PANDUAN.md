# Kopi Nusantara POS — Panduan Langkah demi Langkah

Aplikasi kasir (POS) warung kopi berbasis **Java Web (Servlet + JSP + JDBC)**, database **MySQL/MariaDB bawaan XAMPP**, dibuka dan dijalankan lewat **Apache NetBeans** + **Apache Tomcat 9**.
Tampilan mengikuti desain di `stitch_coffee_shop_pos_system.zip` (Tailwind + Plus Jakarta Sans + JetBrains Mono).

## Fitur

| Halaman | Alamat | Isi |
|---|---|---|
| Login | `/login` | Masuk (admin / kasir), password di-hash PBKDF2 |
| Dashboard Pemesanan | `/pos` | Katalog menu, cari (Ctrl+K), filter kategori, keranjang, diskon (F4), catatan per item, hold bill, 4 metode bayar, uang pas/kembalian, **Bayar & Cetak Struk (F9)** |
| Status Pesanan | `/orders` | Antrean Diproses → Siap → Selesai, batalkan (stok dikembalikan), ringkasan penjualan hari ini |
| Dashboard Menu (admin) | `/menu-admin` | Tambah/ubah/hapus menu, harga, stok, label, URL gambar, aktif/nonaktif, kelola kategori |
| Struk | `/receipt?id=..` | Struk 80 mm siap cetak |
| Ganti Password | `/password` | Ganti password akun yang sedang login |

Stok berkurang otomatis saat pembayaran, dihitung ulang di server (harga & stok tidak bisa dimanipulasi dari browser).

---

## Langkah 1 — Pasang perangkat lunak

1. **JDK 11 atau lebih baru** (disarankan JDK 17).
2. **Apache NetBeans** versi 17 atau lebih baru (mengandung dukungan Maven & Java Web).
3. **XAMPP** (cukup modul *MySQL*; *Apache* opsional untuk phpMyAdmin).
4. **Apache Tomcat 9.0.x** — unduh "Core → zip" dari https://tomcat.apache.org/download-90.cgi lalu ekstrak, mis. ke `C:\apache-tomcat-9.0.xx`.
   > ⚠️ Gunakan **Tomcat 9**, bukan 10/11. Proyek ini memakai paket `javax.servlet`; Tomcat 10+ memakai `jakarta.servlet` dan aplikasi tidak akan jalan.

## Langkah 2 — Siapkan database di XAMPP

1. Buka **XAMPP Control Panel** → klik **Start** pada **MySQL** (dan **Apache** bila ingin memakai phpMyAdmin).
2. Buka http://localhost/phpmyadmin → tab **Import** → *Choose File* → pilih `database/kopi_nusantara.sql` → **Import**.
   (Perintah ini membuat database `kopi_nusantara`, semua tabel, 5 kategori, dan 12 menu contoh dari desain.)
3. Pastikan database `kopi_nusantara` muncul di kolom kiri phpMyAdmin.

> Tanpa phpMyAdmin: buka *Shell* di XAMPP lalu jalankan `mysql -u root < database/kopi_nusantara.sql`.

## Langkah 3 — Daftarkan Tomcat di NetBeans

1. NetBeans → tab **Services** → klik kanan **Servers** → **Add Server…**
2. Pilih **Apache Tomcat or TomEE** → Next → *Server Location*: folder Tomcat 9 tadi.
3. Isi **Username** & **Password** (centang *Create user if it does not exist*) → Finish.

## Langkah 4 — Buka proyek

1. NetBeans → **File → Open Project…** → pilih folder `kopi-nusantara-pos` (ikon berlogo Maven).
2. Tunggu NetBeans mengunduh dependensi (butuh internet, hanya pertama kali): JSTL, driver MariaDB, Gson.
3. Klik kanan proyek → **Properties → Run**: pastikan **Server = Apache Tomcat 9** dan *Java EE Version = Java EE 8 Web*.
4. Jika login MySQL Anda memakai password, ubah `src/main/resources/db.properties`:
   ```properties
   db.url=jdbc:mariadb://localhost:3306/kopi_nusantara
   db.user=root
   db.password=
   ```
   (Default XAMPP: user `root`, password kosong.)

## Langkah 5 — Jalankan

1. Pastikan **MySQL XAMPP masih Start**.
2. Klik kanan proyek → **Clean and Build**, lalu **Run** (atau tekan **F6**).
3. Buka browser ke **http://localhost:8080/kopi-nusantara/**
4. Masuk dengan akun awal (dibuat otomatis saat aplikasi pertama jalan):

   | Role | Username | Password |
   |---|---|---|
   | Admin | `admin` | `admin123` |
   | Kasir | `kasir` | `kasir123` |

5. **Segera ganti password** lewat ikon kunci di pojok kanan atas.

> Layar kosong / error di awal? Lihat jendela **Output → Apache Tomcat** di NetBeans. Pesan
> *"Tidak bisa terhubung ke database"* berarti MySQL belum Start atau SQL belum di-import.

## Langkah 6 — Uji alur utama (checklist)

- [ ] Login sebagai **admin** → buka **Dashboard Menu** → tambah menu baru (mis. "Es Teh Manis", Rp 8.000, stok 20).
- [ ] Buka **Dashboard Pemesanan** → klik beberapa menu → atur qty, klik catatan item → coba **F4** (diskon `10%` atau `5000`).
- [ ] Pilih *Tunai*, klik **Uang Pas** atau ketik uang diterima → **F9**. Dialog cetak struk terbuka, stok menu berkurang.
- [ ] Buka **Status Pesanan** → klik **Tandai Siap** → **Selesaikan**. Coba **Batalkan** pada pesanan lain (stok kembali).
- [ ] Login sebagai **kasir**: menu "Dashboard Menu" tidak tampil (khusus admin).

## Langkah 7 — Memakai sehari-hari (deploy ke komputer kasir)

1. Di NetBeans: klik kanan proyek → **Clean and Build** → hasilnya `target/kopi-nusantara.war`.
2. Salin file itu ke folder `webapps` Tomcat di komputer kasir, jalankan `bin/startup.bat`.
3. Buka http://localhost:8080/kopi-nusantara/ (dari perangkat lain di jaringan toko: `http://IP-KOMPUTER:8080/kopi-nusantara/`).
4. Setiap hari: **Start MySQL** di XAMPP → **start Tomcat** → buka aplikasi.
5. **Backup**: phpMyAdmin → database `kopi_nusantara` → **Export** (lakukan rutin).

### Printer struk thermal
Struk dicetak lewat dialog cetak browser (lebar 80 mm). Jadikan printer thermal sebagai printer default. Agar langsung cetak tanpa dialog, jalankan Chrome dengan opsi `--kiosk-printing`.

## Struktur proyek

```
kopi-nusantara-pos/
├─ pom.xml                          konfigurasi Maven (war, dependensi)
├─ database/kopi_nusantara.sql      skema + data contoh
└─ src/main/
   ├─ java/com/kopinusantara/pos/
   │  ├─ util/     DB (koneksi), Passwords (PBKDF2), Flash
   │  ├─ model/    User, Category, MenuItem, Order, OrderItem, OrderRequest
   │  ├─ dao/      UserDao, CategoryDao, MenuDao, OrderDao (transaksi + stok)
   │  ├─ filter/   AuthFilter (wajib login, admin-only), AppInitListener (akun awal)
   │  └─ servlet/  Login, Logout, Pos, OrderApi, Orders, Receipt, MenuAdmin, Password
   ├─ resources/db.properties       ← pengaturan database
   └─ webapp/
      ├─ assets/pos.js              logika kasir (keranjang, bayar)
      ├─ META-INF/context.xml       alamat aplikasi /kopi-nusantara
      └─ WEB-INF/ web.xml, jsp/ (halaman), jspf/ (header, footer, kartu pesanan)
```

## Masalah umum

| Gejala | Penyebab / solusi |
|---|---|
| `ClassNotFoundException: javax.servlet...` atau halaman 404/500 aneh | Server yang dipakai Tomcat 10/11. Ganti ke **Tomcat 9**. |
| *Tidak dapat terhubung ke database* | MySQL XAMPP belum Start; SQL belum di-import; user/password di `db.properties` salah; port 3306 dipakai aplikasi lain. |
| `Access denied for user 'root'` | Password root MySQL Anda tidak kosong → isi `db.password`. |
| Port 8080 sudah dipakai | Ubah port Tomcat di `conf/server.xml` (`Connector port="8080"`), atau tutup aplikasi lain. |
| `release version 11 not supported` | JDK NetBeans < 11. Pakai JDK 17 (Tools → Options → Java → Maven / Project JDK). |
| Tampilan polos tanpa gaya | Tailwind & font dimuat dari internet (CDN). Pastikan komputer online. |
| Gambar menu tidak muncul | URL gambar dari desain bisa kedaluwarsa. Ganti lewat Dashboard Menu → Ubah → *URL gambar*. Tanpa gambar, ikon cangkir tampil. |
| Alamat bukan `/kopi-nusantara` | Cek *Project Properties → Run → Context Path*, atau baca alamat di Output Tomcat. |

## Catatan keamanan
- Ganti password akun bawaan sebelum dipakai sungguhan.
- Aplikasi dirancang untuk jaringan lokal toko. Jika akan dibuka ke internet, pasang HTTPS (di depan Tomcat) dan buat user MySQL khusus (bukan `root`).
