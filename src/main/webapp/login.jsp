<!DOCTYPE html>
<%@ page isELIgnored="true" %>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sign In | Denim Co.</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  :root{
    --navy:#16213e;
    --navy-soft:#1f2c52;
    --paper:#ffffff;
    --grey-bg:#f4f5f7;
    --line:#e7e7ea;
    --gold:#f0a93b;
    --text:#1c1c22;
    --text-muted:#6b6f7a;
    --error:#d23b3b;
  }
  *{margin:0;padding:0;box-sizing:border-box;}
  body{
    font-family:'Inter',sans-serif;color:var(--text);background:var(--paper);
    -webkit-font-smoothing:antialiased;line-height:1.5;
  }
  h1,h2,h3{font-family:'Oswald',sans-serif;text-transform:uppercase;letter-spacing:.5px;}
  a{text-decoration:none;color:inherit;}
  img{display:block;max-width:100%;}
  button{font-family:inherit;cursor:pointer;border:none;background:none;}
  input{font-family:inherit;}

  .auth-wrap{display:grid;grid-template-columns:1fr 1fr;min-height:100vh;}

  /* ---------- Brand panel ---------- */
  .brand-panel{
    position:relative;background:linear-gradient(160deg,var(--navy) 0%, var(--navy-soft) 60%, #2a3a68 100%);
    color:#fff;padding:54px;display:flex;flex-direction:column;justify-content:space-between;overflow:hidden;
  }
  .brand-panel::before{
    content:"";position:absolute;inset:0;
    background:url('https://placehold.co/900x1200/0c1326/16213e?text=Denim+Texture');
    background-size:cover;opacity:.22;mix-blend-mode:luminosity;
  }
  .brand-top{position:relative;z-index:2;}
  .brand-logo{display:flex;flex-direction:column;line-height:1.1;}
  .brand-logo .name{font-size:24px;font-weight:700;letter-spacing:1px;}
  .brand-logo .est{font-size:9.5px;letter-spacing:2px;color:#aeb6cf;margin-top:4px;}
  .brand-quote{position:relative;z-index:2;max-width:420px;}
  .brand-quote h2{font-size:clamp(26px,3.4vw,36px);font-weight:700;line-height:1.18;}
  .brand-quote p{margin-top:16px;font-size:14.5px;color:#cbd1e5;}
  .brand-stats{position:relative;z-index:2;display:flex;gap:40px;}
  .brand-stats div b{display:block;font-family:'Oswald',sans-serif;font-size:26px;font-weight:700;}
  .brand-stats div span{font-size:12px;color:#aeb6cf;letter-spacing:.5px;}

  /* ---------- Form panel ---------- */
  .form-panel{display:flex;align-items:center;justify-content:center;padding:54px 32px;}
  .form-card{width:100%;max-width:400px;}
  .back-link{
    display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);
    margin-bottom:30px;font-weight:500;
  }
  .back-link svg{width:14px;height:14px;}
  .back-link:hover{color:var(--navy);}
  .form-card h1{font-size:26px;color:var(--navy);font-weight:700;}
  .form-card .sub{margin-top:8px;font-size:14px;color:var(--text-muted);}
  .sub a{color:var(--navy);font-weight:600;text-decoration:underline;}

  .field{margin-top:22px;}
  .field label{
    display:block;font-size:12.5px;font-weight:600;letter-spacing:.4px;color:var(--navy);
    margin-bottom:8px;text-transform:uppercase;
  }
  .input-wrap{position:relative;}
  .input-wrap svg{
    position:absolute;left:14px;top:50%;transform:translateY(-50%);width:17px;height:17px;color:var(--text-muted);
  }
  .field input{
    width:100%;padding:13px 14px 13px 42px;border:1.5px solid var(--line);border-radius:3px;
    font-size:14.5px;background:#fcfcfd;transition:border-color .18s ease, background .18s ease;
  }
  .field input:focus-visible{outline:none;border-color:var(--navy);background:#fff;}
  .field input.error{border-color:var(--error);}
  .toggle-pw{
    position:absolute;right:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);
    display:flex;padding:4px;
  }
  .toggle-pw svg{width:18px;height:18px;}
  .error-msg{font-size:12px;color:var(--error);margin-top:6px;min-height:14px;}

  .row-between{display:flex;align-items:center;justify-content:space-between;margin-top:18px;font-size:13px;}
  .remember{display:flex;align-items:center;gap:8px;color:var(--text-muted);}
  .remember input{width:15px;height:15px;accent-color:var(--navy);}
  .forgot{color:var(--navy);font-weight:600;}
  .forgot:hover{text-decoration:underline;}

  .btn-submit{
    width:100%;margin-top:26px;padding:14px;background:var(--navy);color:#fff;
    font-family:'Oswald',sans-serif;font-size:13px;letter-spacing:1.5px;font-weight:600;
    text-transform:uppercase;border-radius:3px;transition:background .18s ease, transform .18s ease;
    display:flex;align-items:center;justify-content:center;gap:8px;
  }
  .btn-submit:hover{background:var(--navy-soft);transform:translateY(-1px);}
  .btn-submit:focus-visible{outline:3px solid var(--gold);outline-offset:2px;}

  .divider{display:flex;align-items:center;gap:14px;margin:26px 0;color:var(--text-muted);font-size:12px;}
  .divider::before,.divider::after{content:"";flex:1;height:1px;background:var(--line);}

  .social-btn{
    width:100%;padding:12px;border:1.5px solid var(--line);border-radius:3px;
    display:flex;align-items:center;justify-content:center;gap:10px;font-size:13.5px;font-weight:600;
    color:var(--text);transition:border-color .18s ease, background .18s ease;
  }
  .social-btn:hover{background:var(--grey-bg);border-color:var(--navy);}
  .social-btn svg{width:18px;height:18px;}

  .form-note{margin-top:24px;font-size:12px;color:var(--text-muted);text-align:center;}
  .form-note a{color:var(--navy);font-weight:600;text-decoration:underline;}

  .toast{
    position:fixed;bottom:26px;right:26px;background:var(--navy);color:#fff;padding:14px 20px;
    border-radius:4px;font-size:13.5px;font-weight:500;box-shadow:0 14px 30px -10px rgba(0,0,0,.35);
    display:flex;align-items:center;gap:10px;transform:translateY(20px);opacity:0;
    transition:transform .25s ease, opacity .25s ease;pointer-events:none;
  }
  .toast.show{transform:translateY(0);opacity:1;}
  .toast svg{width:18px;height:18px;color:var(--gold);}

  @media (max-width:880px){
    .auth-wrap{grid-template-columns:1fr;}
    .brand-panel{display:none;}
    .form-panel{padding:40px 22px;min-height:100vh;}
  }
</style>
</head>
<body>

<div class="auth-wrap">

  <!-- ============ BRAND PANEL ============ -->
  <aside class="brand-panel">
    <div class="brand-top">
      <a href="index.jsp" class="brand-logo">
        <span class="name">DENIM CO.</span>
        <span class="est">EST. 2020</span>
      </a>
    </div>

    <div class="brand-quote">
      <h2>Welcome back to comfort, built to last.</h2>
      <p>Sign in to track your orders, save favourites, and get early access to new drops and member-only offers.</p>
    </div>

    <div class="brand-stats">
      <div><b>50K+</b><span>Happy Customers</span></div>
      <div><b>4.8★</b><span>Average Rating</span></div>
      <div><b>30 Days</b><span>Free Returns</span></div>
    </div>
  </aside>

  <!-- ============ FORM PANEL ============ -->
  <main class="form-panel">
    <div class="form-card">
      <a href="index.jsp" class="back-link">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M19 12H5M11 6l-6 6 6 6"/></svg>
        Back to store
      </a>

      <h1>Sign In</h1>
      <p class="sub">New here? <a href="signup.jsp">Create an account</a></p>

      <form id="loginForm">
        <div class="field">
          <label for="email">Email Address</label>
          <div class="input-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 6l9 7 9-7"/><rect x="3" y="5" width="18" height="14" rx="2"/></svg>
            <input type="email" id="email" placeholder="you@example.com" required>
          </div>
          <p class="error-msg" id="emailError"></p>
        </div>

        <div class="field">
          <label for="password">Password</label>
          <div class="input-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
            <input type="password" id="password" placeholder="Enter your password" required>
            <button type="button" class="toggle-pw" id="togglePw" aria-label="Show password">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7z"/><circle cx="12" cy="12" r="3"/></svg>
            </button>
          </div>
          <p class="error-msg" id="passwordError"></p>
        </div>

        <div class="row-between">
          <label class="remember"><input type="checkbox" id="remember"> Remember me</label>
          <a href="forgot-password.jsp">Forgot Password?</a>
        </div>

        <button type="submit" class="btn-submit" id="SignInBtn">
          Sign In
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" width="15" height="15"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
        </button>
      </form>

      <div class="divider">OR CONTINUE WITH</div>

      <button class="social-btn" id="googleBtn">
        <svg viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.07 5.07 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.99.67-2.26 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0012 23z"/><path fill="#FBBC05" d="M5.84 14.1A6.6 6.6 0 015.5 12c0-.73.12-1.44.34-2.1V7.06H2.18A11 11 0 001 12c0 1.77.42 3.45 1.18 4.94l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15A10.96 10.96 0 0012 1 11 11 0 002.18 7.06l3.66 2.84C6.71 7.3 9.14 5.38 12 5.38z"/></svg>
        Continue with Google
      </button>

      <p class="form-note">By signing in, you agree to our <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a>.</p>
    </div>
  </main>
</div>

<div class="toast" id="toast">
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M20 6L9 17l-5-5"/></svg>
  <span id="toastText">Signed in successfully!</span>
</div>

<script>
const form = document.getElementById("loginForm");
const emailInput = document.getElementById("email");
const pwInput = document.getElementById("password");
const emailError = document.getElementById("emailError");
const pwError = document.getElementById("passwordError");
const toast = document.getElementById("toast");

function showToast(msg) {
    document.getElementById("toastText").textContent = msg;
    toast.classList.add("show");
    setTimeout(() => {
        toast.classList.remove("show");
    }, 3000);
}

document.getElementById("togglePw").addEventListener("click", function () {
    pwInput.type = pwInput.type === "password" ? "text" : "password";
});

form.addEventListener("submit", async function (e) {

    // STOP PAGE RELOAD
    e.preventDefault();

    console.log("Submit intercepted");

    let valid = true;

    emailError.textContent = "";
    pwError.textContent = "";
    emailInput.classList.remove("error");
    pwInput.classList.remove("error");

    const email = emailInput.value.trim();
    const password = pwInput.value;

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        emailError.textContent = "Enter valid email";
        emailInput.classList.add("error");
        valid = false;
    }

    if (password.length < 6) {
        pwError.textContent = "Password must be at least 6 characters";
        pwInput.classList.add("error");
        valid = false;
    }

    if (!valid) return;

    const data = {
        email: email,
        password: password
    };

    console.log("Sending:", data);

    try {

    const response = await fetch("http://localhost:8081/Bloomster/login-account", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
    });

    console.log("Status:", response.status);

    const result = await response.json();

    console.log(result);

    if (result.success) {
        showToast("Login Successful");
        setTimeout(() => {
            window.location.href = "index.jsp"; // apna home/dashboard page daalo
        }, 800);
    } else {
        showToast(result.error || "Login Failed");
    }

} catch (err) {

    console.error(err);

    showToast("Network error, please try again");
}

});

document.getElementById("googleBtn").addEventListener("click", function () {
    showToast("Google Login");
});
</script>
</body>
</html>