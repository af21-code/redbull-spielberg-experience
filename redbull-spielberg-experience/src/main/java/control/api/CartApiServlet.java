package control.api;

import model.SessionCart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Gestisce il carrello in sessione per utenti NON loggati.
 * URL: /api/cart/*
 *  - POST /add    : productId, [slotId], [qty]
 *  - POST /update : productId, [slotId], qty
 *  - POST /remove : productId, [slotId]
 */
@WebServlet("/api/cart/*")
public class CartApiServlet extends HttpServlet {

    private SessionCart getOrCreateCart(HttpSession session) {
        SessionCart sc = (SessionCart) session.getAttribute("sessionCart");
        if (sc == null) {
            sc = new SessionCart();
            session.setAttribute("sessionCart", sc);
        }
        return sc;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        HttpSession session = req.getSession(true);
        SessionCart cart = getOrCreateCart(session);

        int productId = parseInt(req.getParameter("productId"), -1);
        Integer slotId = parseNullableInt(req.getParameter("slotId"));
        int qty = parseInt(req.getParameter("qty"), 1);

        boolean ok = true;
        String msg = "ok";

        try {
            switch (path) {
                case "/add":
                    if (productId <= 0) throw new IllegalArgumentException("productId mancante/errato");
                    cart.add(productId, slotId, Math.max(1, qty));
                    break;
                case "/update":
                    if (productId <= 0) throw new IllegalArgumentException("productId mancante/errato");
                    cart.setQuantity(productId, slotId, qty);
                    break;
                case "/remove":
                    if (productId <= 0) throw new IllegalArgumentException("productId mancante/errato");
                    cart.remove(productId, slotId);
                    break;
                default:
                    ok = false; msg = "endpoint non valido";
            }
        } catch (Exception e) {
            ok = false;
            msg = e.getMessage();
        }

        resp.setContentType("application/json; charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.print("{\"ok\":" + ok + ",\"message\":\"" + escape(msg) + "\"}");
        }
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
    private Integer parseNullableInt(String s) {
        try { return (s == null || s.isBlank()) ? null : Integer.parseInt(s); } catch (Exception e) { return null; }
    }
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}