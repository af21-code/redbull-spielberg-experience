package model.dao;

import model.CartItem;
import java.time.LocalDate;
import java.util.List;

public interface CartDAO {
    // Overload “semplice” (compatibilità)
    void upsertItem(int userId, int productId, Integer slotId, String size, int quantity) throws Exception;

    // NEW: salva anche i dettagli prenotazione se presenti (null = non aggiornare)
    void upsertItem(int userId, int productId, Integer slotId, String size, int quantity,
                    String driverName, String driverNumber, String companionName,
                    String vehicleCode, LocalDate eventDate) throws Exception;

    void updateQuantity(int userId, int productId, Integer slotId, String size, int quantity) throws Exception;
    void removeItem(int userId, int productId, Integer slotId, String size) throws Exception;
    void clearCart(int userId) throws Exception;
    List<CartItem> findByUser(int userId) throws Exception;
}