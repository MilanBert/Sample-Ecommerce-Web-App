<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Ray's Grocery Main Page</title>
</head>
<body>
    <div style="text-align: center; padding: 10px; background-color: #f8f9fa; border-bottom: 1px solid #ddd;">
        <h1>Welcome to Ray's Grocery</h1>
        <div style="float: right; margin-right: 20px;">
            <%
                // Retrieve the logged-in user from the session
                String authenticatedUser = (String) session.getAttribute("authenticatedUser");
                if (authenticatedUser != null) {
            %>
                <span>Hello, <strong><%= authenticatedUser %></strong>! | <a href="logout.jsp">Logout</a></span>
            <%
                } else {
            %>
                <a href="login.jsp">Login</a>
            <%
                }
            %>
        </div>
    </div>

    <h2 align="center"><a href="login.jsp">Login</a></h2>
    <h2 align="center"><a href="listprod.jsp">Begin Shopping</a></h2>
    <h2 align="center"><a href="listorder.jsp">List All Orders</a></h2>
    <h2 align="center"><a href="customer.jsp">Customer Info</a></h2>
    <h2 align="center"><a href="admin.jsp">Administrators</a></h2>
    <h2 align="center"><a href="logout.jsp">Log out</a></h2>
    <h2 align="center"><a href="restoreDatabase.jsp">Restore Database</a></h2>
    <h2 align="center"><a href="user.jsp">Account Page</a></h2>
    <h2 align="center"><a href="userNew.jsp">Make a New Account</a></h2>

    <%
        // Database connection details
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";

        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // Establish database connection
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            con = DriverManager.getConnection(url, uid, pw);
            stmt = con.createStatement();

            // Set the database context
            stmt.execute("USE orders");

            // Query for the top 3 selling products
            String sql = "SELECT TOP 3 p.productName, SUM(op.quantity) AS totalSold " +
                        "FROM product p " +
                        "JOIN orderproduct op ON p.productId = op.productId " +
                        "GROUP BY p.productName " +
                        "ORDER BY totalSold DESC";
            rs = stmt.executeQuery(sql);

            // Display the top-selling products
            out.println("<h2 align='center'>Top 3 Selling Products</h2>");
            out.println("<div style='text-align: center;'>");
            while (rs.next()) {
                String productName = rs.getString("productName");
                int totalSold = rs.getInt("totalSold");

                // Product box
                out.println("<div style='display: inline-block; margin: 10px; padding: 10px; border: 1px solid black;'>");
                out.println("<h4>" + productName + "</h4>");
                out.println("<p>Sold: " + totalSold + "</p>");
                out.println("</div>");
            }
            out.println("</div>");
        } catch (Exception e) {
            out.println("<p style='color: red;'>Error fetching top-selling products: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            // Close resources
            try { if (rs != null) rs.close(); } catch (Exception ignore) {}
            try { if (stmt != null) stmt.close(); } catch (Exception ignore) {}
            try { if (con != null) con.close(); } catch (Exception ignore) {}
        }
    %>

</body>
</html>
