<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Account Page</title>
</head>
<body>
    <%
        // Check if the user is logged in
        String authenticatedUser = (String) session.getAttribute("authenticatedUser");
        if (authenticatedUser == null) {
            response.sendRedirect("login.jsp"); // Redirect to login if not authenticated
        }

        // Database connection details
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";

        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        // Fetch user information
        String firstName = "", lastName = "", email = "", phoneNum = "", address = "", city = "", state = "", postalCode = "", country = "";
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, uid, pw);

            // Switch to the "orders" database
            Statement switchDbStmt = con.createStatement();
            switchDbStmt.execute("USE orders");

            // Query to fetch user details
            String sql = "SELECT firstName, lastName, email, phoneNum, address, city, state, postalCode, country " +
                         "FROM customer WHERE userid = ?";
            stmt = con.prepareStatement(sql);
            stmt.setString(1, authenticatedUser);
            rs = stmt.executeQuery();

            if (rs.next()) {
                firstName = rs.getString("firstName");
                lastName = rs.getString("lastName");
                email = rs.getString("email");
                phoneNum = rs.getString("phoneNum");
                address = rs.getString("address");
                city = rs.getString("city");
                state = rs.getString("state");
                postalCode = rs.getString("postalCode");
                country = rs.getString("country");
            }
        } catch (Exception ex) {
            out.println("<p>Error fetching user data: " + ex.getMessage() + "</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignore) {}
            try { if (con != null) con.close(); } catch (Exception ignore) {}
        }
    %>

    <h1>User Account Information</h1>
    <p>Welcome, <strong><%= authenticatedUser %></strong>!</p>

    <h3>Your Information:</h3>
    <table border="1">
        <tr><th>First Name</th><td><%= firstName %></td></tr>
        <tr><th>Last Name</th><td><%= lastName %></td></tr>
        <tr><th>Email</th><td><%= email %></td></tr>
        <tr><th>Phone Number</th><td><%= phoneNum %></td></tr>
        <tr><th>Address</th><td><%= address %></td></tr>
        <tr><th>City</th><td><%= city %></td></tr>
        <tr><th>State</th><td><%= state %></td></tr>
        <tr><th>Postal Code</th><td><%= postalCode %></td></tr>
        <tr><th>Country</th><td><%= country %></td></tr>
    </table>

    <h3>Update Your Information:</h3>
    <form method="post" action="user.jsp">
        <label for="newFirstName">First Name:</label>
        <input type="text" id="newFirstName" name="newFirstName" value="<%= firstName %>"><br><br>

        <label for="newLastName">Last Name:</label>
        <input type="text" id="newLastName" name="newLastName" value="<%= lastName %>"><br><br>

        <label for="newEmail">Email:</label>
        <input type="email" id="newEmail" name="newEmail" value="<%= email %>"><br><br>

        <label for="newPhoneNum">Phone Number:</label>
        <input type="text" id="newPhoneNum" name="newPhoneNum" value="<%= phoneNum %>"><br><br>

        <label for="newAddress">Address:</label>
        <input type="text" id="newAddress" name="newAddress" value="<%= address %>"><br><br>

        <label for="newCity">City:</label>
        <input type="text" id="newCity" name="newCity" value="<%= city %>"><br><br>

        <label for="newState">State:</label>
        <input type="text" id="newState" name="newState" value="<%= state %>"><br><br>

        <label for="newPostalCode">Postal Code:</label>
        <input type="text" id="newPostalCode" name="newPostalCode" value="<%= postalCode %>"><br><br>

        <label for="newCountry">Country:</label>
        <input type="text" id="newCountry" name="newCountry" value="<%= country %>"><br><br>

        <button type="submit">Update Information</button>
    </form>

    <%
        // Handle form submission for updating user information
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String newFirstName = request.getParameter("newFirstName");
            String newLastName = request.getParameter("newLastName");
            String newEmail = request.getParameter("newEmail");
            String newPhoneNum = request.getParameter("newPhoneNum");
            String newAddress = request.getParameter("newAddress");
            String newCity = request.getParameter("newCity");
            String newState = request.getParameter("newState");
            String newPostalCode = request.getParameter("newPostalCode");
            String newCountry = request.getParameter("newCountry");

            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                con = DriverManager.getConnection(url, uid, pw);

                Statement switchDbStmt = con.createStatement();
                switchDbStmt.execute("USE orders");

                String updateSql = "UPDATE customer SET firstName = ?, lastName = ?, email = ?, phoneNum = ?, address = ?, " +
                                   "city = ?, state = ?, postalCode = ?, country = ? WHERE userid = ?";
                stmt = con.prepareStatement(updateSql);
                stmt.setString(1, newFirstName);
                stmt.setString(2, newLastName);
                stmt.setString(3, newEmail);
                stmt.setString(4, newPhoneNum);
                stmt.setString(5, newAddress);
                stmt.setString(6, newCity);
                stmt.setString(7, newState);
                stmt.setString(8, newPostalCode);
                stmt.setString(9, newCountry);
                stmt.setString(10, authenticatedUser);

                int rowsUpdated = stmt.executeUpdate();

                if (rowsUpdated > 0) {
                    out.println("<p style='color: green;'>Your information has been updated successfully. Please <a href='user.jsp'>reload the page</a> to see the changes.</p>");
                } else {
                    out.println("<p style='color: red;'>Error: Unable to update your information. Please try again.</p>");
                }
            } catch (Exception ex) {
                out.println("<p style='color: red;'>Error updating user information: " + ex.getMessage() + "</p>");
            } finally {
                try { if (stmt != null) stmt.close(); } catch (Exception ignore) {}
                try { if (con != null) con.close(); } catch (Exception ignore) {}
            }
        }
    %>
</body>
</html>
