/* ═══════════════════════════════════════════════════════════════
   TAKTIKBOOK / FRAME — Main Interactive JavaScript
   Minimal Scroll Reveal, Hero Carousel, Mobile Drawer & Seat Map
   ═══════════════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {
    initHeroSlider();
    initMobileDrawer();
    initMovieTabs();
    initLiveSearch();
    initScrollReveal();
    checkToasts();
    initModals();
    initSeatMap();
    initStarRating();
    highlightNav();
});

/* ─── 1. HERO SLIDER CAROUSEL (IMAGE AUTOPLAY) ─────────────────── */
function initHeroSlider() {
    const slider = document.getElementById('hero-slider');
    if (!slider) return;

    const slides   = slider.querySelectorAll('.slide');
    const dots     = slider.querySelectorAll('.slider-dots .dot');
    const prevBtn  = document.getElementById('slider-prev');
    const nextBtn  = document.getElementById('slider-next');
    let currentIndex = 0;
    let autoplayTimer = null;
    const INTERVAL = 3200;

    if (slides.length <= 1) return;

    function goToSlide(index) {
        if (index < 0) index = slides.length - 1;
        if (index >= slides.length) index = 0;

        slides.forEach((slide, i) => {
            slide.classList.toggle('active', i === index);
        });

        dots.forEach((dot, i) => {
            dot.classList.toggle('active', i === index);
        });

        currentIndex = index;
    }

    // The HTML order is the playback order. Reordering the slide markup should
    // not depend on stale active classes or data-index values.
    goToSlide(0);

    function nextSlide() { goToSlide(currentIndex + 1); }
    function prevSlide() { goToSlide(currentIndex - 1); }

    function startAutoplay() {
        stopAutoplay();
        autoplayTimer = setInterval(nextSlide, INTERVAL);
    }

    function stopAutoplay() {
        if (autoplayTimer) clearInterval(autoplayTimer);
    }

    if (nextBtn) nextBtn.addEventListener('click', () => { nextSlide(); startAutoplay(); });
    if (prevBtn) prevBtn.addEventListener('click', () => { prevSlide(); startAutoplay(); });

    dots.forEach((dot, i) => {
        dot.addEventListener('click', () => {
            goToSlide(i);
            startAutoplay();
        });
    });

    // Touch Swipe Support for Mobile
    let touchStartX = 0;
    slider.addEventListener('touchstart', e => { touchStartX = e.changedTouches[0].screenX; }, { passive: true });
    slider.addEventListener('touchend', e => {
        const touchEndX = e.changedTouches[0].screenX;
        if (touchStartX - touchEndX > 50) nextSlide();
        else if (touchEndX - touchStartX > 50) prevSlide();
    }, { passive: true });

    startAutoplay();
}

/* ─── 2. MINIMAL SCROLL REVEAL ANIMATION ────────────────────────── */
function initScrollReveal() {
    const revealElements = document.querySelectorAll('.scroll-reveal');
    if (!revealElements.length) return;

    if ('IntersectionObserver' in window) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry, index) => {
                if (entry.isIntersecting) {
                    // Minimal staggered reveal delay based on card position
                    setTimeout(() => {
                        entry.target.classList.add('revealed');
                    }, (index % 4) * 80);
                    observer.unobserve(entry.target);
                }
            });
        }, {
            threshold: 0.12,
            rootMargin: '0px 0px -40px 0px'
        });

        revealElements.forEach(el => observer.observe(el));
    } else {
        // Fallback for non-observer environments
        revealElements.forEach(el => el.classList.add('revealed'));
    }
}

/* ─── 3. MOBILE SIDE DRAWER MENU ───────────────────────────────── */
function initMobileDrawer() {
    const toggleBtn  = document.getElementById('drawer-toggle');
    const closeBtn   = document.getElementById('drawer-close');
    const drawer     = document.getElementById('mobile-drawer');
    const overlay    = document.getElementById('drawer-overlay');

    if (!drawer || !toggleBtn) return;

    function openDrawer() {
        drawer.classList.add('active');
        if (overlay) overlay.classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeDrawer() {
        drawer.classList.remove('active');
        if (overlay) overlay.classList.remove('active');
        document.body.style.overflow = '';
    }

    toggleBtn.addEventListener('click', openDrawer);
    if (closeBtn) closeBtn.addEventListener('click', closeDrawer);
    if (overlay) overlay.addEventListener('click', closeDrawer);

    document.addEventListener('keydown', e => {
        if (e.key === 'Escape' && drawer.classList.contains('active')) closeDrawer();
    });

    drawer.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', closeDrawer);
    });
}

