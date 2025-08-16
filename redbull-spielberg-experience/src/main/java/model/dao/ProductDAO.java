package model.dao;

import java.util.List;
import model.Product;

public interface ProductDAO {

    /**
     * Ritorna SOLO i prodotti MERCHANDISE attivi.
     * Se categoryId è null => tutte le categorie.
     */
    List<Product> findActiveMerchandise(Integer categoryId) throws Exception;

    /**
     * Trova un prodotto attivo per id (qualsiasi tipo).
     * Ritorna null se non trovato o non attivo.
     */
    Product findById(int productId) throws Exception;

    /**
     * (Opzionale) Tutti i prodotti attivi, filtrabili per categoria.
     * Utile se vuoi una lista “generica” (esperienze + merchandising).
     */
    List<Product> findAll(Integer categoryId) throws Exception;
}