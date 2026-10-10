package com.jmovie.model;

/**
 * Standard cinema seat.
 * Demonstrates OOP Concept: INHERITANCE
 * - Extends abstract Seat class
 * - Price = base price (no premium)
 */
public class RegularSeat extends Seat {

    public RegularSeat(String seatNumber, boolean isBooked) {
        super(seatNumber, isBooked);
    }

    @Override
    public double getPrice(double basePrice) {
        return basePrice; // No multiplier for regular seats
    }

    @Override
    public String getSeatType() {
        return "REGULAR";
    }

    @Override
    public String displaySeat() {
        return getSeatNumber() + " [Regular]" + (isBooked() ? " - BOOKED" : " - Available");
    }
}
