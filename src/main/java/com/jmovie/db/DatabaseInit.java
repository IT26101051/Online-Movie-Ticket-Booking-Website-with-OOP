package com.jmovie.db;

import com.jmovie.util.PasswordUtil;

import java.sql.*;

/**
 * Creates the jmovie database schema on startup and seeds default data.
 * Runs inside AppInitializer (ServletContextListener).
 * Tables are only created if they don't already exist (safe to re-run).
 */
public class DatabaseInit {

    public static void init() {
        try (Connection conn = DBConnection.getConnection()) {
            createTables(conn);
            seedAdmin(conn);
            seedMovies(conn);
            seedShowtimes(conn);
            System.out.println("[JMovie] Database initialized successfully.");
        } catch (SQLException e) {
            System.err.println("[JMovie] Database initialization failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ─── Table Creation ────────────────────────────────────────────────
    private static void createTables(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {

            // Users
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "  id           VARCHAR(20)  PRIMARY KEY," +
                "  username     VARCHAR(50)  NOT NULL UNIQUE," +
                "  password     VARCHAR(64)  NOT NULL," +
                "  email        VARCHAR(100) NOT NULL," +
                "  phone        VARCHAR(20)  DEFAULT ''," +
                "  role         VARCHAR(10)  NOT NULL DEFAULT 'USER'," +
                "  created_at   VARCHAR(30)  NOT NULL" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // Movies
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS movies (" +
                "  id           VARCHAR(20)  PRIMARY KEY," +
                "  title        VARCHAR(200) NOT NULL," +
                "  genre        VARCHAR(50)  NOT NULL," +
                "  description  TEXT," +
                "  duration     INT          NOT NULL DEFAULT 0," +
                "  rating       DOUBLE       NOT NULL DEFAULT 0.0," +
                "  poster_url   VARCHAR(500) DEFAULT ''," +
                "  release_date VARCHAR(15)  NOT NULL," +
                "  status       VARCHAR(15)  NOT NULL DEFAULT 'NOW_SHOWING'" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // Showtimes
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS showtimes (" +
                "  id              VARCHAR(20)  PRIMARY KEY," +
                "  movie_id        VARCHAR(20)  NOT NULL," +
                "  movie_title     VARCHAR(200) NOT NULL," +
                "  theatre_hall    VARCHAR(50)  NOT NULL," +
                "  show_date       VARCHAR(15)  NOT NULL," +
                "  show_time       VARCHAR(10)  NOT NULL," +
                "  total_seats     INT          NOT NULL DEFAULT 80," +
                "  available_seats INT          NOT NULL DEFAULT 80," +
                "  price           DOUBLE       NOT NULL DEFAULT 0.0," +
                "  booked_seats    TEXT         DEFAULT ''" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // Bookings
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS bookings (" +
                "  id            VARCHAR(20)  PRIMARY KEY," +
                "  user_id       VARCHAR(20)  NOT NULL," +
                "  username      VARCHAR(50)  NOT NULL," +
                "  showtime_id   VARCHAR(20)  NOT NULL," +
                "  movie_id      VARCHAR(20)  NOT NULL," +
                "  movie_title   VARCHAR(200) NOT NULL," +
                "  seats         VARCHAR(200) NOT NULL," +
                "  quantity      INT          NOT NULL DEFAULT 1," +
                "  total_amount  DOUBLE       NOT NULL DEFAULT 0.0," +
                "  status        VARCHAR(15)  NOT NULL DEFAULT 'CONFIRMED'," +
                "  booking_date  VARCHAR(30)  NOT NULL," +
                "  show_date     VARCHAR(15)  NOT NULL," +
                "  show_time     VARCHAR(10)  NOT NULL," +
                "  theatre_hall  VARCHAR(50)  DEFAULT ''" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );

            // Reviews
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reviews (" +
                "  id           VARCHAR(20)  PRIMARY KEY," +
                "  user_id      VARCHAR(20)  NOT NULL," +
                "  username     VARCHAR(50)  NOT NULL," +
                "  movie_id     VARCHAR(20)  NOT NULL," +
                "  movie_title  VARCHAR(200) NOT NULL," +
                "  rating       INT          NOT NULL DEFAULT 5," +
                "  comment      TEXT         NOT NULL," +
                "  created_at   VARCHAR(30)  NOT NULL," +
                "  status       VARCHAR(15)  NOT NULL DEFAULT 'PENDING'," +
                "  review_type  VARCHAR(15)  NOT NULL DEFAULT 'PUBLIC'" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            );
        }
    }

    // ─── Seed Admin ────────────────────────────────────────────────────
    private static void seedAdmin(Connection conn) throws SQLException {
        String check = "SELECT COUNT(*) FROM users WHERE role = 'ADMIN'";
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(check)) {
            rs.next();
            if (rs.getInt(1) > 0) return; // already seeded
        }

        String sql = "INSERT INTO users (id, username, password, email, phone, role, created_at) VALUES (?,?,?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "USR00001");
            ps.setString(2, "admin");
            ps.setString(3, PasswordUtil.hash("admin123"));
            ps.setString(4, "admin@jmovie.lk");
            ps.setString(5, "0777000001");
            ps.setString(6, "ADMIN");
            ps.setString(7, now());
            ps.executeUpdate();
        }
        System.out.println("[JMovie] Default admin seeded → username: admin | password: admin123");
    }

    // ─── Seed Movies ────────────────────────────────────────────────────
    private static void seedMovies(Connection conn) throws SQLException {
        String check = "SELECT COUNT(*) FROM movies";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(check)) {
            rs.next();
            if (rs.getInt(1) > 0) return; // already seeded
        }

        String sql = "INSERT INTO movies (id,title,genre,description,duration,rating,poster_url,release_date,status) VALUES (?,?,?,?,?,?,?,?,?)";
        Object[][] data = {
            {"MOV00001","Interstellar","Sci-Fi","A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",169,8.7,"https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg","2014-11-07","NOW_SHOWING"},
            {"MOV00002","The Dark Knight","Action","When the menace known as the Joker wreaks havoc on the people of Gotham, Batman must accept one of the greatest tests of his ability to fight injustice.",152,9.0,"https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg","2008-07-18","NOW_SHOWING"},
            {"MOV00003","Inception","Thriller","A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",148,8.8,"https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg","2010-07-16","NOW_SHOWING"},
            {"MOV00004","Dune: Part Two","Sci-Fi","Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.",166,8.5,"https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg","2024-03-01","NOW_SHOWING"},
            {"MOV00005","Oppenheimer","Drama","The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb during World War II.",180,8.9,"https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg","2023-07-21","NOW_SHOWING"},
            {"MOV00006","Poor Things","Comedy","The incredible tale about the fantastical evolution of Bella Baxter, a young woman brought back to life by the brilliant scientist Dr. Godwin Baxter.",141,7.9,"https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXIRfka3HBpMd7l.jpg","2023-12-08","COMING_SOON"},
        };

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Object[] row : data) {
                ps.setString(1, (String) row[0]);
                ps.setString(2, (String) row[1]);
                ps.setString(3, (String) row[2]);
                ps.setString(4, (String) row[3]);
                ps.setInt(5,    (Integer) row[4]);
                ps.setDouble(6, (Double) row[5]);
                ps.setString(7, (String) row[6]);
                ps.setString(8, (String) row[7]);
                ps.setString(9, (String) row[8]);
                ps.executeUpdate();
            }
        }
        System.out.println("[JMovie] Sample movies seeded.");
    }

