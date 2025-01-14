<!DOCTYPE html>
<html>
<head>
    <title>Administrator Page</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
    String userName = (String) session.getAttribute("authenticatedUser");
%>

<h3>Sales Report by Day</h3>
<%
    String labels = "";
    String salesData = "";

    String sql = "SELECT year(orderDate) AS year, month(orderDate) AS month, day(orderDate) AS day, SUM(totalAmount) AS total " +
                 "FROM ordersummary " +
                 "GROUP BY year(orderDate), month(orderDate), day(orderDate)";

    try {
        getConnection(); // Establish the database connection
        Statement stmt = con.createStatement();
        stmt.execute("USE orders");

        ResultSet rst = stmt.executeQuery(sql);

        // Begin table
        out.println("<h3>Sales Report by Day</h3>");
        out.println("<table class=\"table\" border=\"1\">");
        out.println("<tr><th>Order Date</th><th>Total Sales</th></tr>");

        while (rst.next()) {
            // Build data for the chart
            if (!labels.isEmpty()) {
                labels += ",";
                salesData += ",";
            }
            labels += "\"" + rst.getString("year") + "-" + rst.getString("month") + "-" + rst.getString("day") + "\"";
            salesData += rst.getDouble("total");

            // Print each row in the table
            out.println("<tr>");
            out.println("<td>" + rst.getString("year") + "-" + rst.getString("month") + "-" + rst.getString("day") + "</td>");
            out.println("<td>" + rst.getDouble("total") + "</td>");
            out.println("</tr>");
        }

        // End table
        out.println("</table>");
    } catch (SQLException ex) {
        out.println("<p>Error occurred while loading sales data: " + ex.getMessage() + "</p>");
    } finally {
        closeConnection(); // Ensure the connection is closed
    }
%>


<h3>Sales Chart</h3>
<!-- Use CSS for Chart Dimensions -->
<canvas id="salesChart" style="width: 100px; height: 25px;"></canvas>

<script>
    const labels = [<%= labels %>];
    const salesData = [<%= salesData %>];

    const ctx = document.getElementById('salesChart').getContext('2d');
    const salesChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Total Sales',
                data: salesData,
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderColor: 'rgba(75, 192, 192, 1)',
                borderWidth: 2,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true, // Chart respects its container
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Sales Amount ($)'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Date'
                    }
                }
            },
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            }
        }
    });
</script>


