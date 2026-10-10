package com.jmovie.servlet;

import com.jmovie.db.MovieDAO;
import com.jmovie.db.ReviewDAO;
import com.jmovie.db.ShowtimeDAO;
import com.jmovie.model.Movie;
import com.jmovie.model.Review;
import com.jmovie.model.Showtime;
import com.jmovie.util.IdGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Handles movie listing, detail, and admin CRUD operations via MySQL database.
 * Routes: /movies, /movies/detail/{id}, POST /movies/add|edit|delete
 */
@WebServlet(name = "MovieServlet", urlPatterns = {"/movies", "/movies/*"})
public class MovieServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            listMovies(req, res);
        } else if (path.startsWith("/detail/")) {
            String id = path.substring("/detail/".length());
            showDetail(req, res, id);
        } else {
            res.sendRedirect(req.getContextPath() + "/movies");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        switch (action == null ? "" : action) {
            case "add":    addMovie(req, res);    break;
            case "edit":   editMovie(req, res);   break;
            case "delete": deleteMovie(req, res); break;
            default: res.sendRedirect(req.getContextPath() + "/admin/manage-movies");
        }
    }

    // ── List all / search ──────────────────────────────────────────────────
    private void listMovies(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String q     = req.getParameter("q");
        String genre = req.getParameter("genre");

        List<Movie> all = MovieDAO.findAll(q, genre);

        req.setAttribute("movies", all);
        req.setAttribute("searchQuery", q);
        req.setAttribute("selectedGenre", genre);
        req.getRequestDispatcher("/WEB-INF/views/movies.jsp").forward(req, res);
    }

    // ── Movie detail page ─────────────────────────────────────────────────
    private void showDetail(HttpServletRequest req, HttpServletResponse res, String movieId)
            throws ServletException, IOException {
        Movie movie = MovieDAO.findById(movieId);
        if (movie == null) {
            res.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        List<Showtime> showtimes = ShowtimeDAO.findByMovieId(movieId);
        List<Review> reviews     = ReviewDAO.findByMovieId(movieId, "APPROVED");

        req.setAttribute("movie", movie);
        req.setAttribute("showtimes", showtimes);
        req.setAttribute("reviews", reviews);
        req.getRequestDispatcher("/WEB-INF/views/movie-detail.jsp").forward(req, res);
    }

    // ── Admin: Add Movie ──────────────────────────────────────────────────
    private void addMovie(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        try {
            Movie m = buildMovieFromRequest(IdGenerator.generate("MOV"), req);
            MovieDAO.insert(m);
            res.sendRedirect(req.getContextPath() + "/admin/manage-movies?msg=saved");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/admin/manage-movies?error=invalid");
        }
    }

    // ── Admin: Edit Movie ─────────────────────────────────────────────────
    private void editMovie(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        try {
            String id = req.getParameter("id");
            Movie m = buildMovieFromRequest(id, req);
            MovieDAO.update(m);
            res.sendRedirect(req.getContextPath() + "/admin/manage-movies?msg=saved");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/admin/manage-movies?error=invalid");
        }
    }

    // ── Admin: Delete Movie ───────────────────────────────────────────────
    private void deleteMovie(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String id = req.getParameter("id");
        MovieDAO.delete(id);
        res.sendRedirect(req.getContextPath() + "/admin/manage-movies?msg=deleted");
    }

    // ── Helpers ────────────────────────────────────────────────────────────
    private Movie buildMovieFromRequest(String id, HttpServletRequest req) {
        String title       = trim(req.getParameter("title"));
        String genre       = trim(req.getParameter("genre"));
        String description = trim(req.getParameter("description"));
        int    duration    = Integer.parseInt(trim(req.getParameter("duration")));
        double rating      = Double.parseDouble(trim(req.getParameter("rating")));
        String posterUrl   = trim(req.getParameter("posterUrl"));
        String releaseDate = trim(req.getParameter("releaseDate"));
        String status      = trim(req.getParameter("status"));
        if (status.isEmpty()) status = "NOW_SHOWING";
        return new Movie(id, title, genre, description, duration, rating, posterUrl, releaseDate, status);
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
        }
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
