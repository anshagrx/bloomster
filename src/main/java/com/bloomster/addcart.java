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

@WebServlet({"/add_cart"})
public class addcart extends HttpServlet {

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

            if (quantity <= 0 || quantity > 100) {
                response.setStatus(400);
                out.println("{\"success\":false,\"error\":\"Quantity 1-100 ke beech honi chahiye\"}");
                return;
            }

            con = DB.getConnection();

            // cart table me insert - cart_id khud AUTO_INCREMENT se ban jayega
            // agar product already hai, quantity update ho jayegi (ON DUPLICATE KEY)
            String sql = "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE quantity = ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, user_id);
            ps.setInt(2, product_id);
            ps.setInt(3, quantity);
            ps.setInt(4, quantity);

            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                out.println("{\"success\":true}");
            } else {
                out.println("{\"success\":false}");
            }

        } catch (ClassCastException e) {
            System.out.println("Type mismatch in add_cart: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Invalid data type - number expected\"}");

        } catch (NullPointerException e) {
            System.out.println("Missing field in add_cart: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Required field missing\"}");

        } catch (SQLException e) {
            System.out.println("DB error in add_cart: " + e.getMessage());
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