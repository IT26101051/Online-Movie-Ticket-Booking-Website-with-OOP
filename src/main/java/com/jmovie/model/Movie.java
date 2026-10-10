package com.jmovie.model;

/**
 * Movie entity class.
 * Demonstrates OOP Concept: ENCAPSULATION
 * - All fields are private
 * - Controlled access through public getters/setters
 */
public class Movie {

    private String id;
    private String title;
    private String genre;
    private String description;
    private int    duration;    // in minutes
    private double rating;      // 0.0 - 10.0
    private String posterUrl;
    private String releaseDate; // yyyy-MM-dd
    private String status;      // NOW_SHOWING | COMING_SOON | ENDED

    public Movie(String id, String title, String genre, String description,
                 int duration, double rating, String posterUrl,
                 String releaseDate, String status) {
        this.id          = id;
        this.title       = title;
        this.genre       = genre;
        this.description = description;
        this.duration    = duration;
        this.rating      = rating;
        this.posterUrl   = posterUrl;
        this.releaseDate = releaseDate;
        this.status      = status;
    }

    // Getters
    public String getId()          { return id; }
    public String getTitle()       { return title; }
    public String getGenre()       { return genre; }
    public String getDescription() { return description; }
    public int    getDuration()    { return duration; }
    public double getRating()      { return rating; }
    public String getPosterUrl()   { return posterUrl; }
    public String getReleaseDate() { return releaseDate; }
    public String getStatus()      { return status; }

    // Setters
    public void setId(String id)                   { this.id = id; }
    public void setTitle(String title)             { this.title = title; }
    public void setGenre(String genre)             { this.genre = genre; }
    public void setDescription(String description) { this.description = description; }
    public void setDuration(int duration)          { this.duration = duration; }
    public void setRating(double rating)           { this.rating = rating; }
    public void setPosterUrl(String posterUrl)     { this.posterUrl = posterUrl; }
    public void setReleaseDate(String releaseDate) { this.releaseDate = releaseDate; }
    public void setStatus(String status)           { this.status = status; }

    /** Returns duration as "2h 28m" format */
    public String getDurationFormatted() {
        int h = duration / 60;
        int m = duration % 60;
        return (h > 0 ? h + "h " : "") + m + "m";
    }

    /**
     * Serialize to pipe-delimited file format.
     * Pipes within description replaced with ~ to avoid parsing issues.
     * Format: id|title|genre|description|duration|rating|posterUrl|releaseDate|status
     */
    public String toFileString() {
        return id + "|" + escape(title) + "|" + genre + "|" + escape(description) + "|" +
               duration + "|" + rating + "|" + escape(posterUrl) + "|" + releaseDate + "|" + status;
    }

    /** Deserialize from pipe-delimited file string */
    public static Movie fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] p = line.split("\\|", -1);
        if (p.length < 9) return null;
        try {
            return new Movie(p[0], unescape(p[1]), p[2], unescape(p[3]),
                    Integer.parseInt(p[4]), Double.parseDouble(p[5]),
                    unescape(p[6]), p[7], p[8]);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String escape(String s)   { return s == null ? "" : s.replace("|", "~PIPE~"); }
    private static String unescape(String s) { return s == null ? "" : s.replace("~PIPE~", "|"); }
}
