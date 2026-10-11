<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Review, java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    String ctx = request.getContextPath();
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) reviews = new java.util.ArrayList<Review>();

    long pending  = 0;
    long approved = 0;
    for (Review r : reviews) {
        if ("PENDING".equals(r.getStatus())) {
            pending++;
        } else if ("APPROVED".equals(r.getStatus())) {
            approved++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Reviews — Admin — JMovie</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>
<div class="admin-layout">
    <aside class="admin-sidebar">
        <div class="sidebar-section">
            <div class="sidebar-label">Overview</div>
            <a href="<%= ctx %>/admin/dashboard" class="sidebar-link"><span class="sidebar-icon">◼</span> Dashboard</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Management</div>
            <a href="<%= ctx %>/admin/manage-movies"    class="sidebar-link"><span class="sidebar-icon">🎬</span> Movies</a>
            <a href="<%= ctx %>/admin/manage-showtimes" class="sidebar-link"><span class="sidebar-icon">🕐</span> Showtimes</a>
            <a href="<%= ctx %>/admin/manage-users"     class="sidebar-link"><span class="sidebar-icon">👥</span> Users</a>
            <a href="<%= ctx %>/admin/manage-reviews"   class="sidebar-link active"><span class="sidebar-icon">✍</span> Reviews</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Platform</div>
            <a href="<%= ctx %>/movies"      class="sidebar-link"><span class="sidebar-icon">▶</span> View Site</a>
            <a href="<%= ctx %>/auth/logout" class="sidebar-link"><span class="sidebar-icon">→</span> Sign Out</a>
        </div>
    </aside>

    <div class="admin-main">
        <div class="page-hd">
            <h1 class="page-hd__title">Review Moderation</h1>
            <p class="page-hd__sub"><%= pending %> pending &middot; <%= approved %> approved &middot; <%= reviews.size() %> total audience reviews</p>
        </div>

        <% if (reviews.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state__icon">✍</div>
            <div class="empty-state__title">No Reviews Submitted</div>
            <div class="empty-state__text">Audience reviews will appear here for moderation once submitted.</div>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>User</th><th>Movie Title</th><th>Rating</th><th>Comment</th><th>Badge</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% for (Review r : reviews) { %>
                <tr>
                    <td style="font-weight:700;"><%= r.getUsername() %></td>
                    <td class="truncate" style="max-width:140px; font-weight:600;"><%= r.getMovieTitle() %></td>
                    <td class="mono-text" style="font-weight:700; color:var(--plasma-lime);"><%= r.getStars() %></td>
                    <td style="max-width:240px; font-size:0.85rem; color:var(--text-light-2); white-space:normal;">
                        <%= r.getComment().length() > 90 ? r.getComment().substring(0,90) + "..." : r.getComment() %>
                    </td>
                    <td>
                        <span class="badge <%= "VERIFIED".equals(r.getReviewType()) ? "badge--green" : "badge--muted" %>">
                            <%= r.getDisplayBadge() %>
                        </span>
                    </td>
                    <td>
                        <% if ("APPROVED".equals(r.getStatus())) { %><span class="badge badge--green">APPROVED</span>
                        <% } else if ("PENDING".equals(r.getStatus())) { %><span class="badge badge--warn">PENDING</span>
                        <% } else { %><span class="badge badge--red">REJECTED</span><% } %>
                    </td>
                    <td>
                        <div style="display:flex; gap:6px; flex-wrap:wrap;">
                            <% if ("PENDING".equals(r.getStatus()) || "REJECTED".equals(r.getStatus())) { %>
                            <form method="post" action="<%= ctx %>/review/approve" style="display:inline;">
                                <input type="hidden" name="reviewId" value="<%= r.getId() %>">
                                <button class="btn btn--secondary btn--xs" style="border-color:var(--plasma-lime); color:var(--plasma-lime);" title="Approve Review">✓ Approve</button>
                            </form>
                            <% } %>
                            <% if ("PENDING".equals(r.getStatus()) || "APPROVED".equals(r.getStatus())) { %>
                            <form method="post" action="<%= ctx %>/review/reject" style="display:inline;">
                                <input type="hidden" name="reviewId" value="<%= r.getId() %>">
                                <button class="btn btn--secondary btn--xs" style="border-color:#facc15; color:#facc15;" title="Reject Review">✕ Reject</button>
                            </form>
                            <% } %>
                            <form id="del-rev-<%= r.getId() %>" method="post" action="<%= ctx %>/review/delete" style="display:none;">
                                <input type="hidden" name="reviewId" value="<%= r.getId() %>">
                                <input type="hidden" name="movieId"  value="<%= r.getMovieId() %>">
                            </form>
                            <button class="btn btn--secondary btn--xs" style="border-color:#f87171; color:#f87171;"
                                    onclick="confirmAction('del-rev-<%= r.getId() %>','Delete this audience review?')">Delete</button>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
