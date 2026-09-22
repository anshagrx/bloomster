package com.bloomster;

import com.myServlet.DB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/ordersverify")
public class ordersverify extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {

            // ==============================
            // CHECK LOGIN SESSION
            // ==============================

            HttpSession session = request.getSession(false);

            if (session == null ||
                session.getAttribute("user_id") == null) {

                response.setStatus(
                    HttpServletResponse.SC_UNAUTHORIZED
                );

                out.println(
                    "{\"success\":false,\"error\":\"Login required\"}"
                );

                return;
            }

            int userId =
                ((Number) session.getAttribute("user_id")).intValue();


            // ==============================
            // SQL QUERY
            // ==============================

            String sql =
                "SELECT " +
                "o.order_id, " +
                "o.product_id, " +
                "o.quantity, " +
                "o.price, " +

                "p.payment_id, " +
                "p.razorpay_order_id, " +
                "p.amount, " +
                "p.total_ammount, " +
                "p.created_at, " +
                "p.updated_at, " +
                "p.status, " +

                "pr.product_name, " +
                "pr.img " +

                "FROM orders o " +

                "LEFT JOIN payments p " +
                "ON o.order_id = p.razorpay_order_id " +
                "AND o.user_id = p.user_id " +

                "LEFT JOIN products pr " +
                "ON o.product_id = pr.product_id " +

                "WHERE o.user_id=? " +

                "ORDER BY p.created_at DESC";


            // ==============================
            // DATABASE
            // ==============================

            try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
            ) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    StringBuilder json =
                        new StringBuilder("[");

                    boolean first = true;


                    // ==============================
                    // LOOP ORDERS
                    // ==============================

                    while (rs.next()) {

                        if (!first) {
                            json.append(",");
                        }


                        // ==============================
                        // ORDER DATA
                        // ==============================

                        String orderId =
                            rs.getString("order_id");

                        int quantity =
                            rs.getInt("quantity");

                        int price =
                            rs.getInt("price");

                        int productId =
                            rs.getInt("product_id");


                        // ==============================
                        // PRODUCT DATA
                        // ==============================

                        String productName =
                            rs.getString("product_name");

                        String image =
                            rs.getString("img");


                        // ==============================
                        // PAYMENT DATA
                        // ==============================

                        String paymentId =
                            rs.getString("payment_id");

                        String razorpayOrderId =
                            rs.getString("razorpay_order_id");

                        int amount =
                            rs.getInt("amount");

                        int totalAmount =
                            rs.getInt("total_ammount");


                        // ==============================
                        // DATE DATA
                        // ==============================

                        String createdAt =
                            rs.getString("created_at");

                        String updatedAt =
                            rs.getString("updated_at");


                        // ==============================
                        // PAYMENT STATUS
                        // ==============================

                        boolean status =
                            rs.getBoolean("status");


                        // ==============================
                        // JSON OBJECT
                        // ==============================

                        json.append("{")

                            // Order ID
                            .append("\"order_id\":\"")
                            .append(escapeJson(orderId))
                            .append("\",")

                            // Product ID
                            .append("\"product_id\":")
                            .append(productId)
                            .append(",")

                            // Product Name
                            .append("\"product_name\":\"")
                            .append(escapeJson(productName))
                            .append("\",")

                            // Product Image
                            .append("\"img\":\"")
                            .append(escapeJson(image))
                            .append("\",")

                            // Quantity
                            .append("\"quantity\":")
                            .append(quantity)
                            .append(",")

                            // Product Price
                            .append("\"price\":")
                            .append(price)
                            .append(",")

                            // Payment ID
                            .append("\"payment_id\":\"")
                            .append(escapeJson(paymentId))
                            .append("\",")

                            // Razorpay Order ID
                            .append("\"razorpay_order_id\":\"")
                            .append(escapeJson(razorpayOrderId))
                            .append("\",")

                            // Payment Amount
                            .append("\"amount\":")
                            .append(amount)
                            .append(",")

                            // Total Amount
                            .append("\"total_amount\":")
                            .append(totalAmount)
                            .append(",")

                            // Created At
                            .append("\"created_at\":\"")
                            .append(escapeJson(createdAt))
                            .append("\",")

                            // Updated At
                            .append("\"updated_at\":\"")
                            .append(escapeJson(updatedAt))
                            .append("\",")

                            // Status
                            .append("\"status\":")
                            .append(status)

                            .append("}");


                        first = false;
                    }


                    // ==============================
                    // CLOSE JSON ARRAY
                    // ==============================

                    json.append("]");

                    out.println(json.toString());
                }
            }


        } catch (SQLException e) {

            System.out.println(
                "SQL error in /ordersverify: "
                + e.getMessage()
            );

            e.printStackTrace();

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.println(
                "{\"success\":false,\"error\":\"Database error\"}"
            );


        } catch (Exception e) {

            System.out.println(
                "Unexpected error in /ordersverify: "
                + e.getMessage()
            );

            e.printStackTrace();

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.println(
                "{\"success\":false,\"error\":\"Something went wrong\"}"
            );
        }
    }


    // ==========================================
    // JSON ESCAPE FUNCTION
    // ==========================================

    private String escapeJson(String value) {

        if (value == null) {
            return "";
        }

        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }
}