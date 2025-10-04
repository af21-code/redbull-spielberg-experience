package model.dao;

import java.util.List;
import model.Product;

public interface ProductDAO {

    // --- Public/Shop ---
    List<Product> findActiveMerchandise(Integer categoryId) throws Exception;
    Product findById(int productId) throws Exception;
    List<Product> findAll(Integer categoryId) throws Exception;

    // --- Admin: gestione catalogo (compat senza paginazione) ---
    /** Tutti i prodotti (anche non attivi), con filtro opzionale per categoria e/o testo nel nome. */
    List<Product> adminFindAll(Integer categoryId, String q, Boolean onlyInactive) throws Exception;

    // --- Admin: paginazione & sort ---
    /** Versione con paginazione e ordinamento. */
    List<Product> adminFindAllPaged(Integer categoryId, String q, Boolean onlyInactive,
                                    String sort, String dir, int limit, int offset) throws Exception;

    /** Conteggio totale record per i filtri indicati. */
    int adminCount(Integer categoryId, String q, Boolean onlyInactive) throws Exception;

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
}