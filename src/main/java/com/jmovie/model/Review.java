package com.jmovie.model;

/**
 * Abstract Review base class.
 * Demonstrates OOP Concept: ABSTRACTION & POLYMORPHISM
 * - Abstract methods getReviewType() and getDisplayBadge() differ per subclass
 * Format: id|userId|username|movieId|movieTitle|rating|comment|createdAt|status|reviewType
 */
public abstract class Review {

    private String id;
    private String userId;
    private String username;
    private String movieId;
    private String movieTitle;
    private int    rating;    // 1 to 5
    private String comment;
    private String createdAt;
    private String status;    // APPROVED | PENDING | REJECTED

    public Review(String id, String userId, String username, String movieId,
                  String movieTitle, int rating, String comment,
                  String createdAt, String status) {
        this.id         = id;
        this.userId     = userId;
        this.username   = username;
        this.movieId    = movieId;
        this.movieTitle = movieTitle;
        this.rating     = rating;
        this.comment    = comment;
        this.createdAt  = createdAt;
        this.status     = status;
    }

    // Getters
    public String getId()         { return id; }
    public String getUserId()     { return userId; }
    public String getUsername()   { return username; }
    public String getMovieId()    { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public int    getRating()     { return rating; }
    public String getComment()    { return comment; }
    public String getCreatedAt()  { return createdAt; }
    public String getStatus()     { return status; }

    // Setters
    public void setId(String id)               { this.id = id; }
    public void setUserId(String userId)       { this.userId = userId; }
    public void setUsername(String username)   { this.username = username; }
    public void setMovieId(String movieId)     { this.movieId = movieId; }
    public void setMovieTitle(String t)        { this.movieTitle = t; }
    public void setRating(int rating)          { this.rating = rating; }
    public void setComment(String comment)     { this.comment = comment; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public void setStatus(String status)       { this.status = status; }

    /** Returns type identifier (Polymorphism) */
    public abstract String getReviewType();

    /** Returns display badge HTML/text (Polymorphism) */
    public abstract String getDisplayBadge();

    /** Generate star string for display, e.g. "★★★★☆" */
    public String getStars() {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            sb.append(i <= rating ? "★" : "☆");
        }
        return sb.toString();
    }

    /** Serialize to file format */
    public String toFileString() {
        return id + "|" + userId + "|" + username + "|" + movieId + "|" +
               esc(movieTitle) + "|" + rating + "|" + esc(comment) + "|" +
               createdAt + "|" + status + "|" + getReviewType();
    }

    /** Deserialize from file string - returns PublicReview or VerifiedReview */
    public static Review fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] p = line.split("\\|", -1);
        if (p.length < 10) return null;
        try {
            String type = p[9];
            if ("VERIFIED".equals(type)) {
                return new VerifiedReview(p[0], p[1], p[2], p[3], unesc(p[4]),
                        Integer.parseInt(p[5]), unesc(p[6]), p[7], p[8]);
            } else {
                return new PublicReview(p[0], p[1], p[2], p[3], unesc(p[4]),
                        Integer.parseInt(p[5]), unesc(p[6]), p[7], p[8]);
            }
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String esc(String s)   { return s == null ? "" : s.replace("|", "~PIPE~"); }
    private static String unesc(String s) { return s == null ? "" : s.replace("~PIPE~", "|"); }
}
