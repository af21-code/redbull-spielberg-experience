package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import model.CartItem;
import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();
    private final CartDAO  cartDAO  = new CartDAOImpl(); // per svuotare carrello DB post-ordine

    @SuppressWarnings("unchecked")
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User auth = (User) req.getSession().getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        List<CartItem> cart = (List<CartItem>) req.getSession().getAttribute("cartItems");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
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

        // se fatturazione assente, copia spedizione (comportamento UX frequente)
        if (isBlank(billing)) billing = shipping;

        // opzionale: controllo totale > 0 (coerente con carrello)
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem it : cart) total = total.add(it.getTotal());
        if (total.signum() <= 0) errors.add("Totale ordine non valido (0 o negativo).");

        if (!errors.isEmpty()) {
            req.setAttribute("checkoutError", String.join(" ", errors));
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            // Crea ordine (persistenza completa dentro il DAO)
            String orderNumber = orderDAO.createOrder(
                    auth.getUserId(), cart, shipping, billing, notes, payment
            );

            // Svuota carrello sessione
            session.removeAttribute("cartItems");

            // Svuota carrello DB (se l’utente usa anche il carrello persistente)
            try { cartDAO.clearCart(auth.getUserId()); } catch (Exception ignore) {}

            // Success: mostra pagina conferma (manteniamo il tuo forward)
            req.setAttribute("orderNumber", orderNumber);
            req.getRequestDispatcher("/views/order_success.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("checkoutError",
                    e.getMessage() == null ? "Errore durante il checkout." : e.getMessage());
            req.getRequestDispatcher("/views/checkout.jsp").forward(req, resp);
        }
    }

    // helpers
    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private static String trim(String s) { return s == null ? null : s.trim(); }
}