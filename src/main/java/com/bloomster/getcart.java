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

@WebServlet({"/get_cart"})
public class getcart extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String userIdParam = request.getParameter("user_id");

        if (userIdParam == null || userIdParam.isEmpty()) {
            response.setStatus(400);
            out.print("{\"error\":\"user_id is required\"}");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            int user_id = Integer.parseInt(userIdParam);

            con = DB.getConnection();

            String sql = "SELECT c.cart_id, c.product_id, c.quantity, p.product_name, p.price, p.img " +
                         "FROM cart c JOIN products p ON c.product_id = p.product_id " +
                         "WHERE c.user_id = ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, user_id);

            try (ResultSet rs = ps.executeQuery()) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;

                while (rs.next()) {
                    if (!first) json.append(",");

                    json.append("{")
                        .append("\"cart_id\":").append(rs.getInt("cart_id")).append(",")
                        .append("\"product_id\":").append(rs.getInt("product_id")).append(",")
                        .append("\"quantity\":").append(rs.getInt("quantity")).append(",")
                        .append("\"product_name\":\"").append(escapeJson(rs.getString("product_name"))).append("\",")
                        .append("\"price\":").append(rs.getDouble("price")).append(",")
                        .append("\"img\":\"").append(escapeJson(rs.getString("img"))).append("\"")
                        .append("}");

                    first = false;
                }
                json.append("]");
                out.print(json.toString());
            }

        } catch (NumberFormatException e) {
            System.out.println("Invalid user_id: " + userIdParam);
            response.setStatus(400);
            out.print("{\"error\":\"Invalid user_id\"}");

        } catch (SQLException e) {
            System.out.println("DB error in get_cart: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(500);
            out.print("{\"error\":\"Database error\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.print("{\"error\":\"Something went wrong\"}");

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                System.out.println("Error closing DB resources: " + e.getMessage());
            }
        }
    } // <-- doGet() yaha khatam hota hai

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    } // <-- escapeJson() yaha class ke andar, doGet() ke bahar hai

} // <-- class getcart yaha khatam hoti hai