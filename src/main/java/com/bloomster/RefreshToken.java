package com.bloomster;

import com.myServlet.DB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import io.jsonwebtoken.Claims;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

@WebServlet("/refresh-token")
public class RefreshToken extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out =
                response.getWriter();

        try {

            String refreshToken =
                    getRefreshTokenFromCookie(request);

            if (refreshToken == null ||
                    refreshToken.isBlank()) {

                response.setStatus(
                        HttpServletResponse.SC_UNAUTHORIZED
                );

                out.write(
                        "{\"success\":false,\"error\":\"Refresh token missing\"}"
                );

                return;
            }

            /*
             * JWT signature + expiry validate
             */
            Claims claims;

            try {

                claims =
                        JwtUtil.validateToken(
                                refreshToken
                        );

            } catch (Exception e) {

                response.setStatus(
                        HttpServletResponse.SC_UNAUTHORIZED
                );

                out.write(
                        "{\"success\":false,\"error\":\"Invalid or expired refresh token\"}"
                );

                return;
            }

            /*
             * Make sure token is actually refresh token
             */
            String tokenType =
                    claims.get(
                            "type",
                            String.class
                    );

            if (!"refresh".equals(tokenType)) {

                response.setStatus(
                        HttpServletResponse.SC_UNAUTHORIZED
                );

                out.write(
                        "{\"success\":false,\"error\":\"Invalid token type\"}"
                );

                return;
            }

            int userId =
                    Integer.parseInt(
                            claims.getSubject()
                    );

            String oldHash =
                    RefreshTokenUtil.hash(
                            refreshToken
                    );

            try (Connection con =
                         DB.getConnection()) {

                /*
                 * Find active refresh token
                 */
                String sql =
                        "SELECT id " +
                        "FROM refresh_tokens " +
                        "WHERE token_hash = ? " +
                        "AND user_id = ? " +
                        "AND revoked = false " +
                        "AND expires_at > NOW()";

                long refreshTokenId;

                try (PreparedStatement ps =
                             con.prepareStatement(sql)) {

                    ps.setString(
                            1,
                            oldHash
                    );

                    ps.setInt(
                            2,
                            userId
                    );

                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (!rs.next()) {

                            response.setStatus(
                                    HttpServletResponse.SC_UNAUTHORIZED
                            );

                            out.write(
                                    "{\"success\":false,\"error\":\"Refresh token revoked or not found\"}"
                            );

                            return;
                        }

                        refreshTokenId =
                                rs.getLong("id");
                    }
                }

                /*
                 * Get user information
                 */
                String email;

                String userSql =
                        "SELECT email FROM user WHERE id = ?";

                try (PreparedStatement ps =
                             con.prepareStatement(userSql)) {

                    ps.setInt(
                            1,
                            userId
                    );

                    try (ResultSet rs =
                                 ps.executeQuery()) {

                        if (!rs.next()) {

                            response.setStatus(
                                    HttpServletResponse.SC_UNAUTHORIZED
                            );

                            out.write(
                                    "{\"success\":false,\"error\":\"User not found\"}"
                            );

                            return;
                        }

                        email =
                                rs.getString("email");
                    }
                }

                /*
                 * ROTATE refresh token
                 */

                String newRefreshToken =
                        JwtUtil.generateRefreshToken(
                                userId
                        );

                String newRefreshHash =
                        RefreshTokenUtil.hash(
                                newRefreshToken
                        );

                Timestamp newExpiresAt =
                        new Timestamp(
                                System.currentTimeMillis()
                                + 30L * 24 * 60 * 60 * 1000
                        );

                /*
                 * Revoke old refresh token
                 */
                String revokeSql =
                        "UPDATE refresh_tokens " +
                        "SET revoked = true " +
                        "WHERE id = ?";

                try (PreparedStatement ps =
                             con.prepareStatement(revokeSql)) {

                    ps.setLong(
                            1,
                            refreshTokenId
                    );

                    ps.executeUpdate();
                }

                /*
                 * Save new refresh token
                 */
                String insertSql =
                        "INSERT INTO refresh_tokens " +
                        "(user_id, token_hash, expires_at, revoked) " +
                        "VALUES (?, ?, ?, false)";

                try (PreparedStatement ps =
                             con.prepareStatement(insertSql)) {

                    ps.setInt(
                            1,
                            userId
                    );

                    ps.setString(
                            2,
                            newRefreshHash
                    );

                    ps.setTimestamp(
                            3,
                            newExpiresAt
                    );

                    ps.executeUpdate();
                }

                /*
                 * Generate NEW access token
                 */
                String newAccessToken =
                        JwtUtil.generateAccessToken(
                                userId,
                                email
                        );

                /*
                 * New refresh cookie
                 */
                String cookie =
                        "refreshToken=" +
                        newRefreshToken +
                        "; Max-Age=2592000" +
                        "; Path=/refresh-token" +
                        "; HttpOnly" +
                        "; Secure" +
                        "; SameSite=Strict";

                response.addHeader(
                        "Set-Cookie",
                        cookie
                );

                response.setStatus(
                        HttpServletResponse.SC_OK
                );

                out.write(
                        "{"
                        + "\"success\":true,"
                        + "\"accessToken\":\""
                        + escapeJson(newAccessToken)
                        + "\","
                        + "\"expiresIn\":900"
                        + "}"
                );
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.write(
                    "{\"success\":false,\"error\":\"Something went wrong\"}"
            );
        }
    }

    private String getRefreshTokenFromCookie(
            HttpServletRequest request
    ) {

        Cookie[] cookies =
                request.getCookies();

        if (cookies == null) {
            return null;
        }

        for (Cookie cookie : cookies) {

            if ("refreshToken".equals(
                    cookie.getName()
            )) {

                return cookie.getValue();
            }
        }

        return null;
    }

    private String escapeJson(String value) {

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"");
    }
}