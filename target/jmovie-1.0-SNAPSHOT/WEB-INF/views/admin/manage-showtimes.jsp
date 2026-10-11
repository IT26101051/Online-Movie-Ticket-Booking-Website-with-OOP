<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Showtime, com.jmovie.model.Movie, java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    String ctx = request.getContextPath();
    List<Showtime> showtimes = (List<Showtime>) request.getAttribute("showtimes");
    List<Movie>    movies    = (List<Movie>)    request.getAttribute("movies");
    if (showtimes == null) showtimes = new java.util.ArrayList<Showtime>();
    if (movies    == null) movies    = new java.util.ArrayList<Movie>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Showtimes — Admin — JMovie</title>
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
            <a href="<%= ctx %>/admin/manage-showtimes" class="sidebar-link active"><span class="sidebar-icon">🕐</span> Showtimes</a>
            <a href="<%= ctx %>/admin/manage-users"     class="sidebar-link"><span class="sidebar-icon">👥</span> Users</a>
            <a href="<%= ctx %>/admin/manage-reviews"   class="sidebar-link"><span class="sidebar-icon">✍</span> Reviews</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Platform</div>
            <a href="<%= ctx %>/movies"      class="sidebar-link"><span class="sidebar-icon">▶</span> View Site</a>
            <a href="<%= ctx %>/auth/logout" class="sidebar-link"><span class="sidebar-icon">→</span> Sign Out</a>
        </div>
    </aside>

    <div class="admin-main">
        <div class="page-hd" style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:16px;">
            <div>
                <h1 class="page-hd__title">Manage Showtimes</h1>
                <p class="page-hd__sub"><%= showtimes.size() %> active screenings scheduled</p>
            </div>
            <button class="btn btn--primary" data-open="add-st-modal">+ Schedule Showtime</button>
        </div>

        <% if (showtimes.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state__icon">🕐</div>
            <div class="empty-state__title">No Scheduled Screenings</div>
            <div class="empty-state__text">Schedule showtimes for currently showing movies.</div>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>Movie Title</th><th>Theatre Hall</th><th>Date</th><th>Screening Time</th><th>Available Seats</th><th>Ticket Price</th><th>Action</th></tr>
                </thead>
                <tbody>
                <% for (Showtime s : showtimes) { %>
                <tr>
                    <td style="font-weight:700; text-transform:uppercase;" class="truncate" style="max-width:180px;"><%= s.getMovieTitle() %></td>
                    <td class="mono-text" style="font-size:0.85rem;"><%= s.getTheatreHall() %></td>
                    <td class="mono-text" style="font-size:0.85rem;"><%= s.getDate() %></td>
                    <td class="mono-text" style="font-size:0.85rem; font-weight:700; color:var(--plasma-lime);"><%= s.getTime() %></td>
                    <td class="mono-text" style="font-size:0.85rem;">
                        <span class="<%= s.getAvailableSeats() == 0 ? "badge badge--red" : "badge badge--muted" %>">
                            <%= s.getAvailableSeats() %> / <%= s.getTotalSeats() %>
                        </span>
                    </td>
                    <td class="mono-text" style="font-weight:700; color:var(--plasma-lime);">LKR <%= String.format("%.0f", s.getPrice()) %></td>
                    <td>
                        <form id="del-st-<%= s.getId() %>" method="post" action="<%= ctx %>/showtimes/delete" style="display:none;">
                            <input type="hidden" name="id" value="<%= s.getId() %>">
                        </form>
                        <button class="btn btn--secondary btn--xs" style="border-color:#f87171; color:#f87171;"
                                onclick="confirmAction('del-st-<%= s.getId() %>','Remove this showtime screening?')">Delete</button>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>
</div>

<!-- Add Showtime Modal -->
<div id="add-st-modal" class="modal-overlay hidden">
    <div class="modal">
        <div class="modal__hd">
            <span class="modal__title">Schedule Showtime</span>
            <button class="modal__close" data-close>&times;</button>
        </div>
        <form method="post" action="<%= ctx %>/showtimes/add">
            <div class="modal__body">
                <div class="form-group">
                    <label class="form-label">Select Movie *</label>
                    <select name="movieId" id="movie-select" class="form-control" onchange="updateMovieTitle(this)" required>
                        <option value="">— Choose a Movie —</option>
                        <% for (Movie m : movies) { %>
                        <option value="<%= m.getId() %>" data-title="<%= m.getTitle() %>"><%= m.getTitle() %> (<%= m.getStatus() %>)</option>
                        <% } %>
                    </select>
                    <input type="hidden" name="movieTitle" id="movie-title-hidden">
                </div>
                <div class="form-row">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Theatre Hall *</label>
                        <input name="theatreHall" type="text" class="form-control" placeholder="e.g. Hall A" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Total Capacity</label>
                        <input name="totalSeats" type="number" class="form-control" value="80" min="1" max="300" required>
                    </div>
                </div>
                <div class="form-row" style="margin-top:16px;">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Screening Date *</label>
                        <input name="date" type="date" class="form-control" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Screening Time *</label>
                        <input name="time" type="time" class="form-control" required>
                    </div>
                </div>
                <div class="form-group" style="margin-top:16px;">
                    <label class="form-label">Standard Ticket Price (LKR) *</label>
                    <input name="price" type="number" step="50" min="0" class="form-control" placeholder="1200" required>
                </div>
            </div>
            <div class="modal__ft">
                <button type="button" class="btn btn--secondary" data-close>Cancel</button>
                <button type="submit" class="btn btn--primary">Confirm Showtime</button>
            </div>
        </form>
    </div>
</div>
<script>
function updateMovieTitle(select) {
    const opt = select.options[select.selectedIndex];
    document.getElementById('movie-title-hidden').value = opt.dataset.title || '';
}
</script>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
