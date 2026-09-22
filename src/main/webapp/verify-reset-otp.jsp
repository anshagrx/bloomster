<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Verify OTP - Bloomster</title></head>
<body><h2>Verify OTP</h2>
<form id="f"><input id="otp" maxlength="4" placeholder="4 digit OTP" required><button>Verify</button></form><p id="m"></p>
<script>
const email=new URLSearchParams(location.search).get("email");
document.getElementById("f").onsubmit=async e=>{
 e.preventDefault(); const otp=document.getElementById("otp").value.trim();
 try{const r=await fetch("verify-reset-otp",{method:"POST",headers:{"Content-Type":"application/json"},credentials:"same-origin",body:JSON.stringify({email,otp})});
 const d=await r.json();document.getElementById("m").innerText=d.message||d.error;
 if(r.ok&&d.success)location.href="reset-password.jsp";
 }catch(x){document.getElementById("m").innerText="Server error";}
};
</script></body></html>
