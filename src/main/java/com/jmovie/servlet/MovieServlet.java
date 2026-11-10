/////// HOME PAGE - PABODA

// Package declaration


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
 * MovieServlet handles movie-related operations.
 *
 * Main responsibilities:
 *   1. Display all movies.
 *   2. Display individual movie details.
 *   3. Allow administrators to add, edit, and delete movies.
 *
 * URL mappings:
 *   /movies          - Display all movies.
 *   /movies/detail/{id} - Display movie details.
 *   /movies/add - Add a new movie.
 *   /movies/edit - Edit an existing movie.
 *   /movies/delete - Delete a movie.
 */
@WebServlet(name = "MovieServlet", urlPatterns = {"/movies", "/movies/*"})
public class MovieServlet extends HttpServlet {

    /**
     * Handles HTTP GET requests.
     *
     * If the requested path is empty or "/",
     * it displays the list of all movies.
     *
     * If the path starts with "/detail/",
     * it extracts the movie ID and displays movie details.
     *
     * For any other path, it redirects the user
     *  to the main movie listing page.
     *
     */
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

    /**
     * Handles HTTP POST requests for movie management.
     *
     * First, checks whether the logged-in user is an administrator.
     * Then retrieves the action parameter from the request.
     *
     * Based on the action, it performs one of the following:
     *  - add: Add a new movie.
     *  - edit: Update an existing movie.
     *  - delete: Delete a movie.
     *
     *  If the action is invalid, redirects to the admin movie management page.
     */
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

    // Handles movie listing and search functionality.
    // Retrieves the search keyword from the request.
    // Retrieves the selected movie genre.
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

    // Handles the movie detail page.
    // Retrieves the selected movie using its ID.
    // Also retrieves available showtimes and approved reviews.
    // Forwards all retrieved data to the movie detail JSP page.

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

    // Handles adding a new movie by the administrator.

    /*
     * Generates a unique movie ID.
     * Creates a Movie object using the submitted form data.
     * Saves the new movie into the database.
     */

    // Redirects with a success or error message.

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

    // Handles updating an existing movie.

    /*
     * Updates the corresponding movie record in the database.
     * Retrieves the movie ID from the submitted form.
     * Builds an updated Movie object using the new form data.
     */

    // Redirects with a success or error message.
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

    // Handles deleting a movie by the administrator.
    // Retrieves the movie ID from the request.
    // Deletes the corresponding movie record from the database.
    // Redirects to the movie management page with a success message.
    private void deleteMovie(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String id = req.getParameter("id");
        MovieDAO.delete(id);
        res.sendRedirect(req.getContextPath() + "/admin/manage-movies?msg=deleted");
    }

    // ── Helpers ────────────────────────────────────────────────────────────

    /*
     * Helper method to create a Movie object from form data.
     * Retrieves and cleans all submitted movie details.
     * Converts duration and rating into numeric values.
     */

    // Sets the default status to NOW_SHOWING if no status is provided.
    // Returns a new Movie object containing the submitted information.

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

    // Verifies that the current user has admin privileges.
    // Retrieves the existing HTTP session.

    /*
     * If no session exists or the user is not an administrator,
     * redirects the user to the login page.
     */

    private void requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
        }
    }

    // Removes unnecessary spaces from input values.
    // Returns an empty string if the input value is null.
    private String trim(String s) { return s == null ? "" : s.trim(); }
}

// Paboda Update 101

// Paboda Update 102

