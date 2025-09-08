package model.dao;

import model.Order;
import model.OrderItem;
import java.util.List;

public interface OrderQueryDAO {
    // Ordini recenti dell'utente
    List<Order> findRecentByUser(int userId, int limit) throws Exception;

    // Ordini recenti globali (per admin)
    List<Order> findRecentAll(int limit) throws Exception;

    // Righe di un ordine
    List<OrderItem> findItemsByOrder(int orderId) throws Exception;
}