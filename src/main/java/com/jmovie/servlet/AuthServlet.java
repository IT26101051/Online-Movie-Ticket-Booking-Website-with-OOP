
// USER REGISTRATION-THARAKA


package com.jmovie.servlet;

import com.jmovie.db.UserDAO;
import com.jmovie.model.RegularUser;
import com.jmovie.model.User;
import com.jmovie.util.IdGenerator;
import com.jmovie.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Handles user authentication via MySQL database: login, logout, registration.
 * Routes: /auth/login, /auth/logout, /auth/register
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth", "/auth/*"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/login";

        switch (path) {
            case "/logout":
                HttpSession s = req.getSession(false);
                if (s != null) s.invalidate();
                res.sendRedirect(req.getContextPath() + "/auth/login?msg=loggedout");
                break;
            case "/register":
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
                break;
            default:
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/login";
        req.setCharacterEncoding("UTF-8");

        if ("/register".equals(path)) {
            handleRegister(req, res);
        } else {
            handleLogin(req, res);
        }
    }

    // ── Login ──────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");

        if (username.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            return;
        }

        User found = UserDAO.findByUsername(username);

        if (found == null || !PasswordUtil.verify(password, found.getPassword())) {
            req.setAttribute("error", "Invalid username or password.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, res);
            return;
        }

        // Create session
        HttpSession session = req.getSession(true);
        session.setAttribute("userId",   found.getId());
        session.setAttribute("username", found.getUsername());
        session.setAttribute("role",     found.getRole());
        session.setMaxInactiveInterval(30 * 60);

        // Redirect based on role (Polymorphism: getDashboardUrl())
        res.sendRedirect(req.getContextPath() + found.getDashboardUrl());
    }

    // ── Register ───────────────────────────────────────────────────────────
    private void handleRegister(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");
        String email    = trim(req.getParameter("email"));
        String phone    = trim(req.getParameter("phone"));

        // Validation
        if (username.isEmpty() || password == null || password.isEmpty() || email.isEmpty()) {
            req.setAttribute("error", "Username, password, and email are required.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            return;
        }
        if (password.length() < 6) {
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            return;
        }
        if (!email.contains("@")) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            return;
        }
        if (UserDAO.findByUsername(username) != null) {
            req.setAttribute("error", "Username '" + username + "' is already taken.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, res);
            return;
        }

        // Create new regular user
        String id = IdGenerator.generate("USR");
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        RegularUser user = new RegularUser(id, username, PasswordUtil.hash(password), email, phone, now);

        UserDAO.insert(user);

        res.sendRedirect(req.getContextPath() + "/auth/login?msg=registered");
    }

    private String trim(String s) { return s == null ? "" : s.trim(); }
}