/* ─── 4. MOVIE TAB FILTERING ("NOW PLAYING" / "COMING SOON") ────── */
function initMovieTabs() {
    const tabBtns = document.querySelectorAll('.movie-tabs .tab-btn');
    const cards   = document.querySelectorAll('#movie-grid .movie-card');

    if (!tabBtns.length || !cards.length) return;

    tabBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const filter = btn.dataset.tab;
            tabBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            cards.forEach(card => {
                const status = card.dataset.status;
                if (filter === 'ALL' || status === filter) {
                    card.style.display = 'flex';
                    // Re-trigger reveal animation if hidden before
                    card.classList.add('revealed');
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });
}

/* ─── 5. CLIENT-SIDE LIVE SEARCH FILTER ────────────────────────── */
function initLiveSearch() {
    const searchInp = document.getElementById('search-input');
    const cards     = document.querySelectorAll('#movie-grid .movie-card');

    if (!searchInp || !cards.length) return;

    searchInp.addEventListener('input', () => {
        const query = searchInp.value.toLowerCase().trim();
        cards.forEach(card => {
            const title = (card.dataset.title || '').toLowerCase();
            const genre = (card.dataset.genre || '').toLowerCase();
            if (title.includes(query) || genre.includes(query)) {
                card.style.display = 'flex';
                card.classList.add('revealed');
            } else {
                card.style.display = 'none';
            }
        });
    });
}

/* ─── 6. TOAST NOTIFICATIONS ────────────────────────────────────── */
function checkToasts() {
    const p = new URLSearchParams(location.search);
    const toasts = {
        'registered': ['Account created! You can now sign in.', 'success'],
        'loggedout':  ['Signed out successfully.', 'info'],
        'booked':     ['Booking confirmed! Enjoy your movie.', 'success'],
        'cancelled':  ['Booking cancelled.', 'info'],
        'saved':      ['Changes saved successfully.', 'success'],
        'deleted':    ['Deleted successfully.', 'info'],
        'reviewadded':['Review submitted for approval!', 'success'],
    };
    const msg = p.get('msg');
    const err = p.get('error');
    if (msg && toasts[msg]) showToast(...toasts[msg]);
    if (err === 'unauthorized') showToast('Please sign in to continue.', 'error');
}

function showToast(message, type = 'info') {
    let wrap = document.querySelector('.toast-wrap');
    if (!wrap) { wrap = document.createElement('div'); wrap.className = 'toast-wrap'; document.body.appendChild(wrap); }

    const t = document.createElement('div');
    t.className = 'toast';
    t.textContent = message;
    const colors = { success: '#32D6A0', error: '#D95757', info: '#BDF76B' };
    t.style.borderLeftColor = colors[type] || '#BDF76B';
    t.style.borderLeftWidth = '4px';
    t.style.borderRadius = '0px';
    wrap.appendChild(t);

    setTimeout(() => { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; setTimeout(() => t.remove(), 300); }, 3500);
}

/* ─── 7. SEAT MAP SELECTION ────────────────────────────────────── */
let selectedSeats = [];
const VIP_ROWS    = ['A', 'B'];
const VIP_MULTI   = 1.5;
let   basePrice   = 0;

function initSeatMap() {
    const mapEl = document.getElementById('seat-map');
    if (!mapEl) return;

    basePrice = parseFloat(mapEl.dataset.price || 0);
    const bookedStr  = mapEl.dataset.booked || '';
    const booked     = bookedStr ? bookedStr.split(',').map(s => s.trim()).filter(Boolean) : [];
    const totalSeats = parseInt(mapEl.dataset.total || 80);
    const cols       = 10;
    const rows       = Math.ceil(totalSeats / cols);
    const LABELS     = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    const grid = document.getElementById('seat-grid');
    if (!grid) return;

    grid.innerHTML = '';
    for (let r = 0; r < rows; r++) {
        const rowLabel = LABELS[r];
        const rowEl    = document.createElement('div');
        rowEl.className = 'seat-row';

        const lbl = document.createElement('span');
        lbl.className = 'seat-row__lbl';
        lbl.textContent = rowLabel;
        rowEl.appendChild(lbl);

        for (let c = 1; c <= cols; c++) {
            if (c === 6) {
                const gap = document.createElement('div');
                gap.className = 'seat-gap';
                rowEl.appendChild(gap);
            }
            const seatId = rowLabel + c;
            const btn    = document.createElement('button');
            btn.type     = 'button';
            btn.className = 'seat' + (VIP_ROWS.includes(rowLabel) ? ' seat--vip' : '');
            btn.dataset.id = seatId;
            btn.title = seatId + (VIP_ROWS.includes(rowLabel) ? ' (VIP - 1.5x)' : '');
            btn.textContent = c;

            if (booked.includes(seatId)) {
                btn.classList.add('seat--booked');
                btn.disabled = true;
            } else {
                btn.addEventListener('click', () => toggleSeat(btn, seatId));
            }
            rowEl.appendChild(btn);
        }
        grid.appendChild(rowEl);
    }
    updateSummary();
}

function toggleSeat(btn, seatId) {
    const idx = selectedSeats.indexOf(seatId);
    if (idx > -1) {
        selectedSeats.splice(idx, 1);
        btn.classList.remove('seat--selected');
    } else {
        if (selectedSeats.length >= 8) { showToast('Max 8 seats per booking.', 'error'); return; }
        selectedSeats.push(seatId);
        btn.classList.add('seat--selected');
    }
    updateSummary();
}

function updateSummary() {
    let total = 0, qty = 0;
    selectedSeats.forEach(id => {
        const isVip = VIP_ROWS.includes(id.charAt(0));
        total += isVip ? basePrice * VIP_MULTI : basePrice;
        qty++;
    });

    const seatsEl  = document.getElementById('sel-seats');
    const totalEl  = document.getElementById('sel-total');
    const qtyEl    = document.getElementById('sel-qty');
    const inputEl  = document.getElementById('selectedSeats');
    const confirmEl= document.getElementById('confirm-btn');

    if (seatsEl)  seatsEl.textContent  = qty > 0 ? selectedSeats.join(', ') : 'None';
    if (totalEl)  totalEl.textContent  = 'LKR ' + total.toFixed(2);
    if (qtyEl)    qtyEl.textContent    = qty;
    if (inputEl)  inputEl.value        = selectedSeats.join(',');
    if (confirmEl) confirmEl.disabled  = qty === 0;
}

/* ─── 8. MODALS & STAR RATING ──────────────────────────────────── */
function initModals() {
    document.querySelectorAll('[data-open]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modal = document.getElementById(btn.dataset.open);
            if (!modal) return;
            Object.keys(btn.dataset).forEach(key => {
                if (key === 'open') return;
                const field = modal.querySelector(`[name="${key}"]`);
                if (field) field.value = btn.dataset[key];
            });
            modal.classList.remove('hidden');
        });
    });
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => { if (e.target === overlay) overlay.classList.add('hidden'); });
    });
    document.querySelectorAll('[data-close]').forEach(btn => {
        btn.addEventListener('click', () => {
            const modal = btn.closest('.modal-overlay');
            if (modal) modal.classList.add('hidden');
        });
    });
}

function initStarRating() {
    document.querySelectorAll('.star-input').forEach(container => {
        const inputId = container.dataset.input;
        const stars   = container.querySelectorAll('button');
        stars.forEach((star, i) => {
            star.addEventListener('click', () => {
                const val = i + 1;
                if (inputId) {
                    const inp = document.getElementById(inputId);
                    if (inp) inp.value = val;
                }
                stars.forEach((s, j) => s.classList.toggle('active', j < val));
            });
        });
    });
}

function highlightNav() {
    const path = location.pathname;
    document.querySelectorAll('.navbar__link').forEach(link => {
        const href = link.getAttribute('href') || '';
        if (href && path.includes(href) && href !== '/') link.classList.add('active');
    });
}
