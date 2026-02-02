package model.dao;

import model.Category;
import java.util.List;

public interface CategoryDAO {
    /** Finds all active categories for the public shop dropdown */
    List<Category> findAllActive();

    List<Category> adminFindAllPaged(String q, Boolean onlyInactive, String sort, String dir, int limit, int offset);

    Category adminFindById(int id);

    void insert(Category category);

    void update(Category category);
}
