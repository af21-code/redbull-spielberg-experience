package model.dao;

import model.User;

public interface UserDAO {
    User validateLogin(String email, String password);
    boolean emailExists(String email);
    boolean save(User user);
}