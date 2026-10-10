package com.jmovie.model;

/**
 * A public review submitted by any registered user.
 * Demonstrates OOP Concept: INHERITANCE
 */
public class PublicReview extends Review {

    public PublicReview(String id, String userId, String username, String movieId,
                        String movieTitle, int rating, String comment,
                        String createdAt, String status) {
        super(id, userId, username, movieId, movieTitle, rating, comment, createdAt, status);
    }

    @Override
    public String getReviewType() {
        return "PUBLIC";
    }

    @Override
    public String getDisplayBadge() {
        return "Public";
    }
}
