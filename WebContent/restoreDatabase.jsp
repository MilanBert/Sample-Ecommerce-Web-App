<%@ page import="java.io.*, java.sql.*" %>
<%@ include file="jdbc.jsp" %>


<%
    String scriptPath = application.getRealPath("/ddl/restoredb_sql.ddl"); // Path to the DDL file
    Statement stmt = null;

    try {
        getConnection(); // Use the defined method to connect to the database

        stmt = con.createStatement();

        // Read the SQL script from the file
        StringBuilder sqlScript = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(scriptPath))) {
            String line;
            while ((line = br.readLine()) != null) {
                sqlScript.append(line).append("\n");
            }
        }

        // Execute the SQL commands in the script
        String[] commands = sqlScript.toString().split(";");
        for (String command : commands) {
            if (!command.trim().isEmpty()) {
                stmt.execute(command.trim());
            }
        }

        out.println("<h3 align=\"center\">Database restored successfully!</h3>");
        out.println("<h3 align=\"center\"><a href=\"index.jsp\">Back to Main Page</a></h3>");
    } catch (SQLException | IOException e) {
        out.println("<p>Error occurred while restoring the database: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        closeConnection(); // Use the defined method to close the connection
    }
%>
