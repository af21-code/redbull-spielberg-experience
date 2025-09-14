package model.dao;

import model.User;

import java.util.List;

public interface AdminUserDAO {
    List<User> adminFindAll(String q, String userType, Boolean onlyInactive) throws Exception;
    void setActive(int userId, boolean active) throws Exception;
    void updateUserType(int userId, String userType) throws Exception; // VISITOR | REGISTERED | PREMIUM | ADMIN
}