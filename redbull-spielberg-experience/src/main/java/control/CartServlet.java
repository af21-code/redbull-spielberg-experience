package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

import model.CartItem;
import model.Product;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;

@WebServlet(urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/clear"})
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ProductDAO productDAO = new ProductDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/cart".equals(path)) {
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
            case "/cart/add":
                handleAdd(req, resp);
                break;
            case "/cart/update":
                handleUpdate(req, resp);
                break;
            case "/cart/remove":
                handleRemove(req, resp);
                break;
            case "/cart/clear":
                handleClear(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ------- handlers -------

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        int productId = Integer.parseInt(req.getParameter("productId"));
        int quantity = Integer.parseInt(Optional.ofNullable(req.getParameter("quantity")).orElse("1"));
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);

        final Product p;
        try {
            p = productDAO.findById(productId); // <-- può lanciare Exception
        } catch (Exception e) {
            log("Errore recuperando il prodotto id=" + productId, e);
            resp.sendRedirect(req.getContextPath() + "/views/shop.jsp");
            return;
        }

        if (p == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shop.jsp");
            return;
        }

        List<CartItem> cart = getCart(req.getSession());

        // merge su stessa chiave (productId + slotId)
        for (CartItem it : cart) {
            if (it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId)) {
                it.setQuantity(it.getQuantity() + Math.max(1, quantity));
                redirectBack(req, resp);
                return;
            }
        }

        CartItem item = new CartItem();
        item.setProductId(productId);
        item.setSlotId(slotId);
        item.setProductName(p.getName());
        item.setUnitPrice(p.getPrice()); // BigDecimal
        item.setQuantity(Math.max(1, quantity));
        item.setProductType(p.getProductType() == null ? null : p.getProductType().name()); // enum -> String
        item.setImageUrl(p.getImageUrl());

        cart.add(item);
        redirectBack(req, resp);
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);
        int quantity = Math.max(1, Integer.parseInt(req.getParameter("quantity")));

        List<CartItem> cart = getCart(req.getSession());
        for (CartItem it : cart) {
            if (it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId)) {
                it.setQuantity(quantity);
                break;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/views/cart.jsp");
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        String slotParam = req.getParameter("slotId");
        Integer slotId = (slotParam == null || slotParam.isBlank()) ? null : Integer.valueOf(slotParam);

        List<CartItem> cart = getCart(req.getSession());
        cart.removeIf(it -> it.getProductId() == productId && Objects.equals(it.getSlotId(), slotId));
        resp.sendRedirect(req.getContextPath() + "/views/cart.jsp");
    }

    private void handleClear(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<CartItem> cart = getCart(req.getSession());
        cart.clear();
        resp.sendRedirect(req.getContextPath() + "/views/cart.jsp");
    }

    // ------- helpers -------

    @SuppressWarnings("unchecked")
    private List<CartItem> getCart(HttpSession session) {
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cartItems");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cartItems", cart);
        }
        return cart;
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.isBlank()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/cart.jsp");
        }
    }
}