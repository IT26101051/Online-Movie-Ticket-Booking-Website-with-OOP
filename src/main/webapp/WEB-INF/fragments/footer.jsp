<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer class="footer" id="footer">
    <div class="container-fluid">
        <div class="footer-grid">
            <!-- Brand Column -->
            <div class="footer-col footer-col--brand">
                <a href="<%= request.getContextPath() %>/movies" class="navbar__logo mb-3">
                    J<strong>MOVIE</strong>
                </a>
                <p class="footer-about">
                    JMovie is your premier digital movie ticket booking platform. Reserve real-time seat locations, explore now showing blockbusters, and stay updated with cinema editorials.
                </p>
                <div class="social-links mt-4">
                    <a href="#" class="social-btn" aria-label="Facebook">FB</a>
                    <a href="#" class="social-btn" aria-label="Twitter">TW</a>
                    <a href="#" class="social-btn" aria-label="Instagram">IG</a>
                    <a href="#" class="social-btn" aria-label="YouTube">YT</a>
                </div>
            </div>

            <!-- Head Office & Contact -->
            <div class="footer-col">
                <h4 class="footer-title mono-text">HEADQUARTERS</h4>
                <ul class="footer-info mono-text">
                    <li>NO. 45 CINEMA AVENUE, COLOMBO 03</li>
                    <li>SUPPORT@JMOVIE.LK</li>
                    <li>+94 11 234 5678 / +94 77 123 4567</li>
                    <li>HOURS: 08:00 &ndash; 23:00 DAILY</li>
                </ul>
            </div>

            <!-- Quick Links -->
            <div class="footer-col">
                <h4 class="footer-title mono-text">NAVIGATION</h4>
                <ul class="footer-links mono-text">
                    <li><a href="<%= request.getContextPath() %>/movies">NOW SHOWING</a></li>
                    <li><a href="<%= request.getContextPath() %>/movies">COMING SOON</a></li>
                    <li><a href="#articles">EDITORIAL BLOG</a></li>
                </ul>
            </div>

            <!-- Support & Legal -->
            <div class="footer-col">
                <h4 class="footer-title mono-text">LEGAL & HELP</h4>
                <ul class="footer-links mono-text">
                    <li><a href="#">HELP & FAQ</a></li>
                    <li><a href="#">TERMS OF USE</a></li>
                    <li><a href="#">PRIVACY POLICY</a></li>
                    <li><a href="#">REFUND POLICY</a></li>
                </ul>
            </div>
        </div>

        <div class="footer-bottom mono-text">
            <p>&copy; <%= java.time.Year.now().getValue() %> JMOVIE. ALL RIGHTS RESERVED. SE1020 OOP PROJECT.</p>
            <div class="footer-bottom__badges">
                <span>🔒 256-BIT SSL ENCRYPTED</span>
            </div>
        </div>
    </div>
</footer>
<script src="<%= request.getContextPath() %>/js/main.js?v=4.5"></script>
