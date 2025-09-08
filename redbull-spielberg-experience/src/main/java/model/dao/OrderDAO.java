package model.dao;

import model.CartItem;
import java.util.List;

public interface OrderDAO {
    /**
     * Crea un ordine con i relativi item, gestendo in transazione:
     *  - decremento stock MERCHANDISE
     *  - incremento booked_capacity per slot EXPERIENCE
     * Ritorna l'order_number generato.
     */
    String createOrder(int userId,
                       List<CartItem> items,
                       String shippingAddress,
                       String billingAddress,
                       String notes,
                       String paymentMethod) throws Exception;
}