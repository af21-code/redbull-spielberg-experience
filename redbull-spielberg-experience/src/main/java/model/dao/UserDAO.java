package model.dao;

import model.User;

public interface UserDAO {
    boolean existsByEmail(String email) throws Exception;
    User findByEmail(String email) throws Exception;
    User save(User user) throws Exception; // ritorna user con id
}