    // ─── Seed Showtimes ────────────────────────────────────────────────
    private static void seedShowtimes(Connection conn) throws SQLException {
        String check = "SELECT COUNT(*) FROM showtimes";
        try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery(check)) {
            rs.next();
            if (rs.getInt(1) > 0) return;
        }

        String sql = "INSERT INTO showtimes (id,movie_id,movie_title,theatre_hall,show_date,show_time,total_seats,available_seats,price,booked_seats) VALUES (?,?,?,?,?,?,?,?,?,?)";
        Object[][] data = {
            {"SHW00001","MOV00001","Interstellar","Hall A","2026-10-15","10:00",80,80,850.0,""},
            {"SHW00002","MOV00001","Interstellar","Hall B","2026-10-15","14:30",80,80,850.0,""},
            {"SHW00003","MOV00001","Interstellar","Hall A","2026-10-16","18:00",80,80,850.0,""},
            {"SHW00004","MOV00002","The Dark Knight","Hall C","2026-10-15","11:00",80,80,750.0,""},
            {"SHW00005","MOV00002","The Dark Knight","Hall C","2026-10-16","15:00",80,80,750.0,""},
            {"SHW00006","MOV00003","Inception","Hall B","2026-10-17","13:00",80,80,800.0,""},
            {"SHW00007","MOV00004","Dune: Part Two","IMAX Hall","2026-10-15","16:00",60,60,1200.0,""},
            {"SHW00008","MOV00004","Dune: Part Two","IMAX Hall","2026-10-16","19:30",60,60,1200.0,""},
            {"SHW00009","MOV00005","Oppenheimer","Hall A","2026-10-18","12:00",80,80,900.0,""},
        };

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Object[] row : data) {
                ps.setString(1, (String) row[0]);
                ps.setString(2, (String) row[1]);
                ps.setString(3, (String) row[2]);
                ps.setString(4, (String) row[3]);
                ps.setString(5, (String) row[4]);
                ps.setString(6, (String) row[5]);
                ps.setInt(7,    (Integer) row[6]);
                ps.setInt(8,    (Integer) row[7]);
                ps.setDouble(9, (Double) row[8]);
                ps.setString(10,(String) row[9]);
                ps.executeUpdate();
            }
        }
        System.out.println("[JMovie] Sample showtimes seeded.");
    }

    private static String now() {
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
    }
}
