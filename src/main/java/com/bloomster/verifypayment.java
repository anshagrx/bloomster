package com.bloomster;

import com.myServlet.DB;
import com.razorpay.Utils;

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
import java.sql.SQLException;
import java.util.Map;

@WebServlet("/verify_payment")
public class verifypayment extends HttpServlet {

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

            /*
             * =====================================================
             * GET LOGGED-IN USER FROM SESSION
             * =====================================================
             */

            HttpSession session =
                    request.getSession(false);


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
                    ((Number) session
                            .getAttribute("user_id"))
                            .intValue();


            /*
             * =====================================================
             * READ JSON
             * =====================================================
             */

            ReadJSON readJSON =
                    new ReadJSON();

            Map<String, Object> data =
                    readJSON.readJSON(request);


            String razorpayOrderId =
                    data.get("razorpay_order_id") != null
                            ? data.get("razorpay_order_id").toString()
                            : null;


            String razorpayPaymentId =
                    data.get("razorpay_payment_id") != null
                            ? data.get("razorpay_payment_id").toString()
                            : null;


            String razorpaySignature =
                    data.get("razorpay_signature") != null
                            ? data.get("razorpay_signature").toString()
                            : null;


            /*
             * =====================================================
             * BASIC VALIDATION
             * =====================================================
             */

            if (razorpayOrderId == null ||
                razorpayPaymentId == null ||
                razorpaySignature == null ||
                razorpayOrderId.trim().isEmpty() ||
                razorpayPaymentId.trim().isEmpty() ||
                razorpaySignature.trim().isEmpty()) {

                response.setStatus(
                        HttpServletResponse.SC_BAD_REQUEST
                );

                out.println(
                    "{\"success\":false,\"error\":\"Required payment data missing\"}"
                );

                return;
            }


            /*
             * =====================================================
             * VERIFY RAZORPAY SIGNATURE
             * =====================================================
             */

            JSONObject options =
                    new JSONObject();

            options.put(
                    "razorpay_order_id",
                    razorpayOrderId
            );

            options.put(
                    "razorpay_payment_id",
                    razorpayPaymentId
            );

            options.put(
                    "razorpay_signature",
                    razorpaySignature
            );


            boolean isValid =
                    Utils.verifyPaymentSignature(
                            options,
                            RazorpayConfig.KEY_SECRET
                    );


            if (!isValid) {

                response.setStatus(
                        HttpServletResponse.SC_BAD_REQUEST
                );

                out.println(
                    "{\"success\":false,\"error\":\"Payment verification failed\"}"
                );

                return;
            }


            /*
             * =====================================================
             * DATABASE CONNECTION
             * =====================================================
             */

            con =
                    DB.getConnection();

            con.setAutoCommit(false);


            /*
             * =====================================================
             * ADDRESS CHECK
             * =====================================================
             */

            String addressSql =
                    "SELECT address " +
                    "FROM user " +
                    "WHERE id = ?";


            try (PreparedStatement ps =
                    con.prepareStatement(addressSql)) {

                ps.setInt(
                        1,
                        userId
                );


                try (ResultSet rs =
                        ps.executeQuery()) {

                    if (!rs.next() ||
                        rs.getString("address") == null ||
                        rs.getString("address")
                          .trim()
                          .isEmpty()) {

                        con.rollback();

                        response.setStatus(
                                HttpServletResponse.SC_BAD_REQUEST
                        );

                        out.println(
                            "{\"success\":false,\"error\":\"Address required\"}"
                        );

                        return;
                    }
                }
            }


            /*
             * =====================================================
             * CHECK DUPLICATE PAYMENT
             * =====================================================
             */

            String checkPaymentSql =
                    "SELECT payment_id " +
                    "FROM payments " +
                    "WHERE payment_id = ?";


            try (PreparedStatement ps =
                    con.prepareStatement(
                            checkPaymentSql)) {

                ps.setString(
                        1,
                        razorpayPaymentId
                );


                try (ResultSet rs =
                        ps.executeQuery()) {

                    if (rs.next()) {

                        /*
                         * Already processed.
                         */

                        con.rollback();

                        out.println(
                            "{\"success\":true,\"message\":\"Payment already verified\"}"
                        );

                        return;
                    }
                }
            }


            /*
             * =====================================================
             * READ CART
             *
             * User ki complete cart.
             * Price products table se aayega.
             * Client ke price par trust nahi karna.
             * =====================================================
             */

            String cartSql =
                    "SELECT c.product_id, " +
                    "c.quantity, " +
                    "p.price " +
                    "FROM cart c " +
                    "INNER JOIN products p " +
                    "ON c.product_id = p.product_id " +
                    "WHERE c.user_id = ?";


            double totalAmount =
                    0.0;

            int cartItems =
                    0;


            /*
             * Temporary arrays nahi chahiye.
             * Pehle total calculate karenge,
             * phir second query se orders insert karenge.
             */

            try (PreparedStatement ps =
                    con.prepareStatement(cartSql)) {

                ps.setInt(
                        1,
                        userId
                );


                try (ResultSet rs =
                        ps.executeQuery()) {

                    while (rs.next()) {

                        int quantity =
                                rs.getInt(
                                        "quantity"
                                );

                        double price =
                                rs.getDouble(
                                        "price"
                                );


                        if (quantity <= 0) {

                            con.rollback();

                            response.setStatus(
                                    HttpServletResponse.SC_BAD_REQUEST
                            );

                            out.println(
                                "{\"success\":false,\"error\":\"Invalid cart quantity\"}"
                            );

                            return;
                        }


                        if (quantity > 100) {

                            con.rollback();

                            response.setStatus(
                                    HttpServletResponse.SC_BAD_REQUEST
                            );

                            out.println(
                                "{\"success\":false,\"error\":\"Cart quantity too high\"}"
                            );

                            return;
                        }


                        totalAmount +=
                                price * quantity;

                        cartItems++;
                    }
                }
            }


