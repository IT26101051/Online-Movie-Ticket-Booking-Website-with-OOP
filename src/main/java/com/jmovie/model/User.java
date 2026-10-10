package com.jmovie.model;

/**
 * Abstract base class for all users in the system.
 * Demonstrates OOP Concept: ABSTRACTION & ENCAPSULATION
 * - Private fields with public getters/setters (Encapsulation)
 * - Abstract methods force subclasses to provide implementation (Abstraction)
 */
public abstract class User {

    // Encapsulated fields - private, access only through getters/setters
    private String id;
    private String username;
    private String password;
    private String email;
    private String phone;
    private String createdAt;

    public User(String id, String username, String password, String email, String phone, String createdAt) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.phone = phone;
        this.createdAt = createdAt;
    }

    // Getters (Encapsulation)
    public String getId()        { return id; }
    public String getUsername()  { return username; }
    public String getPassword()  { return password; }
    public String getEmail()     { return email; }
    public String getPhone()     { return phone; }
    public String getCreatedAt() { return createdAt; }

    // Setters (Encapsulation)
    public void setId(String id)               { this.id = id; }
    public void setUsername(String username)   { this.username = username; }
    public void setPassword(String password)   { this.password = password; }
    public void setEmail(String email)         { this.email = email; }
    public void setPhone(String phone)         { this.phone = phone; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    // Abstract methods - must be implemented by subclasses (Polymorphism)
    public abstract String getRole();
    public abstract String getDashboardUrl();
    public abstract String displayInfo();

    /**
     * Serialize user to pipe-delimited file format.
     * Format: id|username|password|email|phone|role|createdAt
     */
    public String toFileString() {
        return id + "|" + username + "|" + password + "|" +
               email + "|" + phone + "|" + getRole() + "|" + createdAt;
    }

    /**
     * Factory method: deserialize a User from file string.
     * Returns AdminUser or RegularUser based on role field.
     */
    public static User fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] parts = line.split("\\|", -1);
        if (parts.length < 7) return null;
        String role = parts[5];
        if ("ADMIN".equals(role)) {
            return new AdminUser(parts[0], parts[1], parts[2], parts[3], parts[4], parts[6]);
        } else {
            return new RegularUser(parts[0], parts[1], parts[2], parts[3], parts[4], parts[6]);
        }
    }
}
