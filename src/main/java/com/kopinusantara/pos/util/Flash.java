package com.kopinusantara.pos.util;

import javax.servlet.http.HttpSession;

/** Pesan satu kali tampil (muncul setelah redirect). */
public final class Flash {
    private Flash() {}

    public static void ok(HttpSession s, String msg) { set(s, "ok", msg); }
    public static void error(HttpSession s, String msg) { set(s, "error", msg); }

    private static void set(HttpSession s, String type, String msg) {
        s.setAttribute("flashType", type);
        s.setAttribute("flashMsg", msg);
    }
}
