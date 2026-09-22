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

@WebServlet("/product")
public class product extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter(); // bahar nikala - catch me safe rahega

        String id = request.getParameter("id");

        if (id == null || id.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Product ID is required\"}");
            return;
        }

        String sql = "SELECT * FROM products WHERE product_id = ?";

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, Integer.parseInt(id));

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Product not found\"}");
                    return;
                }

                out.print("{");
                out.print("\"id\":" + rs.getInt("product_id") + ",");
                out.print("\"name\":\"" + escapeJson(rs.getString("product_name")) + "\",");
                out.print("\"category\":\"" + escapeJson(rs.getString("category_id")) + "\",");
                out.print("\"price\":" + rs.getDouble("price") + ",");
                out.print("\"rating\":" + rs.getDouble("rating") + ",");
                out.print("\"reviews\":\"" + escapeJson(rs.getString("reviews")) + "\",");
                out.print("\"description\":\"" + escapeJson(rs.getString("description")) + "\",");
                out.print("\"img\":\"" + escapeJson(rs.getString("img")) + "\"}");
            }

        } catch (NumberFormatException e) {
            // ab out already available hai, closed nahi hua
            System.out.println("Invalid product id received: " + id);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid product ID\"}");

        } catch (SQLException e) {
            System.out.println("SQL error in /product: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Database error\"}");

        } catch (Exception e) {
            // koi bhi anjaana error catch karega, stack trace se pata chalega exact wajah
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