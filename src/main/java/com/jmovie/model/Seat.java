package com.jmovie.model;

/**
 * Abstract Seat class.
 * Demonstrates OOP Concept: ABSTRACTION & POLYMORPHISM
 * - Abstract class cannot be instantiated directly
 * - Subclasses (RegularSeat, VIPSeat) provide different price calculations
 */
public abstract class Seat {

    private String  seatNumber;
    private boolean isBooked;

    public Seat(String seatNumber, boolean isBooked) {
        this.seatNumber = seatNumber;
        this.isBooked   = isBooked;
    }

    public String  getSeatNumber() { return seatNumber; }
    public boolean isBooked()      { return isBooked; }
    public void    setBooked(boolean booked) { this.isBooked = booked; }

    /** Each seat type calculates its price differently (Polymorphism) */
    public abstract double getPrice(double basePrice);

    /** Each seat type identifies itself (Polymorphism) */
    public abstract String getSeatType();

    /** Each seat type displays info differently (Polymorphism) */
    public abstract String displaySeat();
}
