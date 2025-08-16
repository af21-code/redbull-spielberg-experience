package model.dao;

import model.Product;
import java.util.List;

public interface ProductDAO {

    /**
     * Ritorna tutti i prodotti attivi. Se categoryId != null filtra per categoria.
     */
    List<Product> findAll(Integer categoryId) throws Exception;

    /**
     * Trova un prodotto per id (attivo o non attivo, a tua scelta; qui manteniamo solo attivi).
     */
    Product findById(int productId) throws Exception;
}