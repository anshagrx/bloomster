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
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet({"/update_user"})
public class updateuser extends HttpServlet {

    // Sirf ye fields allow honge update karne ke liye - security ke liye
    // (taaki koi 'password' ya 'id' seedha overwrite na kar sake is API se)
    private static final List<String> ALLOWED_FIELDS = List.of(
        "address", "first_name", "last_name", "username"
    );

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

            int userId = (int) data.get("user_id");

            // Sirf allowed fields nikalo jo JSON me aaye hain
            List<String> fieldsToUpdate = new ArrayList<>();
            List<Object> values = new ArrayList<>();

            for (String field : ALLOWED_FIELDS) {
                if (data.containsKey(field)) {
                    Object value = data.get(field);

                    if (value == null || value.toString().trim().isEmpty()) {
                        continue; // khali field skip karo
                    }

                    if (value.toString().length() > 500) {
                        response.setStatus(400);
                        out.println("{\"success\":false,\"error\":\"" + field + " is too long\"}");
                        return;
                    }

                    fieldsToUpdate.add(field);
                    values.add(value.toString().trim());
                }
            }

            if (fieldsToUpdate.isEmpty()) {
                response.setStatus(400);
                out.println("{\"success\":false,\"error\":\"No valid fields to update\"}");
                return;
            }

            // Dynamic query banao: "UPDATE user SET address = ?, first_name = ? WHERE id = ?"
            StringBuilder sql = new StringBuilder("UPDATE user SET ");
            for (int i = 0; i < fieldsToUpdate.size(); i++) {
                sql.append(fieldsToUpdate.get(i)).append(" = ?");
                if (i < fieldsToUpdate.size() - 1) sql.append(", ");
            }
            sql.append(" WHERE id = ?");

            con = DB.getConnection();
            ps = con.prepareStatement(sql.toString());

            int paramIndex = 1;
            for (Object value : values) {
                ps.setString(paramIndex++, value.toString());
            }
            ps.setInt(paramIndex, userId);

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated > 0) {
                out.println("{\"success\":true}");
            } else {
                response.setStatus(404);
                out.println("{\"success\":false,\"error\":\"User not found\"}");
            }

        } catch (ClassCastException e) {
            System.out.println("Type mismatch in update_user: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"Invalid data type\"}");

        } catch (NullPointerException e) {
            System.out.println("Missing field in update_user: " + e.getMessage());
            response.setStatus(400);
            out.println("{\"success\":false,\"error\":\"user_id is required\"}");

        } catch (SQLException e) {
            System.out.println("DB error in update_user: " + e.getMessage());
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