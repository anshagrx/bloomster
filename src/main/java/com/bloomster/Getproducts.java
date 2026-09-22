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

@WebServlet("/get-products")
public class Getproducts extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM products");
                ResultSet rs = ps.executeQuery();
                PrintWriter out = response.getWriter()
        ) {

            out.print("[");

            boolean first = true;

            while (rs.next()) {

                if (!first) {
                    out.print(",");
                }
                first = false;

                out.printf(
                        "{\"id\":%d," +
                        "\"name\":\"%s\"," +
                        "\"categoryId\":%d," +
                        "\"price\":%d," +
                        "\"stock\":%d," +
                        "\"img\":\"%s\"," +
                        "\"rating\":%.1f," +
                        "\"description\":\"%s\"," +
                        "\"reviews\":\"%s\"," +
                        "\"discount\":%.1f," +
                        "\"category\":\"%s\"}",

                        rs.getInt("product_id"),
                        escapeJson(rs.getString("product_name")),
                        rs.getInt("category_id"),
                        rs.getInt("price"),
                        rs.getInt("stock"),
                        escapeJson(rs.getString("img")),
                        rs.getFloat("rating"),
                        escapeJson(rs.getString("description")),
                        escapeJson(rs.getString("reviews")),
                        rs.getFloat("discount"),
                        escapeJson(rs.getString("category"))
                );
            }

            out.print("]");

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Unable to load products from the database", e);
        }
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "null";
        }

        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}