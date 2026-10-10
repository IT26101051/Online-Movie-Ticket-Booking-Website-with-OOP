<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — JMovie</title>
    <meta name="description" content="Sign in to your JMovie account to book movie tickets online.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="auth-logo">
            <span style="color:var(--plasma-lime);">▶</span> J<span style="color:var(--plasma-lime);">MOVIE</span>
        </div>
        <div class="auth-title">Welcome Back</div>
        <div class="auth-sub">Sign in to your account to reserve tickets and access bookings.</div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert--error"><%= error %></div>
        <% } %>

        <form method="post" action="<%= ctx %>/auth/login">
            <div class="form-group">
                <label class="form-label" for="username">Username</label>
                <input id="username" name="username" type="text" class="form-control"
                       placeholder="Enter your username" required autofocus>
            </div>
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input id="password" name="password" type="password" class="form-control"
                       placeholder="Enter your password" required>
            </div>
            <button type="submit" class="btn btn--primary btn--block" style="margin-top:10px;">
                Sign In
            </button>
        </form>

        <div class="auth-footer">
            Don't have an account?
            <a href="<%= ctx %>/auth/register">Create Account</a>
        </div>

        <!-- Demo credentials hint -->
        <div style="margin-top:28px; padding:16px; background:var(--abyss); border:1px solid var(--graphite-teal); font-size:0.78rem; color:var(--text-light-2);">
            <div style="font-weight:700; color:var(--plasma-lime); text-transform:uppercase; margin-bottom:4px;" class="mono-text">Demo Credentials</div>
            <div><strong>Admin:</strong> admin / admin123</div>
            <div><strong>User:</strong> john / user123</div>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
