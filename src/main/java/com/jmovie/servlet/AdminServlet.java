package com.jmovie.servlet;

import com.jmovie.db.*;
import com.jmovie.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Admin panel via MySQL database: dashboard, movie/user/showtime/review management pages.
 * Routes: GET /admin/dashboard|manage-movies|manage-users|manage-showtimes|manage-reviews
 * Also handles: POST /admin/users/delete|update
 */
@WebServlet(name = "AdminServlet", urlPatterns = {"/admin", "/admin/*"})
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;

        String path = req.getPathInfo();
        if (path == null) path = "/dashboard";

        switch (path) {
            case "/dashboard":        showDashboard(req, res);       break;
            case "/manage-movies":    showManageMovies(req, res);    break;
            case "/manage-users":     showManageUsers(req, res);     break;
            case "/manage-showtimes": showManageShowtimes(req, res); break;
            case "/manage-reviews":   showManageReviews(req, res);   break;
            default: res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo();
        if ("/users/delete".equals(path)) {
            deleteUser(req, res);
        } else if ("/users/update".equals(path)) {
            updateUser(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ── Dashboard ──────────────────────────────────────────────────────────
    private void showDashboard(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setAttribute("userCount",     UserDAO.count());
        req.setAttribute("movieCount",    (long) MovieDAO.findAll().size());
        req.setAttribute("bookingCount",  BookingDAO.count());
        req.setAttribute("showtimeCount", ShowtimeDAO.count());

        List<Booking> bookings = BookingDAO.findAll();
        req.setAttribute("recentBookings", bookings.subList(0, Math.min(5, bookings.size())));

        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, res);
    }

    // ── Manage Movies ──────────────────────────────────────────────────────
    private void showManageMovies(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        List<Movie> movies = MovieDAO.findAll();
        req.setAttribute("movies", movies);
        req.getRequestDispatcher("/WEB-INF/views/admin/manage-movies.jsp").forward(req, res);
    }

    // ── Manage Users ───────────────────────────────────────────────────────
    private void showManageUsers(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        List<User> users = UserDAO.findAll();
        req.setAttribute("users", users);
        req.getRequestDispatcher("/WEB-INF/views/admin/manage-users.jsp").forward(req, res);
    }

    // ── Manage Showtimes ───────────────────────────────────────────────────
    private void showManageShowtimes(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        List<Showtime> showtimes = ShowtimeDAO.findAll();
        List<Movie> movies       = MovieDAO.findAll();

        req.setAttribute("showtimes", showtimes);
        req.setAttribute("movies", movies);
        req.getRequestDispatcher("/WEB-INF/views/admin/manage-showtimes.jsp").forward(req, res);
    }

    // ── Manage Reviews ─────────────────────────────────────────────────────
    private void showManageReviews(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        List<Review> reviews = ReviewDAO.findAll();
        req.setAttribute("reviews", reviews);
        req.getRequestDispatcher("/WEB-INF/views/admin/manage-reviews.jsp").forward(req, res);
    }

    // ── Admin: Delete User ─────────────────────────────────────────────────
    private void deleteUser(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String adminId = (String) req.getSession().getAttribute("userId");
        if (!id.equals(adminId)) { // Can't delete yourself
            UserDAO.delete(id);
        }
        res.sendRedirect(req.getContextPath() + "/admin/manage-users?msg=deleted");
    }

    // ── Admin: Update User ─────────────────────────────────────────────────
    private void updateUser(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String id    = req.getParameter("id");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");

        User u = UserDAO.findById(id);
        if (u != null) {
            u.setEmail(email != null ? email.trim() : u.getEmail());
            u.setPhone(phone != null ? phone.trim() : u.getPhone());
            UserDAO.update(u);
        }
        res.sendRedirect(req.getContextPath() + "/admin/manage-users?msg=saved");
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role")))
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
    }
}



/////////