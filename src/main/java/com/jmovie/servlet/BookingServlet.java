////// USHAN'S PART - BOOKING


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
import java.util.UUID;

/**
 * Handles ticket booking via MySQL database:
 * - Seat Selection & Booking (/booking/new)
 * - Simulated Payment Gateway (/booking/checkout, /booking/payment)
 * - Booking Confirmation & E-Ticket Receipt (/booking/success)
 * - My Bookings List & Cancellation (/booking, /booking/cancel)
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
        } else if ("/success".equals(path)) {
            showSuccessReceipt(req, res);
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
        } else if ("/checkout".equals(path)) {
            prepareCheckout(req, res);
        } else if ("/payment".equals(path)) {
            processPayment(req, res);
        } else {
            prepareCheckout(req, res);
        }
    }

    // ── 1. My Bookings ─────────────────────────────────────────────────────
    private void listMyBookings(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String userId = (String) req.getSession().getAttribute("userId");
        List<Booking> bookings = BookingDAO.findByUserId(userId);
        req.setAttribute("bookings", bookings);
        req.getRequestDispatcher("/WEB-INF/views/my-bookings.jsp").forward(req, res);
    }

    // ── 2. Booking / Seat Selection Page ───────────────────────────────────
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

    // ── 3. Prepare Checkout / Payment Step ─────────────────────────────────
    private void prepareCheckout(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String showtimeId    = req.getParameter("showtimeId");
        String selectedSeats = req.getParameter("selectedSeats"); // e.g. "A1,A2"

        if (showtimeId == null || selectedSeats == null || selectedSeats.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/booking/new?showtimeId=" + showtimeId + "&error=noseats");
            return;
        }

        Showtime showtime = ShowtimeDAO.findById(showtimeId);
        if (showtime == null) { res.sendRedirect(req.getContextPath() + "/movies"); return; }

        Movie movie = MovieDAO.findById(showtime.getMovieId());

        // Validate that requested seats aren't already booked
        String[] requestedSeats = selectedSeats.split(",");
        List<String> alreadyBooked = new ArrayList<>(
            Arrays.asList(showtime.getBookedSeats().split(","))
        );
        for (String seat : requestedSeats) {
            seat = seat.trim();
            if (!seat.isEmpty() && alreadyBooked.contains(seat)) {
                req.setAttribute("error", "Seat " + seat + " was just booked. Please pick another seat.");
                showBookingPage(req, res);
                return;
            }
        }

        // Calculate total amount using Seat subclasses (OOP Polymorphism)
        String[] vipRows = {"A", "B"};
        double total = 0;
        int quantity = 0;
        int vipCount = 0;
        int regularCount = 0;
        for (String seatId : requestedSeats) {
            seatId = seatId.trim();
            if (seatId.isEmpty()) continue;
            String rowLabel = String.valueOf(seatId.charAt(0));
            boolean isVip = Arrays.asList(vipRows).contains(rowLabel);
            Seat seat = isVip ? new VIPSeat(seatId, false) : new RegularSeat(seatId, false);
            total += seat.getPrice(showtime.getPrice());
            quantity++;
            if (isVip) vipCount++; else regularCount++;
        }

        if (quantity == 0) {
            res.sendRedirect(req.getContextPath() + "/booking/new?showtimeId=" + showtimeId + "&error=noseats");
            return;
        }

        req.setAttribute("showtime", showtime);
        req.setAttribute("movie", movie);
        req.setAttribute("selectedSeats", selectedSeats.trim());
        req.setAttribute("quantity", quantity);
        req.setAttribute("vipCount", vipCount);
        req.setAttribute("regularCount", regularCount);
        req.setAttribute("totalAmount", total);

        req.getRequestDispatcher("/WEB-INF/views/payment.jsp").forward(req, res);
    }

    // ── 4. Process Mock Payment Gateway ────────────────────────────────────
    private void processPayment(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        String userId   = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");

        String showtimeId    = req.getParameter("showtimeId");
        String selectedSeats = req.getParameter("selectedSeats");
        String paymentMethod = req.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) paymentMethod = "CARD";

        String cardHolder = req.getParameter("cardHolder");
        String cardNumber = req.getParameter("cardNumber");
        String expiry     = req.getParameter("expiry");
        String cvv        = req.getParameter("cvv");

        // Validate basic inputs
        if (showtimeId == null || selectedSeats == null || selectedSeats.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/movies");
            return;
        }

        Showtime showtime = ShowtimeDAO.findById(showtimeId);
        if (showtime == null) { res.sendRedirect(req.getContextPath() + "/movies"); return; }

        // Simulated Payment Verification Logic
        if ("CARD".equals(paymentMethod)) {
            String cleanCard = cardNumber != null ? cardNumber.replaceAll("[^0-9]", "") : "";
            String cleanCvv  = cvv != null ? cvv.replaceAll("[^0-9]", "") : "";
            if (cleanCard.length() != 16 || cleanCvv.length() < 3 || expiry == null || expiry.trim().isEmpty()) {
                req.setAttribute("paymentError", "Payment verification failed: Please enter a valid 16-digit card number and 3-digit CVV.");
                prepareCheckout(req, res);
                return;
            }
        }

        // Calculate totals
        String[] requestedSeats = selectedSeats.split(",");
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

        // Update showtime booked seats in MySQL
        String newBooked = showtime.getBookedSeats().isEmpty()
                ? selectedSeats
                : showtime.getBookedSeats() + "," + selectedSeats;
        showtime.setBookedSeats(newBooked);
        showtime.setAvailableSeats(showtime.getAvailableSeats() - quantity);
        ShowtimeDAO.update(showtime);

        // Generate Simulated Gateway Transaction ID
        String txnId = "TXN-" + (System.currentTimeMillis() % 10000000) + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
        String methodDisplay = "CARD".equals(paymentMethod)
                ? ("VISA " + Payment.maskCardNumber(cardNumber))
                : ("WALLET • " + (req.getParameter("walletPhone") != null ? req.getParameter("walletPhone") : "MOBILE"));

        // Create booking record with payment details in MySQL
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String bookingId = IdGenerator.generate("BKG");
        Booking booking = new Booking(
            bookingId, userId, username, showtimeId,
            showtime.getMovieId(), showtime.getMovieTitle(),
            selectedSeats.trim(), quantity,
            total, "CONFIRMED", now,
            showtime.getDate(), showtime.getTime(), showtime.getTheatreHall(),
            methodDisplay, txnId
        );

        BookingDAO.insert(booking);

        // Redirect to digital receipt / success page
        res.sendRedirect(req.getContextPath() + "/booking/success?id=" + bookingId);
    }

    // ── 5. Payment Success / Digital Receipt Page ──────────────────────────
    private void showSuccessReceipt(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String bookingId = req.getParameter("id");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/booking");
            return;
        }

        Booking booking = BookingDAO.findById(bookingId);
        String userId = (String) req.getSession().getAttribute("userId");
        if (booking == null || !booking.getUserId().equals(userId)) {
            res.sendRedirect(req.getContextPath() + "/booking");
            return;
        }

        Movie movie = MovieDAO.findById(booking.getMovieId());
        Showtime showtime = ShowtimeDAO.findById(booking.getShowtimeId());

        req.setAttribute("booking", booking);
        req.setAttribute("movie", movie);
        req.setAttribute("showtime", showtime);
        req.getRequestDispatcher("/WEB-INF/views/booking-success.jsp").forward(req, res);
    }

    // ── 6. Cancel Booking ──────────────────────────────────────────────────
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
