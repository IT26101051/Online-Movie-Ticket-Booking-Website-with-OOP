<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Booking, java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    String ctx = request.getContextPath();
    Long userCount     = (Long) request.getAttribute("userCount");
    Long movieCount    = (Long) request.getAttribute("movieCount");
    Long bookingCount  = (Long) request.getAttribute("bookingCount");
    Long showtimeCount = (Long) request.getAttribute("showtimeCount");
    List<Booking> recentBookings = (List<Booking>) request.getAttribute("recentBookings");
    if (recentBookings == null) recentBookings = new java.util.ArrayList<Booking>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — JMovie</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>
<div class="admin-layout">
    <!-- Sidebar -->
    <aside class="admin-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Overview</div>
            <a href="<%= ctx %>/admin/dashboard" class="sidebar-link active">
                <span class="sidebar-icon">◼</span> Dashboard
            </a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Management</div>
            <a href="<%= ctx %>/admin/manage-movies"    class="sidebar-link"><span class="sidebar-icon">🎬</span> Movies</a>
            <a href="<%= ctx %>/admin/manage-showtimes" class="sidebar-link"><span class="sidebar-icon">🕐</span> Showtimes</a>
            <a href="<%= ctx %>/admin/manage-users"     class="sidebar-link"><span class="sidebar-icon">👥</span> Users</a>
            <a href="<%= ctx %>/admin/manage-reviews"   class="sidebar-link"><span class="sidebar-icon">✍</span> Reviews</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Platform</div>
            <a href="<%= ctx %>/movies" class="sidebar-link"><span class="sidebar-icon">▶</span> View Site</a>
            <a href="<%= ctx %>/auth/logout" class="sidebar-link"><span class="sidebar-icon">→</span> Sign Out</a>
        </div>
    </aside>

    <div class="admin-main">
        <div class="page-hd">
            <h1 class="page-hd__title">Dashboard</h1>
            <p class="page-hd__sub">Welcome back, Admin. System metric summary and active operations.</p>
        </div>

        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-card__label">Registered Users</div>
                <div class="stat-card__value"><%= userCount != null ? userCount : 0 %></div>
            </div>
            <div class="stat-card">
                <div class="stat-card__label">Active Movies</div>
                <div class="stat-card__value stat-card__accent"><%= movieCount != null ? movieCount : 0 %></div>
            </div>
            <div class="stat-card">
                <div class="stat-card__label">Total Reservations</div>
                <div class="stat-card__value"><%= bookingCount != null ? bookingCount : 0 %></div>
            </div>
            <div class="stat-card">
                <div class="stat-card__label">Screenings</div>
                <div class="stat-card__value"><%= showtimeCount != null ? showtimeCount : 0 %></div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div style="margin-bottom:36px;">
            <div style="font-size:0.8rem; font-weight:700; text-transform:uppercase; color:var(--text-light-2); margin-bottom:12px;" class="mono-text">
                Quick Control Actions
            </div>
            <div style="display:flex; gap:12px; flex-wrap:wrap;">
                <a href="<%= ctx %>/admin/manage-movies"    class="btn btn--outline">+ Add New Movie</a>
                <a href="<%= ctx %>/admin/manage-showtimes" class="btn btn--outline">+ Schedule Showtime</a>
                <a href="<%= ctx %>/admin/manage-reviews"   class="btn btn--outline">Moderate Reviews</a>
                <a href="<%= ctx %>/admin/manage-users"     class="btn btn--outline">Manage User Roles</a>
            </div>
        </div>

        <!-- Recent Bookings Table -->
        <div>
            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:16px;">
                <div style="font-size:1.1rem; font-weight:700; text-transform:uppercase; color:var(--text-light-1);">Recent Bookings</div>
                <span class="mono-text" style="font-size:0.75rem; color:var(--text-light-2);">LATEST 5 TRANSACTIONS</span>
            </div>
            <% if (recentBookings.isEmpty()) { %>
            <div class="empty-state" style="padding:40px;"><div class="empty-state__text">No bookings recorded yet.</div></div>
            <% } else { %>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Booking ID</th><th>User</th><th>Movie Title</th>
                            <th>Screening</th><th>Seats</th><th>Amount</th><th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Booking b : recentBookings) { %>
                    <tr>
                        <td class="mono-text" style="font-size:0.75rem; color:var(--text-light-2);"><%= b.getId() != null && b.getId().length() >= 8 ? b.getId().substring(0,8) + "..." : b.getId() %></td>
                        <td style="font-weight:600;"><%= b.getUsername() %></td>
                        <td class="truncate" style="max-width:160px; font-weight:600;"><%= b.getMovieTitle() %></td>
                        <td class="mono-text" style="font-size:0.78rem;"><%= b.getShowDate() %> <%= b.getShowTime() %></td>
                        <td class="mono-text" style="color:var(--plasma-lime);"><%= b.getSeats() %></td>
                        <td class="mono-text" style="font-weight:700; color:var(--plasma-lime);">LKR <%= String.format("%.0f", b.getTotalAmount()) %></td>
                        <td>
                            <% if ("CONFIRMED".equals(b.getStatus())) { %>
                            <span class="badge badge--green">CONFIRMED</span>
                            <% } else { %>
                            <span class="badge badge--red">CANCELLED</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>
</div>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
