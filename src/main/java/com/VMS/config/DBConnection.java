package com.VMS.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection provides the central database connectivity for the application.
 * It uses the MySQL JDBC driver to connect to the 'auth_db' database.
 */
public class DBConnection {
    // Database URL, credentials and driver configuration
    private static final String URL = "jdbc:mysql://localhost:3306/auth_db?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = ""; // Please update with your actual password

    static {
        try {
            // Registering the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Establishes and returns a database connection.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
