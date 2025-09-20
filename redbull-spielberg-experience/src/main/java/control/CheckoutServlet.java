package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import model.CartItem;
import model.User;
import service.CheckoutService;

@WebServlet(urlPatterns = {"/checkout", "/checkout/confirm"})
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @SuppressWarnings("unchecked")
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User auth = (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        List<CartItem> cart = (List<CartItem>) session.getAttribute("cartItems");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        // --- Idempotency key per prevenire doppi invii (F5 / doppio click)
        String idem = (String) session.getAttribute("checkoutIdem");
        if (idem == null || idem.isEmpty()) {
            idem = UUID.randomUUID().toString();
            session.setAttribute("checkoutIdem", idem);
        }
        req.setAttribute("idempotencyKey", idem);

        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        final String ctx = req.getContextPath();
        final String path = req.getServletPath();
        if (!"/checkout/confirm".equals(path)) {
            // Se qualcuno posta per errore su /checkout, rimanda alla review
            resp.sendRedirect(ctx + "/checkout");
            return;
        }

        HttpSession session = req.getSession();
        User auth = (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(ctx + "/views/login.jsp");
            return;
        }

        List<CartItem> cart = (List<CartItem>) session.getAttribute("cartItems");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(ctx + "/shop");
            return;
        }

        // --- Verifica idempotency
        String idemForm = trim(req.getParameter("idempotencyKey"));
        String idemSess = (String) session.getAttribute("checkoutIdem");
        if (idemSess == null || !idemSess.equals(idemForm)) {
            // Key mancante/non combaciante: evita doppio submit o sessione scaduta
            resp.sendRedirect(ctx + "/checkout");
            return;
        }

        // --- Lettura form
        String shipping = trim(req.getParameter("shippingAddress"));
        String billing  = trim(req.getParameter("billingAddress"));
        String notes    = trim(req.getParameter("notes"));
        String payment  = trim(req.getParameter("paymentMethod"));

        // --- Validazioni server-side minime
        List<String> errors = new ArrayList<>();
        if (isBlank(shipping)) errors.add("L'indirizzo di spedizione è obbligatorio.");
        if (isBlank(payment))  errors.add("Seleziona un metodo di pagamento.");
        if (!( "CARD".equalsIgnoreCase(payment) ||
               "PAYPAL".equalsIgnoreCase(payment) ||
               "BANK_TRANSFER".equalsIgnoreCase(payment))) {
            errors.add("Metodo di pagamento non valido.");
        }

        // se fatturazione assente, copia spedizione
        if (isBlank(billing)) billing = shipping;

        // opzionale: controllo totale > 0 (coerente con carrello sessione)
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart) total = total.add(it.getTotal());
        if (total.signum() <= 0) errors.add("Totale ordine non valido (0 o negativo).");

        if (!errors.isEmpty()) {
            req.setAttribute("checkoutError", String.join(" ", errors));
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            // --- Checkout transazionale con lock (products/time_slots) + snapshot prezzo/nome
        	CheckoutService.Input in = new CheckoutService.Input(shipping, billing, notes, payment);
        	CheckoutService svc = new CheckoutService();
        	CheckoutService.Result res = svc.checkout(auth.getUserId(), idemForm, in, cart);

            // Consuma la chiave di idempotency
            session.removeAttribute("checkoutIdem");

            // Svuota carrello di sessione (il carrello DB è svuotato dal service)
            session.removeAttribute("cartItems");

            // Success: forward alla pagina esistente di successo (manteniamo il tuo flow)
            req.setAttribute("orderNumber", res.orderNumber);
            req.getRequestDispatcher("/views/order_success.jsp").forward(req, resp);

            // In alternativa: PRG per evitare re-post su refresh.
            // resp.sendRedirect(ctx + "/orders/" + res.orderNumber);
            // return;

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("checkoutError",
                    (e.getMessage() == null ? "Errore durante il checkout." : e.getMessage()));
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }

    // helpers
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private static String trim(String s) { return s == null ? null : s.trim(); }
}