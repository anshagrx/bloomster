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

@WebServlet({"/orders"})
public class orders extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter(); // bahar rakha taaki catch me bhi use ho sake

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM orders");
                ResultSet rs = ps.executeQuery()
        ) {
            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"order_id\":").append(rs.getInt("order_id")).append(",")
                    .append("\"quantity\":").append(rs.getInt("quantity")).append(",")
                    .append("\"price\":").append(rs.getInt("price"))
                    .append("}");
                first = false;
            }
            json.append("]");

            out.println(json.toString());

        } catch (SQLException e) {
            // Ye batayega EXACT kya galat hai - galat column name,
            // table missing, ya connection fail
            System.out.println("SQL error in /orders: " + e.getMessage());
            e.printStackTrace();

            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Database error: " + e.getMessage() + "\"}");

        } catch (Exception e) {
            // koi bhi aur anjaana error
            System.out.println("Unexpected error in /orders: " + e.getMessage());
            e.printStackTrace();

            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Something went wrong\"}");
        }
    }
}