<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
    <title>Ray's Grocery - Product Information</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%@ include file="header.jsp" %>

<%
// Get product ID from the request
String productId = request.getParameter("id");

String sql = "SELECT productId, productName, productPrice, productImageURL, productImage FROM Product P WHERE productId = ?";
String reviewsSql = "SELECT r.reviewComment, r.reviewRating, r.reviewDate, c.firstName, c.lastName " +
                    "FROM review r " +
                    "JOIN customer c ON r.customerId = c.customerId " +
                    "WHERE r.productId = ?";
String addReviewSql = "INSERT INTO review (reviewRating, reviewDate, customerId, productId, reviewComment) VALUES (?, GETDATE(), ?, ?, ?)";

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

// Check if a new review is being submitted
if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        getConnection();
        Statement stmt = con.createStatement();
        stmt.execute("USE orders");

        // Insert the new review
        int customerId = 1; // Replace with the actual logged-in customer ID
        String reviewRating = request.getParameter("reviewRating");
        String reviewComment = request.getParameter("reviewComment");

        PreparedStatement addReviewPstmt = con.prepareStatement(addReviewSql);
        addReviewPstmt.setInt(1, Integer.parseInt(reviewRating));
        addReviewPstmt.setInt(2, customerId);
        addReviewPstmt.setInt(3, Integer.parseInt(productId));
        addReviewPstmt.setString(4, reviewComment);

        int rowsInserted = addReviewPstmt.executeUpdate();

        if (rowsInserted > 0) {
            out.println("<p style='color: green;'>Review added successfully!</p>");
        } else {
            out.println("<p style='color: red;'>Error adding review. Please try again.</p>");
        }

        addReviewPstmt.close();
    } catch (SQLException ex) {
        out.println("<p style='color: red;'>Error: " + ex.getMessage() + "</p>");
    } finally {
        closeConnection();
    }
}
%>

<%
try {
    getConnection();
    Statement stmt = con.createStatement();            
    stmt.execute("USE orders");
    
    // Fetch product details
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(productId));            
    ResultSet rst = pstmt.executeQuery();
            
    if (!rst.next())
    {
        out.println("Invalid product");
    }
    else
    {        
        out.println("<h2>" + rst.getString(2) + "</h2>");
        
        int prodId = rst.getInt(1);
        out.println("<table><tr>");
        out.println("<th>Id</th><td>" + prodId + "</td></tr>"                
                + "<tr><th>Price</th><td>" + currFormat.format(rst.getDouble(3)) + "</td></tr>");
        
        // Retrieve any image with a URL
        String imageLoc = rst.getString(4);
        if (imageLoc != null)
            out.println("<img src=\"" + imageLoc + "\" alt=\"Product Image\" style=\"width:300px;height:300px;\">");
        
        // Retrieve any image stored directly in database
        String imageBinary = rst.getString(5);
        if (imageBinary != null)
            out.println("<img src=\"displayImage.jsp?id=" + prodId + "\" alt=\"Binary Product Image\" style=\"width:300px;height:300px;\">");    
        out.println("</table>");
        

        out.println("<h3><a href=\"addcart.jsp?id=" + prodId + "&name=" + rst.getString(2)
                                + "&price=" + rst.getDouble(3) + "\">Add to Cart</a></h3>");        
        
        out.println("<h3><a href=\"listprod.jsp\">Continue Shopping</a></h3>");
    }

    // Fetch product reviews
    PreparedStatement reviewsPstmt = con.prepareStatement(reviewsSql);
    reviewsPstmt.setInt(1, Integer.parseInt(productId));
    ResultSet reviewsRs = reviewsPstmt.executeQuery();

    out.println("<h2>Product Reviews</h2>");
    if (reviewsRs.next()) {
        out.println("<ul>");
        do {
            String customerName = reviewsRs.getString("firstName") + " " + reviewsRs.getString("lastName");
            String reviewComment = reviewsRs.getString("reviewComment");
            int reviewRating = reviewsRs.getInt("reviewRating");
            java.sql.Date reviewDate = reviewsRs.getDate("reviewDate");

            out.println("<li><strong>" + customerName + "</strong> (" + reviewDate + ") - Rating: " + reviewRating + "/5<br>");
            out.println(reviewComment + "</li>");
        } while (reviewsRs.next());
        out.println("</ul>");
    } else {
        out.println("<p>No reviews available for this product.</p>");
    }

    reviewsRs.close();
    reviewsPstmt.close();
} 
catch (SQLException ex) {
    out.println(ex);
}
finally
{
    closeConnection();
}
%>

<h2>Add a Review</h2>
<form method="post" action="product.jsp?id=<%= productId %>">
    <label for="reviewRating">Rating (1-5):</label>
    <input type="number" id="reviewRating" name="reviewRating" min="1" max="5" required><br><br>

    <label for="reviewComment">Comment:</label><br>
    <textarea id="reviewComment" name="reviewComment" rows="4" cols="50" required></textarea><br><br>

    <button type="submit">Submit Review</button>
</form>

</body>
</html>
