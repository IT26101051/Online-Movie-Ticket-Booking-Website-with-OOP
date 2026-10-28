<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Movie, com.jmovie.model.Showtime" %>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }

    Movie    movie    = (Movie)    request.getAttribute("movie");
    Showtime showtime = (Showtime) request.getAttribute("showtime");
    String   ctx      = request.getContextPath();
    String   error    = request.getParameter("error");

    if (showtime == null || movie == null) { response.sendRedirect(ctx + "/movies"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select Seats — <%= movie.getTitle() %> — JMovie</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body class="theme-frame">
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>

<main class="page">
<div class="container-fluid">

    <!-- Breadcrumb -->
    <div class="mono-text text-xs mb-4" style="color:var(--text-light-2);">
        <a href="<%= ctx %>/movies">MOVIES</a>
        <span style="margin:0 8px; color:var(--graphite-teal);">/</span>
        <a href="<%= ctx %>/movies/detail/<%= movie.getId() %>"><%= movie.getTitle().toUpperCase() %></a>
        <span style="margin:0 8px; color:var(--graphite-teal);">/</span>
        <span style="color:var(--plasma-lime);">SELECT SEATS</span>
    </div>

    <div class="page-hd" style="border-bottom:1px solid var(--graphite-teal); margin-bottom:32px;">
        <h1 class="section-title">SELECT YOUR SEATS</h1>
        <p class="mono-text text-xs mt-2" style="color:var(--text-light-2);">
            <%= movie.getTitle().toUpperCase() %> &nbsp;&middot;&nbsp;
            <%= showtime.getDate() %> &nbsp;&middot;&nbsp;
            <%= showtime.getTime() %> &nbsp;&middot;&nbsp;
            <%= showtime.getTheatreHall().toUpperCase() %>
        </p>
    </div>

    <% if ("noseats".equals(error)) { %>
    <div class="alert alert--error mono-text mb-4">PLEASE SELECT AT LEAST ONE SEAT TO PROCEED.</div>
    <% } %>

    <div class="booking-layout">

        <!-- Seat Map -->
        <div>
            <div class="seat-map"
                 id="seat-map"
                 data-price="<%= showtime.getPrice() %>"
                 data-booked="<%= showtime.getBookedSeats() %>"
                 data-total="<%= showtime.getTotalSeats() %>">

                <!-- Screen Indicator -->
                <div class="seat-map__screen">
                    <div class="seat-map__bar" style="background:var(--plasma-lime); height:2px;"></div>
                    <div class="seat-map__label mono-text" style="color:var(--plasma-lime);">S C R E E N</div>
                </div>

                <!-- Seat Grid (Rendered by JS) -->
                <div id="seat-grid" class="seat-grid"></div>

                <!-- Legend -->
                <div class="seat-legend mono-text text-xs">
                    <div class="seat-legend__item">
                        <div class="seat-legend__dot" style="background:var(--graphite-teal);border:1px solid var(--graphite-teal);"></div>
                        AVAILABLE (LKR <%= String.format("%.0f", showtime.getPrice()) %>)
                    </div>
                    <div class="seat-legend__item">
                        <div class="seat-legend__dot" style="background:var(--ion-mint);border:1px solid var(--ion-mint);"></div>
                        VIP (ROWS A,B - 1.5x)
                    </div>
                    <div class="seat-legend__item">
                        <div class="seat-legend__dot" style="background:var(--plasma-lime);border:1px solid var(--plasma-lime);"></div>
                        SELECTED
                    </div>
                    <div class="seat-legend__item">
                        <div class="seat-legend__dot" style="background:var(--abyss);border:1px solid var(--graphite-teal);opacity:.4;"></div>
                        OCCUPIED
                    </div>
                </div>
            </div>
        </div>

        <!-- Booking Summary & Form -->
        <div>
            <div class="booking-summary" style="background:var(--graphite-teal); border:1px solid var(--graphite-teal); padding:24px;">
                <h3 class="section-title text-sm mb-4" style="font-size:1.1rem; color:var(--text-light-1);">BOOKING SUMMARY</h3>

                <div class="booking-summary__row mono-text">
                    <span>MOVIE</span>
                    <span style="text-align:right;max-width:180px;color:var(--text-light-1);" class="truncate"><%= movie.getTitle().toUpperCase() %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>DATE & TIME</span>
                    <span style="color:var(--text-light-1);"><%= showtime.getDate() %> <%= showtime.getTime() %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>HALL</span>
                    <span style="color:var(--text-light-1);"><%= showtime.getTheatreHall().toUpperCase() %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>SEATS</span>
                    <span id="sel-seats" style="color:var(--plasma-lime);text-align:right;font-weight:700;">NONE</span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>QUANTITY</span>
                    <span id="sel-qty" style="color:var(--text-light-1);">0</span>
                </div>

                <div class="booking-summary__total mono-text" style="border-top:1px solid var(--abyss); padding-top:16px; margin-top:16px; color:var(--plasma-lime); font-size:1.1rem;">
                    <span>TOTAL</span>
                    <span id="sel-total">LKR 0.00</span>
                </div>

                <form method="post" action="<%= ctx %>/booking/checkout" style="margin-top:24px;">
                    <input type="hidden" name="showtimeId"    value="<%= showtime.getId() %>">
                    <input type="hidden" name="selectedSeats" id="selectedSeats" value="">
                    <button type="submit" id="confirm-btn" class="btn btn--primary btn--block" disabled>
                        PROCEED TO PAYMENT &rarr;
                    </button>
                </form>

                <p class="mono-text text-xs text-center mt-3" style="color:var(--text-light-2);">MAXIMUM 8 SEATS PER TRANSACTION</p>
            </div>
        </div>

    </div>

</div>
</main>
<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
