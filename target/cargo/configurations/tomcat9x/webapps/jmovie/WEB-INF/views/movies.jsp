<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Movie, java.util.List" %>
<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");
    String searchQuery   = (String) request.getAttribute("searchQuery");
    String selectedGenre = (String) request.getAttribute("selectedGenre");
    String ctx = request.getContextPath();
    if (movies == null) movies = new java.util.ArrayList<Movie>();
    String[] genres = new String[]{"Action","Drama","Sci-Fi","Thriller","Comedy","Horror","Romance","Animation"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JMovie — Online Movie Ticket Booking System</title>
    <meta name="description" content="Experience seamless online movie ticket reservations and cinema premieres with JMovie.">
    <!-- Google Fonts: Space Grotesk, Inter & IBM Plex Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.4">
</head>
<body class="theme-frame">

<!-- Sticky Header Navigation -->
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>

<main class="main-content">

    <!-- HERO SLIDER SECTION (AUTOPLAY CAROUSEL WITH HIGH VISIBILITY BACKGROUND PHOTOS) -->
    <section class="hero-slider" id="hero-slider" aria-label="JMovie Cinema Carousel">
        <div class="slider-wrapper" id="slider-wrapper">

            <!-- Slide 2: Oppenheimer -->
            <div class="slide" data-index="1">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/oppenheimer-black-3840x2160-15916.jpeg');"></div>
            </div>

             <!-- Slide 4: Sadie Sink / Cinematic Art -->
            <div class="slide" data-index="3">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/sadie-sink-jean-7680x4320-26963.jpg');"></div>
            </div>

            <!-- Slide 3: Blade Runner 2049 -->
            <div class="slide" data-index="5">
               <div class="slide__bg" style="background-image: url('<%= ctx %>/images/wp12002181-bladerunner-2049-4k-computer-wallpapers.jpg');"></div>
            </div>

            <!-- Slide 4: Dune Part Two -->
            <div class="slide" data-index="6">
               <div class="slide__bg" style="background-image: url('<%= ctx %>/images/dune-2-timothee-5120x2880-15792.jpg');"></div>
            </div>


            <!-- Slide 1: House of the Dragon -->
            <div class="slide active" data-index="0">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/house-of-the-dragon-7680x3200-17464.jpg');"></div>
            </div>

            <!-- Slide 3: Peaky Blinders -->
            <div class="slide" data-index="2">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/peaky-blinders-tv-4491x2526-14931.jpg');"></div>
            </div>

           
            <!-- Slide 5: High-Res Movie Banner -->
            <div class="slide" data-index="4">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/1410488.jpg');"></div>
            </div>

            <!-- Slide 8: Cinema Artwork -->
            <div class="slide" data-index="7">
                <div class="slide__bg" style="background-image: url('<%= ctx %>/images/1409095.jpg');"></div>
            </div>




        </div>

        <div class="slide__overlay"></div>

        <!-- APP BRANDING OVERLAY CONTENT (CLEAN TEXT OVERLAY - NO BACKGROUND BOX) -->
        <div class="container-fluid hero-content-wrap">
            <div class="hero-text-container">
                <h1 class="hero-title">REDEFINING THE MOVIE BOOKING EXPERIENCE</h1>
                <div class="hero-actions">
                    <a href="#movies-section" class="btn btn--primary btn--lg">
                        <span>EXPLORE MOVIES</span>
                    </a>
                    <a href="<%= ctx %>/auth/register" class="btn btn--secondary btn--lg">
                        <span>GET STARTED</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- Carousel Controls -->
        <button type="button" class="slider-arrow slider-arrow--prev" id="slider-prev" aria-label="Previous Slide">&lsaquo;</button>
        <button type="button" class="slider-arrow slider-arrow--next" id="slider-next" aria-label="Next Slide">&rsaquo;</button>
        
        <div class="slider-dots" id="slider-dots">
            <button class="dot active" data-slide="0" aria-label="Slide 1"></button>
            <button class="dot" data-slide="1" aria-label="Slide 2"></button>
            <button class="dot" data-slide="2" aria-label="Slide 3"></button>
            <button class="dot" data-slide="3" aria-label="Slide 4"></button>
            <button class="dot" data-slide="4" aria-label="Slide 5"></button>
        </div>
    </section>

    <!-- MAIN MOVIES SECTION (FULL WIDTH) -->
    <section class="section section--movies" id="movies-section">
        <div class="container-fluid">
            
            <!-- Section Header & Filter Controls -->
            <div class="movies-header">
                <div class="movies-header__title-wrap">
                    <span class="section-tag mono-text">// NOW SHOWING & COMING SOON</span>
                    <h2 class="section-title">MOVIES AT <span class="highlight">JMOVIE</span></h2>
                </div>

                <!-- Tabs: Now Playing / Coming Soon -->
                <div class="movie-tabs" id="movie-tabs">
                    <button type="button" class="tab-btn active" data-tab="ALL">ALL MOVIES</button>
                    <button type="button" class="tab-btn" data-tab="NOW_SHOWING">NOW SHOWING</button>
                    <button type="button" class="tab-btn" data-tab="COMING_SOON">COMING SOON</button>
                </div>
            </div>

            <!-- Search & Genre Filter Bar -->
            <div class="filter-bar">
                <form method="get" action="<%= ctx %>/movies" class="search-form">
                    <div class="search-input-wrap">
                        <input id="search-input" name="q" type="text" class="search-input"
                               placeholder="Search movies, directors, or genres..."
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                    
                    <div class="select-wrap">
                        <select id="genre-filter" name="genre" class="genre-select" onchange="this.form.submit()">
                            <option value="">ALL GENRES</option>
                            <% for (String g : genres) { %>
                            <option value="<%= g %>" <%= g.equals(selectedGenre) ? "selected" : "" %>><%= g.toUpperCase() %></option>
                            <% } %>
                        </select>
                    </div>

                    <button type="submit" class="btn btn--primary">FILTER</button>
                    <% if ((searchQuery != null && !searchQuery.isEmpty()) || (selectedGenre != null && !selectedGenre.isEmpty())) { %>
                    <a href="<%= ctx %>/movies" class="btn btn--secondary">RESET</a>
                    <% } %>
                </form>
            </div>

            <!-- Results Info Bar -->
            <% if ((searchQuery != null && !searchQuery.isEmpty()) || (selectedGenre != null && !selectedGenre.isEmpty())) { %>
            <div class="search-results-info mono-text">
                <span>FILTER RESULTS: <strong>"<%= searchQuery != null ? searchQuery : selectedGenre %>"</strong></span>
                <span class="count-badge"><%= movies.size() %> MOVIE(S) FOUND</span>
            </div>
            <% } %>

            <!-- Movies Responsive Card Grid with Scroll Reveal Animation -->
            <% if (movies.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-state__icon">🎬</div>
                <h3 class="empty-state__title">NO MOVIES MATCH YOUR SEARCH</h3>
                <p class="empty-state__text">Try adjusting your keyword filter or browse all genres.</p>
                <a href="<%= ctx %>/movies" class="btn btn--secondary mt-3">RESET FILTERS</a>
            </div>
            <% } else { %>
            <div class="movie-grid" id="movie-grid">
                <% for (Movie m : movies) {
                    boolean isComingSoon = "COMING_SOON".equalsIgnoreCase(m.getStatus());
                %>
                <div class="movie-card scroll-reveal" data-status="<%= m.getStatus() %>" data-genre="<%= m.getGenre() %>" data-title="<%= m.getTitle().toLowerCase() %>">
                    <div class="movie-card__poster-wrap">
                        <% if (m.getPosterUrl() != null && !m.getPosterUrl().isEmpty()) { %>
                        <img src="<%= m.getPosterUrl() %>" alt="<%= m.getTitle() %>" class="movie-card__img" loading="lazy"
                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                        <div class="movie-card__placeholder" style="display:none;">🎬</div>
                        <% } else { %>
                        <div class="movie-card__placeholder">🎬</div>
                        <% } %>

                        <!-- Status Tag -->
                        <div class="movie-card__badge-wrap">
                            <% if (isComingSoon) { %>
                            <span class="badge badge--coming mono-text">COMING SOON</span>
                            <% } else { %>
                            <span class="badge badge--now mono-text">NOW SHOWING</span>
                            <% } %>
                        </div>

                        <!-- Hover Action Overlay -->
                        <div class="movie-card__overlay">
                            <a href="<%= ctx %>/movies/detail/<%= m.getId() %>" class="btn btn--secondary btn--sm">VIEW DETAILS</a>
                        </div>
                    </div>

                    <div class="movie-card__body">
                        <div class="movie-card__header">
                            <h3 class="movie-card__title">
                                <a href="<%= ctx %>/movies/detail/<%= m.getId() %>"><%= m.getTitle() %></a>
                            </h3>
                            <div class="movie-card__rating mono-text">
                                <span>★ <%= String.format("%.1f", m.getRating()) %></span>
                            </div>
                        </div>

                        <div class="movie-card__info mono-text">
                            <span class="genre"><%= m.getGenre() %></span>
                            <span class="dot">&bull;</span>
                            <span class="duration"><%= m.getDurationFormatted() %></span>
                        </div>

                        <div class="movie-card__footer">
                            <% if (isComingSoon) { %>
                            <div class="release-note mono-text">IN THEATERS <%= m.getReleaseDate() != null ? m.getReleaseDate() : "SOON" %></div>
                            <button type="button" class="btn btn--disabled btn--block mt-2" disabled>NOT AVAILABLE</button>
                            <% } else { %>
                            <a href="<%= ctx %>/movies/detail/<%= m.getId() %>" class="btn btn--primary btn--block mt-2">BUY TICKETS</a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

        </div>
    </section>

    <!-- CINEMAS & VENUES SECTION -->
    <section class="section section--cinemas" id="cinemas">
        <div class="container-fluid">
            <div class="section-header">
                <span class="section-tag mono-text">// PREMIUM VENUES</span>
                <h2 class="section-title">THE CINEMA <span class="highlight">EXPERIENCE</span></h2>
            </div>

            <div class="cinemas-grid">
                <!-- Cinema Venue 1 -->
                <div class="cinema-card scroll-reveal">
                    <div class="cinema-card__badge mono-text">IMAX WITH LASER</div>
                    <h3 class="cinema-card__title">Colombo Grand IMAX</h3>
                    <p class="cinema-card__desc">Experience groundbreaking 4K laser projection with dual 12-channel spatial audio, delivering pristine imagery and monumental sound for world-class blockbusters.</p>
                    <div class="cinema-card__features mono-text">
                        <span>70MM DUAL LASER</span> &bull; <span>480 SEATS</span> &bull; <span>CURVED SCREEN</span>
                    </div>
                    <div class="cinema-card__footer">
                        <span class="cinema-card__loc mono-text">HALL 01 &bull; LEVEL 3</span>
                        <a href="#movies-section" class="btn btn--outline btn--sm">VIEW SHOWTIMES</a>
                    </div>
                </div>

                <!-- Cinema Venue 2 -->
                <div class="cinema-card scroll-reveal">
                    <div class="cinema-card__badge mono-text">DOLBY ATMOS</div>
                    <h3 class="cinema-card__title">Dolby Soundstage Arena</h3>
                    <p class="cinema-card__desc">Equipped with 64 discrete speaker outputs moving audio with pinpoint precision all around you, including overhead, for an unprecedented sensory immersion.</p>
                    <div class="cinema-card__features mono-text">
                        <span>DOLBY 3D READY</span> &bull; <span>320 SEATS</span> &bull; <span>4K DIGITAL</span>
                    </div>
                    <div class="cinema-card__footer">
                        <span class="cinema-card__loc mono-text">HALL 02 &bull; LEVEL 2</span>
                        <a href="#movies-section" class="btn btn--outline btn--sm">VIEW SHOWTIMES</a>
                    </div>
                </div>

                <!-- Cinema Venue 3 -->
                <div class="cinema-card scroll-reveal">
                    <div class="cinema-card__badge mono-text">VIP LUXURY</div>
                    <h3 class="cinema-card__title">The Director's Club VIP</h3>
                    <p class="cinema-card__desc">Ultimate luxury with motorized plush leather recliners, personal tables, in-seat gourmet dining service, and intimate boutique seating.</p>
                    <div class="cinema-card__features mono-text">
                        <span>FULL RECLINER</span> &bull; <span>60 SEATS</span> &bull; <span>IN-SEAT DINING</span>
                    </div>
                    <div class="cinema-card__footer">
                        <span class="cinema-card__loc mono-text">HALL 03 &bull; PENTHOUSE</span>
                        <a href="#movies-section" class="btn btn--outline btn--sm">VIEW SHOWTIMES</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ARTICLES / NEWS SECTION (FULL WIDTH) -->
    <section class="section section--articles" id="articles">
        <div class="container-fluid">
            <div class="section-header">
                <span class="section-tag mono-text">// CINEMA EDITORIAL</span>
                <h2 class="section-title">EDITORIAL & INSIGHTS</h2>
            </div>

            <div class="articles-grid">
                <!-- Article Card 1 -->
                <article class="article-card scroll-reveal">
                    <div class="article-card__img-wrap">
                        <img src="<%= ctx %>/images/images.jpeg" alt="Article 1" loading="lazy">
                    </div>
                    <div class="article-card__body">
                        <div class="article-meta mono-text">
                            <span>OCTOBER 08, 2026</span> &bull; <span>5 MIN READ</span>
                        </div>
                        <h3 class="article-title">The Evolution of IMAX Dual Laser Projection Technology</h3>
                        <p class="article-snippet">Explore how dual laser 70mm projection revolutionizes color depth and contrast for modern blockbusters.</p>
                        <a href="#articles" class="read-more-link mono-text">READ FULL ARTICLE &rarr;</a>
                    </div>
                </article>

                <!-- Article Card 2 -->
                <article class="article-card scroll-reveal">
                    <div class="article-card__img-wrap">
                        <img src="<%= ctx %>/images/Ice-Cube_High-Rollers-Vol-1-Tour-_UK_04-scaled.jpg" alt="Article 2" loading="lazy">
                    </div>
                    <div class="article-card__body">
                        <div class="article-meta mono-text">
                            <span>SEPTEMBER 29, 2026</span> &bull; <span>4 MIN READ</span>
                        </div>
                        <h3 class="article-title">Why Sound Design Matters: Inside Hans Zimmer's Studio</h3>
                        <p class="article-snippet">How atmospheric soundscapes elevate cinematic storytelling and turn simple scenes into unforgettable experiences.</p>
                        <a href="#articles" class="read-more-link mono-text">READ FULL ARTICLE &rarr;</a>
                    </div>
                </article>

                <!-- Article Card 3 -->
                <article class="article-card scroll-reveal">
                    <div class="article-card__img-wrap">
                        <img src="<%= ctx %>/images/73751ae8edb5e89a7ff6b2d4ac1752f06fed62df225994a457c7cfac20dc8522._UR1920,1080_.jpg" alt="Article 3" loading="lazy">
                    </div>
                    <div class="article-card__body">
                        <div class="article-meta mono-text">
                            <span>SEPTEMBER 15, 2026</span> &bull; <span>6 MIN READ</span>
                        </div>
                        <h3 class="article-title">Top 10 Most Anticipated Sci-Fi Releases of Late 2026</h3>
                        <p class="article-snippet">From mind-bending thrillers to epic interstellar sagas, check out what films are coming to JMovie screens.</p>
                        <a href="#articles" class="read-more-link mono-text">READ FULL ARTICLE &rarr;</a>
                    </div>
                </article>
            </div>
        </div>
    </section>

</main>

<!-- Footer Fragment -->
<jsp:include page="/WEB-INF/fragments/footer.jsp"/>

</body>
</html>
