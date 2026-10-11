<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%
    String _username = (String) session.getAttribute("username");
    String _role     = (String) session.getAttribute("role");
    boolean _isAdmin = "ADMIN".equals(_role);
    String  _ctx     = request.getContextPath();
%>
<header class="header sticky-top">
    <nav class="navbar container-fluid">
        <!-- Logo -->
        <a href="<%= _ctx %>/movies" class="navbar__logo">
            <span class="logo-box">▶</span>
            <span class="logo-text">J<span>MOVIE</span></span>
        </a>

        <!-- Desktop Navigation Links -->
        <div class="navbar__nav">
            <a href="<%= _ctx %>/movies" class="navbar__link active">HOME</a>
            <a href="<%= _ctx %>/movies" class="navbar__link">MOVIES</a>
            <a href="#articles" class="navbar__link">EDITORIAL</a>
            <% if (_username != null && !_isAdmin) { %>
            <a href="<%= _ctx %>/booking" class="navbar__link">MY BOOKINGS</a>
            <% } %>
            <% if (_isAdmin) { %>
            <a href="<%= _ctx %>/admin/dashboard" class="navbar__link navbar__link--admin">ADMIN PORTAL</a>
            <% } %>
        </div>

        <!-- Action Controls & User -->
        <div class="navbar__right">
            <a href="#movies-section" class="btn btn--primary hide-mobile">
                <span>BUY TICKETS</span>
            </a>

            <% if (_username != null) { %>
            <div class="user-pill">
                <span class="user-pill__name">HI, <strong><%= _username.toUpperCase() %></strong></span>
                <a href="<%= _ctx %>/auth/logout" class="btn btn--outline btn--xs">SIGN OUT</a>
            </div>
            <% } else { %>
            <a href="<%= _ctx %>/auth/login" class="btn btn--outline btn--sm">SIGN IN</a>
            <a href="<%= _ctx %>/auth/register" class="btn btn--secondary btn--sm hide-mobile">REGISTER</a>
            <% } %>

            <!-- Mobile Hamburger Button -->
            <button type="button" class="mobile-toggle" id="drawer-toggle" aria-label="Toggle menu">
                <span></span><span></span><span></span>
            </button>
        </div>
    </nav>
</header>

<!-- Mobile Slide-In Side Drawer -->
<div class="drawer-overlay" id="drawer-overlay"></div>
<aside class="drawer" id="mobile-drawer">
    <div class="drawer__header">
        <a href="<%= _ctx %>/movies" class="navbar__logo">
            <span class="logo-box">▶</span>
            <span class="logo-text">J<span>MOVIE</span></span>
        </a>
        <button type="button" class="drawer__close" id="drawer-close" aria-label="Close menu">&times;</button>
    </div>
    <div class="drawer__content">
        <ul class="drawer__menu">
            <li><a href="<%= _ctx %>/movies" class="drawer__link active">HOME</a></li>
            <li><a href="<%= _ctx %>/movies" class="drawer__link">MOVIES</a></li>
            <li><a href="#articles" class="drawer__link">CINEMA EDITORIAL</a></li>
            <% if (_username != null && !_isAdmin) { %>
            <li><a href="<%= _ctx %>/booking" class="drawer__link">MY BOOKINGS</a></li>
            <% } %>
            <% if (_isAdmin) { %>
            <li><a href="<%= _ctx %>/admin/dashboard" class="drawer__link drawer__link--admin">ADMIN PORTAL</a></li>
            <% } %>
        </ul>
        <div class="drawer__actions">
            <a href="#movies-section" class="btn btn--primary btn--block">BUY MOVIE TICKETS</a>
            <% if (_username == null) { %>
            <a href="<%= _ctx %>/auth/login" class="btn btn--outline btn--block mt-2">SIGN IN</a>
            <a href="<%= _ctx %>/auth/register" class="btn btn--secondary btn--block mt-2">CREATE ACCOUNT</a>
            <% } else { %>
            <a href="<%= _ctx %>/auth/logout" class="btn btn--outline btn--block mt-2">SIGN OUT</a>
            <% } %>
        </div>
    </div>
</aside>
