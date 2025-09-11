package listener;

import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionAttributeListener;
import jakarta.servlet.http.HttpSessionBindingEvent;
import model.SessionCart;
import model.SessionCartItem;
import model.dao.CartDAO;
import model.dao.impl.CartDAOImpl;
import utils.DatabaseConnection;

import java.sql.Connection;

/**
 * Quando in sessione viene impostato "authUser" (login effettuato),
 * se esiste un carrello in sessione ("sessionCart") lo fonde nel DB.
 */
public class SessionCartMergeListener implements HttpSessionAttributeListener {

    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        maybeMerge(event);
    }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) {
        maybeMerge(event);
    }

    private void maybeMerge(HttpSessionBindingEvent event) {
        if (!"authUser".equals(event.getName())) return;

        HttpSession session = event.getSession();
        Object authUser = session.getAttribute("authUser");
        if (authUser == null) return;

        Integer userId = null;
        try {
            userId = (Integer) authUser.getClass().getMethod("getUserId").invoke(authUser);
        } catch (Exception ignored) {}

        if (userId == null) return;

        SessionCart sc = (SessionCart) session.getAttribute("sessionCart");
        if (sc == null || sc.isEmpty()) return;

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {
            con.setAutoCommit(false);

            CartDAO dao = new CartDAOImpl(con); // usa la stessa transazione
            for (SessionCartItem it : sc.getItems()) {
                dao.upsertItem(userId, it.getProductId(), it.getSlotId(), it.getQuantity());
            }

            con.commit();
            sc.clear();
            session.removeAttribute("sessionCart");
        } catch (Exception e) {
            e.printStackTrace(); // in caso di errore, non svuotiamo il carrello in sessione
        }
    }
}