<%
    try {
        getConnection(); // Establish the database connection

        String sql2 = "SELECT customerId, firstName, lastName, email, phonenum, " +
                  "address, city, state, postalCode, country, userid " +
                  "FROM customer " +
                  "ORDER BY lastName, firstName";


        // Switch to the correct database
        Statement stmt2 = con.createStatement();
        stmt2.execute("USE orders");

        // Execute the query to fetch customer information
        ResultSet rst2 = con.createStatement().executeQuery(sql2);

        // Render the customer information table
        out.println("<h3>Customer Information</h3>");
        out.println("<table class=\"table\" border=\"1\">");
        out.println("<tr><th>First Name</th><th>Last Name</th><th>Email</th><th>Phone Number</th><th>Address</th><th>City</th><th>State</th><th>Postal Code</th><th>Country</th><th>User ID</th></tr>");

        // Iterate through the results and populate the table
        while (rst2.next()) {
            out.println("<tr>");
            out.println("<td>" + rst2.getString("firstName") + "</td>");
            out.println("<td>" + rst2.getString("lastName") + "</td>");
            out.println("<td>" + rst2.getString("email") + "</td>");
            out.println("<td>" + rst2.getString("phonenum") + "</td>");
            out.println("<td>" + rst2.getString("address") + "</td>");
            out.println("<td>" + rst2.getString("city") + "</td>");
            out.println("<td>" + rst2.getString("state") + "</td>");
            out.println("<td>" + rst2.getString("postalCode") + "</td>");
            out.println("<td>" + rst2.getString("country") + "</td>");
            out.println("<td>" + rst2.getString("userid") + "</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    } catch (SQLException ex) {
        out.println("<p>Error occurred while loading customer data: " + ex.getMessage() + "</p>");
    } finally {
        closeConnection(); // Ensure the connection is closed
    }
%>




<!-- New Feature: Remove Product -->
<h3>Remove Product</h3>
<form method="post">
    <label for="productId">Enter Product ID to Remove:</label>
    <input type="text" id="productId" name="productId" required>
    <button type="submit">Remove Product</button>
</form>

<%
    if (request.getMethod().equalsIgnoreCase("POST")) {
        // Get product ID from the form
        String productId = request.getParameter("productId");
        String productName = "";

        try {
            getConnection();

            // Ensure the correct database context
            Statement stmt = con.createStatement();
            stmt.execute("USE orders");

            // Step 1: Retrieve the product name
            String getProductSql = "SELECT productName FROM Product WHERE productId = ?";
            try (PreparedStatement stmtGetProduct = con.prepareStatement(getProductSql)) {
                stmtGetProduct.setInt(1, Integer.parseInt(productId));
                ResultSet rs = stmtGetProduct.executeQuery();
                if (rs.next()) {
                    productName = rs.getString("productName");
                } else {
                    out.println("<p>Product with ID " + productId + " does not exist.</p>");
                    return; // Exit the operation if the product doesn't exist
                }
            }

            // Step 2: Delete related rows in the productinventory table
            String deleteInventorySql = "DELETE FROM productinventory WHERE productId = ?";
            try (PreparedStatement stmtDeleteInventory = con.prepareStatement(deleteInventorySql)) {
                stmtDeleteInventory.setInt(1, Integer.parseInt(productId));
                stmtDeleteInventory.executeUpdate();
            }

            // Step 3: Delete related rows in the orderproduct table
            String deleteRelatedSql = "DELETE FROM orderproduct WHERE productId = ?";
            try (PreparedStatement stmtDeleteRelated = con.prepareStatement(deleteRelatedSql)) {
                stmtDeleteRelated.setInt(1, Integer.parseInt(productId));
                stmtDeleteRelated.executeUpdate();
            }

            // Step 4: Delete the product from the Product table
            String sqlRemove = "DELETE FROM Product WHERE productId = ?";
            try (PreparedStatement stmtRemove = con.prepareStatement(sqlRemove)) {
                stmtRemove.setInt(1, Integer.parseInt(productId));
                int rowsAffected = stmtRemove.executeUpdate();
                if (rowsAffected > 0) {
                    out.println("<p>Product <strong>" + productName.toUpperCase() + "</strong> with ID " + productId + " has been removed successfully!</p>");
                } else {
                    out.println("<p>Product with ID " + productId + " does not exist.</p>");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error occurred while removing the product: " + e.getMessage() + "</p>");
        } catch (NumberFormatException e) {
            out.println("<p>Invalid Product ID format.</p>");
        } finally {
            closeConnection();
        }
    }
%>

<!-- Existing Code Above -->


<!-- New Section: Add Product -->
<h3>Add a New Product</h3>
<form method="post">
    <label for="productName">Product Name:</label>
    <input type="text" id="productName" name="productName" required><br>

    <label for="categoryId">Category ID:</label>
    <input type="number" id="categoryId" name="categoryId" required><br>

    <label for="productDesc">Description:</label>
    <textarea id="productDesc" name="productDesc" required></textarea><br>

    <label for="productPrice">Price:</label>
    <input type="number" step="0.01" id="productPrice" name="productPrice" required><br>

    <button type="submit" name="action" value="addProduct">Add Product</button>
</form>

<%
    if (request.getMethod().equalsIgnoreCase("POST") && "addProduct".equals(request.getParameter("action"))) {
        // Get product details from the form
        String productName = request.getParameter("productName");
        String categoryId = request.getParameter("categoryId");
        String productDesc = request.getParameter("productDesc");
        String productPrice = request.getParameter("productPrice");

        try {
            getConnection();

            // Ensure the correct database context
            Statement stmt = con.createStatement();
            stmt.execute("USE orders");

            // Insert the new product into the database
            String insertProductSql = "INSERT INTO Product (productName, categoryId, productDesc, productPrice) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmtInsertProduct = con.prepareStatement(insertProductSql)) {
                stmtInsertProduct.setString(1, productName);
                stmtInsertProduct.setInt(2, Integer.parseInt(categoryId));
                stmtInsertProduct.setString(3, productDesc);
                stmtInsertProduct.setDouble(4, Double.parseDouble(productPrice));

                int rowsInserted = stmtInsertProduct.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<p>Product <strong>" + productName + "</strong> has been added successfully!</p>");
                } else {
                    out.println("<p>Failed to add the product. Please try again.</p>");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error occurred while adding the product: " + e.getMessage() + "</p>");
        } catch (NumberFormatException e) {
            out.println("<p>Invalid input format for Category ID or Price.</p>");
        } finally {
            closeConnection();
        }
    }
%>



</body>
</html>