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

@WebServlet({"/get_address"})
public class getaddress extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
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
            int userId = Integer.parseInt(userIdParam);

            con = DB.getConnection();
            ps = con.prepareStatement("SELECT address FROM user WHERE id = ?");
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    response.setStatus(404);
                    out.print("{\"error\":\"User not found\"}");
                    return;
                }

                String address = rs.getString("address");

                if (address == null || address.trim().isEmpty()) {
                    out.print("{\"address\":null}");
                } else {
                    out.print("{\"address\":\"" + escapeJson(address) + "\"}");
                }
            }

        } catch (NumberFormatException e) {
            System.out.println("Invalid user_id in get_address: " + userIdParam);
            response.setStatus(400);
            out.print("{\"error\":\"Invalid user_id\"}");

        } catch (SQLException e) {
            System.out.println("DB error in get_address: " + e.getMessage());
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
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}