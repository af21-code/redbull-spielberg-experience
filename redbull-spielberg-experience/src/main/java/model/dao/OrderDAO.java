package model.dao;

import model.CartItem;
import java.util.List;

public interface OrderDAO {
    /**
     * Crea l'ordine (header + righe) prendendo i prezzi/nomi dal carrello (snapshot),
     * aggiorna stock (MERCHANDISE) e capacity degli slot (EXPERIENCE).
     * Ritorna l'order_number generato.
     */
    String createOrder(int userId,
                       List<model.CartItem> cart,
                       String shippingAddress,
                       String billingAddress,
                       String notes,
                       String paymentMethod) throws Exception;
}