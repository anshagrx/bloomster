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

@WebServlet({"/products"})
public class products extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter(); // bahar nikala taaki catch me bhi safe use ho

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM products");
                ResultSet rs = ps.executeQuery()
        ) {
            StringBuilder json = new StringBuilder("[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");

                json.append(String.format(
                        "{\"product_id\":%d,\"product_name\":\"%s\",\"category_id\":\"%s\",\"price\":%.2f}",
                        rs.getInt("product_id"),
                        escapeJson(rs.getString("product_name")),
                        escapeJson(rs.getString("category_id")),
                        rs.getDouble("price")
                ));

                first = false;
            }
            json.append("]");

            out.print(json.toString());

        } catch (SQLException e) {
            System.out.println("SQL error in /products: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Database error\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Something went wrong\"}");
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}