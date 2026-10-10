package com.jmovie.model;

/**
 * Admin user with elevated privileges.
 * Demonstrates OOP Concept: INHERITANCE
 * - Inherits all fields and methods from User
 * - Provides concrete implementation of abstract methods (Polymorphism)
 */
public class AdminUser extends User {

    public AdminUser(String id, String username, String password,
                     String email, String phone, String createdAt) {
        super(id, username, password, email, phone, createdAt);
    }

    @Override
    public String getRole() {
        return "ADMIN";
    }

    @Override
    public String getDashboardUrl() {
        return "/admin/dashboard";
    }

    @Override
    public String displayInfo() {
        return "[ADMIN] " + getUsername() + " | " + getEmail();
    }
}
