package com.bloomster;

import com.myServlet.DB;
import com.razorpay.RazorpayClient;
import com.razorpay.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONObject;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/create_razorpay_order")
public class createrazorpayorder extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        Connection con = null;

        try {

            // ==============================
            // LOGIN CHECK
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
            // DATABASE
            // ==============================

            con = DB.getConnection();


            /*
             * Cart ke saare products DB se nikalo.
             *
             * IMPORTANT:
             * price products table se liya ja raha hai.
             * Frontend ka price trust nahi kar rahe.
             */

            String sql =
                "SELECT c.product_id, " +
                "c.quantity, " +
                "p.price " +
                "FROM cart c " +
                "INNER JOIN products p " +
                "ON c.product_id = p.product_id " +
                "WHERE c.user_id = ?";


            double totalAmount = 0;

            boolean hasItems = false;


            try (PreparedStatement ps =
                    con.prepareStatement(sql)) {

                ps.setInt(1, userId);


                try (ResultSet rs =
                        ps.executeQuery()) {

                    while (rs.next()) {

                        hasItems = true;

                        int quantity =
                            rs.getInt("quantity");

                        double price =
                            rs.getDouble("price");


                        if (quantity <= 0 ||
                            quantity > 100) {

                            response.setStatus(400);

                            out.println(
                                "{\"success\":false,\"error\":\"Invalid cart quantity\"}"
                            );

                            return;
                        }


                        totalAmount +=
                            price * quantity;
                    }
                }
            }


            // ==============================
            // EMPTY CART
            // ==============================

            if (!hasItems) {

                response.setStatus(400);

                out.println(
                    "{\"success\":false,\"error\":\"Cart is empty\"}"
                );

                return;
            }


            // ==============================
            // RUPEES → PAISE
            // ==============================

            int amountInPaise =
                (int) Math.round(
                    totalAmount * 100
                );


            if (amountInPaise <= 0) {

                response.setStatus(400);

                out.println(
                    "{\"success\":false,\"error\":\"Invalid cart total\"}"
                );

                return;
            }


            // ==============================
            // RAZORPAY
            // ==============================

            RazorpayClient razorpay =
                new RazorpayClient(
                    RazorpayConfig.KEY_ID,
                    RazorpayConfig.KEY_SECRET
                );


            JSONObject orderRequest =
                new JSONObject();

            orderRequest.put(
                "amount",
                amountInPaise
            );

            orderRequest.put(
                "currency",
                "INR"
            );

            orderRequest.put(
                "receipt",
                "receipt_" +
                System.currentTimeMillis()
            );


            Order razorpayOrder =
                razorpay.orders.create(
                    orderRequest
                );


            // ==============================
            // RESPONSE
            // ==============================

            out.println(
                "{"
                + "\"success\":true,"
                + "\"order_id\":\""
                + razorpayOrder.get("id")
                + "\","
                + "\"amount\":"
                + amountInPaise
                + ","
                + "\"currency\":\"INR\","
                + "\"key_id\":\""
                + RazorpayConfig.KEY_ID
                + "\""
                + "}"
            );


        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.println(
                "{\"success\":false,\"error\":\"Payment initialization failed\"}"
            );

        } finally {

            try {

                if (con != null) {
                    con.close();
                }

            } catch (Exception ignored) {
            }
        }
    }
}