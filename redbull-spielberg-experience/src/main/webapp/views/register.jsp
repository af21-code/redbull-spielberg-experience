<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - RedBull Spielberg Experience</title>
    <link rel="stylesheet" href="styles/register.css">
</head>
<body>
<jsp:include page="header.jsp" />

<h2>Register</h2>
<form action="register" method="post">
    <label>First Name:</label>
    <input type="text" name="firstName" required>
    <br>
    <label>Last Name:</label>
    <input type="text" name="lastName" required>
    <br>
    <label>Email:</label>
    <input type="email" name="email" required>
    <br>
    <label>Phone:</label>
    <input type="text" name="phoneNumber">
    <br>
    <label>Password:</label>
    <input type="password" name="password" required>
    <br>
    <button type="submit">Register</button>
</form>

<% if (request.getAttribute("errorMessage") != null) { %>
    <p style="color:red;"><%= request.getAttribute("errorMessage") %></p>
<% } %>

<p>Already have an account? <a href="login.jsp">Login here</a></p>

<jsp:include page="footer.jsp" />
</body>
</html>