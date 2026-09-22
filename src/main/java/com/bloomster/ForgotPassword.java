package com.bloomster;

import com.myServlet.DB;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.Instant;
import java.util.Map;
import java.util.Random;

@WebServlet("/forgot-password")
public class ForgotPassword extends HttpServlet {
 protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException{
  res.setContentType("application/json"); res.setCharacterEncoding("UTF-8");
  PrintWriter out=res.getWriter();
  try{
   Map<String,Object> d=new ReadJSON().readJSON(req);
   String email=(String)d.get("email");
   if(email==null||email.trim().isEmpty()){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Email is required\"}");return;}
   email=email.trim(); int id;
   try(Connection c=DB.getConnection();PreparedStatement p=c.prepareStatement("SELECT id FROM user WHERE email=?")){
    p.setString(1,email);try(ResultSet r=p.executeQuery()){if(!r.next()){res.setStatus(404);out.print("{\"success\":false,\"error\":\"Email not found\"}");return;}id=r.getInt("id");}
   }
   String otp=String.format("%04d",new Random().nextInt(10000));
   Timestamp expiry=Timestamp.from(Instant.now().plusSeconds(300));
   try(Connection c=DB.getConnection();PreparedStatement p=c.prepareStatement("UPDATE user SET otp=?,otp_expires_at=? WHERE id=?")){
    p.setInt(1,Integer.parseInt(otp));p.setTimestamp(2,expiry);p.setInt(3,id);p.executeUpdate();
   }
  new EmailService().send(email,"Bloomster - Password Reset OTP",
  "<h2>Bloomster Password Reset</h2><p>Your OTP is:</p><h1>"+otp+"</h1><p>Valid for 5 minutes.</p>");
   out.print("{\"success\":true,\"message\":\"OTP sent to your email\"}");
  }catch(Exception e)
  {
    e.printStackTrace();
    res.setStatus(500);
    out.print("{\"success\":false,\"error\":\"Something went wrong\"}");
  }
 }
}