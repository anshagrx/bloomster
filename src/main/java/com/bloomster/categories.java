
package com.bloomster;

import com.myServlet.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

// import com.myServlet.DB;
// import java.sql.Connection;
// import java.sql.PreparedStatement;
// import java.sql.ResultSet;

@WebServlet({"/categories"})
public class categories extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM categories");
                ResultSet rs = ps.executeQuery();
                PrintWriter out = response.getWriter()
        ) {
             while (rs.next()) {
                out.println(rs.getInt("category_id ") + " " + rs.getString("category_name"));
            }
        } catch (SQLException e) {
            throw new ServletException("Unable to load users from the database", e);
        }
    }
}