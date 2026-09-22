package com.bloomster;

import com.myServlet.DB;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;
import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Map;

@WebServlet("/reset-password")
public class ResetPassword extends HttpServlet {
 protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException{
  res.setContentType("application/json");res.setCharacterEncoding("UTF-8");PrintWriter out=res.getWriter();
  try{
   HttpSession s=req.getSession(false);
   Object idObj=s==null?null:s.getAttribute("reset_user_id");
   if(s==null||!Boolean.TRUE.equals(s.getAttribute("reset_verified"))||!(idObj instanceof Integer)){res.setStatus(401);out.print("{\"success\":false,\"error\":\"Reset session expired\"}");return;}
   Map<String,Object>d=new ReadJSON().readJSON(req);String password=(String)d.get("password");
   if(password==null||password.length()<8){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Password must be at least 8 characters\"}");return;}
   String hash=BCrypt.hashpw(password,BCrypt.gensalt(12));
   try(Connection c=DB.getConnection();PreparedStatement p=c.prepareStatement("UPDATE user SET password=?,otp=0,otp_expires_at=NULL WHERE id=?")){
    p.setString(1,hash);p.setInt(2,(Integer)idObj);if(p.executeUpdate()==0){res.setStatus(400);out.print("{\"success\":false,\"error\":\"Password reset failed\"}");return;}
   }
   s.removeAttribute("reset_user_id");s.removeAttribute("reset_verified");
   out.print("{\"success\":true,\"message\":\"Password reset successfully\"}");
  }catch(Exception e){e.printStackTrace();res.setStatus(500);out.print("{\"success\":false,\"error\":\"Something went wrong\"}");}
 }
}
