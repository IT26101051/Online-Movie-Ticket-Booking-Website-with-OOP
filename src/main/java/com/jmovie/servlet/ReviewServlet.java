///// MOVIEW REVIEW - KAVIN




package com.jmovie.servlet;

import com.jmovie.db.BookingDAO;
import com.jmovie.db.ReviewDAO;
import com.jmovie.model.PublicReview;
import com.jmovie.model.Review;
import com.jmovie.model.VerifiedReview;
import com.jmovie.util.IdGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles Review CRUD operations via MySQL database.
 * Routes: POST /review/add|edit|delete|approve|reject
 */
@WebServlet(name = "ReviewServlet", urlPatterns = {"/review", "/review/*"})
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireLogin(req, res);
        if (res.isCommitted()) return;
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo();
        if (path == null) path = "/";
        switch (path) {
            case "/add":     addReview(req, res);     break;
            case "/edit":    editReview(req, res);    break;
            case "/delete":  deleteReview(req, res);  break;
            case "/approve": approveReview(req, res); break;
            case "/reject":  rejectReview(req, res);  break;
            default: res.sendRedirect(req.getContextPath() + "/movies");
        }
    }

    // ── Add Review ─────────────────────────────────────────────────────────
    private void addReview(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession();
        String userId   = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        String movieId    = req.getParameter("movieId");
        String movieTitle = req.getParameter("movieTitle");
        String ratingStr  = req.getParameter("rating");
        String comment    = trim(req.getParameter("comment"));

        if (movieId == null || ratingStr == null || comment.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/movies/detail/" + movieId + "?error=reviewinvalid");
            return;
        }

        int rating;
        try { rating = Integer.parseInt(ratingStr); }
        catch (NumberFormatException e) { rating = 5; }
        rating = Math.max(1, Math.min(5, rating));

        // Determine review type: VERIFIED if user has a confirmed booking for this movie in MySQL
        boolean hasBooked = BookingDAO.userHasBookedMovie(userId, movieId);
        Review review = hasBooked
            ? new VerifiedReview(IdGenerator.generate("REV"), userId, username, movieId, movieTitle, rating, comment, now(), "APPROVED")
            : new PublicReview(  IdGenerator.generate("REV"), userId, username, movieId, movieTitle, rating, comment, now(), "PENDING");

        ReviewDAO.insert(review);

        res.sendRedirect(req.getContextPath() + "/movies/detail/" + movieId + "?msg=reviewadded");
    }

    // ── Edit Review ────────────────────────────────────────────────────────
    private void editReview(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String reviewId  = req.getParameter("reviewId");
        String movieId   = req.getParameter("movieId");
        String ratingStr = req.getParameter("rating");
        String comment   = trim(req.getParameter("comment"));
        String userId    = (String) req.getSession().getAttribute("userId");

        Review r = ReviewDAO.findById(reviewId);
        if (r == null || !r.getUserId().equals(userId)) {
            res.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        int rating;
        try { rating = Integer.parseInt(ratingStr); }
        catch (NumberFormatException e) { rating = r.getRating(); }

        r.setRating(Math.max(1, Math.min(5, rating)));
        r.setComment(comment);
        ReviewDAO.updateStatus(reviewId, r.getStatus());

        res.sendRedirect(req.getContextPath() + "/movies/detail/" + movieId + "?msg=saved");
    }

    // ── Delete Review ──────────────────────────────────────────────────────
    private void deleteReview(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String reviewId = req.getParameter("reviewId");
        String movieId  = req.getParameter("movieId");
        String userId   = (String) req.getSession().getAttribute("userId");
        String role     = (String) req.getSession().getAttribute("role");

        Review r = ReviewDAO.findById(reviewId);
        if (r != null && (r.getUserId().equals(userId) || "ADMIN".equals(role))) {
            ReviewDAO.delete(reviewId);
        }

        if ("ADMIN".equals(role)) {
            res.sendRedirect(req.getContextPath() + "/admin/manage-reviews?msg=deleted");
        } else {
            res.sendRedirect(req.getContextPath() + "/movies/detail/" + movieId + "?msg=deleted");
        }
    }

    // ── Admin: Approve Review ──────────────────────────────────────────────
    private void approveReview(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;
        String reviewId = req.getParameter("reviewId");
        ReviewDAO.updateStatus(reviewId, "APPROVED");
        res.sendRedirect(req.getContextPath() + "/admin/manage-reviews?msg=saved");
    }

    // ── Admin: Reject Review ───────────────────────────────────────────────
    private void rejectReview(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;
        String reviewId = req.getParameter("reviewId");
        ReviewDAO.updateStatus(reviewId, "REJECTED");

        /// update 103
        res.sendRedirect(req.getContextPath() + "/admin/manage-reviews?msg=saved");
    }

    private void requireLogin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null)
            res.sendRedirect(req.getContextPath() + "/auth/login");
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role")))
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
    /// update 102
    private String now() { return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")); }


}