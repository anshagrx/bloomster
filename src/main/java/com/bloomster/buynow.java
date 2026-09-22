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
import java.util.Map;

@WebServlet({"/buy_now"})
public class buynow extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        Connection con = null;
        PreparedStatement checkAddressPs = null;
        PreparedStatement getPricePs = null;
        PreparedStatement insertPs = null;

        try {
            ReadJSON readJSON = new ReadJSON();
            Map<String, Object> data = readJSON.readJSON(request);

            int userId = (int) data.get("user_id");
            int productId = (int) data.get("product_id");
            int quantity = (int) data.get("quantity");

            if (quantity <= 0 || quantity > 100) {
                response.setStatus(400);
                out.println("{\"success\":false,\"error\":\"Quantity 1-100 ke beech honi chahiye\"}");
                return;
            }

            con = DB.getConnection();

            // Address hona zaroori hai order place karne ke liye
            checkAddressPs = con.prepareStatement("SELECT address FROM user WHERE id = ?");
            checkAddressPs.setInt(1, userId);

            try (ResultSet rs = checkAddressPs.executeQuery()) {
                if (!rs.next() || rs.getString("address") == null || rs.getString("address").trim().isEmpty()) {
                    response.setStatus(400);
                    out.println("{\"success\":false,\"error\":\"Address required before placing order\"}");
                    return;
                }
            }

            // Product ka price nikalo
            getPricePs = con.prepareStatement("SELECT price FROM products WHERE product_id = ?");
            getPricePs.setInt(1, productId);

            double price;
            try (ResultSet rs = getPricePs.executeQuery()) {
                if (!rs.next()) {
                    response.setStatus(404);
                    out.println("{\"success\":false,\"error\":\"Product not found\"}");
                    return;
                }
                price = rs.getDouble("price");
            }

            // Order insert karo
            insertPs = con.prepareStatement(
                "INSERT INTO orders (user_id, product_id, quantity, price) VALUES (?, ?, ?, ?)"
            );
            insertPs.setInt(1, userId);
            insertPs.setInt(2, productId);
            insertPs.setInt(3, quantity);
            insertPs.setDouble(4, price);

            int rowsInserted = insertPs.executeUpdate();

            if (rowsInserted > 0) {
                out.println("{\"success\":true,\"message\":\"Order placed successfully\"}");
            } else {
                response.setStatus(500);
                out.println("{\"success\":false,\"error\":\"Failed to place order\"}");
            }

        } catch (ClassCastException e) {
            System.out.println("Type mismatch in buy_now: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Invalid data type\"}");

        } catch (NullPointerException e) {
            System.out.println("Missing field in buy_now: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Required field missing\"}");

        } catch (SQLException e) {
            System.out.println("DB error in buy_now: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Database error\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            out.println("{\"success\":false,\"error\":\"Something went wrong\"}");

        } finally {
            try {
                if (checkAddressPs != null) checkAddressPs.close();
                if (getPricePs != null) getPricePs.close();
                if (insertPs != null) insertPs.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                System.out.println("Error closing DB resources: " + e.getMessage());
            }
        }
    }
}