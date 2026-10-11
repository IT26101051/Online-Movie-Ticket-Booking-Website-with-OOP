<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account — JMovie</title>
    <meta name="description" content="Create a JMovie account to start booking movie tickets online.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="auth-logo">
            <span style="color:var(--plasma-lime);">▶</span> J<span style="color:var(--plasma-lime);">MOVIE</span>
        </div>
        <div class="auth-title">Create Account</div>
        <div class="auth-sub">Join JMovie to browse premium screenings & reserve seats.</div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert--error"><%= error %></div>
        <% } %>

        <form method="post" action="<%= ctx %>/auth/register">
            <div class="form-group">
                <label class="form-label" for="username">Username *</label>
                <input id="username" name="username" type="text" class="form-control"
                       placeholder="Choose a username" required autofocus>
            </div>
            <div class="form-row">
                <div class="form-group" style="margin-bottom:0">
                    <label class="form-label" for="email">Email *</label>
                    <input id="email" name="email" type="email" class="form-control"
                           placeholder="you@email.com" required>
                </div>
                <div class="form-group" style="margin-bottom:0">
                    <label class="form-label" for="phone">Phone</label>
                    <input id="phone" name="phone" type="text" class="form-control"
                           placeholder="07X XXXXXXX">
                </div>
            </div>
            <div class="form-group" style="margin-top:16px;">
                <label class="form-label" for="password">Password *</label>
                <input id="password" name="password" type="password" class="form-control"
                       placeholder="At least 6 characters" required>
            </div>
            <button type="submit" class="btn btn--primary btn--block" style="margin-top:10px;">
                Register Account
            </button>
        </form>

        <div class="auth-footer">
            Already have an account?
            <a href="<%= ctx %>/auth/login">Sign In</a>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
