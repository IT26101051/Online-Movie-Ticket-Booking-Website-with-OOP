package com.jmovie.db;

import com.jmovie.model.Showtime;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Showtime entity.
 */
public class ShowtimeDAO {

    public static List<Showtime> findAll() {
        List<Showtime> list = new ArrayList<>();
        String sql = "SELECT * FROM showtimes ORDER BY show_date, show_time";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static List<Showtime> findByMovieId(String movieId) {
        List<Showtime> list = new ArrayList<>();
        String sql = "SELECT * FROM showtimes WHERE movie_id=? ORDER BY show_date, show_time";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, movieId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static Showtime findById(String id) {
        String sql = "SELECT * FROM showtimes WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    public static boolean insert(Showtime s) {
        String sql = "INSERT INTO showtimes (id,movie_id,movie_title,theatre_hall,show_date,show_time,total_seats,available_seats,price,booked_seats) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, s.getId());
            ps.setString(2, s.getMovieId());
            ps.setString(3, s.getMovieTitle());
            ps.setString(4, s.getTheatreHall());
            ps.setString(5, s.getDate());
            ps.setString(6, s.getTime());
            ps.setInt(7,    s.getTotalSeats());
            ps.setInt(8,    s.getAvailableSeats());
            ps.setDouble(9, s.getPrice());
            ps.setString(10, s.getBookedSeats() == null ? "" : s.getBookedSeats());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    public static boolean update(Showtime s) {
        String sql = "UPDATE showtimes SET available_seats=?, booked_seats=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1,    s.getAvailableSeats());
            ps.setString(2, s.getBookedSeats() == null ? "" : s.getBookedSeats());
            ps.setString(3, s.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    public static boolean delete(String id) {
        String sql = "DELETE FROM showtimes WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    public static long count() {
        String sql = "SELECT COUNT(*) FROM showtimes";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { log(e); }
        return 0;
    }

    private static Showtime map(ResultSet rs) throws SQLException {
        return new Showtime(
            rs.getString("id"), rs.getString("movie_id"),
            rs.getString("movie_title"), rs.getString("theatre_hall"),
            rs.getString("show_date"), rs.getString("show_time"),
            rs.getInt("total_seats"), rs.getInt("available_seats"),
            rs.getDouble("price"), rs.getString("booked_seats")
        );
    }

    private static void log(SQLException e) { System.err.println("[ShowtimeDAO] " + e.getMessage()); }
}
