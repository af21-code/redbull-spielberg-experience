package listener;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.*;
import model.CartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;
import utils.DatabaseConnection;

import java.sql.Connection;
import java.util.List;

@WebListener
public class SessionCartMergeListener implements HttpSessionAttributeListener {

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) { maybeMerge(event); }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) { maybeMerge(event); }

    private void maybeMerge(HttpSessionBindingEvent event) {
        if (!"authUser".equals(event.getName())) return;

        HttpSession session = event.getSession();
        Object authUser = session.getAttribute("authUser");
        if (authUser == null) return;

        Integer userId = null;
        try { userId = (Integer) authUser.getClass().getMethod("getUserId").invoke(authUser); }
        catch (Exception ignored) {}

        if (userId == null) return;

        @SuppressWarnings("unchecked")
        List<CartItem> items = (List<CartItem>) session.getAttribute("cartItems");
        if (items == null || items.isEmpty()) return;

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            con.setAutoCommit(false);
            CartDAO dao = new CartDAOImpl(con);

            for (CartItem it : items) {
                dao.upsertItem(userId, it.getProductId(), it.getSlotId(), it.getQuantity());
            }

            con.commit();
            items.clear();                       // svuota il carrello sessione
            session.setAttribute("cartItems", items);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}