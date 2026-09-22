package com.bloomster;

import java.util.Map;

import com.myServlet.DB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

import java.security.MessageDigest;
import java.time.Instant;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import org.mindrot.jbcrypt.BCrypt;


@WebServlet({"/login-account"})
public class Login extends HttpServlet {


    private void saveRefreshToken(
            int userId,
            String refreshToken
    ) throws Exception {

        String tokenHash =
                hashToken(refreshToken);

        String sql = """
            INSERT INTO refresh_tokens
            (user_id, token_hash, expires_at, revoked)
            VALUES (?, ?, ?, 0)
            """;

        try (
            Connection con =
                    DB.getConnection();

            PreparedStatement ps =
                    con.prepareStatement(sql)
        ) {

            ps.setInt(1, userId);

            ps.setString(
                    2,
                    tokenHash
            );

            ps.setTimestamp(
                    3,
                    Timestamp.from(
                        Instant.now().plusSeconds(
                            30L * 24 * 60 * 60
                        )
                    )
            );

            ps.executeUpdate();
        }
    }


    private String hashToken(
            String token
    ) throws Exception {

        MessageDigest digest =
                MessageDigest.getInstance(
                        "SHA-256"
                );

        byte[] hash =
                digest.digest(
                    token.getBytes(
                        java.nio.charset.StandardCharsets.UTF_8
                    )
                );

        StringBuilder hex =
                new StringBuilder();

        for (byte b : hash) {

            hex.append(
                String.format(
                    "%02x",
                    b
                )
            );
        }

        return hex.toString();
    }


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {


        response.setContentType(
                "application/json"
        );

        response.setCharacterEncoding(
                "UTF-8"
        );


        PrintWriter out =
                response.getWriter();


        Connection con = null;
        PreparedStatement ps = null;


        try {

            ReadJSON readJSON =
                    new ReadJSON();

            Map<String, Object> data =
                    readJSON.readJSON(request);


            String email =
                    (String) data.get("email");

            String password =
                    (String) data.get("password");


            if (
                email == null ||
                email.isEmpty() ||
                password == null ||
                password.isEmpty()
            ) {

                response.setStatus(
                        HttpServletResponse.SC_BAD_REQUEST
                );

                out.write(
                    "{\"success\":false,\"error\":\"Email and password are required\"}"
                );

                return;
            }


            con =
                    DB.getConnection();


            /*
             * =================================================
             * USER KO EMAIL SE FIND KARO
             * =================================================
             *
             * Password WHERE clause me nahi lagana.
             * Database se hashed password nikaalna hai.
             */

            String sql =
                    "SELECT id, email, password " +
                    "FROM user " +
                    "WHERE email = ?";


            ps =
                    con.prepareStatement(sql);


            ps.setString(
                    1,
                    email
            );


            try (
                ResultSet rs =
                        ps.executeQuery()
            ) {


                if (!rs.next()) {

                    response.setStatus(
                            HttpServletResponse.SC_UNAUTHORIZED
                    );

                    out.write(
                        "{\"success\":false,\"error\":\"Invalid email or password\"}"
                    );

                    return;
                }


                /*
                 * =================================================
                 * USER FOUND
                 * =================================================
                 */

                int userId =
                        rs.getInt("id");


                String storedPassword =
                        rs.getString("password");


                /*
                 * =================================================
                 * BCRYPT PASSWORD CHECK
                 * =================================================
                 */

                boolean passwordCorrect =
                        BCrypt.checkpw(
                                password,
                                storedPassword
                        );


                if (!passwordCorrect) {

                    response.setStatus(
                            HttpServletResponse.SC_UNAUTHORIZED
                    );

                    out.write(
                        "{\"success\":false,\"error\":\"Invalid email or password\"}"
                    );

                    return;
                }


                /*
                 * =================================================
                 * PASSWORD CORRECT
                 * =================================================
                 *
                 * IMPORTANT:
                 * user_id ko HTTP SESSION me save kar rahe hain.
                 *
                 * product.jsp isi session se user_id lega.
                 */

                HttpSession session =
                        request.getSession(true);

                session.setAttribute(
                        "user_id",
                        userId
                );


                /*
                 * =================================================
                 * ACCESS TOKEN
                 * =================================================
                 */

                String accessToken =
                        JwtUtil.generateAccessToken(
                                userId,
                                email
                        );


                /*
                 * =================================================
                 * REFRESH TOKEN
                 * =================================================
                 */

                String refreshToken =
                        JwtUtil.generateRefreshToken(
                                userId
                        );


                /*
                 * =================================================
                 * REFRESH TOKEN KA HASH DB ME SAVE
                 * =================================================
                 */

                saveRefreshToken(
                        userId,
                        refreshToken
                );


                /*
                 * =================================================
                 * REFRESH TOKEN COOKIE
                 * =================================================
                 */

                Cookie refreshCookie =
                        new Cookie(
                            "refreshToken",
                            refreshToken
                        );


                /*
                 * JavaScript is cookie ko read nahi kar sakta.
                 */

                refreshCookie.setHttpOnly(
                        true
                );


                /*
                 * =================================================
                 * LOCAL HTTP TESTING
                 * =================================================
                 *
                 * Localhost HTTP par false.
                 *
                 * Production HTTPS par true karna.
                 */

                refreshCookie.setSecure(
                        false
                );


                /*
                 * Cookie poore application ke liye available.
                 */

                refreshCookie.setPath(
                        "/"
                );


                /*
                 * 30 DAYS
                 */

                refreshCookie.setMaxAge(
                        30 * 24 * 60 * 60
                );


                response.addCookie(
                        refreshCookie
                );


                /*
                 * =================================================
                 * LOGIN SUCCESS
                 * =================================================
                 */

                response.setStatus(
                        HttpServletResponse.SC_OK
                );


                out.write(
                    "{\"success\":true," +
                    "\"message\":\"Login Successful\"," +
                    "\"user_id\":" + userId + "," +
                    "\"accessToken\":\"" +
                    accessToken +
                    "\"," +
                    "\"expiresIn\":900}"
                );
            }


        } catch (ClassCastException e) {

            System.out.println(
                "Type mismatch in login: " +
                e.getMessage()
            );

            response.setStatus(
                    HttpServletResponse.SC_BAD_REQUEST
            );

            out.write(
                "{\"success\":false,\"error\":\"Invalid data format\"}"
            );


        } catch (NullPointerException e) {

            System.out.println(
                "Missing field in login: " +
                e.getMessage()
            );

            response.setStatus(
                    HttpServletResponse.SC_BAD_REQUEST
            );

            out.write(
                "{\"success\":false,\"error\":\"Required field missing\"}"
            );


        } catch (SQLException e) {

            System.out.println(
                "DB error in login: " +
                e.getMessage()
            );

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.write(
                "{\"success\":false,\"error\":\"Database error\"}"
            );


        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.write(
                "{\"success\":false,\"error\":\"Something went wrong\"}"
            );


        } finally {

            try {

                if (ps != null) {
                    ps.close();
                }

                if (con != null) {
                    con.close();
                }

            } catch (SQLException e) {

                System.out.println(
                    "Error closing DB resources: " +
                    e.getMessage()
                );
            }
        }
    }
}