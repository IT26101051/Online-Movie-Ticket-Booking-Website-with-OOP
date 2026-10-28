<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.jmovie.model.Movie, com.jmovie.model.Showtime" %>
<%
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null) { response.sendRedirect(request.getContextPath() + "/auth/login"); return; }

    Movie    movie         = (Movie)    request.getAttribute("movie");
    Showtime showtime      = (Showtime) request.getAttribute("showtime");
    String   selectedSeats = (String)   request.getAttribute("selectedSeats");
    Double   totalAmount   = (Double)   request.getAttribute("totalAmount");
    Integer  quantity      = (Integer)  request.getAttribute("quantity");
    Integer  vipCount      = (Integer)  request.getAttribute("vipCount");
    Integer  regularCount  = (Integer)  request.getAttribute("regularCount");
    String   paymentError  = (String)   request.getAttribute("paymentError");
    String   ctx           = request.getContextPath();

    if (showtime == null || movie == null || selectedSeats == null || totalAmount == null) {
        response.sendRedirect(ctx + "/movies");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Gateway — <%= movie.getTitle() %> — JMovie</title>
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
        <a href="<%= ctx %>/booking/new?showtimeId=<%= showtime.getId() %>">SEATS</a>
        <span style="margin:0 8px; color:var(--graphite-teal);">/</span>
        <span style="color:var(--plasma-lime);">PAYMENT GATEWAY</span>
    </div>

    <!-- Header -->
    <div class="page-hd" style="display:flex; justify-content:space-between; align-items:flex-end; flex-wrap:wrap; gap:16px;">
        <div>
            <span class="mono-text text-xs" style="color:var(--plasma-lime); font-weight:700; letter-spacing:1.5px;">// STEP 02 : PAYMENT AUTHORIZATION</span>
            <h1 class="section-title mt-2">SECURE PAYMENT GATEWAY</h1>
            <p class="mono-text text-xs mt-2" style="color:var(--text-light-2);">
                Simulated Sandbox Gateway &middot; 256-Bit SSL Encryption Active
            </p>
        </div>
        <div class="mono-text text-xs" style="background:#0e232b; border:1px solid var(--graphite-teal); padding:8px 16px; color:var(--ion-mint);">
            🔒 SANDBOX DEMO ENVIRONMENT
        </div>
    </div>

    <% if (paymentError != null) { %>
    <div class="alert alert--error mono-text mb-4">
        <%= paymentError %>
    </div>
    <% } %>

    <div class="booking-layout">

        <!-- Left: Payment Form & Gateway -->
        <div>
            <div style="background:#0e232b; border:1px solid var(--graphite-teal); padding:32px;">
                
                <!-- Payment Method Tabs -->
                <div style="display:flex; gap:10px; margin-bottom:28px;">
                    <button type="button" id="tab-card" class="tab-btn--payment active" style="flex:1;" onclick="switchPaymentMethod('CARD')">
                        💳 CREDIT / DEBIT CARD
                    </button>
                    <button type="button" id="tab-wallet" class="tab-btn--payment" style="flex:1;" onclick="switchPaymentMethod('WALLET')">
                        📱 DIGITAL WALLET / EZ-CASH
                    </button>
                </div>

                <form id="payment-form" method="post" action="<%= ctx %>/booking/payment">
                    <input type="hidden" name="showtimeId" value="<%= showtime.getId() %>">
                    <input type="hidden" name="selectedSeats" value="<%= selectedSeats %>">
                    <input type="hidden" id="paymentMethod" name="paymentMethod" value="CARD">

                    <!-- CARD PAYMENT VIEW -->
                    <div id="card-payment-view">
                        
                        <!-- Test Card Banner -->
                        <div style="background:var(--abyss); border:1px dashed var(--graphite-teal); padding:16px; margin-bottom:24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">
                            <div>
                                <span class="mono-text text-xs" style="color:var(--plasma-lime); font-weight:700;">TEST CARD READY:</span>
                                <div class="mono-text text-xs" style="color:var(--text-light-2); margin-top:2px;">
                                    Card: <strong>4242 4242 4242 4242</strong> &middot; Exp: <strong>12/28</strong> &middot; CVV: <strong>123</strong>
                                </div>
                            </div>
                            <button type="button" class="btn btn--secondary btn--xs" onclick="autoFillTestCard()">
                                ⚡ AUTO-FILL TEST CARD
                            </button>
                        </div>

                        <div class="form-group">
                            <label class="form-label mono-text" for="cardHolder">CARDHOLDER NAME</label>
                            <input type="text" id="cardHolder" name="cardHolder" class="form-control"
                                   placeholder="Full Name as on card" value="<%= username.toUpperCase() %>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label mono-text" for="cardNumber">CARD NUMBER</label>
                            <div style="position:relative;">
                                <input type="text" id="cardNumber" name="cardNumber" class="form-control mono-text"
                                       placeholder="4242 4242 4242 4242" maxlength="19" required
                                       oninput="formatCardNumber(this)">
                                <span id="card-brand" class="mono-text text-xs" style="position:absolute; right:16px; top:12px; color:var(--plasma-lime); font-weight:700;">
                                    VISA / MASTER
                                </span>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group" style="margin-bottom:0">
                                <label class="form-label mono-text" for="expiry">EXPIRY DATE (MM/YY)</label>
                                <input type="text" id="expiry" name="expiry" class="form-control mono-text"
                                       placeholder="MM/YY" maxlength="5" required oninput="formatExpiry(this)">
                            </div>
                            <div class="form-group" style="margin-bottom:0">
                                <label class="form-label mono-text" for="cvv">SECURITY CODE (CVV)</label>
                                <input type="password" id="cvv" name="cvv" class="form-control mono-text"
                                       placeholder="123" maxlength="4" required>
                            </div>
                        </div>

                    </div>

                    <!-- DIGITAL WALLET VIEW -->
                    <div id="wallet-payment-view" style="display:none;">
                        <div style="background:var(--abyss); border:1px solid var(--graphite-teal); padding:16px; margin-bottom:24px;">
                            <span class="mono-text text-xs" style="color:var(--ion-mint); font-weight:700;">INSTANT MOBILE CHECKOUT:</span>
                            <div class="mono-text text-xs" style="color:var(--text-light-2); margin-top:4px;">
                                A payment prompt will be simulated to your mobile number.
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label mono-text">SELECT PROVIDER</label>
                            <select class="form-control mono-text" name="walletProvider">
                                <option value="EZ_CASH">Dialog eZ Cash</option>
                                <option value="MCASH">Mobitel mCash</option>
                                <option value="GENIE">FriMi / Genie / Bank App</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label mono-text" for="walletPhone">MOBILE NUMBER</label>
                            <input type="text" id="walletPhone" name="walletPhone" class="form-control mono-text"
                                   placeholder="07X XXXXXXX" value="0771234567">
                        </div>
                    </div>

                    <!-- Security & Info -->
                    <div style="margin-top:28px; padding-top:20px; border-top:1px solid var(--graphite-teal); display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">
                        <span class="mono-text text-xs" style="color:var(--text-light-2);">
                            🔒 NO REAL CHARGES WILL OCCUR (SANDBOX MOCK)
                        </span>
                        <div style="display:flex; gap:8px;">
                            <span class="badge" style="background:#152c34; border:1px solid var(--graphite-teal); font-size:0.7rem;">PCI-DSS</span>
                            <span class="badge" style="background:#152c34; border:1px solid var(--graphite-teal); font-size:0.7rem;">3D SECURE</span>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" id="pay-submit-btn" class="btn btn--primary btn--block" style="margin-top:24px; padding:16px; font-size:1rem;">
                        CONFIRM &amp; PAY LKR <%= String.format("%.2f", totalAmount) %> &rarr;
                    </button>

                </form>

                <div style="text-align:center; margin-top:20px;">
                    <a href="<%= ctx %>/booking/new?showtimeId=<%= showtime.getId() %>" class="mono-text text-xs" style="color:var(--text-light-2);">
                        &larr; CANCEL &amp; CHANGE SEATS
                    </a>
                </div>

            </div>
        </div>

        <!-- Right: Order Summary Sidebar -->
        <div>
            <div class="booking-summary" style="background:#0e232b; border:1px solid var(--graphite-teal); padding:28px;">
                <h3 class="mono-text" style="font-size:1.05rem; font-weight:700; color:var(--text-light-1); margin-bottom:20px; border-bottom:1px solid var(--graphite-teal); padding-bottom:12px;">
                    ORDER SUMMARY
                </h3>

                <!-- Movie Info -->
                <div style="display:flex; gap:16px; margin-bottom:20px; align-items:center;">
                    <% if (movie.getPosterUrl() != null && !movie.getPosterUrl().isEmpty()) { %>
                    <img src="<%= movie.getPosterUrl() %>" alt="<%= movie.getTitle() %>" style="width:64px; height:90px; object-fit:cover; border:1px solid var(--graphite-teal);">
                    <% } %>
                    <div>
                        <div style="font-size:1.05rem; font-weight:700; text-transform:uppercase; color:var(--text-light-1); line-height:1.2;">
                            <%= movie.getTitle() %>
                        </div>
                        <div class="mono-text text-xs mt-2" style="color:var(--plasma-lime);">
                            <%= movie.getGenre().toUpperCase() %> &middot; <%= movie.getDurationFormatted() %>
                        </div>
                    </div>
                </div>

                <div class="booking-summary__row mono-text">
                    <span>SCREENING</span>
                    <span style="color:var(--text-light-1);"><%= showtime.getDate() %> &middot; <%= showtime.getTime() %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>THEATRE HALL</span>
                    <span style="color:var(--text-light-1);"><%= showtime.getTheatreHall().toUpperCase() %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>SELECTED SEATS</span>
                    <span style="color:var(--plasma-lime); font-weight:700;"><%= selectedSeats %></span>
                </div>
                <div class="booking-summary__row mono-text">
                    <span>TOTAL TICKETS</span>
                    <span style="color:var(--text-light-1);"><%= quantity %> Ticket<%= quantity != 1 ? "s" : "" %></span>
                </div>

                <!-- Breakdown -->
                <div style="border-top:1px solid var(--graphite-teal); padding-top:14px; margin-top:14px;">
                    <% if (regularCount != null && regularCount > 0) { %>
                    <div class="booking-summary__row mono-text text-xs">
                        <span><%= regularCount %>x Standard Seat<%= regularCount > 1 ? "s" : "" %></span>
                        <span>LKR <%= String.format("%.2f", regularCount * showtime.getPrice()) %></span>
                    </div>
                    <% } %>
                    <% if (vipCount != null && vipCount > 0) { %>
                    <div class="booking-summary__row mono-text text-xs">
                        <span><%= vipCount %>x VIP Seat (Rows A,B)</span>
                        <span style="color:var(--ion-mint);">LKR <%= String.format("%.2f", vipCount * (showtime.getPrice() * 1.5)) %></span>
                    </div>
                    <% } %>
                    <div class="booking-summary__row mono-text text-xs">
                        <span>Gateway Processing Fee</span>
                        <span style="color:var(--plasma-lime);">FREE</span>
                    </div>
                </div>

                <!-- Total -->
                <div class="booking-summary__total mono-text" style="border-top:1px solid var(--graphite-teal); padding-top:16px; margin-top:16px;">
                    <span style="font-weight:700; color:var(--text-light-1);">AMOUNT DUE</span>
                    <span style="font-size:1.35rem; font-weight:700; color:var(--plasma-lime);">
                        LKR <%= String.format("%.2f", totalAmount) %>
                    </span>
                </div>
            </div>
        </div>

    </div>

</div>
</main>

<!-- Simulated Gateway Authorization Processing Modal -->
<div id="processing-modal" class="modal-overlay hidden" style="background:rgba(9, 26, 32, 0.95);">
    <div class="modal" style="max-width:440px; text-align:center; padding:40px 30px;">
        <div style="width:64px; height:64px; border:4px solid var(--graphite-teal); border-top-color:var(--plasma-lime); border-radius:50%; margin:0 auto 24px; animation:spin 0.8s linear infinite;"></div>
        <h3 class="mono-text" style="font-size:1.15rem; font-weight:700; color:var(--text-light-1); margin-bottom:8px;">
            AUTHORIZING PAYMENT...
        </h3>
        <p class="mono-text text-xs" style="color:var(--text-light-2); line-height:1.6;">
            Communicating with mock payment gateway. Securing ticket tokens and finalizing transaction...
        </p>
    </div>
</div>

<style>
@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
</style>

<script>
function switchPaymentMethod(method) {
    document.getElementById('paymentMethod').value = method;
    const cardTab   = document.getElementById('tab-card');
    const walletTab = document.getElementById('tab-wallet');
    const cardView   = document.getElementById('card-payment-view');
    const walletView = document.getElementById('wallet-payment-view');

    if (method === 'CARD') {
        cardTab.classList.add('active');
        walletTab.classList.remove('active');
        cardView.style.display = 'block';
        walletView.style.display = 'none';
        document.getElementById('cardNumber').required = true;
        document.getElementById('expiry').required = true;
        document.getElementById('cvv').required = true;
    } else {
        walletTab.classList.add('active');
        cardTab.classList.remove('active');
        cardView.style.display = 'none';
        walletView.style.display = 'block';
        document.getElementById('cardNumber').required = false;
        document.getElementById('expiry').required = false;
        document.getElementById('cvv').required = false;
    }
}

function autoFillTestCard() {
    document.getElementById('cardNumber').value = '4242 4242 4242 4242';
    document.getElementById('expiry').value = '12/28';
    document.getElementById('cvv').value = '123';
    document.getElementById('card-brand').textContent = 'VISA (TEST)';
}

function formatCardNumber(input) {
    let value = input.value.replace(/\D/g, '');
    let formatted = value.match(/.{1,4}/g)?.join(' ') || value;
    input.value = formatted.substring(0, 19);

    const brandEl = document.getElementById('card-brand');
    if (value.startsWith('4')) {
        brandEl.textContent = 'VISA';
    } else if (value.startsWith('5')) {
        brandEl.textContent = 'MASTERCARD';
    } else {
        brandEl.textContent = 'CARD';
    }
}

function formatExpiry(input) {
    let value = input.value.replace(/\D/g, '');
    if (value.length >= 2) {
        input.value = value.substring(0, 2) + '/' + value.substring(2, 4);
    } else {
        input.value = value;
    }
}

// Intercept submit to show simulated gateway loading spinner
document.getElementById('payment-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const modal = document.getElementById('processing-modal');
    modal.classList.remove('hidden');

    // Simulate 1.2s gateway delay
    setTimeout(() => {
        this.submit();
    }, 1200);
});
</script>

<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
