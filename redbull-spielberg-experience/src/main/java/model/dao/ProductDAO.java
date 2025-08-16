package model.dao;

import model.Product;
import java.util.List;

public interface ProductDAO {
    List<Product> findAllActive();
    List<Product> findByCategoryActive(int categoryId);
    List<Product> findFeaturedActive();
    Product findById(int productId);
}