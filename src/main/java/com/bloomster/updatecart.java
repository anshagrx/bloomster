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
import java.sql.SQLException;
import java.util.Map;

@WebServlet({"/update_cart"})
public class updatecart extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        Connection con = null;
        PreparedStatement ps = null;

        try {
            ReadJSON readJSON = new ReadJSON();
            Map<String, Object> data = readJSON.readJSON(request);

            int user_id = (int) data.get("user_id");
            int product_id = (int) data.get("product_id");
            int quantity = (int) data.get("quantity");

            // Upper limit check
            if (quantity > 100) {
                response.setStatus(400);
                out.println("{\"success\":false,\"error\":\"Max 100 quantity allowed\"}");
                return;
            }

            con = DB.getConnection();

            if (quantity <= 0) {
                // Quantity 0 ya negative -> product cart se hata do
                String sql = "DELETE FROM cart WHERE user_id = ? AND product_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, user_id);
                ps.setInt(2, product_id);

                int rowsDeleted = ps.executeUpdate();

                if (rowsDeleted > 0) {
                    out.println("{\"success\":true,\"removed\":true}");
                } else {
                    response.setStatus(400);
                    out.println("{\"success\":false,\"error\":\"Product not found in cart\"}");
                }

            } else {
                // Normal quantity badhana/ghatana (1-100 ke beech)
                String sql = "UPDATE cart SET quantity = ? WHERE user_id = ? AND product_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, quantity);
                ps.setInt(2, user_id);
                ps.setInt(3, product_id);

                int rowsUpdated = ps.executeUpdate();

                if (rowsUpdated > 0) {
                    out.println("{\"success\":true,\"removed\":false}");
                } else {
                    response.setStatus(400);
                    out.println("{\"success\":false,\"error\":\"Product not found in cart\"}");
                }
            }

        } catch (ClassCastException e) {
            System.out.println("Type mismatch in update_cart: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Invalid data type - number expected\"}");

        } catch (NullPointerException e) {
            System.out.println("Missing field in update_cart: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Required field missing\"}");

        } catch (SQLException e) {
            System.out.println("DB error in update_cart: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Database error\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Something went wrong\"}");

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                System.out.println("Error closing DB resources: " + e.getMessage());
            }
        }
    }
}