package com.jmovie.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Password hashing utility using SHA-256.
 * Passwords are never stored in plain text.
 */
public class PasswordUtil {

    /** Hash a plain-text password using SHA-256 */
    public static String hash(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) hex.append('0');
                hex.append(h);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // Fallback (should never happen with SHA-256)
            return password;
        }
    }

    /** Verify a plain-text password against a stored hash */
    public static boolean verify(String plainPassword, String storedHash) {
        return hash(plainPassword).equals(storedHash);
    }
}
