package com.jmovie.db;

import com.jmovie.model.Movie;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Movie entity.
 * Replaces FileHandler usage for movies.txt
 */
public class MovieDAO {

    /** Get all movies, optional search/genre filter */
    public static List<Movie> findAll(String search, String genre) {
        List<Movie> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM movies WHERE 1=1");
        if (search != null && !search.isEmpty()) sql.append(" AND (LOWER(title) LIKE ? OR LOWER(genre) LIKE ?)");
        if (genre  != null && !genre.isEmpty())  sql.append(" AND LOWER(genre) = LOWER(?)");
        sql.append(" ORDER BY title");

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int idx = 1;
            if (search != null && !search.isEmpty()) {
                ps.setString(idx++, "%" + search.toLowerCase() + "%");
                ps.setString(idx++, "%" + search.toLowerCase() + "%");
            }
            if (genre != null && !genre.isEmpty()) ps.setString(idx, genre);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { log(e); }
        return list;
    }

    /** Get all movies (no filter) */
    public static List<Movie> findAll() { return findAll(null, null); }

    /** Find movie by ID */
    public static Movie findById(String id) {
        String sql = "SELECT * FROM movies WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { log(e); }
        return null;
    }

    /** Insert new movie */
    public static boolean insert(Movie m) {
        String sql = "INSERT INTO movies (id,title,genre,description,duration,rating,poster_url,release_date,status) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, m.getId());
            ps.setString(2, m.getTitle());
            ps.setString(3, m.getGenre());
            ps.setString(4, m.getDescription());
            ps.setInt(5,    m.getDuration());
            ps.setDouble(6, m.getRating());
            ps.setString(7, m.getPosterUrl());
            ps.setString(8, m.getReleaseDate());
            ps.setString(9, m.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Update existing movie */
    public static boolean update(Movie m) {
        String sql = "UPDATE movies SET title=?,genre=?,description=?,duration=?,rating=?,poster_url=?,release_date=?,status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, m.getTitle());
            ps.setString(2, m.getGenre());
            ps.setString(3, m.getDescription());
            ps.setInt(4,    m.getDuration());
            ps.setDouble(5, m.getRating());
            ps.setString(6, m.getPosterUrl());
            ps.setString(7, m.getReleaseDate());
            ps.setString(8, m.getStatus());
            ps.setString(9, m.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Delete movie by ID */
    public static boolean delete(String id) {
        String sql = "DELETE FROM movies WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { log(e); return false; }
    }

    /** Count total movies */
    public static long count() {
        String sql = "SELECT COUNT(*) FROM movies";
        try (Connection c = DBConnection.getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) { log(e); }
        return 0;
    }

    // ── Map ResultSet → Movie ─────────────────────────────────────────
    private static Movie map(ResultSet rs) throws SQLException {
        return new Movie(
            rs.getString("id"),
            rs.getString("title"),
            rs.getString("genre"),
            rs.getString("description"),
            rs.getInt("duration"),
            rs.getDouble("rating"),
            rs.getString("poster_url"),
            rs.getString("release_date"),
            rs.getString("status")
        );
    }

    private static void log(SQLException e) {
        System.err.println("[MovieDAO] SQL error: " + e.getMessage());
    }
}
