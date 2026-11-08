/////// SHOW TIME - KANCHANA

//IMPORTS & SERVLET SETUP
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

//DISPLAY SHOWTIMES (doGet)
@Override
protected void doGet(HttpServletRequest req, HttpServletResponse res)
        throws ServletException, IOException {

    requireAdmin(req, res);
    if (res.isCommitted()) return;

    List<Showtime> showtimes = ShowtimeDAO.findAll();
    List<Movie> movies = MovieDAO.findAll();

    req.setAttribute("showtimes", showtimes);
    req.setAttribute("movies", movies);

    req.getRequestDispatcher(
            "/WEB-INF/views/admin/manage-showtimes.jsp"
    ).forward(req, res);
}