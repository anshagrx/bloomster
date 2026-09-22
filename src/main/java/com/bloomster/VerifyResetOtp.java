package com.bloomster;

import com.myServlet.DB;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.Instant;
import java.util.Map;

@WebServlet("/verify-reset-otp")
public class VerifyResetOtp extends HttpServlet {
 protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException{
  res.setContentType("application/json");res.setCharacterEncoding("UTF-8");PrintWriter out=res.getWriter();
  try{
   Map<String,Object>d=new ReadJSON().readJSON(req);String email=(String)d.get("email"),otp=(String)d.get("otp");
   if(email==null||otp==null){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Email and OTP are required\"}");return;}
   int entered;try{entered=Integer.parseInt(otp.trim());}catch(Exception x){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Invalid OTP\"}");return;}
   try(Connection c=DB.getConnection();PreparedStatement p=c.prepareStatement("SELECT id,otp,otp_expires_at FROM user WHERE email=?")){
    p.setString(1,email.trim());try(ResultSet r=p.executeQuery()){
     if(!r.next()||r.getInt("otp")!=entered){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Invalid OTP\"}");return;}
     Timestamp exp=r.getTimestamp("otp_expires_at");
     if(exp==null||exp.toInstant().isBefore(Instant.now())){res.setStatus(400);out.print("{\"success\":false,\"error\":\"OTP expired\"}");return;}
     HttpSession s=req.getSession(true);s.setAttribute("reset_user_id",r.getInt("id"));s.setAttribute("reset_verified",true);
     out.print("{\"success\":true,\"message\":\"OTP verified successfully\"}");
    }
   }
  }catch(Exception e){e.printStackTrace();res.setStatus(500);out.print("{\"success\":false,\"error\":\"Something went wrong\"}");}
 }
}
