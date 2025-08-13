package model.dao.impl;

import model.User;
import model.dao.UserDAO;
import utils.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class UserDAOImpl implements UserDAO {

    @Override
    public boolean existsByEmail(String email) throws Exception {
        final String sql = "SELECT 1 FROM users WHERE email = ? LIMIT 1";
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    public User findByEmail(String email) throws Exception {
        final String sql = "SELECT user_id, email, password, first_name, last_name, phone_number, " +
                           "user_type, registration_date, is_active " +
                           "FROM users WHERE email = ? LIMIT 1";
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setFirstName(rs.getString("first_name"));
                u.setLastName(rs.getString("last_name"));
                u.setPhoneNumber(rs.getString("phone_number"));
                u.setUserType(User.UserType.valueOf(rs.getString("user_type")));
                u.setActive(rs.getBoolean("is_active"));
                return u;
            }
        }
    }

    @Override
    public User save(User user) throws Exception {
        final String sql = "INSERT INTO users " +
                "(email, password, first_name, last_name, phone_number, user_type) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword()); // già hashata da PasswordUtil.hash(...)
            ps.setString(3, user.getFirstName());
            ps.setString(4, user.getLastName());
            ps.setString(5, user.getPhoneNumber());
            ps.setString(6, user.getUserType().name());

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    user.setUserId(keys.getInt(1));
                }
            }
            return user;
        }
    }
}