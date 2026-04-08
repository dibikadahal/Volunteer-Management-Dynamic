<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login — Volunteer Management System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

<div class="login-container">
    <h1>Volunteer Management System</h1>
    <h2>Sign In</h2>

    <% if (request.getAttribute("error") != null) { %>
        <p class="error-msg"><%= request.getAttribute("error") %></p>
    <% } %>

    <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" placeholder="Enter your email" required />
        </div>
        <div class="form-group">
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password" required />
        </div>
        <button type="submit" class="btn-login">Login</button>
    </form>

    <p class="register-link">New volunteer? <a href="${pageContext.request.contextPath}/register">Register here</a></p>
</div>

</body>
</html>