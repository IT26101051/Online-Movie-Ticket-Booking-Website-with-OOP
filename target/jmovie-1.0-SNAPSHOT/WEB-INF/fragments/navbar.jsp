<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %><%
    String _username = (String) session.getAttribute("username");
    String _role     = (String) session.getAttribute("role");
    boolean _isAdmin = "ADMIN".equals(_role);
    String  _ctx     = request.getContextPath();
    String  _uri     = request.getRequestURI();
    boolean _isBooking = _uri != null && _uri.contains("/booking");
    boolean _isAdminUri = _uri != null && _uri.contains("/admin");
    boolean _isMovies = _uri != null && _uri.contains("/movies") && !_isBooking && !_isAdminUri;
%>
<header class="header sticky-top">
    <nav class="navbar">
        <!-- Logo on far left: Bold white typography -->
        <a href="<%= _ctx %>/movies" class="navbar__logo">
            J<strong>MOVIE</strong>
        </a>

        <!-- Right-aligned navigation & action items -->
        <div class="navbar__right-group">
            <div class="navbar__nav">
                <a href="<%= _ctx %>/movies" class="navbar__link <%= _isMovies ? "active" : "" %>" data-nav="home">Home</a>
                <a href="<%= _ctx %>/movies#movies-section" class="navbar__link" data-nav="movies">Movies</a>
                <a href="<%= _ctx %>/movies#cinemas" class="navbar__link" data-nav="cinemas">Cinemas</a>
                <a href="<%= _ctx %>/movies#footer" class="navbar__link" data-nav="contact">Contact Us</a>
                <% if (_username != null && !_isAdmin) { %>
                <a href="<%= _ctx %>/booking" class="navbar__link <%= _isBooking ? "active" : "" %>" data-nav="booking">My Bookings</a>
                <% } %>
                <% if (_isAdmin) { %>
                <a href="<%= _ctx %>/admin/dashboard" class="navbar__link navbar__link--admin <%= _isAdminUri ? "active" : "" %>" data-nav="admin">Admin Portal</a>
                <% } %>
            </div>

            <!-- Actions: User Auth & Buy Tickets Button -->
            <div class="navbar__actions">
                <a href="<%= _ctx %>/movies#movies-section" class="btn btn--buy-tickets hide-mobile">BUY TICKETS</a>

                <% if (_username != null) { %>
                <div class="user-pill hide-mobile">
                    <span class="user-pill__name">HI, <strong><%= _username.toUpperCase() %></strong></span>
                    <a href="<%= _ctx %>/auth/logout" class="navbar__auth-link">Sign Out</a>
                </div>
                <% } else { %>
                <a href="<%= _ctx %>/auth/login" class="navbar__auth-link hide-mobile">Sign In</a>
                <% } %>

                <!-- Mobile Hamburger Toggle Button -->
                <button type="button" class="mobile-toggle" id="drawer-toggle" aria-label="Toggle navigation menu">
                    <span></span><span></span><span></span>
                </button>
            </div>
        </div>
    </nav>
</header>

<!-- Mobile Slide-In Side Drawer -->
<div class="drawer-overlay" id="drawer-overlay"></div>
<aside class="drawer" id="mobile-drawer">
    <div class="drawer__header">
        <a href="<%= _ctx %>/movies" class="navbar__logo">
            J<strong>MOVIE</strong>
        </a>
        <button type="button" class="drawer__close" id="drawer-close" aria-label="Close menu">&times;</button>
    </div>
    <div class="drawer__content">
        <ul class="drawer__menu">
            <li><a href="<%= _ctx %>/movies" class="drawer__link <%= _isMovies ? "active" : "" %>" data-nav="home">Home</a></li>
            <li><a href="<%= _ctx %>/movies#movies-section" class="drawer__link" data-nav="movies">Movies</a></li>
            <li><a href="<%= _ctx %>/movies#cinemas" class="drawer__link" data-nav="cinemas">Cinemas</a></li>
            <li><a href="<%= _ctx %>/movies#footer" class="drawer__link" data-nav="contact">Contact Us</a></li>
            <% if (_username != null && !_isAdmin) { %>
            <li><a href="<%= _ctx %>/booking" class="drawer__link <%= _isBooking ? "active" : "" %>" data-nav="booking">My Bookings</a></li>
            <% } %>
            <% if (_isAdmin) { %>
            <li><a href="<%= _ctx %>/admin/dashboard" class="drawer__link drawer__link--admin <%= _isAdminUri ? "active" : "" %>" data-nav="admin">Admin Portal</a></li>
            <% } %>
        </ul>
        <div class="drawer__actions">
            <a href="<%= _ctx %>/movies#movies-section" class="btn btn--buy-tickets btn--block">BUY TICKETS</a>
            <% if (_username == null) { %>
            <a href="<%= _ctx %>/auth/login" class="btn btn--secondary btn--block mt-2">Sign In</a>
            <a href="<%= _ctx %>/auth/register" class="btn btn--secondary btn--block mt-2">Create Account</a>
            <% } else { %>
            <a href="<%= _ctx %>/auth/logout" class="btn btn--secondary btn--block mt-2">Sign Out</a>
            <% } %>
        </div>
    </div>
</aside>
