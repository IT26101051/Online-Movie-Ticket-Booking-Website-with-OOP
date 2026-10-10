<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Notice — JMovie</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=4.0">
</head>
<body>
<jsp:include page="/WEB-INF/fragments/navbar.jsp"/>
<main class="page">
<div class="container" style="max-width:640px; text-align:center; padding-top:60px;">
    <div class="empty-state">
        <div class="empty-state__icon" style="color:#f87171;">⚠️</div>
        <div class="empty-state__title">Unexpected System Error</div>
        <div class="empty-state__text">
            <%= request.getAttribute("javax.servlet.error.message") != null
                ? request.getAttribute("javax.servlet.error.message")
                : "An unexpected condition occurred while processing your request." %>
        </div>
        <div style="display:flex; gap:12px; margin-top:16px;">
            <a href="<%= ctx %>/movies" class="btn btn--primary">Go to Homepage</a>
            <a href="javascript:history.back()" class="btn btn--secondary">Go Back</a>
        </div>
    </div>
</div>
</main>
<jsp:include page="/WEB-INF/fragments/footer.jsp"/>
<script src="<%= ctx %>/js/main.js?v=4.0"></script>
</body>
</html>
