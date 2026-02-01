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
import java.util.Objects;
import java.util.UUID;

import model.CartItem;
import model.User;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;
import service.CheckoutService;
import service.CheckoutService.AvailabilityException;

@WebServlet(urlPatterns = { "/checkout", "/checkout/confirm" })
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CartDAO cartDao = new CartDAOImpl();

    @SuppressWarnings("unchecked")
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Anti-cache per evitare ri-submit col back
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");

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

        // VERIFICA DISPONIBILITÀ SLOT PRIMA DI MOSTRARE CHECKOUT
        String unavailableError = checkSlotAvailability(cart);
        if (unavailableError != null) {
            // Reindirizza al carrello con errore
            session.setAttribute("cartError", unavailableError);
            resp.sendRedirect(req.getContextPath() + "/cart/view");
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

    /**
     * Verifica la disponibilità degli slot nel carrello.
     * 
     * @return messaggio d'errore se uno slot non è disponibile, null se tutto ok
     */
    private String checkSlotAvailability(List<CartItem> cart) {
        for (CartItem it : cart) {
            if (it.getSlotId() == null)
                continue; // MERCH, skip

            try (java.sql.Connection c = utils.DatabaseConnection.getInstance().getConnection();
                    java.sql.PreparedStatement ps = c.prepareStatement(
                            "SELECT is_available, slot_date, slot_time, max_capacity, booked_capacity " +
                                    "FROM time_slots WHERE slot_id = ?")) {
                ps.setInt(1, it.getSlotId());
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return "Lo slot selezionato per \"" + it.getProductName() + "\" non esiste più.";
                    }
                    if (rs.getInt("is_available") == 0) {
                        return "Lo slot selezionato per \"" + it.getProductName() + "\" non è più disponibile.";
                    }
                    java.time.LocalDate slotDate = rs.getDate("slot_date").toLocalDate();
                    java.time.LocalTime slotTime = rs.getTime("slot_time").toLocalTime();
                    if (slotDate.isBefore(java.time.LocalDate.now()) ||
                            (slotDate.equals(java.time.LocalDate.now())
                                    && slotTime.isBefore(java.time.LocalTime.now()))) {
                        return "Lo slot selezionato per \"" + it.getProductName() + "\" è scaduto.";
                    }
                    int maxCap = rs.getInt("max_capacity");
                    int booked = rs.getInt("booked_capacity");
                    if (booked + it.getQuantity() > maxCap) {
                        return "Lo slot selezionato per \"" + it.getProductName() + "\" non ha più posti disponibili.";
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                return "Errore durante la verifica della disponibilità. Riprova.";
            }
        }
        return null; // tutto ok
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
        String billing = trim(req.getParameter("billingAddress"));
        String notes = trim(req.getParameter("notes"));
        String payment = trim(req.getParameter("paymentMethod"));

        // Validazioni minime
        List<String> errors = new ArrayList<>();
        if (isBlank(shipping))
            errors.add("L'indirizzo di spedizione è obbligatorio.");
        if (isBlank(payment))
            errors.add("Seleziona un metodo di pagamento.");
        if (!("CARD".equalsIgnoreCase(payment) ||
                "PAYPAL".equalsIgnoreCase(payment) ||
                "BANK_TRANSFER".equalsIgnoreCase(payment))) {
            errors.add("Metodo di pagamento non valido.");
        }

        if (isBlank(billing))
            billing = shipping;

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart)
            total = total.add(it.getTotal());
        if (total.signum() <= 0)
            errors.add("Totale ordine non valido (0 o negativo).");

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

            // Consuma idempotency + pulizia sessione carrello
            session.removeAttribute("checkoutIdem");
            session.removeAttribute("cartItems");
            // (nel dubbio) pulizia di eventuali chiavi alternative usate altrove
            session.removeAttribute("sessionCart");
            session.removeAttribute("cart");
            session.removeAttribute("cartCount");

            // Ruota il CSRF (non riusare lo stesso token dopo un POST critico)
            session.setAttribute("csrfToken", UUID.randomUUID().toString());

            // PRG: redirect alla pagina di successo con orderNumber come parametro
            String target = ctx + "/views/order_success.jsp?orderNumber=" +
                    URLEncoder.encode(res.orderNumber, StandardCharsets.UTF_8);
            resp.sendRedirect(target);
            return;

        } catch (AvailabilityException ae) {
            pruneUnavailable(session, ae.productId, ae.slotId, ae.size);
            req.setAttribute("checkoutError", ae.getMessage());
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("checkoutError",
                    (e.getMessage() == null ? "Errore durante il checkout." : e.getMessage()));
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }

    // helpers
    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    @SuppressWarnings("unchecked")
    private void pruneUnavailable(HttpSession session, int productId, Integer slotId, String size) {
        if (session == null)
            return;
        String sizeKey = size == null ? "" : size;
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cartItems");
        if (cart != null) {
            cart.removeIf(it -> it.getProductId() == productId
                    && Objects.equals(it.getSlotId(), slotId)
                    && Objects.equals(nz(it.getSize()), sizeKey));
        }
        // Aggiorna DB se l'utente è loggato
        User auth = (User) session.getAttribute("authUser");
        if (auth != null) {
            try {
                cartDao.removeItem(auth.getUserId(), productId, slotId, sizeKey);
            } catch (Exception ignored) {
            }
        }
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}