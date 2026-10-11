<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.User, java.util.List" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"ADMIN".equals(role)) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }
    String ctx = request.getContextPath();
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) users = new java.util.ArrayList<User>();
    String currentAdminId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users — Admin — JMovie</title>
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
            <a href="<%= ctx %>/admin/manage-users"     class="sidebar-link active"><span class="sidebar-icon">👥</span> Users</a>
            <a href="<%= ctx %>/admin/manage-reviews"   class="sidebar-link"><span class="sidebar-icon">✍</span> Reviews</a>
        </div>
        <div class="sidebar-section">
            <div class="sidebar-label">Platform</div>
            <a href="<%= ctx %>/movies"      class="sidebar-link"><span class="sidebar-icon">▶</span> View Site</a>
            <a href="<%= ctx %>/auth/logout" class="sidebar-link"><span class="sidebar-icon">→</span> Sign Out</a>
        </div>
    </aside>

    <div class="admin-main">
        <div class="page-hd">
            <h1 class="page-hd__title">User Accounts</h1>
            <p class="page-hd__sub"><%= users.size() %> registered user profiles</p>
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr><th>User ID</th><th>Username</th><th>Email</th><th>Phone</th><th>Role</th><th>Joined Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% for (User u : users) { %>
                <tr>
                    <td class="mono-text" style="font-size:0.75rem; color:var(--text-light-2);"><%= u.getId() %></td>
                    <td style="font-weight:700;"><%= u.getUsername() %></td>
                    <td class="mono-text" style="font-size:0.85rem; color:var(--text-light-2);"><%= u.getEmail() %></td>
                    <td class="mono-text" style="font-size:0.85rem; color:var(--text-light-2);"><%= u.getPhone() != null && !u.getPhone().isEmpty() ? u.getPhone() : "—" %></td>
                    <td>
                        <span class="badge <%= "ADMIN".equals(u.getRole()) ? "badge--gold" : "badge--muted" %>">
                            <%= u.getRole() %>
                        </span>
                    </td>
                    <td class="mono-text" style="font-size:0.85rem; color:var(--text-light-2);"><%= u.getCreatedAt() != null && u.getCreatedAt().length() >= 10 ? u.getCreatedAt().substring(0,10) : u.getCreatedAt() %></td>
                    <td>
                        <div style="display:flex; gap:8px;">
                            <button class="btn btn--secondary btn--xs" data-open="edit-user-modal"
                                data-id="<%= u.getId() %>"
                                data-email="<%= u.getEmail() %>"
                                data-phone="<%= u.getPhone() %>">Edit</button>
                            <% if (!u.getId().equals(currentAdminId)) { %>
                            <form id="del-usr-<%= u.getId() %>" method="post" action="<%= ctx %>/admin/users/delete" style="display:none;">
                                <input type="hidden" name="id" value="<%= u.getId() %>">
                            </form>
                            <button class="btn btn--secondary btn--xs" style="border-color:#f87171; color:#f87171;"
                                    onclick="confirmAction('del-usr-<%= u.getId() %>','Delete user profile <%= u.getUsername() %>?')">Delete</button>
                            <% } else { %>
                            <span class="mono-text" style="font-size:0.75rem; color:var(--plasma-lime); padding:4px 8px;">[Active Admin]</span>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Edit User Modal -->
<div id="edit-user-modal" class="modal-overlay hidden">
    <div class="modal">
        <div class="modal__hd">
            <span class="modal__title">Edit User Contact</span>
            <button class="modal__close" data-close>&times;</button>
        </div>
        <form method="post" action="<%= ctx %>/admin/users/update">
            <input type="hidden" name="id" id="edit-user-id">
            <div class="modal__body">
                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <input name="email" id="edit-user-email" type="email" class="form-control" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input name="phone" id="edit-user-phone" type="text" class="form-control">
                </div>
            </div>
            <div class="modal__ft">
                <button type="button" class="btn btn--secondary" data-close>Cancel</button>
                <button type="submit" class="btn btn--primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>
<script>
document.querySelectorAll('[data-open="edit-user-modal"]').forEach(btn => {
    btn.addEventListener('click', () => {
        document.getElementById('edit-user-id').value    = btn.dataset.id || '';
        document.getElementById('edit-user-email').value = btn.dataset.email || '';
        document.getElementById('edit-user-phone').value = btn.dataset.phone || '';
    });
});
</script>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
