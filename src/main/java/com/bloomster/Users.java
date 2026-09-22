
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

@WebServlet({"/users-account"})
public class Users extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM user");
                ResultSet rs = ps.executeQuery();
                PrintWriter out = response.getWriter()
        ) {
            out.write("[");
           
            while (rs.next()) {
               
                out.printf(
                        "{\"id\":%d,\"firstName\":\"%s\",\"lastName\":\"%s\",\"gender\":\"%s\",\"email\":\"%s\",\"phone\":\"%s\",\"username\":\"%s\",\"address\":\"%s\",\"dob\":\"%s\",\"country\":\"%s\",\"city\":\"%s\",\"state\":\"%s\"}",
                        rs.getInt("id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("gender"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("username"),
                        rs.getString("address"),
                        rs.getDate("dob"),
                        rs.getString("country"),
                        rs.getString("city"),
                        rs.getString("state")
                );
            }
            out.write("]");
        } catch (SQLException e) {
            System.out.println("Message: " + e.getMessage());
    System.out.println("SQLState: " + e.getSQLState());
    System.out.println("ErrorCode: " + e.getErrorCode());
     e.printStackTrace();
            throw new ServletException("Unable to load users from the database", e);
            
        }
    }
}