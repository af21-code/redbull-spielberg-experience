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
     * Lista admin "storica".
     * Filtra per data e, opzionalmente, per utente.
     */
    List<Map<String, Object>> adminList(LocalDate from, LocalDate to, Integer userId) throws Exception;

    /**
     * Lista ordini per admin con filtri (data da/a, query cliente, stato) e paginazione.
     * Campi attesi: order_id, order_number, order_date (timestamp), customer, total_amount, status, payment_status, payment_method
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
     * Conteggio totale per paginazione con gli stessi filtri della lista admin.
     */
    int countOrdersAdmin(
            Date from,
            Date to,
            String customerQuery,
            String status
    ) throws Exception;

    // ===================== DETTAGLIO ORDINE =====================

    /**
     * Header del singolo ordine (con dati acquirente).
     * Ritorna una mappa con i campi usati dalla JSP.
     */
    Map<String, Object> findOrderHeader(int orderId) throws Exception;

    /**
     * Righe del singolo ordine (con eventuale image_url del prodotto).
     * Ritorna una lista di mappe con i campi usati dalla JSP.
     */
    List<Map<String, Object>> findOrderItems(int orderId) throws Exception;

    /**
     * Aggiorna corriere/codice tracking; imposta shipped_at se non valorizzato (se presente nello schema).
     */
    boolean updateTracking(int orderId, String carrier, String trackingCode) throws Exception;

    /**
     * Segna l'ordine come COMPLETED; imposta delivered_at se non valorizzato (se presente nello schema).
     */
    boolean markCompleted(int orderId) throws Exception;

    /**
     * Annulla l'ordine (idempotente):
     * - non annulla se già CANCELLED o COMPLETED o se shipped_at NON è NULL (già spedito);
     * - ripristina stock per i prodotti MERCHANDISE;
     * - decrementa la booked_capacity degli slot interessati di SUM(quantità);
     * - imposta lo stato a CANCELLED.
     * Ritorna true se è stato aggiornato lo stato a CANCELLED.
     */
    boolean cancelOrder(int orderId) throws Exception;
}