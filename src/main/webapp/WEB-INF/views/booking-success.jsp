<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Booking, com.jmovie.model.Movie, com.jmovie.model.Showtime" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }

    Booking  booking  = (Booking)  request.getAttribute("booking");
    Movie    movie    = (Movie)    request.getAttribute("movie");
    Showtime showtime = (Showtime) request.getAttribute("showtime");
    String   ctx      = request.getContextPath();

    if (booking == null) {
        response.sendRedirect(ctx + "/booking");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful — Booking Confirmed — JMovie</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
    <style>
    @media print {
        .header, .footer, .no-print, .page-hd { display: none !important; }
        body, main, .page { background: #fff !important; color: #000 !important; }
        .eticket { border: 2px solid #000 !important; background: #fff !important; color: #000 !important; box-shadow: none !important; }
        .eticket * { color: #000 !important; }
    }
    .barcode-line {
        height: 48px;
        background: var(--text-light-1);
        display: inline-block;
        margin: 0 1.5px;
    }
    </style>
</head>
<body class="theme-frame">
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>

<main class="page">
<div class="container" style="max-width:860px;">

    <!-- Success Celebration Banner -->
    <div style="text-align:center; padding:32px 20px 40px;" class="no-print">
        <div style="width:72px; height:72px; background:var(--plasma-lime); color:var(--abyss); font-size:2.2rem; font-weight:900; display:inline-flex; align-items:center; justify-content:center; margin-bottom:20px; box-shadow:0 0 30px rgba(189,247,107,0.4);">
            ✓
        </div>
        <div class="mono-text text-xs" style="color:var(--plasma-lime); font-weight:700; letter-spacing:2px;">
            // TRANSACTION APPROVED &bull; MOCK GATEWAY 200 OK
        </div>
        <h1 class="section-title mt-2" style="font-size:2.4rem;">
            PAYMENT SUCCESSFUL!
        </h1>
        <p class="mono-text text-xs mt-2" style="color:var(--text-light-2); max-width:540px; margin:8px auto 0;">
            Your ticket reservation is confirmed and logged into the JMovie system. Your digital entry pass is generated below.
        </p>
    </div>

    <!-- DIGITAL E-TICKET -->
    <div class="eticket" style="background:#0e232b; border:1px solid var(--graphite-teal); margin-bottom:32px; position:relative; overflow:hidden;">
        
        <!-- Ticket Header Bar -->
        <div style="background:#061318; border-bottom:1px solid var(--graphite-teal); padding:16px 28px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">
            <div style="display:flex; align-items:center; gap:10px;">
                <span style="color:var(--plasma-lime); font-size:1.1rem; font-weight:900;">▶</span>
                <span class="mono-text" style="font-weight:700; letter-spacing:1px; color:var(--text-light-1);">JMOVIE CINEMAS ADMISSION PASS</span>
            </div>
            <span class="badge badge--green mono-text">PAID &amp; CONFIRMED</span>
        </div>

        <div style="padding:32px; display:grid; grid-template-columns:140px 1fr; gap:28px; align-items:start;">
            
            <!-- Poster -->
            <div>
                <% if (movie != null && movie.getPosterUrl() != null && !movie.getPosterUrl().isEmpty()) { %>
                <img src="<%= movie.getPosterUrl() %>" alt="<%= movie.getTitle() %>" style="width:100%; aspect-ratio:2/3; object-fit:cover; border:1px solid var(--graphite-teal);">
                <% } else { %>
                <div style="width:100%; aspect-ratio:2/3; background:var(--abyss); border:1px solid var(--graphite-teal); display:flex; align-items:center; justify-content:center; font-size:2rem;">
                    🎬
                </div>
                <% } %>
            </div>

            <!-- Ticket Core Details -->
            <div>
                <h2 style="font-size:1.8rem; font-weight:700; text-transform:uppercase; color:var(--text-light-1); line-height:1.15; margin-bottom:8px;">
                    <%= booking.getMovieTitle() %>
                </h2>
                
                <div class="mono-text text-xs" style="color:var(--plasma-lime); margin-bottom:20px;">
                    <% if (movie != null) { %><%= movie.getGenre().toUpperCase() %> &middot; <%= movie.getDurationFormatted() %><% } %>
                </div>

                <!-- 4 Column Grid for Screening Info -->
                <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(130px, 1fr)); gap:18px; padding:18px 0; border-top:1px solid var(--graphite-teal); border-bottom:1px solid var(--graphite-teal); margin-bottom:20px;">
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block; margin-bottom:4px;">SCREENING DATE</span>
                        <strong class="mono-text" style="color:var(--text-light-1); font-size:0.95rem;"><%= booking.getShowDate() %></strong>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block; margin-bottom:4px;">SCREENING TIME</span>
                        <strong class="mono-text" style="color:var(--plasma-lime); font-size:0.95rem;"><%= booking.getShowTime() %></strong>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block; margin-bottom:4px;">THEATRE HALL</span>
                        <strong class="mono-text" style="color:var(--text-light-1); font-size:0.95rem;"><%= booking.getTheatreHall() != null && !booking.getTheatreHall().isEmpty() ? booking.getTheatreHall() : "MAIN HALL" %></strong>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block; margin-bottom:4px;">RESERVED SEATS</span>
                        <strong class="mono-text" style="color:var(--plasma-lime); font-size:1.1rem;"><%= booking.getSeats() %></strong>
                    </div>
                </div>

                <!-- Transaction / Payment Meta -->
                <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(160px, 1fr)); gap:16px;">
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block;">BOOKING ID</span>
                        <span class="mono-text" style="color:var(--text-light-1); font-size:0.85rem;"><%= booking.getId() %></span>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block;">TRANSACTION REF</span>
                        <span class="mono-text" style="color:var(--ion-mint); font-size:0.85rem;"><%= booking.getTransactionId() != null && !booking.getTransactionId().isEmpty() ? booking.getTransactionId() : "TXN-APPROVED" %></span>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block;">PAYMENT METHOD</span>
                        <span class="mono-text" style="color:var(--text-light-1); font-size:0.85rem;"><%= booking.getPaymentMethod() %></span>
                    </div>
                    <div>
                        <span class="mono-text text-xs" style="color:var(--text-light-2); display:block;">AMOUNT PAID</span>
                        <span class="mono-text" style="color:var(--plasma-lime); font-size:1.1rem; font-weight:700;">LKR <%= String.format("%.2f", booking.getTotalAmount()) %></span>
                    </div>
                </div>

            </div>

        </div>

        <!-- Ticket Footer & Simulated Barcode -->
        <div style="background:#061318; border-top:1px dashed var(--graphite-teal); padding:20px 32px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px;">
            <div>
                <span class="mono-text text-xs" style="color:var(--text-light-2); display:block; margin-bottom:6px;">
                    ENTRY SCAN TOKEN (PRESENT AT GATE)
                </span>
                <!-- Barcode Graphics -->
                <div style="display:flex; align-items:center;">
                    <% int[] widths = {2, 4, 1, 3, 2, 5, 1, 4, 2, 3, 1, 4, 3, 2, 5, 2, 1, 3, 4, 2, 1, 3, 2, 4, 1, 5, 2, 3, 1, 4};
                       for (int w : widths) { %>
                    <span class="barcode-line" style="width:<%= w %>px;"></span>
                    <% } %>
                    <span class="mono-text text-xs" style="margin-left:14px; letter-spacing:3px; color:var(--text-light-2);"><%= booking.getId() %></span>
                </div>
            </div>
            <div class="mono-text text-xs" style="color:var(--text-light-2); text-align:right;">
                ISSUED: <%= booking.getBookingDate() %> &middot; JMOVIE SRL
            </div>
        </div>

    </div>

    <!-- Actions -->
    <div style="display:flex; justify-content:center; gap:16px; flex-wrap:wrap;" class="no-print">
        <button type="button" class="btn btn--primary" onclick="window.print()">
            🖨️ PRINT / SAVE PASS
        </button>
        <a href="<%= ctx %>/booking" class="btn btn--secondary">
            VIEW ALL MY BOOKINGS
        </a>
        <a href="<%= ctx %>/movies" class="btn btn--outline">
            BROWSE MORE MOVIES
        </a>
    </div>

</div>
</main>

<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
