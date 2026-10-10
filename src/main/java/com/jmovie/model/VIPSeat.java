package com.jmovie.model;

/**
 * Premium VIP seat with recliner and extra legroom.
 * Demonstrates OOP Concept: INHERITANCE & POLYMORPHISM
 * - Extends Seat, applies 1.5x price multiplier
 * - Same interface as RegularSeat but different behavior
 */
public class VIPSeat extends Seat {

    private static final double VIP_MULTIPLIER = 1.5; // 50% premium

    public VIPSeat(String seatNumber, boolean isBooked) {
        super(seatNumber, isBooked);
    }

    @Override
    public double getPrice(double basePrice) {
        return basePrice * VIP_MULTIPLIER; // 50% premium for VIP
    }

    @Override
    public String getSeatType() {
        return "VIP";
    }

    @Override
    public String displaySeat() {
        return getSeatNumber() + " [VIP ★]" + (isBooked() ? " - BOOKED" : " - Available");
    }

    public static double getMultiplier() {
        return VIP_MULTIPLIER;
    }
}
