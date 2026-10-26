-- =====================================================================
--  Kopi Nusantara POS - skema database (XAMPP / MariaDB / MySQL)
--  Cara pakai: phpMyAdmin > tab "Import" > pilih file ini > Go
-- =====================================================================
CREATE DATABASE IF NOT EXISTS kopi_nusantara
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kopi_nusantara;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(100) NOT NULL,
  role          ENUM('ADMIN','KASIR') NOT NULL DEFAULT 'KASIR',
  active        TINYINT(1)   NOT NULL DEFAULT 1,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(80) NOT NULL,
  icon       VARCHAR(16) NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE menu_items (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  category_id  INT NOT NULL,
  name         VARCHAR(120) NOT NULL,
  description  VARCHAR(255) NOT NULL DEFAULT '',
  price        INT NOT NULL,                 -- Rupiah, tanpa desimal
  stock        INT NOT NULL DEFAULT 0,
  badge        VARCHAR(30) NULL,
  default_note VARCHAR(150) NOT NULL DEFAULT '',
  image_url    VARCHAR(1000) NOT NULL DEFAULT '',
  active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_menu_cat FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;

CREATE TABLE orders (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  order_no       VARCHAR(30) NULL UNIQUE,
  order_type     ENUM('DINE_IN','TAKE_AWAY','OJOL') NOT NULL DEFAULT 'DINE_IN',
  table_no       VARCHAR(10) NULL,
  customer_name  VARCHAR(100) NOT NULL DEFAULT '',
  note           VARCHAR(255) NOT NULL DEFAULT '',
  subtotal       INT NOT NULL,
  discount       INT NOT NULL DEFAULT 0,
  tax            INT NOT NULL,
  total          INT NOT NULL,
  payment_method ENUM('TUNAI','QRIS','DEBIT','TRANSFER') NOT NULL,
  cash_received  INT NOT NULL DEFAULT 0,
  change_amount  INT NOT NULL DEFAULT 0,
  status         ENUM('DIPROSES','SIAP','SELESAI','BATAL') NOT NULL DEFAULT 'DIPROSES',
  user_id        INT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_orders_status (status),
  INDEX idx_orders_created (created_at)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  order_id     INT NOT NULL,
  menu_item_id INT NULL,
  item_name    VARCHAR(120) NOT NULL,
  unit_price   INT NOT NULL,
  qty          INT NOT NULL,
  note         VARCHAR(150) NOT NULL DEFAULT '',
  line_total   INT NOT NULL,
  CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_oi_menu  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  Data awal
--  (akun admin & kasir dibuat otomatis oleh aplikasi saat pertama jalan:
--   admin / admin123  dan  kasir / kasir123)
-- ---------------------------------------------------------------------
INSERT INTO categories (id, name, icon, sort_order) VALUES
 (1, 'Kopi Tradisional',          '☕', 1),
 (2, 'Espresso Based & Susu',     '🥤', 2),
 (3, 'Non-Kopi & Teh',            '🍵', 3),
 (4, 'Makanan Ringan & Camilan',  '🥪', 4),
 (5, 'Makanan Berat / Sarapan',   '🍛', 5);

INSERT INTO menu_items (category_id, name, description, price, stock, badge, default_note, image_url) VALUES
(2, 'Kopi Susu Gula Aren', 'Espresso blend, susu segar, aren cair', 18000, 34, 'Best Seller', 'Less ice, normal sweet', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBIpeq5VQ0ebLPFY29CnbCNy2Vk7LExOpS0nFovZBJTrEWSMRCOXZocv55MkgLl6AfCuvcgK4jYTtqXkfV7I5bRrtsPispQDephBkmZcz0paYGf1qPzMHnEnXLYGV23uPRIRmdFoQ-6kkcxL3EnAs0GU8Sx3vzUtZB0MG7Mt3oX7g25G3fl8yaiW5CZLjGdBDls3D7sSbim4nqId5JUjIbYP_XhtVp8aIJVcYw6kQ1cGUMoxPv-FEea'),
(1, 'Tubruk Robusta Dampit', 'Malang Selatan, bold choco notes', 12000, 50, 'Tradisional', 'Gula pisah, cangkir enamel', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwlq7Ye5szXeS-nFDQBR1zTzqFBQ6oN3504X_Di1n946g-elpYo7AkvTtPRNSEM851qHcG6SL7VTlQ3zpfdSWJ1X81_xQIvWUQ2barVv-89WQGtSfvyNaouI-tiYxLWSzDL1L37SD01j9JU3PF6D2EilJBs0hWWhaPIERDbm8NCByH7Buh6DByDdGTkDtEkogmftt3jmomsSNtHQz-6iljuMmR-yIRJuu81lR7fgYGBQozJF7X9z7c'),
(1, 'V60 Arabika Gayo', 'Aceh Gayo, floral, citric, peach note', 25000, 18, 'Single Origin', 'Hot, beans Gayo Natural', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDrHXkz9BJczqW4661UxwoL6eZ06GkQiWcI7NYfGc8X1mjnUCG4ejWDNLGo_byg1tPSmOLcJW3uw7bMmEL46HP9uc4ZE6SVrY2MB9ZbT78afaMgbVHqerZuS9QIXFTUxtd42QpY-NmcXkMv-RMksVG6_-ebsl2gnaO11lTye-eCx3RzwCurx13oFdMrTZWZuJtj-qKyNi4mRriKZAEYxqft-LpcH_p7g3K9HRNmePNXjeuXpOTQ43hL'),
(2, 'Es Kopi Klepon Pandan', 'Pandan leaf syrup & roasted coconut', 22000, 22, 'Signature', 'Medium sweet, toasted coconut', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBi2RNR9Kdx-vCbXzhhrFhI1o-Bhr9guyvDkcdBWQZ-93c_ExdG5rbMP8rHswOT3H70PL4vSGxKSrM6HcOJSDi1uOq2vRgKxyTSlzBTHmRFlwqtRXT2txXYB55-oJClPpdY2lVIOX5rsK0YEi96qMw78xDiQ6DtGo9xV92bdIfcJdTu6tt8ThtgW8w3y5xd8aS14cAqSkHl1l5nqKq2Y9O4bTbIDXl_LYFh7bUZyQUHTUxSKv3H25Zw'),
(1, 'Kopi Tarik Aceh', 'Kopi ulee kareng ditarik berbusa', 16000, 40, NULL, 'Panas berbusa tebal', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAC2rwV0Xox-2zN7qp7PN85Rb4bU3xH1Jc2Nigq8xEUZTwH0Hga3Rsmq1X8PVuDEWvf1gd9q9QJw_8tc0nCjACmmsnhEWG2imgt-9SlC9mdSchMhM7LUhWGR3YRMQSPpVbBIJzmUjyeLSpakP08CkQrNaxWDNXRvqXG4-Kl6iLyGmxbM8dUpXlv7LMyrxK-xDXqtQjL6xaDNUqm005vFPsIjMqPFqLRSVZoNJibFy_NMe3kMkCErEdC'),
(3, 'Teh Tarik Rempah', 'Teh hitam wangi kayu manis & kapulaga', 14000, 28, NULL, 'Hangat, cengkeh wangi', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAf378nAD-4lkiZWsKiTI30-53auhCDaJ8q5gjBP0-2HYhV7fO8UE8IZmuMpWEV0O3W7aU_kPsKrPjODp2xV5rYUmtz-HHPuZgBQgfMAXryjmr4nq6NUWirnpX9BF-U__DUgpQOdGXNAxGQ31CqcHh8G6H4duNqD6741srRPn6q3lr9-82_ZuTKLsyRafFaZImNyI8K2mB0KF10IZzHFAl66iUvBLitnlqa0kTXQ6BvFvcscVtn_ove'),
(4, 'Roti Bakar Cokelat Keju', 'Roti gandum bakar arang, mentega wangi', 20000, 15, NULL, 'Cokelat melimpah, keju cheddar parut', 'https://lh3.googleusercontent.com/aida-public/AB6AXuD-PhU5O4E7lcUrCQWKw7rFuVZ_OTwfm6oIP6FcCxxXXePv_VAs-Hqxy7Tpy35bDwr1V9Pu5QW20O7-xWt1af_Sl9GXt_5KUFdgz1xJJoKla6JCbg93wkEU0MNLdmZmbcdy2kQfjazXJRvPgCF-9TQpNEf4kNRXYbzSGvsOjuzWhavl-3NPhEDZzmQ_Wbqlg_3U5seWmmXf9ompU-lsLTnDtSXAYm7-eF_DZLrgzm8SXuJAceSiwZwS'),
(4, 'Pisang Goreng Crispy', 'Pisang raja manis renyah wijen', 15000, 19, NULL, 'Taburan wijen sangrai & gula palem', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuZ0HBJHEUNuGmhyTyI6_33aCpX2wqVxRPUDsGLn2X0nlEpsLW1EJJQPwNICFibhUH0Iy2scyWUe70gIKDGIgfq1vR-aweiznjlGb52gNBY6u0QfzkjGHKapRFOfX_q5xnPkt-h9ORESgdsqseSNKFZlPNxTGOexe1NkELz9WT1GODhqYRVNat7rzhTiw-HY7ikKmxqcF3Vs-sNBMfMjQXy0VOc2u81CFk3-XKm2dvYNq_KxCZKwp_'),
(4, 'Cireng Bumbu Rujak', 'Aci kenyal gurih saus rujak asam manis', 14000, 25, NULL, 'Saus rujak pedas sedang', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBBWTMTvh-6PEpUNpIFAeTfWUmVX2OjY1F_GZb1z4xm2_1XJQCEIkQALMmB5OZafmapsh1Wn79kAIvOl5CfbYKkLuzhxZmFHN5ICVum6dF1zG_ktHJNkihezmScawxwQodJv9s7uMd4Xuezdn0HWiGfsbXzsLEXMsmv-K4r7wgzebJUN6zKCvLs7MlRtQNqH0ogenLIaZXC0qUNwJXg7KGE2RAgpX8eGBCvZbds1S66VNiFv3n2ttIY'),
(5, 'Indomie Nyemek Kornet', 'Telur bebek lumer, kornet, sawi segar', 22000, 12, 'Favorit Malam', 'Pedas cabe rawit 5, telur setengah matang', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjthczSosDPEs722ycL2nxdHW5SKw9xHKE1Paqq7ZdALqQVuC4lwwDJI2vBsEpIPaY6f7T-qz5jBaAgyVqezZwJCBT8wAmM40DbV1lH9V0Tc2fF4oWYww82cpBRqhAplFHDWKJeorbPdvtal7ghB96WO_K21ptVlAK3HUnRtVHp7kMtbpCvkR1vcyzEIBOMr1ybOqTBPLfoV3QjgSclq7pBaVVZD-0T8b11_7StV0K4DsS78ne5I0w'),
(3, 'Matcha Latte Creamy', 'Pure Kyoto Uji matcha, fresh steam milk', 24000, 16, NULL, 'Less ice, oatmilk', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCVn69cFtMO0NlIu--nyfsTJ8YXmX412Xf_Zbo5rLQpp_HUuLjG_5Qqxn_1oM6gl7GhvCNa3ND7TE32WN2LbdpjWoI48rkoN0U8TntSrPJUZogYIlYD75Ltaxlkilz36Ve6U-PO0tJ1w6zxOCpBt-9VOSRwwml0k4JDO27cfYn7FRSO20MlNn5bmXx2MGTPIMlb6UTJYa5wZM1aPZtcdwG03z63W7Nl_X-q6HOxtIAIYhHFBr5BRl5O'),
(3, 'Es Lemon Tea Selasih', 'Perasan lemon murni, selasih, mint segar', 15000, 30, NULL, 'Dingin segar, daun mint', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCN7DbLYpfFeIFakQhbAEw0U3AB1E5rlmln0sXmfKhBeqTne4gyxHMxPrZfrfVQhVTwYpXH2tK7W-swu1xckJU7GVpcfJQCsxJmr-gw_5awkEcscLfC2klg3jJHXO6-5VbOcmY506Va4VUNfgsnB6Xn8h-CZpwgQCvH3W8uIbjiDHKY5TvbJa-VF5uOLavWyOf130aM9L7HzDyi4y3kBQcewy9WCkE1SRoJgL1vLE3sMDsRvoDMfIDP');
