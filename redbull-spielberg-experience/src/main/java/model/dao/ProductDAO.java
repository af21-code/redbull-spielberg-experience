package model.dao;

import java.util.List;
import model.Product;

public interface ProductDAO {

    // --- Public/Shop (già esistenti) ---
    List<Product> findActiveMerchandise(Integer categoryId) throws Exception;
    Product findById(int productId) throws Exception;
    List<Product> findAll(Integer categoryId) throws Exception;

    // --- Admin: gestione catalogo (lista completa senza paging) ---
    /** Tutti i prodotti (anche non attivi), con filtro opzionale per categoria e/o testo nel nome. */
    List<Product> adminFindAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception;

    /** Trova anche se non attivo. */
    Product adminFindById(int productId) throws Exception;

    /** Crea nuovo prodotto. Ritorna il product_id generato. */
    int insert(Product p) throws Exception;

    /** Aggiorna un prodotto esistente. */
    void update(Product p) throws Exception;

    /** Soft-delete: imposta is_active=false. */
    void softDelete(int productId) throws Exception;

    /** Attiva/disattiva. */
    void setActive(int productId, boolean active) throws Exception;

    /** Evidenzia/Non evidenzia (home/featured). */
    void setFeatured(int productId, boolean featured) throws Exception;

    // --- Admin: paginazione + ordinamento ---
    /** Conta i risultati (con gli stessi filtri della lista). */
    int adminCountAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception;

    /**
     * Ricerca con paginazione e ordinamento.
     * @param sortBy  colonne consentite: product_id, name, price, created_at, updated_at, is_active, is_featured, stock_quantity
     * @param sortDir "asc" | "desc"
     * @param offset  offset risultati (>=0)
     * @param limit   numero risultati (1..N)
     */
    List<Product> adminFindAllPaged(Integer categoryId, String q, Boolean onlyInactive,
                                    String sortBy, String sortDir,
                                    int offset, int limit) throws Exception;
}