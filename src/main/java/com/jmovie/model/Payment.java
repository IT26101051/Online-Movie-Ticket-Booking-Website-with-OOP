//////// PAYMENT - SATHSAARA






package com.jmovie.model;

/**
 * Payment model representing the financial transaction for a booking.
 * Demonstrates OOP Concept: ENCAPSULATION
 */
public class Payment {

    private String paymentId;
    private String bookingId;
    private double amount;
    private String paymentMethod;     // CARD | DIGITAL_WALLET
    private String cardNumberMasked;  // e.g. "•••• •••• •••• 4242"
    private String cardHolder;
    private String transactionId;     // e.g. "TXN-20261028-7B4D1"
    private String status;            // SUCCESS | FAILED
    private String paidAt;            // Timestamp

    public Payment(String paymentId, String bookingId, double amount,
                   String paymentMethod, String cardNumberMasked,
                   String cardHolder, String transactionId,
                   String status, String paidAt) {
        this.paymentId        = paymentId;
        this.bookingId        = bookingId;
        this.amount           = amount;
        this.paymentMethod    = paymentMethod;
        this.cardNumberMasked = cardNumberMasked;
        this.cardHolder       = cardHolder;
        this.transactionId    = transactionId;
        this.status           = status;
        this.paidAt           = paidAt;
    }

    // Getters
    public String getPaymentId()        { return paymentId; }
    public String getBookingId()        { return bookingId; }
    public double getAmount()           { return amount; }
    public String getPaymentMethod()    { return paymentMethod; }
    public String getCardNumberMasked() { return cardNumberMasked; }
    public String getCardHolder()       { return cardHolder; }
    public String getTransactionId()    { return transactionId; }
    public String getStatus()           { return status; }
    public String getPaidAt()           { return paidAt; }

    // Setters
    public void setPaymentId(String paymentId)               { this.paymentId = paymentId; }
    public void setBookingId(String bookingId)               { this.bookingId = bookingId; }
    public void setAmount(double amount)                     { this.amount = amount; }
    public void setPaymentMethod(String paymentMethod)       { this.paymentMethod = paymentMethod; }
    public void setCardNumberMasked(String cardNumberMasked) { this.cardNumberMasked = cardNumberMasked; }
    public void setCardHolder(String cardHolder)             { this.cardHolder = cardHolder; }
    public void setTransactionId(String transactionId)       { this.transactionId = transactionId; }
    public void setStatus(String status)                     { this.status = status; }
    public void setPaidAt(String paidAt)                     { this.paidAt = paidAt; }

    /** Helper to mask 16-digit card number into "•••• •••• •••• 1234" */
    public static String maskCardNumber(String rawNumber) {
        if (rawNumber == null || rawNumber.length() < 4) return "•••• •••• •••• 4242";
        String clean = rawNumber.replaceAll("\\s+", "");
        if (clean.length() <= 4) return "•••• " + clean;
        String last4 = clean.substring(clean.length() - 4);
        return "•••• •••• •••• " + last4;
    }
}