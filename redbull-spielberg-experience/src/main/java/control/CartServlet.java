package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import model.User;
import model.CartItem;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;

@WebServlet(urlPatterns = {
        "/cart", "/cart/view",
        "/cart/add", "/cart/update", "/cart/remove", "/cart/clear"
})
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ProductDAO productDAO = new ProductDAOImpl();
    private final CartDAO    cartDAO    = new CartDAOImpl(); // usa connessioni on-demand

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/cart".equals(path) || "/cart/view".equals(path)) {
            List<CartItem> cart = getCart(req.getSession());
            req.setAttribute("cartItems", cart);
            req.getRequestDispatcher("/views/cart.jsp").forward(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/cart/add"    -> handleAdd(req, resp);
            case "/cart/update" -> handleUpdate(req, resp);
            case "/cart/remove" -> handleRemove(req, resp);
            case "/cart/clear"  -> handleClear(req, resp);
            default             -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        int quantity  = Integer.parseInt(Optional.ofNullable(req.getParameter("quantity")).orElse("1"));
        String size   = Optional.ofNullable(req.getParameter("size")).orElse("");

        // slot (solo esperienze)
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);

        // nuovi parametri prenotazione (possono essere null per il merch)
        String driverName    = Optional.ofNullable(req.getParameter("driverName")).orElse(null);
        String driverNumber  = Optional.ofNullable(req.getParameter("driverNumber")).orElse(null);
        String companionName = Optional.ofNullable(req.getParameter("companionName")).orElse(null);
        String vehicleCode   = Optional.ofNullable(req.getParameter("vehicleCode")).orElse(req.getParameter("vehicle"));
        LocalDate eventDate  = null;
        String dateParam     = req.getParameter("eventDate");
        if (dateParam != null && !dateParam.isBlank()) {
            try { eventDate = LocalDate.parse(dateParam); } catch (Exception ignored) {}
        }

        final Product p;
        try {
            p = productDAO.findById(productId);
        } catch (Exception e) {
            log("Errore recuperando il prodotto id=" + productId, e);
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }
        if (p == null) {
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        boolean isExperience = (p.getProductType() != null && p.getProductType().name().equalsIgnoreCase("EXPERIENCE"));
        if (isExperience) quantity = 1;

        // Esperienze richiedono slot selezionato
        if (isExperience && slotId == null) {
            resp.sendRedirect(req.getContextPath() + "/booking?productId=" + productId + "&err=slot_required");
            return;
        }

        List<CartItem> cart = getCart(req.getSession());

        // Merge solo per MERCH (stessa chiave productId+slotId+size)
        boolean merged = false;
        if (!isExperience) {
            for (CartItem it : cart) {
                if (it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId)
                        && Objects.equals(it.getSize(), size)) {
                    it.setQuantity(it.getQuantity() + Math.max(1, quantity));
                    merged = true;
                    break;
                }
            }
        } else {
            for (CartItem it : cart) {
                if (it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId)) {
                    // Già presente: aggiorna dettagli e mantieni quantità a 1
                    it.setDriverName(driverName);
                    it.setDriverNumber(driverNumber);
                    it.setCompanionName(companionName);
                    it.setVehicleCode(vehicleCode);
                    it.setEventDate(eventDate);
                    it.setQuantity(1);
                    merged = true;
                    // Persisti la versione aggiornata nel DB se loggato
                    Integer userId = getLoggedUserId(req.getSession());
                    if (userId != null) {
                        try {
                            cartDAO.removeItem(userId, productId, slotId, size);
                            cartDAO.upsertItem(userId, productId, slotId, size, 1,
                                    driverName, driverNumber, companionName, vehicleCode, eventDate);
                        } catch (Exception e) {
                            log("SYNC DB refresh experience failed", e);
                        }
                    }
                    redirectBack(req, resp);
                    return;
                }
            }
        }

        if (!merged) {
            CartItem item = new CartItem();
            item.setProductId(productId);
            item.setSlotId(slotId);
            item.setProductName(p.getName());
            item.setUnitPrice(p.getPrice());
            item.setQuantity(Math.max(1, quantity));
            item.setProductType(p.getProductType() == null ? null : p.getProductType().name());
            item.setImageUrl(p.getImageUrl());
            item.setSize(size);
            // set nuovi campi
            item.setDriverName(driverName);
            item.setDriverNumber(driverNumber);
            item.setCompanionName(companionName);
            item.setVehicleCode(vehicleCode);
            item.setEventDate(eventDate);
            cart.add(item);
        }

     // --- SYNC DB se loggato ---
        Integer userId = getLoggedUserId(req.getSession());
        if (userId != null) {
            try {
                if (isExperience) {
                    cartDAO.upsertItem(userId, productId, slotId, size, 1,
                            driverName, driverNumber, companionName, vehicleCode, eventDate);
                } else if (merged) {
                    cartDAO.upsertItem(userId, productId, slotId, size, Math.max(1, quantity),
                            driverName, driverNumber, companionName, vehicleCode, eventDate);
                } else {
                    cartDAO.upsertItem(userId, productId, slotId, size, Math.max(1, quantity),
                            driverName, driverNumber, companionName, vehicleCode, eventDate);
                }
            } catch (Exception e) {
                log("SYNC DB add cart failed", e);
            }
        }

        redirectBack(req, resp);
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);
        String size = Optional.ofNullable(req.getParameter("size")).orElse("");
        int quantity = Math.max(1, Integer.parseInt(req.getParameter("quantity")));

        List<CartItem> cart = getCart(req.getSession());
        for (CartItem it : cart) {
            if (it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId) && Objects.equals(it.getSize(), size)) {
                it.setQuantity(quantity);
                break;
            }
        }

        // --- SYNC DB se loggato ---
        Integer userId = getLoggedUserId(req.getSession());
        if (userId != null) {
            try {
                cartDAO.updateQuantity(userId, productId, slotId, size, quantity);
            } catch (Exception e) {
                log("SYNC DB update qty failed", e);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/cart/view");
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);
        String size = Optional.ofNullable(req.getParameter("size")).orElse("");

        List<CartItem> cart = getCart(req.getSession());
        cart.removeIf(it -> it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId) && Objects.equals(it.getSize(), size));

        // --- SYNC DB se loggato ---
        Integer userId = getLoggedUserId(req.getSession());
        if (userId != null) {
            try {
                cartDAO.removeItem(userId, productId, slotId, size);
            } catch (Exception e) {
                log("SYNC DB remove item failed", e);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/cart/view");
    }

    private void handleClear(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<CartItem> cart = getCart(req.getSession());
        cart.clear();

        // --- SYNC DB se loggato ---
        Integer userId = getLoggedUserId(req.getSession());
        if (userId != null) {
            try {
                cartDAO.clearCart(userId);
            } catch (Exception e) {
                log("SYNC DB clear failed", e);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/cart/view");
    }

    @SuppressWarnings("unchecked")
    private List<CartItem> getCart(HttpSession session) {
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cartItems");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cartItems", cart);
        }
        return cart;
    }

    private Integer getLoggedUserId(HttpSession session) {
        Object u = session.getAttribute("authUser");
        if (u == null) return null;
        try {
            if (u instanceof User) return ((User) u).getUserId();
            return (Integer) u.getClass().getMethod("getUserId").invoke(u);
        } catch (Exception e) {
            return null;
        }
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isBlank()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/cart/view");
        }
    }
}