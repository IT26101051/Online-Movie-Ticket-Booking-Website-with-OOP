package com.jmovie.model;

/**
 * Regular customer user.
 * Demonstrates OOP Concept: INHERITANCE & POLYMORPHISM
 * - Inherits from User, overrides abstract methods differently from AdminUser
 */
public class RegularUser extends User {

    public RegularUser(String id, String username, String password,
                       String email, String phone, String createdAt) {
        super(id, username, password, email, phone, createdAt);
    }

    @Override
    public String getRole() {
        return "USER";
    }

    @Override
    public String getDashboardUrl() {
        return "/movies";
    }

    @Override
    public String displayInfo() {
        return "[USER] " + getUsername() + " | " + getEmail();
    }
}
