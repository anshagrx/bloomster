<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Forgot Password - Bloomster</title></head>
<body>
<h2>Forgot Password</h2>
<form id="f"><input type="email" id="email" placeholder="Email" required><button>Send OTP</button></form>
<p id="m"></p>
<script>
document.getElementById("f").onsubmit=async e=>{
 e.preventDefault(); const email=document.getElementById("email").value.trim();
 try{
  const r=await fetch("forgot-password",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({email})});
  const d=await r.json(); document.getElementById("m").innerText=d.message||d.error;
  if(r.ok&&d.success) location.href="verify-reset-otp.jsp?email="+encodeURIComponent(email);
 }catch(x){document.getElementById("m").innerText="Server error";}
};
</script></body></html>
