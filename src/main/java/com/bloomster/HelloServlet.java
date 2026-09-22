package com.bloomster;

import com.myServlet.DB;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet({"/", "/hello", "/dbstatus"})
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        if ("/".equals(request.getServletPath())) {
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        String title = request.getRequestURI().endsWith("/dbstatus")
                ? "Database Status"
                : "Welcome to Bloomster";

        try (Connection connection = DB.getConnection()) {
            response.getWriter().println("<h1>" + title + "</h1>");
            response.getWriter().println("<p>Database connection successful.</p>");
            response.getWriter().println("<p>Connected to: " + connection.getMetaData().getURL() + "</p>");
        } catch (SQLException e) {
            response.getWriter().println("<h1>" + title + "</h1>");
            response.getWriter().println("<p>Database connection failed.</p>");
            response.getWriter().println("<p>Error: " + e.getMessage() + "</p>");
        }
    }
}
