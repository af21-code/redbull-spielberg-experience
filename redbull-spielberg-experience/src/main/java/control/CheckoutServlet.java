package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
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

        // Idempotency key (anti doppio invio)
        String idem = (String) session.getAttribute("checkoutIdem");
        if (idem == null || idem.isEmpty()) {
            idem = UUID.randomUUID().toString();
            session.setAttribute("checkoutIdem", idem);
        }
        req.setAttribute("idempotencyKey", idem);

        // CSRF token (token in sessione come da traccia)
        String csrf = (String) session.getAttribute("csrfToken");
        if (csrf == null || csrf.isEmpty()) {
            csrf = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", csrf);
        }
        req.setAttribute("csrfToken", csrf);

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

        // CSRF check
        String csrfForm = trim(req.getParameter("csrf"));
        String csrfSess = (String) session.getAttribute("csrfToken");
        if (csrfSess == null || !csrfSess.equals(csrfForm)) {
            resp.sendRedirect(ctx + "/checkout");
            return;
        }

        // Idempotency check
        String idemForm = trim(req.getParameter("idempotencyKey"));
        String idemSess = (String) session.getAttribute("checkoutIdem");
        if (idemSess == null || !idemSess.equals(idemForm)) {
            resp.sendRedirect(ctx + "/checkout");
            return;
        }

        // Lettura form
        String shipping = trim(req.getParameter("shippingAddress"));
        String billing  = trim(req.getParameter("billingAddress"));
        String notes    = trim(req.getParameter("notes"));
        String payment  = trim(req.getParameter("paymentMethod"));

        // Validazioni minime
        List<String> errors = new ArrayList<>();
        if (isBlank(shipping)) errors.add("L'indirizzo di spedizione è obbligatorio.");
        if (isBlank(payment))  errors.add("Seleziona un metodo di pagamento.");
        if (!( "CARD".equalsIgnoreCase(payment) ||
               "PAYPAL".equalsIgnoreCase(payment) ||
               "BANK_TRANSFER".equalsIgnoreCase(payment))) {
            errors.add("Metodo di pagamento non valido.");
        }

        if (isBlank(billing)) billing = shipping;

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart) total = total.add(it.getTotal());
        if (total.signum() <= 0) errors.add("Totale ordine non valido (0 o negativo).");

        if (!errors.isEmpty()) {
            req.setAttribute("checkoutError", String.join(" ", errors));
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            // Checkout transazionale con locking (service)
            CheckoutService.Input in = new CheckoutService.Input(shipping, billing, notes, payment);
            CheckoutService svc = new CheckoutService();
            CheckoutService.Result res = svc.checkout(auth.getUserId(), idemForm, in, cart);

            // Consuma idempotency + pulizia sessione
            session.removeAttribute("checkoutIdem");
            session.removeAttribute("cartItems");

            // PRG: redirect alla pagina di successo con orderNumber come parametro
            String target = ctx + "/views/order_success.jsp?orderNumber=" +
                    URLEncoder.encode(res.orderNumber, StandardCharsets.UTF_8);
            resp.sendRedirect(target);
            return;

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