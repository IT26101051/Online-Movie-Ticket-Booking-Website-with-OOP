<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Booking, java.util.List" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }

    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    String ctx = request.getContextPath();
    if (bookings == null) bookings = new java.util.ArrayList<Booking>();

    long confirmed  = 0;
    long cancelled  = 0;
    double spent    = 0.0;
    for (Booking b : bookings) {
        if ("CONFIRMED".equals(b.getStatus())) {
            confirmed++;
            spent += b.getTotalAmount();
        } else {
            cancelled++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings — JMovie</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>
<main class="page">
<div class="container">

    <div class="page-hd">
        <h1 class="page-hd__title">My Bookings</h1>
        <p class="page-hd__sub">View and manage your active and past movie ticket reservations</p>
    </div>

    <!-- Quick Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-card__label">Confirmed Tickets</div>
            <div class="stat-card__value stat-card__accent"><%= confirmed %></div>
        </div>
        <div class="stat-card">
            <div class="stat-card__label">Cancelled</div>
            <div class="stat-card__value"><%= cancelled %></div>
        </div>
        <div class="stat-card">
            <div class="stat-card__label">Total Invested</div>
            <div class="stat-card__value" style="font-size:1.6rem; color:var(--plasma-lime);">LKR <%= String.format("%.0f", spent) %></div>
        </div>
    </div>

    <!-- Bookings List -->
    <% if (bookings.isEmpty()) { %>
    <div class="empty-state">
        <div class="empty-state__icon">🎟️</div>
        <div class="empty-state__title">No Bookings Found</div>
        <div class="empty-state__text">You haven't reserved any tickets yet. Explore currently showing movies!</div>
        <a href="<%= ctx %>/movies" class="btn btn--primary">Browse Movies</a>
    </div>
    <% } else { %>
    <% for (Booking b : bookings) { %>
    <div class="booking-card scroll-reveal">
        <div class="booking-card__hd">
            <div>
                <div class="booking-card__title"><%= b.getMovieTitle() %></div>
                <div class="mono-text" style="font-size:0.75rem; color:var(--text-light-2); margin-top:4px;">
                    BOOKING: <strong><%= b.getId() %></strong> &bull;
                    TXN: <span style="color:var(--ion-mint);"><%= b.getTransactionId() != null && !b.getTransactionId().isEmpty() ? b.getTransactionId() : "TXN-PAID" %></span> &bull;
                    <span style="color:var(--plasma-lime);"><%= b.getPaymentMethod() != null ? b.getPaymentMethod() : "CARD" %></span>
                </div>
            </div>
            <% if ("CONFIRMED".equals(b.getStatus())) { %>
            <span class="badge badge--green">CONFIRMED &bull; PAID</span>
            <% } else { %>
            <span class="badge badge--red">CANCELLED</span>
            <% } %>
        </div>
        <div class="booking-card__body">
            <div class="booking-card__item">
                <label>Date</label>
                <span><%= b.getShowDate() %></span>
            </div>
            <div class="booking-card__item">
                <label>Showtime</label>
                <span><%= b.getShowTime() %></span>
            </div>
            <div class="booking-card__item">
                <label>Theatre Hall</label>
                <span><%= b.getTheatreHall() != null && !b.getTheatreHall().isEmpty() ? b.getTheatreHall() : "Screen A" %></span>
            </div>
            <div class="booking-card__item">
                <label>Seats Selected</label>
                <span class="mono-text" style="color:var(--plasma-lime);"><%= b.getSeats() %></span>
            </div>
            <div class="booking-card__item">
                <label>Quantity</label>
                <span><%= b.getQuantity() %> Ticket<%= b.getQuantity() != 1 ? "s" : "" %></span>
            </div>
            <div class="booking-card__item">
                <label>Booking Date</label>
                <span><%= b.getBookingDate() != null ? b.getBookingDate().substring(0,10) : "—" %></span>
            </div>
        </div>
        <div class="booking-card__ft">
            <div class="booking-card__amount">LKR <%= String.format("%.2f", b.getTotalAmount()) %></div>
            <div style="display:flex; gap:10px; align-items:center;">
                <% if ("CONFIRMED".equals(b.getStatus())) { %>
                <a href="<%= ctx %>/booking/success?id=<%= b.getId() %>" class="btn btn--outline btn--sm">
                    🎟️ VIEW E-TICKET
                </a>
                <button type="button" class="btn btn--secondary btn--sm"
                        onclick="confirmAction('cancel-<%= b.getId() %>', 'Cancel reservation for <%= b.getMovieTitle() %>?')">
                    Cancel Booking
                </button>
                <form id="cancel-<%= b.getId() %>" method="post" action="<%= ctx %>/booking/cancel" style="display:none;">
                    <input type="hidden" name="bookingId" value="<%= b.getId() %>">
            </form>
            <% } else { %>
            <a href="<%= ctx %>/movies" class="btn btn--outline btn--sm">Book Again</a>
            <% } %>
        </div>
    </div>
    <% } %>
    <% } %>

</div>
</main>
<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
