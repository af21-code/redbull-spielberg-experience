package model.dao;

import model.CartItem;
import java.util.List;

public interface CartDAO {
    void addOrIncrement(int userId, int productId, Integer slotId, int quantity) throws Exception;
    void updateQuantity(int userId, int productId, Integer slotId, int quantity) throws Exception;
    void removeItem(int userId, int productId, Integer slotId) throws Exception;
    void clearCart(int userId) throws Exception;
    List<CartItem> findByUser(int userId) throws Exception;
}