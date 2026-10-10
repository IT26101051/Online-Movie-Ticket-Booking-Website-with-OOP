package com.jmovie.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Manages the MySQL database connection for the JMovie application.
 * Uses XAMPP default settings (root, no password).
 *
 * To use a different password, edit DB_PASSWORD below,
 * or set the system property: -Djmovie.db.password=yourpassword
 */
public class DBConnection {

    // ─── XAMPP default connection settings ───────────────────────────
    private static final String DB_HOST     = "localhost";
    private static final String DB_PORT     = "3306";
    private static final String DB_NAME     = "jmovie";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "";   // XAMPP default: empty password

    private static final String URL =
        "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME
        + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
        + "&characterEncoding=UTF-8";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("[JMovie] MySQL JDBC driver not found: " + e.getMessage());
        }
    }

    /**
     * Returns a new connection to the jmovie database.
     * Caller is responsible for closing it (use try-with-resources).
     */
    public static Connection getConnection() throws SQLException {
        String pw = System.getProperty("jmovie.db.password", DB_PASSWORD);
        return DriverManager.getConnection(URL, DB_USER, pw);
    }

    /** Test the connection — returns true if successful */
    public static boolean testConnection() {
        try (Connection c = getConnection()) {
            return c.isValid(2);
        } catch (SQLException e) {
            System.err.println("[JMovie] DB connection failed: " + e.getMessage());
            return false;
        }
    }

    public static void main(String[] args) {
        if (testConnection()) {
            System.out.println("[JMovie] ✅ Connected to XAMPP MySQL successfully!");
        } else {
            System.out.println("[JMovie] ❌ Failed to connect to XAMPP MySQL.");
        }
    }
}
