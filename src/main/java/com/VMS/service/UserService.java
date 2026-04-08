package com.VMS.service;

import com.VMS.model.User;
import com.VMS.config.DBConnection;

import java.sql.*;
import java.util.UUID;

public class UserService {

    public boolean registerUser(User user) throws SQLException {

        // generate a unique ID for each new user
        String generatedId = UUID.randomUUID().toString();
        user.setId(generatedId);

        Connection conn = DBConnection.getConnection();

        String sql = "INSERT INTO user (id, email, username, password, role, isActive) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, user.getId());
        ps.setString(2, user.getEmail());
        ps.setString(3, user.getUsername());
        ps.setString(4, user.getPassword());
        ps.setString(5, "volunteer");   // default role
        ps.setBoolean(6, true);         // isActive default

        return ps.executeUpdate() > 0;
    }

    public User loginUser(String email, String password) throws SQLException {

        Connection conn = DBConnection.getConnection();

        String sql = "SELECT * FROM user WHERE email = ? AND password = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        ps.setString(2, password);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            User user = new User();
            user.setId(rs.getString("id"));
            user.setEmail(rs.getString("email"));
            user.setUsername(rs.getString("username"));
            user.setRole(rs.getString("role"));
            user.setActive(rs.getBoolean("isActive"));
            return user;
        }

        return null; // login failed
    }
}