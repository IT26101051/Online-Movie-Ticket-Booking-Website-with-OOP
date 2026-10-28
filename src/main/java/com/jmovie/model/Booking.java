package com.jmovie.model;

/**
 * Booking entity - represents a ticket purchase transaction.
 * Demonstrates OOP Concept: ENCAPSULATION
 * Format: id|userId|username|showtimeId|movieId|movieTitle|seats|quantity|totalAmount|status|bookingDate|showDate|showTime
 */
public class Booking {

    private String id;
    private String userId;
    private String username;
    private String showtimeId;
    private String movieId;
    private String movieTitle;
    private String seats;        // comma-separated seat IDs e.g. "A1,A2"
    private int    quantity;
    private double totalAmount;
    private String status;       // CONFIRMED | CANCELLED
    private String bookingDate;
    private String showDate;
    private String showTime;
    private String theatreHall;
    private String paymentMethod; // e.g. "VISA •••• 4242", "MASTERCARD", "DIGITAL_WALLET"
    private String transactionId; // e.g. "TXN-20261028-A4B92"

    public Booking(String id, String userId, String username, String showtimeId,
                   String movieId, String movieTitle, String seats, int quantity,
                   double totalAmount, String status, String bookingDate,
                   String showDate, String showTime, String theatreHall) {
        this(id, userId, username, showtimeId, movieId, movieTitle, seats, quantity,
             totalAmount, status, bookingDate, showDate, showTime, theatreHall, "CARD", "");
    }

    public Booking(String id, String userId, String username, String showtimeId,
                   String movieId, String movieTitle, String seats, int quantity,
                   double totalAmount, String status, String bookingDate,
                   String showDate, String showTime, String theatreHall,
                   String paymentMethod, String transactionId) {
        this.id            = id;
        this.userId        = userId;
        this.username      = username;
        this.showtimeId    = showtimeId;
        this.movieId       = movieId;
        this.movieTitle    = movieTitle;
        this.seats         = seats;
        this.quantity      = quantity;
        this.totalAmount   = totalAmount;
        this.status        = status;
        this.bookingDate   = bookingDate;
        this.showDate      = showDate;
        this.showTime      = showTime;
        this.theatreHall   = theatreHall == null ? "" : theatreHall;
        this.paymentMethod = paymentMethod == null || paymentMethod.isEmpty() ? "CARD" : paymentMethod;
        this.transactionId = transactionId == null ? "" : transactionId;
    }

    // Getters
    public String getId()            { return id; }
    public String getUserId()        { return userId; }
    public String getUsername()      { return username; }
    public String getShowtimeId()    { return showtimeId; }
    public String getMovieId()       { return movieId; }
    public String getMovieTitle()    { return movieTitle; }
    public String getSeats()         { return seats; }
    public int    getQuantity()      { return quantity; }
    public double getTotalAmount()   { return totalAmount; }
    public String getStatus()        { return status; }
    public String getBookingDate()   { return bookingDate; }
    public String getShowDate()      { return showDate; }
    public String getShowTime()      { return showTime; }
    public String getTheatreHall()   { return theatreHall; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getTransactionId() { return transactionId; }

    // Setters
    public void setId(String id)                       { this.id = id; }
    public void setUserId(String userId)               { this.userId = userId; }
    public void setUsername(String username)           { this.username = username; }
    public void setShowtimeId(String showtimeId)       { this.showtimeId = showtimeId; }
    public void setMovieId(String movieId)             { this.movieId = movieId; }
    public void setMovieTitle(String movieTitle)       { this.movieTitle = movieTitle; }
    public void setSeats(String seats)                 { this.seats = seats; }
    public void setQuantity(int quantity)              { this.quantity = quantity; }
    public void setTotalAmount(double totalAmount)     { this.totalAmount = totalAmount; }
    public void setStatus(String status)               { this.status = status; }
    public void setBookingDate(String bookingDate)     { this.bookingDate = bookingDate; }
    public void setShowDate(String showDate)           { this.showDate = showDate; }
    public void setShowTime(String showTime)           { this.showTime = showTime; }
    public void setTheatreHall(String theatreHall)     { this.theatreHall = theatreHall; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    /** Serialize to file format */
    public String toFileString() {
        return id + "|" + userId + "|" + username + "|" + showtimeId + "|" + movieId + "|" +
               esc(movieTitle) + "|" + seats + "|" + quantity + "|" +
               String.format("%.2f", totalAmount) + "|" + status + "|" +
               bookingDate + "|" + showDate + "|" + showTime + "|" + esc(theatreHall) + "|" +
               esc(paymentMethod) + "|" + esc(transactionId);
    }

    /** Deserialize from file string */
    public static Booking fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] p = line.split("\\|", -1);
        if (p.length < 13) return null;
        try {
            String hall = p.length >= 14 ? unesc(p[13]) : "";
            String pMethod = p.length >= 15 ? unesc(p[14]) : "CARD";
            String txnId = p.length >= 16 ? unesc(p[15]) : "";
            return new Booking(p[0], p[1], p[2], p[3], p[4], unesc(p[5]),
                    p[6], Integer.parseInt(p[7]), Double.parseDouble(p[8]),
                    p[9], p[10], p[11], p[12], hall, pMethod, txnId);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String esc(String s)   { return s == null ? "" : s.replace("|", "~PIPE~"); }
    private static String unesc(String s) { return s == null ? "" : s.replace("~PIPE~", "|"); }
}
