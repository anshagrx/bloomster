package com.bloomster;

import com.myServlet.DB;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/logout")
public class logout extends HttpServlet {

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

            if (refreshToken != null &&
                    !refreshToken.isBlank()) {

                String tokenHash =
                        RefreshTokenUtil.hash(
                                refreshToken
                        );

                try (Connection con =
                             DB.getConnection()) {

                    String sql =
                            "UPDATE refresh_tokens " +
                            "SET revoked = true " +
                            "WHERE token_hash = ?";

                    try (PreparedStatement ps =
                                 con.prepareStatement(sql)) {

                        ps.setString(
                                1,
                                tokenHash
                        );

                        ps.executeUpdate();
                    }
                }
            }

            /*
             * Delete refresh token cookie
             */
            String deleteCookie =
                    "refreshToken=;" +
                    " Max-Age=0" +
                    " Path=/refresh-token" +
                    " HttpOnly" +
                    " Secure" +
                    " SameSite=Strict";

            response.addHeader(
                    "Set-Cookie",
                    deleteCookie
            );

            response.setStatus(
                    HttpServletResponse.SC_OK
            );

            out.write(
                    "{\"success\":true,\"message\":\"Logout Successful\"}"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.setStatus(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            out.write(
                    "{\"success\":false,\"error\":\"Logout failed\"}"
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
}