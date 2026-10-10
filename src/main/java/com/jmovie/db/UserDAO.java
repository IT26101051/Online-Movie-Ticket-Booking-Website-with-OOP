package com.jmovie.db;

import com.jmovie.model.AdminUser;
import com.jmovie.model.RegularUser;
import com.jmovie.model.User;
import com.jmovie.util.IdGenerator;
import com.jmovie.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for User entity.
 * Replaces FileHandler usage for users.txt
 */
public class UserDAO {

    /** Find user by username (case-insensitive) */
    public static User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE LOWER(username) = LOWER(?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    /** Find user by ID */
    public static User findById(String id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    /** Get all users */
    public static List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY created_at DESC";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    /** Insert new user */
    public static boolean insert(User user) {
        String sql = "INSERT INTO users (id,username,password,email,phone,role,created_at) VALUES (?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, user.getId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getCreatedAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Update user email and phone */
    public static boolean update(User user) {
        String sql = "UPDATE users SET email=?, phone=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Delete user by ID */
    public static boolean delete(String id) {
        String sql = "DELETE FROM users WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Count total users */
    public static long count() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { log(e); }
        return 0;
    }

    // ── Map ResultSet → User ──────────────────────────────────────────
    private static User map(ResultSet rs) throws SQLException {
        String id   = rs.getString("id");
        String user = rs.getString("username");
        String pw   = rs.getString("password");
        String mail = rs.getString("email");
        String ph   = rs.getString("phone");
        String role = rs.getString("role");
        String date = rs.getString("created_at");
        if ("ADMIN".equals(role)) return new AdminUser(id, user, pw, mail, ph, date);
        return new RegularUser(id, user, pw, mail, ph, date);
    }

    private static void log(SQLException e) {
        System.err.println("[UserDAO] SQL error: " + e.getMessage());
    }
}
