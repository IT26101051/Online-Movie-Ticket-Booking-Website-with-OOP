package com.jmovie.model;

/**
 * A verified review - only users who actually booked the movie can post this.
 * Demonstrates OOP Concept: INHERITANCE & POLYMORPHISM
 * - Same interface as PublicReview but different badge display
 */
public class VerifiedReview extends Review {

    public VerifiedReview(String id, String userId, String username, String movieId,
                          String movieTitle, int rating, String comment,
                          String createdAt, String status) {
        super(id, userId, username, movieId, movieTitle, rating, comment, createdAt, status);
    }

    @Override
    public String getReviewType() {
        return "VERIFIED";
    }

    @Override
    public String getDisplayBadge() {
        return "✓ Verified Booking";
    }
}
