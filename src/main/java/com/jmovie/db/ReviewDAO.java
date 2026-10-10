package com.jmovie.db;

import com.jmovie.model.PublicReview;
import com.jmovie.model.Review;
import com.jmovie.model.VerifiedReview;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Review entity.
 */
public class ReviewDAO {

    public static List<Review> findByMovieId(String movieId, String status) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT * FROM reviews WHERE movie_id=?" + (status != null ? " AND status=?" : "") + " ORDER BY created_at DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, movieId);
            if (status != null) ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static List<Review> findAll() {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT * FROM reviews ORDER BY created_at DESC";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    public static Review findById(String id) {
        String sql = "SELECT * FROM reviews WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    public static boolean insert(Review r) {
        String sql = "INSERT INTO reviews (id,user_id,username,movie_id,movie_title,rating,comment,created_at,status,review_type) VALUES (?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1,  r.getId());
            ps.setString(2,  r.getUserId());
            ps.setString(3,  r.getUsername());
            ps.setString(4,  r.getMovieId());
            ps.setString(5,  r.getMovieTitle());
            ps.setInt(6,     r.getRating());
            ps.setString(7,  r.getComment());
            ps.setString(8,  r.getCreatedAt());
            ps.setString(9,  r.getStatus());
            ps.setString(10, r.getReviewType());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    public static boolean updateStatus(String id, String status) {
        String sql = "UPDATE reviews SET status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    public static boolean delete(String id) {
        String sql = "DELETE FROM reviews WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    private static Review map(ResultSet rs) throws SQLException {
        String id    = rs.getString("id");
        String uid   = rs.getString("user_id");
        String uname = rs.getString("username");
        String mid   = rs.getString("movie_id");
        String mtit  = rs.getString("movie_title");
        int    rat   = rs.getInt("rating");
        String com   = rs.getString("comment");
        String date  = rs.getString("created_at");
        String stat  = rs.getString("status");
        String type  = rs.getString("review_type");
        if ("VERIFIED".equals(type))
            return new VerifiedReview(id, uid, uname, mid, mtit, rat, com, date, stat);
        return new PublicReview(id, uid, uname, mid, mtit, rat, com, date, stat);
    }

    private static void log(SQLException e) { System.err.println("[ReviewDAO] " + e.getMessage()); }
}
