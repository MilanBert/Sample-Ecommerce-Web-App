<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create New Account</title>
    <script>
        // Frontend Validation
        function validateForm() {
            const email = document.getElementById("email").value;
            const phone = document.getElementById("phoneNum").value;
            const postalCode = document.getElementById("postalCode").value;

            // Email Validation
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!emailRegex.test(email)) {
                alert("Please enter a valid email address.");
                return false;
            }

            // Phone Number Validation
            const phoneRegex = /^\d{10,15}$/;
            if (!phoneRegex.test(phone)) {
                alert("Phone number must be 10-15 digits long.");
                return false;
            }

            // Postal Code Validation
            const postalRegex = /^[A-Za-z0-9\s-]+$/;
            if (!postalRegex.test(postalCode)) {
                alert("Please enter a valid postal code.");
                return false;
            }

            return true; // All validations passed
        }
    </script>
</head>
<body>
    <h1>Create a New Account</h1>

    <!-- Form with Frontend Validation -->
    <form method="post" action="userNew.jsp" onsubmit="return validateForm();">
        <label for="firstName">First Name:</label>
        <input type="text" id="firstName" name="firstName" required><br><br>

        <label for="lastName">Last Name:</label>
        <input type="text" id="lastName" name="lastName" required><br><br>

        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br><br>

        <label for="phoneNum">Phone Number:</label>
        <input type="text" id="phoneNum" name="phoneNum" required><br><br>

        <label for="address">Address:</label>
        <input type="text" id="address" name="address" required><br><br>

        <label for="city">City:</label>
        <input type="text" id="city" name="city" required><br><br>

        <label for="state">State:</label>
        <input type="text" id="state" name="state" required><br><br>

        <label for="postalCode">Postal Code:</label>
        <input type="text" id="postalCode" name="postalCode" required><br><br>

        <label for="country">Country:</label>
        <input type="text" id="country" name="country" required><br><br>

        <label for="userId">User ID:</label>
        <input type="text" id="userId" name="userId" required><br><br>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br><br>

        <button type="submit">Create Account</button>
    </form>

    <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phoneNum = request.getParameter("phoneNum");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String postalCode = request.getParameter("postalCode");
            String country = request.getParameter("country");
            String userId = request.getParameter("userId");
            String password = request.getParameter("password");

            // Backend Validation
            boolean isValid = true;
            String errorMessage = "";

            if (firstName == null || firstName.trim().isEmpty()) {
                isValid = false;
                errorMessage += "First name is required.<br>";
            }
            if (lastName == null || lastName.trim().isEmpty()) {
                isValid = false;
                errorMessage += "Last name is required.<br>";
            }
            if (email == null || !email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
                isValid = false;
                errorMessage += "Invalid email format.<br>";
            }
            if (phoneNum == null || !phoneNum.matches("\\d{10,15}")) {
                isValid = false;
                errorMessage += "Phone number must be 10-15 digits.<br>";
            }
            if (postalCode == null || !postalCode.matches("[A-Za-z0-9\\s-]+")) {
                isValid = false;
                errorMessage += "Invalid postal code.<br>";
            }

            if (isValid) {
                // Database interaction only if validation passed
                String url = "jdbc:sqlserver://cosc304_sqlserver:1433;TrustServerCertificate=True";
                String uid = "sa";
                String pw = "304#sa#pw";
                Connection con = null;
                PreparedStatement stmt = null;

                try {
                    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                    con = DriverManager.getConnection(url, uid, pw);

                    Statement switchDbStmt = con.createStatement();
                    switchDbStmt.execute("USE orders");

                    String sql = "INSERT INTO customer (firstName, lastName, email, phoneNum, address, city, state, postalCode, country, userid, password) " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    stmt = con.prepareStatement(sql);
                    stmt.setString(1, firstName);
                    stmt.setString(2, lastName);
                    stmt.setString(3, email);
                    stmt.setString(4, phoneNum);
                    stmt.setString(5, address);
                    stmt.setString(6, city);
                    stmt.setString(7, state);
                    stmt.setString(8, postalCode);
                    stmt.setString(9, country);
                    stmt.setString(10, userId);
                    stmt.setString(11, password);

                    int rowsInserted = stmt.executeUpdate();

                    if (rowsInserted > 0) {
                        out.println("<p>Account created successfully!</p>");
                    } else {
                        out.println("<p>Error: Unable to create account. Please try again.</p>");
                    }
                } catch (ClassNotFoundException | SQLException ex) {
                    out.println("<p>Error: " + ex.getMessage() + "</p>");
                } finally {
                    try { if (stmt != null) stmt.close(); } catch (Exception ignore) {}
                    try { if (con != null) con.close(); } catch (Exception ignore) {}
                }
            } else {
                // Display validation errors
                out.println("<p style='color: red;'>" + errorMessage + "</p>");
            }
        }
    %>
</body>
</html>
