package com.kopinusantara.pos.dao;

/** Kesalahan bisnis (stok habis, uang kurang, dst) yang pesannya boleh ditampilkan ke kasir. */
public class OrderException extends Exception {
    public OrderException(String message) { super(message); }
}
