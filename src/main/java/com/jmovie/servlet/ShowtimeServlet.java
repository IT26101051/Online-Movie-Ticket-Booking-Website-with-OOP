package com.jmovie.servlet;

import com.jmovie.db.MovieDAO;
import com.jmovie.db.ShowtimeDAO;
import com.jmovie.model.Movie;
import com.jmovie.model.Showtime;
import com.jmovie.util.IdGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * Handles Showtime CRUD operations via MySQL database (Admin only).
 * Routes: POST /showtimes/add|edit|delete
 */
@WebServlet(name = "ShowtimeServlet", urlPatterns = {"/showtimes", "/showtimes/*"})
public class ShowtimeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;

        List<Showtime> showtimes = ShowtimeDAO.findAll();
        List<Movie> movies       = MovieDAO.findAll();

        req.setAttribute("showtimes", showtimes);
        req.setAttribute("movies", movies);
        req.getRequestDispatcher("/WEB-INF/views/admin/manage-showtimes.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireAdmin(req, res);
        if (res.isCommitted()) return;
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo();
        if (path == null) path = "/";
        switch (path) {
            case "/add":    addShowtime(req, res);    break;
            case "/edit":   editShowtime(req, res);   break;
            case "/delete": deleteShowtime(req, res); break;
            default: res.sendRedirect(req.getContextPath() + "/showtimes");
        }
    }

    private void addShowtime(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            Showtime s = buildFromRequest(IdGenerator.generate("SHW"), req);
            ShowtimeDAO.insert(s);
            res.sendRedirect(req.getContextPath() + "/showtimes?msg=saved");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/showtimes?error=invalid");
        }
    }

    private void editShowtime(HttpServletRequest req, HttpServletResponse res) throws IOException {
        try {
            String id = req.getParameter("id");
            Showtime s = buildFromRequest(id, req);
            ShowtimeDAO.update(s);
            res.sendRedirect(req.getContextPath() + "/showtimes?msg=saved");
        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/showtimes?error=invalid");
        }
    }

    private void deleteShowtime(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        ShowtimeDAO.delete(id);
        res.sendRedirect(req.getContextPath() + "/showtimes?msg=deleted");
    }

    private Showtime buildFromRequest(String id, HttpServletRequest req) {
        String movieId    = req.getParameter("movieId");
        String movieTitle = req.getParameter("movieTitle");
        String hall       = req.getParameter("theatreHall");
        String date       = req.getParameter("date");
        String time       = req.getParameter("time");
        int    total      = Integer.parseInt(req.getParameter("totalSeats"));
        double price      = Double.parseDouble(req.getParameter("price"));

        // Get movie title if not provided
        if (movieTitle == null || movieTitle.isEmpty()) {
            Movie m = MovieDAO.findById(movieId);
            movieTitle = m != null ? m.getTitle() : "Unknown";
        }
        return new Showtime(id, movieId, movieTitle, hall, date, time, total, total, price, "");
    }

    private void requireAdmin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role")))
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
    }
}
