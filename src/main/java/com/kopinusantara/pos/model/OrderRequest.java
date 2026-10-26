package com.kopinusantara.pos.model;

import java.util.List;

/** Bentuk JSON yang dikirim halaman kasir saat menekan "Bayar & Cetak Struk". */
public class OrderRequest {
    public String orderType;
    public String tableNo;
    public String customerName;
    public String note;
    public String paymentMethod;
    public int cashReceived;
    public int discount;
    public List<Line> items;

    public static class Line {
        public int menuId;
        public int qty;
        public String note;
    }
}
