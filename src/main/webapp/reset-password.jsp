<%@ page import="jakarta.servlet.http.HttpSession" %><%
HttpSession s=request.getSession(false);
if(s==null||!Boolean.TRUE.equals(s.getAttribute("reset_verified"))){response.sendRedirect("forgot-password.jsp");return;}
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Reset Password - Bloomster</title></head><body>
<h2>New Password</h2><form id="f"><input type="password" id="p" placeholder="New password" required><input type="password" id="c" placeholder="Confirm password" required><button>Reset Password</button></form><p id="m"></p>
<script>
document.getElementById("f").onsubmit=async e=>{e.preventDefault();let p=document.getElementById("p").value,c=document.getElementById("c").value,m=document.getElementById("m");
if(p!==c){m.innerText="Passwords do not match";return}if(p.length<8){m.innerText="Password must be at least 8 characters";return}
try{let r=await fetch("reset-password",{method:"POST",headers:{"Content-Type":"application/json"},credentials:"same-origin",body:JSON.stringify({password:p})});let d=await r.json();m.innerText=d.message||d.error;if(r.ok&&d.success)setTimeout(()=>location.href="login.jsp",1200)}catch(x){m.innerText="Server error"}};
</script></body></html>
