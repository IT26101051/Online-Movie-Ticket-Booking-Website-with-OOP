<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Movie, com.jmovie.model.Showtime, com.jmovie.model.Review, java.util.List" %>
<%
    Movie movie           = (Movie)       request.getAttribute("movie");
    List<Showtime> showtimes = (List<Showtime>) request.getAttribute("showtimes");
    List<Review>   reviews   = (List<Review>)   request.getAttribute("reviews");
    String ctx = request.getContextPath();
    String userId   = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (movie == null) { response.sendRedirect(ctx + "/movies"); return; }
    if (showtimes == null) showtimes = new java.util.ArrayList<Showtime>();
    if (reviews   == null) reviews   = new java.util.ArrayList<Review>();
    double avgRating = 0;
    if (!reviews.isEmpty()) {
        double sum = 0;
        for (Review r : reviews) { sum += r.getRating(); }
        avgRating = sum / reviews.size();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= movie.getTitle() %> — JMovie</title>
    <meta name="description" content="<%= movie.getDescription().length() > 150 ? movie.getDescription().substring(0,150) + "..." : movie.getDescription() %>">
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
        <span style="color:var(--plasma-lime);"><%= movie.getTitle().toUpperCase() %></span>
    </div>

    <!-- Movie Hero -->
    <div class="movie-hero">
        <div class="movie-hero__poster">
            <% if (movie.getPosterUrl() != null && !movie.getPosterUrl().isEmpty()) { %>
            <img src="<%= movie.getPosterUrl() %>" alt="<%= movie.getTitle() %>"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
            <div class="movie-hero__poster-placeholder" style="display:none;">🎬</div>
            <% } else { %>
            <div class="movie-hero__poster-placeholder">🎬</div>
            <% } %>
        </div>
        <div class="movie-hero__body">
            <h1 class="movie-hero__title"><%= movie.getTitle() %></h1>
            <div class="movie-hero__meta mono-text">
                <% if ("NOW_SHOWING".equals(movie.getStatus())) { %>
                <span class="badge badge--now">NOW SHOWING</span>
                <% } else if ("COMING_SOON".equals(movie.getStatus())) { %>
                <span class="badge badge--coming">COMING SOON</span>
                <% } %>
                <span class="badge" style="border:1px solid var(--graphite-teal); color:var(--text-light-2);"><%= movie.getGenre().toUpperCase() %></span>
                <span class="badge" style="border:1px solid var(--graphite-teal); color:var(--text-light-2);"><%= movie.getDurationFormatted() %></span>
                <div class="movie-hero__rating">★ <%= String.format("%.1f", movie.getRating()) %></div>
            </div>
            <p class="movie-hero__desc"><%= movie.getDescription() %></p>

            <div class="mono-text text-xs" style="color:var(--text-light-2); margin-bottom:24px; display:flex; gap:24px; flex-wrap:wrap;">
                <span>RELEASE DATE: <strong style="color:var(--text-light-1)"><%= movie.getReleaseDate() %></strong></span>
                <span>RUNTIME: <strong style="color:var(--text-light-1)"><%= movie.getDurationFormatted() %></strong></span>
                <span>USER RATING: <strong style="color:var(--plasma-lime)">
                    <%= reviews.isEmpty() ? "NO REVIEWS YET" : String.format("%.1f", avgRating) + " / 5 (" + reviews.size() + " REVIEWS)" %>
                </strong></span>
            </div>

            <% if (userId == null) { %>
            <div class="alert alert--info mono-text" style="max-width:460px;">
                <a href="<%= ctx %>/auth/login" style="color:var(--plasma-lime);font-weight:700;">SIGN IN</a>
                &nbsp;TO BOOK TICKETS FOR THIS SHOWTIME.
            </div>
            <% } %>
        </div>
    </div>

    <!-- Showtimes Section -->
    <div class="section" style="border-top:1px solid var(--graphite-teal);">
        <div class="section-hd">
            <div>
                <span class="section-tag mono-text">// AVAILABLE SHOWTIMES</span>
                <h2 class="section-title">SELECT A SHOWTIME</h2>
            </div>
        </div>
        <% if (showtimes.isEmpty()) { %>
        <div class="empty-state" style="padding:40px;">
            <div class="empty-state__icon">🕐</div>
            <h3 class="empty-state__title">NO SHOWTIMES CURRENTLY SCHEDULED</h3>
            <p class="empty-state__text">Check back later for updated theater showtimes.</p>
        </div>
        <% } else { %>
        <div class="showtime-list">
            <% for (Showtime st : showtimes) { %>
            <div class="showtime-item">
                <div class="showtime-item__info">
                    <div class="showtime-item__time mono-text"><%= st.getTime() %></div>
                    <div>
                        <div style="font-size:.95rem; font-weight:700; text-transform:uppercase;"><%= st.getTheatreHall() %></div>
                        <div class="showtime-item__seats mono-text text-xs" style="color:var(--text-light-2);">
                            <%= st.getDate() %> &middot;
                            <%= st.getAvailableSeats() %> / <%= st.getTotalSeats() %> SEATS AVAILABLE
                        </div>
                    </div>
                </div>
                <div class="showtime-item__right">
                    <div class="showtime-item__price mono-text">LKR <%= String.format("%.0f", st.getPrice()) %>+</div>
                    <% if (userId != null && st.isAvailable()) { %>
                    <a href="<%= ctx %>/booking/new?showtimeId=<%= st.getId() %>"
                       class="btn btn--primary btn--sm">SELECT SEATS</a>
                    <% } else if (!st.isAvailable()) { %>
                    <span class="badge" style="background:var(--error); color:#fff;">SOLD OUT</span>
                    <% } else { %>
                    <a href="<%= ctx %>/auth/login" class="btn btn--outline btn--sm">SIGN IN TO BOOK</a>
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- Reviews Section -->
    <div class="section">
        <div class="section-hd" style="display:flex; justify-content:space-between; align-items:flex-end;">
            <div>
                <span class="section-tag mono-text">// USER AUDIENCE REVIEWS</span>
                <h2 class="section-title">REVIEWS (<%= reviews.size() %>)</h2>
            </div>
            <% if (userId != null) { %>
            <button class="btn btn--primary btn--sm" data-open="review-modal">WRITE A REVIEW</button>
            <% } %>
        </div>

        <% if (reviews.isEmpty()) { %>
        <div class="empty-state" style="padding:40px;">
            <div class="empty-state__icon">✍️</div>
            <h3 class="empty-state__title">NO USER REVIEWS YET</h3>
            <p class="empty-state__text">Be the first verified viewer to post a review for <%= movie.getTitle() %>.</p>
        </div>
        <% } else { %>
        <% for (Review r : reviews) { %>
        <div class="review-card">
            <div class="review-card__hd">
                <div>
                    <div class="review-card__user">
                        <%= r.getUsername().toUpperCase() %>
                        &nbsp;<span class="badge mono-text" style="background:var(--graphite-teal); color:var(--ion-mint);">
                            <%= r.getDisplayBadge().toUpperCase() %>
                        </span>
                    </div>
                    <div class="review-card__date mono-text text-xs" style="color:var(--text-light-2);"><%= r.getCreatedAt() %></div>
                </div>
                <div class="review-card__stars mono-text" style="color:var(--plasma-lime); font-weight:700;"><%= r.getStars() %></div>
            </div>
            <div class="review-card__text"><%= r.getComment() %></div>
            <% if (userId != null && userId.equals(r.getUserId())) { %>
            <div style="margin-top:12px;">
                <form method="post" action="<%= ctx %>/review/delete" style="display:inline;">
                    <input type="hidden" name="reviewId" value="<%= r.getId() %>">
                    <input type="hidden" name="movieId"  value="<%= movie.getId() %>">
                    <button type="button" class="btn btn--secondary btn--xs"
                            onclick="confirmAction('del-rev-<%= r.getId() %>', 'Delete your review?')"
                            style="color:var(--error);border-color:var(--graphite-teal);">DELETE</button>
                </form>
                <form id="del-rev-<%= r.getId() %>" method="post" action="<%= ctx %>/review/delete" style="display:none;">
                    <input type="hidden" name="reviewId" value="<%= r.getId() %>">
                    <input type="hidden" name="movieId"  value="<%= movie.getId() %>">
                </form>
            </div>
            <% } %>
        </div>
        <% } %>
        <% } %>
    </div>

</div>
</main>

<!-- Review Modal -->
<% if (userId != null) { %>
<div id="review-modal" class="modal-overlay hidden">
    <div class="modal">
        <div class="modal__hd">
            <span class="modal__title mono-text">WRITE REVIEW FOR "<%= movie.getTitle().toUpperCase() %>"</span>
            <button class="modal__close" data-close>&times;</button>
        </div>
        <form method="post" action="<%= ctx %>/review/add">
            <div class="modal__body">
                <input type="hidden" name="movieId"    value="<%= movie.getId() %>">
                <input type="hidden" name="movieTitle" value="<%= movie.getTitle() %>">
                <input type="hidden" id="rating-val"   name="rating" value="5">

                <div class="form-group">
                    <label class="form-label mono-text">YOUR RATING</label>
                    <div class="star-input" data-input="rating-val">
                        <button type="button">★</button>
                        <button type="button">★</button>
                        <button type="button">★</button>
                        <button type="button">★</button>
                        <button type="button">★</button>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label mono-text" for="review-comment">YOUR COMMENTS</label>
                    <textarea id="review-comment" name="comment" class="form-control"
                              placeholder="Share your thoughts about this movie..." required></textarea>
                </div>
            </div>
            <div class="modal__ft">
                <button type="button" class="btn btn--secondary" data-close>CANCEL</button>
                <button type="submit" class="btn btn--primary">SUBMIT REVIEW</button>
            </div>
        </form>
    </div>
</div>
<% } %>

<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
