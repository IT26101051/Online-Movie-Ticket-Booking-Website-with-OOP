package com.jmovie.servlet;

import com.jmovie.db.BookingDAO;
import com.jmovie.db.MovieDAO;
import com.jmovie.db.ShowtimeDAO;
import com.jmovie.model.*;
import com.jmovie.util.IdGenerator;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Handles ticket booking via MySQL database: list my bookings, book seats, cancel booking.
 * Routes: GET /booking (my bookings), GET /booking/new?showtimeId=xxx, POST /booking/create|cancel
 */
@WebServlet(name = "BookingServlet", urlPatterns = {"/booking", "/booking/*"})
public class BookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireLogin(req, res);
        if (res.isCommitted()) return;

        String path = req.getPathInfo();
        if ("/new".equals(path)) {
            showBookingPage(req, res);
        } else {
            listMyBookings(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        requireLogin(req, res);
        if (res.isCommitted()) return;
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo();
        if ("/cancel".equals(path)) {
            cancelBooking(req, res);
        } else {
            createBooking(req, res);
        }
    }

    // ── My Bookings ────────────────────────────────────────────────────────
    private void listMyBookings(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String userId = (String) req.getSession().getAttribute("userId");
        List<Booking> bookings = BookingDAO.findByUserId(userId);
        req.setAttribute("bookings", bookings);
        req.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(req, res);
    }

    // ── Booking/Seat Selection Page ────────────────────────────────────────
    private void showBookingPage(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String showtimeId = req.getParameter("showtimeId");
        if (showtimeId == null) { res.sendRedirect(req.getContextPath() + "/movies"); return; }

        Showtime showtime = ShowtimeDAO.findById(showtimeId);
        if (showtime == null) { res.sendRedirect(req.getContextPath() + "/movies"); return; }

        Movie movie = MovieDAO.findById(showtime.getMovieId());

        req.setAttribute("showtime", showtime);
        req.setAttribute("movie", movie);
        req.getRequestDispatcher("/WEB-INF/views/book-ticket.jsp").forward(req, res);
    }

    // ── Create Booking ─────────────────────────────────────────────────────
    private void createBooking(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession();
        String userId   = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        String showtimeId    = req.getParameter("showtimeId");
        String selectedSeats = req.getParameter("selectedSeats"); // "A1,A2,B3"

        if (showtimeId == null || selectedSeats == null || selectedSeats.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/booking/new?showtimeId=" + showtimeId + "&error=noseats");
            return;
        }

        // Load and validate showtime
        Showtime showtime = ShowtimeDAO.findById(showtimeId);
        if (showtime == null) { res.sendRedirect(req.getContextPath() + "/movies"); return; }

        // Validate requested seats not already booked
        String[] requestedSeats = selectedSeats.split(",");
        List<String> alreadyBooked = new ArrayList<>(
            Arrays.asList(showtime.getBookedSeats().split(","))
        );
        for (String seat : requestedSeats) {
            seat = seat.trim();
            if (!seat.isEmpty() && alreadyBooked.contains(seat)) {
                req.setAttribute("error", "Seat " + seat + " was just taken. Please choose again.");
                showBookingPage(req, res);
                return;
            }
        }

        // Calculate total amount using Seat subclasses (OOP Polymorphism demo)
        String[] vipRows = {"A", "B"};
        double total = 0;
        int quantity = 0;
        for (String seatId : requestedSeats) {
            seatId = seatId.trim();
            if (seatId.isEmpty()) continue;
            String rowLabel = String.valueOf(seatId.charAt(0));
            boolean isVip = Arrays.asList(vipRows).contains(rowLabel);
            Seat seat = isVip ? new VIPSeat(seatId, false) : new RegularSeat(seatId, false);
            total += seat.getPrice(showtime.getPrice());
            quantity++;
        }

        if (quantity == 0) {
            res.sendRedirect(req.getContextPath() + "/booking/new?showtimeId=" + showtimeId + "&error=noseats");
            return;
        }

        // Update showtime booked seats in MySQL
        String newBooked = showtime.getBookedSeats().isEmpty()
                ? selectedSeats
                : showtime.getBookedSeats() + "," + selectedSeats;
        showtime.setBookedSeats(newBooked);
        showtime.setAvailableSeats(showtime.getAvailableSeats() - quantity);

        ShowtimeDAO.update(showtime);

        // Create booking record in MySQL
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String bookingId = IdGenerator.generate("BKG");
        Booking booking = new Booking(
            bookingId, userId, username, showtimeId,
            showtime.getMovieId(), showtime.getMovieTitle(),
            selectedSeats.trim(), quantity,
            total, "CONFIRMED", now,
            showtime.getDate(), showtime.getTime(), showtime.getTheatreHall()
        );

        BookingDAO.insert(booking);

        res.sendRedirect(req.getContextPath() + "/booking?msg=booked&id=" + bookingId);
    }

    // ── Cancel Booking ─────────────────────────────────────────────────────
    private void cancelBooking(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        String bookingId = req.getParameter("bookingId");
        String userId    = (String) req.getSession().getAttribute("userId");

        Booking booking = BookingDAO.findById(bookingId);
        if (booking == null || !booking.getUserId().equals(userId)) {
            res.sendRedirect(req.getContextPath() + "/booking");
            return;
        }

        // Restore seats in showtime
        Showtime st = ShowtimeDAO.findById(booking.getShowtimeId());
        if (st != null) {
            List<String> booked = new ArrayList<>(Arrays.asList(st.getBookedSeats().split(",")));
            booked.removeAll(Arrays.asList(booking.getSeats().split(",")));
            st.setBookedSeats(String.join(",", booked));
            st.setAvailableSeats(st.getAvailableSeats() + booking.getQuantity());

            ShowtimeDAO.update(st);
        }

        // Mark booking as cancelled in MySQL
        BookingDAO.updateStatus(bookingId, "CANCELLED");

        res.sendRedirect(req.getContextPath() + "/booking?msg=cancelled");
    }

    // ── Auth Guard ─────────────────────────────────────────────────────────
    private void requireLogin(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/auth/login?error=unauthorized");
        }
    }
}
