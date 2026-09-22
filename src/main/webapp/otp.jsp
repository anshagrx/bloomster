<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>OTP Verification</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body{
    background:#f5f7fb;
}
.card{
    border-radius:15px;
}
.otp-input{
    width:55px;
    height:55px;
    text-align:center;
    font-size:22px;
    margin:5px;
}
</style>

</head>
<body>

<div class="container d-flex justify-content-center align-items-center vh-100">

<div class="card shadow p-4" style="width:420px;">

<h3 class="text-center text-success">Verify OTP</h3>

<p class="text-center text-muted">
OTP has been sent to your Email / Mobile
</p>

<form  method="post" id="otp-form">

<div class="d-flex justify-content-center">

<input type="text" maxlength="1" class="form-control otp-input" name="o1">
<input type="text" maxlength="1" class="form-control otp-input" name="o2">
<input type="text" maxlength="1" class="form-control otp-input" name="o3">
<input type="text" maxlength="1" class="form-control otp-input" name="o4">
<%-- <input type="text" maxlength="1" class="form-control otp-input" name="o5">
<input type="text" maxlength="1" class="form-control otp-input" name="o6"> --%>

</div>

<div class="text-center mt-3">

<button class="btn btn-success w-100">
Verify OTP
</button>

</div>

<div class="text-center mt-3">
<a href="ResendOtp" class="text-decoration-none">
Resend OTP
</a>
</div>

</form>

</div>

</div>
<script>
const form = document.getElementById('otp-form');
form.addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(form);
    
    let otp ="";

    const url = new URL(window.location.href);
    const params = new URLSearchParams(url.search);
    otp = formData.get("o1") + formData.get("o2") + formData.get("o3") + formData.get("o4") ;
    // Retrieve a single parameter
    const email = params.get("email"); // "John"
const data = {"otp": otp, "email": email};
    formData.forEach((value, key) => {
        otp += value;
    });
    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };
    console.log(requestOptions);
    fetch('http://localhost:8081/Bloomster/verify-account', requestOptions)
        .then(response => response.json())
        .then(response => {
            console.log('Success:', response.status);
            alert("your account is Verified successfully!");
            if ( response.status==200 ) {
                alert("OTP verified successfully! Redirecting to login page.");
                window.location.href = "login.jsp";
            } else {
                alert("Invalid OTP. Please try again.");
                console.error('Error:', response);
            }
        })
        .catch((error) => {
            console.error('Error:', error);
            alert("An error occurred while verifying the OTP. Please try again.");
        });
});

</script>

</body>
</html>