package model.dao.impl;

import model.User;
import model.dao.AdminUserDAO;
import utils.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AdminUserDAOImpl implements AdminUserDAO {

    private static final String BASE_SELECT = """
        SELECT user_id, email, first_name, last_name, phone_number,
               user_type, registration_date, /* last_login, */ is_active
        FROM users
    """;

    private Connection getConnection() throws Exception {
        return DatabaseConnection.getInstance().getConnection();
    }

    @Override
    public List<User> adminFindAll(String q, String userType, Boolean onlyInactive) throws Exception {
        StringBuilder sb = new StringBuilder(BASE_SELECT).append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sb.append(" AND (LOWER(email) LIKE ? OR LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?) ");
            String like = "%" + q.toLowerCase().trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        if (userType != null && !userType.isBlank()) {
            sb.append(" AND user_type = ? ");
            params.add(userType);
        }
        if (onlyInactive != null && onlyInactive) {
            sb.append(" AND is_active = 0 ");
        }

        // Sort compatibile MySQL (niente NULLS LAST)
        sb.append(" ORDER BY registration_date DESC ");

        List<User> list = new ArrayList<>();
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {

            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserId(rs.getInt("user_id"));
                    u.setEmail(rs.getString("email"));
                    u.setFirstName(rs.getString("first_name"));
                    u.setLastName(rs.getString("last_name"));
                    u.setPhoneNumber(rs.getString("phone_number"));

                    // enum User.UserType
                    String t = rs.getString("user_type");
                    if (t != null) u.setUserType(User.UserType.valueOf(t));

                    // LocalDateTime per registrationDate
                    Timestamp reg = rs.getTimestamp("registration_date");
                    if (reg != null) {
                        LocalDateTime ldt = reg.toLocalDateTime();
                        u.setRegistrationDate(ldt);
                    }

                    // attivo (il tuo model presumibilmente espone setActive(Boolean))
                    u.setActive(rs.getBoolean("is_active"));

                    // last_login / created_at / updated_at NON impostati per compatibilità col tuo model
                    list.add(u);
                }
            }
        }
        return list;
    }

    @Override
    public void setActive(int userId, boolean active) throws Exception {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE users SET is_active=?, updated_at=NOW() WHERE user_id=?")) {
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateUserType(int userId, String userType) throws Exception {
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE users SET user_type=?, updated_at=NOW() WHERE user_id=?")) {
            ps.setString(1, userType);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}