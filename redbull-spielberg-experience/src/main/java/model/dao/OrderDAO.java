package model.dao;

import model.CartItem;

import java.time.LocalDate;
import java.sql.Date;
import java.util.List;
import java.util.Map;

public interface OrderDAO {

    /**
     * Crea un ordine persistendo snapshot prezzo/nome degli articoli.
     */
    String createOrder(int userId,
                       List<CartItem> cart,
                       String shippingAddress,
                       String billingAddress,
                       String notes,
                       String paymentMethod) throws Exception;

    /**
     * Lista admin "storica" (già presente).
     * Filtra per data e, opzionalmente, per utente.
     */
    List<Map<String, Object>> adminList(LocalDate from, LocalDate to, Integer userId) throws Exception;

    /**
     * NUOVO: lista ordini per admin con filtri (data da/a, query cliente, stato)
     * e paginazione (offset/limit). I campi mappati nelle mappe sono:
     *  - order_id, order_number, order_date (string formattata), customer, total_amount, status, payment_status
     */
    List<Map<String, Object>> findOrdersAdmin(
            Date from,
            Date to,
            String customerQuery,   // match su email/nome/cognome
            String status,          // PENDING/CONFIRMED/PROCESSING/COMPLETED/CANCELLED
            int offset,
            int limit
    ) throws Exception;

    /**
     * NUOVO: conteggio totale per paginazione con gli stessi filtri della lista.
     */
    int countOrdersAdmin(
            Date from,
            Date to,
            String customerQuery,
            String status
    ) throws Exception;
}