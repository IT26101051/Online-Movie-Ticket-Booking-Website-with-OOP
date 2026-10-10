package com.jmovie.model;

/**
 * Showtime entity - represents a scheduled screening of a movie.
 * Demonstrates OOP Concept: ENCAPSULATION
 * Format: id|movieId|movieTitle|theatreHall|date|time|totalSeats|availableSeats|price|bookedSeats
 */
public class Showtime {

    private String id;
    private String movieId;
    private String movieTitle;
    private String theatreHall;
    private String date;           // yyyy-MM-dd
    private String time;           // HH:mm
    private int    totalSeats;
    private int    availableSeats;
    private double price;
    private String bookedSeats;    // comma-separated seat IDs e.g. "A1,A2,B3"

    public Showtime(String id, String movieId, String movieTitle, String theatreHall,
                    String date, String time, int totalSeats, int availableSeats,
                    double price, String bookedSeats) {
        this.id             = id;
        this.movieId        = movieId;
        this.movieTitle     = movieTitle;
        this.theatreHall    = theatreHall;
        this.date           = date;
        this.time           = time;
        this.totalSeats     = totalSeats;
        this.availableSeats = availableSeats;
        this.price          = price;
        this.bookedSeats    = bookedSeats == null ? "" : bookedSeats;
    }

    // Getters
    public String getId()             { return id; }
    public String getMovieId()        { return movieId; }
    public String getMovieTitle()     { return movieTitle; }
    public String getTheatreHall()    { return theatreHall; }
    public String getDate()           { return date; }
    public String getTime()           { return time; }
    public int    getTotalSeats()     { return totalSeats; }
    public int    getAvailableSeats() { return availableSeats; }
    public double getPrice()          { return price; }
    public String getBookedSeats()    { return bookedSeats; }

    // Setters
    public void setId(String id)                         { this.id = id; }
    public void setMovieId(String movieId)               { this.movieId = movieId; }
    public void setMovieTitle(String movieTitle)         { this.movieTitle = movieTitle; }
    public void setTheatreHall(String theatreHall)       { this.theatreHall = theatreHall; }
    public void setDate(String date)                     { this.date = date; }
    public void setTime(String time)                     { this.time = time; }
    public void setTotalSeats(int totalSeats)            { this.totalSeats = totalSeats; }
    public void setAvailableSeats(int availableSeats)    { this.availableSeats = availableSeats; }
    public void setPrice(double price)                   { this.price = price; }
    public void setBookedSeats(String bookedSeats)       { this.bookedSeats = bookedSeats == null ? "" : bookedSeats; }

    public boolean isAvailable()     { return availableSeats > 0; }

    /** Serialize to file format */
    public String toFileString() {
        return id + "|" + movieId + "|" + esc(movieTitle) + "|" + theatreHall + "|" +
               date + "|" + time + "|" + totalSeats + "|" + availableSeats + "|" + price + "|" + bookedSeats;
    }

    /** Deserialize from file string */
    public static Showtime fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] p = line.split("\\|", -1);
        if (p.length < 9) return null;
        try {
            String booked = p.length >= 10 ? p[9] : "";
            return new Showtime(p[0], p[1], unesc(p[2]), p[3], p[4], p[5],
                    Integer.parseInt(p[6]), Integer.parseInt(p[7]), Double.parseDouble(p[8]), booked);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String esc(String s)   { return s == null ? "" : s.replace("|", "~PIPE~"); }
    private static String unesc(String s) { return s == null ? "" : s.replace("~PIPE~", "|"); }
}
