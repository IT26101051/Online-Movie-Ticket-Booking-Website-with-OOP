<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Movie, java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    String ctx = request.getContextPath();
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    if (movies == null) movies = new java.util.ArrayList<Movie>();
    String[] genres   = {"Action","Drama","Sci-Fi","Thriller","Comedy","Horror","Romance","Animation","Biography","Fantasy"};
    String[] statuses = {"NOW_SHOWING","COMING_SOON","ENDED"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Movies — Admin — JMovie</title>
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
            <a href="<%= ctx %>/admin/manage-movies"    class="sidebar-link active"><span class="sidebar-icon">🎬</span> Movies</a>
            <a href="<%= ctx %>/admin/manage-showtimes" class="sidebar-link"><span class="sidebar-icon">🕐</span> Showtimes</a>
            <a href="<%= ctx %>/admin/manage-users"     class="sidebar-link"><span class="sidebar-icon">👥</span> Users</a>
            <a href="<%= ctx %>/admin/manage-reviews"   class="sidebar-link"><span class="sidebar-icon">✍</span> Reviews</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Platform</div>
            <a href="<%= ctx %>/movies"       class="sidebar-link"><span class="sidebar-icon">▶</span> View Site</a>
            <a href="<%= ctx %>/auth/logout"  class="sidebar-link"><span class="sidebar-icon">→</span> Sign Out</a>
        </div>
    </aside>

    <div class="admin-main">
        <div class="page-hd" style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:16px;">
            <div>
                <h1 class="page-hd__title">Manage Movies</h1>
                <p class="page-hd__sub"><%= movies.size() %> active movies registered in catalogue</p>
            </div>
            <button class="btn btn--primary" data-open="add-movie-modal">+ Add New Movie</button>
        </div>

        <% if (movies.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state__icon">🎬</div>
            <div class="empty-state__title">No Movies Available</div>
            <div class="empty-state__text">Add your first movie to start selling tickets.</div>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Title</th><th>Genre</th><th>Runtime</th><th>Rating</th><th>Status</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Movie m : movies) { %>
                <tr>
                    <td style="font-weight:700; text-transform:uppercase;"><%= m.getTitle() %></td>
                    <td><span class="badge badge--muted"><%= m.getGenre() %></span></td>
                    <td class="mono-text" style="font-size:0.8rem; color:var(--text-light-2);"><%= m.getDurationFormatted() %></td>
                    <td class="mono-text" style="font-weight:700; color:var(--plasma-lime);">★ <%= String.format("%.1f", m.getRating()) %></td>
                    <td>
                        <% if ("NOW_SHOWING".equals(m.getStatus())) { %><span class="badge badge--green">NOW SHOWING</span>
                        <% } else if ("COMING_SOON".equals(m.getStatus())) { %><span class="badge badge--gold">COMING SOON</span>
                        <% } else { %><span class="badge badge--muted">ENDED</span><% } %>
                    </td>
                    <td>
                        <div style="display:flex; gap:8px;">
                            <button class="btn btn--secondary btn--xs" data-open="edit-movie-modal"
                                data-id="<%= m.getId() %>"
                                data-title="<%= m.getTitle() %>"
                                data-genre="<%= m.getGenre() %>"
                                data-description="<%= m.getDescription().replace("\"","&quot;") %>"
                                data-duration="<%= m.getDuration() %>"
                                data-rating="<%= m.getRating() %>"
                                data-posterurl="<%= m.getPosterUrl() %>"
                                data-releasedate="<%= m.getReleaseDate() %>"
                                data-status="<%= m.getStatus() %>">Edit</button>
                            <form id="del-mov-<%= m.getId() %>" method="post" action="<%= ctx %>/movies">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= m.getId() %>">
                            </form>
                            <button class="btn btn--secondary btn--xs" style="border-color:#f87171; color:#f87171;"
                                    onclick="confirmAction('del-mov-<%= m.getId() %>','Permanently delete movie <%= m.getTitle() %>?')">Delete</button>
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

<!-- Add Movie Modal -->
<div id="add-movie-modal" class="modal-overlay hidden">
    <div class="modal">
        <div class="modal__hd">
            <span class="modal__title">Add New Movie</span>
            <button class="modal__close" data-close>&times;</button>
        </div>
        <form method="post" action="<%= ctx %>/movies">
            <input type="hidden" name="action" value="add">
            <div class="modal__body">
                <div class="form-group">
                    <label class="form-label">Movie Title *</label>
                    <input name="title" type="text" class="form-control" placeholder="e.g. Oppenheimer" required>
                </div>
                <div class="form-row">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Genre</label>
                        <select name="genre" class="form-control">
                            <% for (String g : genres) { %><option><%= g %></option><% } %>
                        </select>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Screening Status</label>
                        <select name="status" class="form-control">
                            <option value="NOW_SHOWING">Now Showing</option>
                            <option value="COMING_SOON">Coming Soon</option>
                            <option value="ENDED">Ended</option>
                        </select>
                    </div>
                </div>
                <div class="form-group" style="margin-top:16px;">
                    <label class="form-label">Synopsis</label>
                    <textarea name="description" class="form-control" placeholder="Brief movie description..."></textarea>
                </div>
                <div class="form-row">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Duration (minutes) *</label>
                        <input name="duration" type="number" class="form-control" placeholder="148" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Rating (0-10) *</label>
                        <input name="rating" type="number" step="0.1" min="0" max="10" class="form-control" placeholder="8.5" required>
                    </div>
                </div>
                <div class="form-row" style="margin-top:16px;">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Release Date *</label>
                        <input name="releaseDate" type="date" class="form-control" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Poster Image URL</label>
                        <input name="posterUrl" type="text" class="form-control" placeholder="https://...">
                    </div>
                </div>
            </div>
            <div class="modal__ft">
                <button type="button" class="btn btn--secondary" data-close>Cancel</button>
                <button type="submit" class="btn btn--primary">Save Movie</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Movie Modal -->
<div id="edit-movie-modal" class="modal-overlay hidden">
    <div class="modal">
        <div class="modal__hd">
            <span class="modal__title">Edit Movie Entry</span>
            <button class="modal__close" data-close>&times;</button>
        </div>
        <form method="post" action="<%= ctx %>/movies">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="edit-id">
            <div class="modal__body">
                <div class="form-group">
                    <label class="form-label">Movie Title *</label>
                    <input name="title" id="edit-title" type="text" class="form-control" required>
                </div>
                <div class="form-row">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Genre</label>
                        <select name="genre" id="edit-genre" class="form-control">
                            <% for (String g : genres) { %><option><%= g %></option><% } %>
                        </select>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Status</label>
                        <select name="status" id="edit-status" class="form-control">
                            <option value="NOW_SHOWING">Now Showing</option>
                            <option value="COMING_SOON">Coming Soon</option>
                            <option value="ENDED">Ended</option>
                        </select>
                    </div>
                </div>
                <div class="form-group" style="margin-top:16px;">
                    <label class="form-label">Synopsis</label>
                    <textarea name="description" id="edit-description" class="form-control"></textarea>
                </div>
                <div class="form-row">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Duration (min)</label>
                        <input name="duration" id="edit-duration" type="number" class="form-control" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Rating (0-10)</label>
                        <input name="rating" id="edit-rating" type="number" step="0.1" min="0" max="10" class="form-control" required>
                    </div>
                </div>
                <div class="form-row" style="margin-top:16px;">
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Release Date</label>
                        <input name="releaseDate" id="edit-releaseDate" type="date" class="form-control" required>
                    </div>
                    <div class="form-group" style="margin-bottom:0">
                        <label class="form-label">Poster Image URL</label>
                        <input name="posterUrl" id="edit-posterUrl" type="text" class="form-control">
                    </div>
                </div>
            </div>
            <div class="modal__ft">
                <button type="button" class="btn btn--secondary" data-close>Cancel</button>
                <button type="submit" class="btn btn--primary">Update Movie</button>
            </div>
        </form>
    </div>
</div>

<script>
document.querySelectorAll('[data-open="edit-movie-modal"]').forEach(btn => {
    btn.addEventListener('click', () => {
        document.getElementById('edit-id').value          = btn.dataset.id || '';
        document.getElementById('edit-title').value       = btn.dataset.title || '';
        document.getElementById('edit-genre').value       = btn.dataset.genre || '';
        document.getElementById('edit-status').value      = btn.dataset.status || 'NOW_SHOWING';
        document.getElementById('edit-description').value = btn.dataset.description || '';
        document.getElementById('edit-duration').value    = btn.dataset.duration || '';
        document.getElementById('edit-rating').value      = btn.dataset.rating || '';
        document.getElementById('edit-releaseDate').value = btn.dataset.releasedate || '';
        document.getElementById('edit-posterUrl').value   = btn.dataset.posterurl || '';
    });
});
</script>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
