package com.jmovie.db;

import com.jmovie.model.Booking;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Booking entity.
 */
public class BookingDAO {

    public static List<Booking> findByUserId(String userId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE user_id=? ORDER BY booking_date DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static List<Booking> findAll() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY booking_date DESC";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static Booking findById(String id) {
        String sql = "SELECT * FROM bookings WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    public static boolean insert(Booking b) {
        String sql = "INSERT INTO bookings (id,user_id,username,showtime_id,movie_id,movie_title,seats,quantity,total_amount,status,booking_date,show_date,show_time,theatre_hall,payment_method,transaction_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1,  b.getId());
            ps.setString(2,  b.getUserId());
            ps.setString(3,  b.getUsername());
            ps.setString(4,  b.getShowtimeId());
            ps.setString(5,  b.getMovieId());
            ps.setString(6,  b.getMovieTitle());
            ps.setString(7,  b.getSeats());
            ps.setInt(8,     b.getQuantity());
            ps.setDouble(9,  b.getTotalAmount());
            ps.setString(10, b.getStatus());
            ps.setString(11, b.getBookingDate());
            ps.setString(12, b.getShowDate());
            ps.setString(13, b.getShowTime());
            ps.setString(14, b.getTheatreHall());
            ps.setString(15, b.getPaymentMethod() != null ? b.getPaymentMethod() : "CARD");
            ps.setString(16, b.getTransactionId() != null ? b.getTransactionId() : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Update booking status (CONFIRMED → CANCELLED) */
    public static boolean updateStatus(String id, String status) {
        String sql = "UPDATE bookings SET status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Count confirmed bookings */
    public static long countConfirmed() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status='CONFIRMED'";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { log(e); }
        return 0;
    }

    /** Recent bookings (last N records) */
    public static List<Booking> findRecent(int limit) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY booking_date DESC LIMIT ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    /** Check if a user has a confirmed booking for a specific movie */
    public static boolean userHasBookedMovie(String userId, String movieId) {
        String sql = "SELECT COUNT(*) FROM bookings WHERE user_id=? AND movie_id=? AND status='CONFIRMED'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, movieId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) { log(e); }
        return false;
    }

    public static long count() {
        String sql = "SELECT COUNT(*) FROM bookings WHERE status='CONFIRMED'";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { log(e); }
        return 0;
    }

    private static Booking map(ResultSet rs) throws SQLException {
        String pMethod = "CARD";
        String txnId = "";
        try {
            pMethod = rs.getString("payment_method");
            if (pMethod == null) pMethod = "CARD";
        } catch (SQLException ignored) {}
        try {
            txnId = rs.getString("transaction_id");
            if (txnId == null) txnId = "";
        } catch (SQLException ignored) {}

        return new Booking(
            rs.getString("id"), rs.getString("user_id"),
            rs.getString("username"), rs.getString("showtime_id"),
            rs.getString("movie_id"), rs.getString("movie_title"),
            rs.getString("seats"), rs.getInt("quantity"),
            rs.getDouble("total_amount"), rs.getString("status"),
            rs.getString("booking_date"), rs.getString("show_date"),
            rs.getString("show_time"), rs.getString("theatre_hall"),
            pMethod, txnId
        );
    }

    private static void log(SQLException e) { System.err.println("[BookingDAO] " + e.getMessage()); }
}