            /*
             * =====================================================
             * EMPTY CART CHECK
             * =====================================================
             */

            if (cartItems == 0) {

                con.rollback();

                response.setStatus(
                        HttpServletResponse.SC_BAD_REQUEST
                );

                out.println(
                    "{\"success\":false,\"error\":\"Cart is empty\"}"
                );

                return;
            }


            /*
             * =====================================================
             * ROUND TOTAL
             * =====================================================
             */

            double finalTotal =
                    Math.round(
                        totalAmount * 100.0
                    ) / 100.0;


            /*
             * =====================================================
             * INSERT ONE PAYMENT
             *
             * payments table mein ek hi payment row.
             *
             * product_id:
             * Existing schema compatibility ke liye
             * first cart product ID save kar rahe hain.
             * Actual multiple products orders table mein hain.
             * =====================================================
             */

            int firstProductId = 0;


            String firstProductSql =
                    "SELECT product_id " +
                    "FROM cart " +
                    "WHERE user_id = ? " +
                    "ORDER BY product_id " +
                    "LIMIT 1";


            try (PreparedStatement ps =
                    con.prepareStatement(
                            firstProductSql)) {

                ps.setInt(
                        1,
                        userId
                );


                try (ResultSet rs =
                        ps.executeQuery()) {

                    if (rs.next()) {

                        firstProductId =
                                rs.getInt(
                                        "product_id"
                                );
                    }
                }
            }


            /*
             * =====================================================
             * PAYMENT INSERT
             * =====================================================
             */

            String paymentSql =
                    "INSERT INTO payments " +
                    "(payment_id, razorpay_order_id, user_id, " +
                    "product_id, amount, total_ammount, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";


            try (PreparedStatement ps =
                    con.prepareStatement(
                            paymentSql)) {

                ps.setString(
                        1,
                        razorpayPaymentId
                );

                ps.setString(
                        2,
                        razorpayOrderId
                );

                ps.setInt(
                        3,
                        userId
                );

                /*
                 * Existing payments.product_id ke liye
                 * first product save.
                 */
                ps.setInt(
                        4,
                        firstProductId
                );


                /*
                 * Amount rupees mein.
                 */
                ps.setDouble(
                        5,
                        finalTotal
                );


                ps.setDouble(
                        6,
                        finalTotal
                );


                /*
                 * Existing column boolean/status
                 * compatibility.
                 */
                ps.setBoolean(
                        7,
                        true
                );


                ps.executeUpdate();
            }


            /*
             * =====================================================
             * INSERT ALL ORDERS
             *
             * Har cart product ki separate order row.
             *
             * Same Razorpay order_id sab rows mein hoga.
             * =====================================================
             */

            String orderSql =
                    "INSERT INTO orders " +
                    "(user_id, product_id, quantity, price, order_id) " +
                    "VALUES (?, ?, ?, ?, ?)";


            try (PreparedStatement ps =
                    con.prepareStatement(
                            orderSql)) {

                ps.setInt(
                        1,
                        userId
                );


                try (PreparedStatement cartPs =
                        con.prepareStatement(
                                cartSql)) {

                    cartPs.setInt(
                            1,
                            userId
                    );


                    try (ResultSet rs =
                            cartPs.executeQuery()) {

                        while (rs.next()) {

                            int productId =
                                    rs.getInt(
                                            "product_id"
                                    );

                            int quantity =
                                    rs.getInt(
                                            "quantity"
                                    );

                            double price =
                                    rs.getDouble(
                                            "price"
                                    );


                            ps.setInt(
                                    2,
                                    productId
                            );

                            ps.setInt(
                                    3,
                                    quantity
                            );

                            ps.setDouble(
                                    4,
                                    price
                            );

                            /*
                             * Same Razorpay order ID
                             * multiple item rows ke liye.
                             */
                            ps.setString(
                                    5,
                                    razorpayOrderId
                            );


                            ps.addBatch();
                        }
                    }
                }


                ps.executeBatch();
            }


            /*
             * =====================================================
             * CLEAR CART
             *
             * Payment + orders successful hone ke baad hi.
             * =====================================================
             */

            String deleteCartSql =
                    "DELETE FROM cart " +
                    "WHERE user_id = ?";


            try (PreparedStatement ps =
                    con.prepareStatement(
                            deleteCartSql)) {

                ps.setInt(
                        1,
                        userId
                );

                ps.executeUpdate();
            }


            /*
             * =====================================================
             * COMMIT
             * =====================================================
             */

            con.commit();


            /*
             * =====================================================
             * SUCCESS
             * =====================================================
             */

            out.println(
                "{\"success\":true," +
                "\"message\":\"Payment verified and all orders placed\"}"
            );


        } catch (SQLException e) {

            rollbackQuietly(con);

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.println(
                "{\"success\":false,\"error\":\"Database error\"}"
            );


        } catch (Exception e) {

            rollbackQuietly(con);

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.println(
                "{\"success\":false,\"error\":\"Payment verification error\"}"
            );


        } finally {

            try {

                if (con != null) {

                    con.setAutoCommit(true);

                    con.close();
                }

            } catch (SQLException e) {

                e.printStackTrace();
            }
        }
    }


    /*
     * =============================================================
     * ROLLBACK HELPER
     * =============================================================
     */

    private void rollbackQuietly(
            Connection con) {

        if (con != null) {

            try {

                con.rollback();

            } catch (SQLException e) {

                e.printStackTrace();
            }
        }
    }
}