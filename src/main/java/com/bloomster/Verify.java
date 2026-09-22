
package com.bloomster;

import java.util.Map;
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
import com.bloomster.ReadJSON;
import java.sql.SQLException;

@WebServlet({"/verify-account"})
public class Verify extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
ReadJSON readJSON = new ReadJSON();
              Map<String, Object> data = readJSON.readJSON(request); 

              String otp = (String) data.get("otp");
              String email = (String) data.get("email");
              email = email.replaceAll("%40", "@");
              
       int intotp = Integer.parseInt(otp);
   try (
                Connection con = DB.getConnection();
                PreparedStatement ps = con.prepareStatement("SELECT * FROM user WHERE email = \""+email+"\"");
                ResultSet rs = ps.executeQuery();
                PrintWriter out = response.getWriter()
   ){
       if (rs.next()) {
            int dbOtp = rs.getInt("otp");
            if (dbOtp != intotp) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\":\"Invalid OTP\"}");
                return;
            }
        //  PrintWriter out = response.getWriter();
         response.setStatus(HttpServletResponse.SC_OK);
         out.write("{\"message\":\"OTP verified successfully!\", \"status\":200}");

         return;
         
        }
     } catch (SQLException e) {
             System.out.println("Message: " + e.getMessage());
    System.out.println("SQLState: " + e.getSQLState());
    System.out.println("ErrorCode: " + e.getErrorCode());
      e.printStackTrace();
            throw new ServletException("Unable to load users from the database", e);
           
        }
    }
}