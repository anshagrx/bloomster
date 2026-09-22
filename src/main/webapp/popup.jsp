

<!DOCTYPE html>
<%@ page isELIgnored="true" %>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Create Account | Denim Co.</title>
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
    --success:#2f9e5b;
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
  .perk-list{position:relative;z-index:2;display:flex;flex-direction:column;gap:14px;}
  .perk-list div{display:flex;align-items:center;gap:12px;font-size:13.5px;color:#dfe3ee;}
  .perk-list svg{width:18px;height:18px;color:var(--gold);flex-shrink:0;}

  /* ---------- Form panel ---------- */
  .form-panel{display:flex;align-items:center;justify-content:center;padding:54px 32px;}
  .form-card{width:100%;max-width:420px;}
  .back-link{
    display:inline-flex;align-items:center;gap:6px;font-size:13px;color:var(--text-muted);
    margin-bottom:30px;font-weight:500;
  }
  .back-link svg{width:14px;height:14px;}
  .back-link:hover{color:var(--navy);}
  .form-card h1{font-size:26px;color:var(--navy);font-weight:700;}
  .form-card .sub{margin-top:8px;font-size:14px;color:var(--text-muted);}
  .sub a{color:var(--navy);font-weight:600;text-decoration:underline;}

  .field-row{display:grid;grid-template-columns:1fr 1fr;gap:14px;}
  .field{margin-top:20px;}
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
  .field input.success{border-color:var(--success);}
  .toggle-pw{
    position:absolute;right:12px;top:50%;transform:translateY(-50%);color:var(--text-muted);
    display:flex;padding:4px;
  }
  .toggle-pw svg{width:18px;height:18px;}
  .error-msg{font-size:12px;color:var(--error);margin-top:6px;min-height:14px;}

  .pw-meter{display:flex;gap:4px;margin-top:8px;}
  .pw-meter span{height:4px;flex:1;border-radius:2px;background:var(--line);transition:background .2s ease;}
  .pw-hint{font-size:11.5px;color:var(--text-muted);margin-top:6px;}

  .terms-row{display:flex;align-items:flex-start;gap:10px;margin-top:22px;font-size:12.5px;color:var(--text-muted);}
  .terms-row input{width:16px;height:16px;margin-top:1px;accent-color:var(--navy);flex-shrink:0;}
  .terms-row a{color:var(--navy);font-weight:600;text-decoration:underline;}

  .btn-submit{
    width:100%;margin-top:24px;padding:14px;background:var(--navy);color:#fff;
    font-family:'Oswald',sans-serif;font-size:13px;letter-spacing:1.5px;font-weight:600;
    text-transform:uppercase;border-radius:3px;transition:background .18s ease, transform .18s ease;
    display:flex;align-items:center;justify-content:center;gap:8px;
  }
  .btn-submit:hover{background:var(--navy-soft);transform:translateY(-1px);}
  .btn-submit:focus-visible{outline:3px solid var(--gold);outline-offset:2px;}
  .btn-submit:disabled{opacity:.55;cursor:not-allowed;transform:none;}

  .divider{display:flex;align-items:center;gap:14px;margin:24px 0;color:var(--text-muted);font-size:12px;}
  .divider::before,.divider::after{content:"";flex:1;height:1px;background:var(--line);}

  .social-btn{
    width:100%;padding:12px;border:1.5px solid var(--line);border-radius:3px;
    display:flex;align-items:center;justify-content:center;gap:10px;font-size:13.5px;font-weight:600;
    color:var(--text);transition:border-color .18s ease, background .18s ease;
  }
  .social-btn:hover{background:var(--grey-bg);border-color:var(--navy);}
  .social-btn svg{width:18px;height:18px;}

  .form-note{margin-top:22px;font-size:12px;color:var(--text-muted);text-align:center;}
  .form-note a{color:var(--navy);font-weight:600;text-decoration:underline;}

  .toast{
    position:fixed;bottom:26px;right:26px;background:var(--navy);color:#fff;padding:14px 20px;
    border-radius:4px;font-size:13.5px;font-weight:500;box-shadow:0 14px 30px -10px rgba(0,0,0,.35);
    display:flex;align-items:center;gap:10px;transform:translateY(20px);opacity:0;
    transition:transform .25s ease, opacity .25s ease;pointer-events:none;max-width:320px;z-index:200;
  }
  .toast.show{transform:translateY(0);opacity:1;}
  .toast svg{width:18px;height:18px;color:var(--gold);flex-shrink:0;}

  /* ---------- OTP Modal ---------- */
  .otp-overlay{
    position:fixed;inset:0;background:rgba(15,18,32,.55);display:flex;align-items:center;justify-content:center;
    padding:20px;z-index:150;opacity:0;pointer-events:none;transition:opacity .2s ease;
  }
  .otp-overlay.show{opacity:1;pointer-events:auto;}
  .otp-card{
    background:#fff;border-radius:6px;padding:40px 36px;width:100%;max-width:400px;
    box-shadow:0 30px 60px -15px rgba(0,0,0,.4);transform:translateY(14px);transition:transform .22s ease;
  }
  .otp-overlay.show .otp-card{transform:translateY(0);}
  .otp-card h2{font-size:21px;color:var(--navy);}
  .otp-card .otp-sub{margin-top:8px;font-size:13.5px;color:var(--text-muted);}
  .otp-card .otp-sub b{color:var(--text);font-weight:600;}
  .otp-digits{display:flex;gap:10px;margin-top:26px;}
  .otp-digits input{
    width:100%;aspect-ratio:1;text-align:center;font-size:20px;font-weight:600;
    border:1.5px solid var(--line);border-radius:4px;background:#fcfcfd;color:var(--navy);
  }
  .otp-digits input:focus-visible{outline:none;border-color:var(--navy);background:#fff;}
  .otp-digits input.error{border-color:var(--error);animation:shake .3s ease;}
  @keyframes shake{
    25%{transform:translateX(-4px);} 75%{transform:translateX(4px);}
  }
  .otp-error-msg{font-size:12.5px;color:var(--error);margin-top:12px;min-height:16px;display:flex;align-items:center;gap:6px;}
  .otp-error-msg svg{width:14px;height:14px;flex-shrink:0;}
  .otp-resend{margin-top:18px;font-size:12.5px;color:var(--text-muted);}
  .otp-resend button{color:var(--navy);font-weight:600;text-decoration:underline;}
  .otp-resend button:disabled{color:var(--text-muted);text-decoration:none;cursor:not-allowed;}
  .btn-verify{
    width:100%;margin-top:22px;padding:13px;background:var(--navy);color:#fff;
    font-family:'Oswald',sans-serif;font-size:13px;letter-spacing:1.5px;font-weight:600;
    text-transform:uppercase;border-radius:3px;transition:background .18s ease;
  }
  .btn-verify:hover{background:var(--navy-soft);}
  .btn-verify:disabled{opacity:.55;cursor:not-allowed;}

  @media (max-width:880px){
    .auth-wrap{grid-template-columns:1fr;}
    .brand-panel{display:none;}
    .form-panel{padding:40px 22px;min-height:100vh;}
  }
  @media (max-width:480px){
    .field-row{grid-template-columns:1fr;}
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
      <h2>Join the denim family.</h2>
      <p>Create your account to unlock member pricing, faster checkout, and a 20% discount on your very first order.</p>
    </div>

    <div class="perk-list">
      <div><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M20 6L9 17l-5-5"/></svg> Member-only pricing &amp; early drops</div>
      <div><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M20 6L9 17l-5-5"/></svg> Track orders &amp; save your fits</div>
      <div><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M20 6L9 17l-5-5"/></svg> 30-day free returns on everything</div>
    </div>
  </aside>

  <!-- ============ FORM PANEL ============ -->
  <main class="form-panel">
    <div class="form-card">
      <a href="index.jsp" class="back-link">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M19 12H5M11 6l-6 6 6 6"/></svg>
        Back to store
      </a>

      <h1>Create Account</h1>
      <p class="sub">Already a member? <a href="login.jsp">Sign in</a></p>

      <form id="signupForm" novalidate>
        <div class="field-row">
          <div class="field">
            <label for="firstName">First Name</label>
            <div class="input-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>
              <input type="text" id="firstName" placeholder="Rahul" required>
            </div>
          </div>
          <div class="field">
            <label for="lastName">Last Name</label>
            <div class="input-wrap">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>
              <input type="text" id="lastName" placeholder="Sharma" required>
            </div>
          </div>
        </div>

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
            <input type="password" id="password" placeholder="Create a password" required>
            <button type="button" class="toggle-pw" id="togglePw" aria-label="Show password">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7z"/><circle cx="12" cy="12" r="3"/></svg>
            </button>
          </div>
          <div class="pw-meter">
            <span id="bar1"></span><span id="bar2"></span><span id="bar3"></span><span id="bar4"></span>
          </div>
          <p class="pw-hint" id="pwHint">Use 8+ characters with a number and a symbol.</p>
        </div>

        <div class="field">
          <label for="confirmPassword">Confirm Password</label>
          <div class="input-wrap">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
            <input type="password" id="confirmPassword" placeholder="Re-enter your password" required>
          </div>
          <p class="error-msg" id="confirmError"></p>
        </div>

        <label class="terms-row">
          <input type="checkbox" id="terms">
          <span>I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a>, and I'd like to receive offers by email.</span>
        </label>

        <button type="submit" class="btn-submit" id="createAccountBtn">
          <span id="createBtnText">Create Account</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" width="15" height="15"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
        </button>
      </form>

      <div class="divider">OR SIGN UP WITH</div>

      <button class="social-btn" id="googleBtn">
        <svg viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.07 5.07 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.27-4.74 3.27-8.1z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.99.67-2.26 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84A11 11 0 0012 23z"/><path fill="#FBBC05" d="M5.84 14.1A6.6 6.6 0 015.5 12c0-.73.12-1.44.34-2.1V7.06H2.18A11 11 0 001 12c0 1.77.42 3.45 1.18 4.94l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15A10.96 10.96 0 0012 1 11 11 0 002.18 7.06l3.66 2.84C6.71 7.3 9.14 5.38 12 5.38z"/></svg>
        Continue with Google
      </button>

      <p class="form-note">We'll never share your details with anyone else.</p>
    </div>
  </main>
</div>

<div class="toast" id="toast">
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M20 6L9 17l-5-5"/></svg>
  <span id="toastText">Account created!</span>
</div>

<script>
  const form = document.getElementById('signupForm');
  const emailInput = document.getElementById('email');
  const pwInput = document.getElementById('password');
  const confirmInput = document.getElementById('confirmPassword');
  const emailError = document.getElementById('emailError');
  const confirmError = document.getElementById('confirmError');
  const termsInput = document.getElementById('terms');
  const toast = document.getElementById('toast');
  const bars = [document.getElementById('bar1'), document.getElementById('bar2'), document.getElementById('bar3'), document.getElementById('bar4')];
  const pwHint = document.getElementById('pwHint');
  const createBtn = document.getElementById('createAccountBtn');
  const createBtnText = document.getElementById('createBtnText');

  function showToast(msg){
    document.getElementById('toastText').textContent = msg;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 3400);
  }

  document.getElementById('togglePw').addEventListener('click', () => {
    pwInput.type = pwInput.type === 'password' ? 'text' : 'password';
  });

  function passwordScore(val){
    let score = 0;
    if (val.length >= 8) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;
    return score;
  }

  const colors = ['#d23b3b', '#e08a3b', '#e0c63b', '#2f9e5b'];
  const labels = ['Weak password', 'Could be stronger', 'Good password', 'Strong password'];

  pwInput.addEventListener('input', () => {
    const score = passwordScore(pwInput.value);
    bars.forEach((bar, i) => {
      bar.style.background = i < score ? colors[Math.max(score - 1, 0)] : '#e7e7ea';
    });
    pwHint.textContent = pwInput.value ? labels[Math.max(score - 1, 0)] : 'Use 8+ characters with a number and a symbol.';
  });

  // ================= SIGNUP SUBMIT =================
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    let valid = true;

    const emailVal = emailInput.value.trim();
    const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailVal);
    if (!emailOk){
      emailInput.classList.add('error');
      emailError.textContent = 'Enter a valid email address.';
      valid = false;
    } else {
      emailInput.classList.remove('error');
      emailError.textContent = '';
    }

    if (pwInput.value.length < 8){
      pwInput.classList.add('error');
      valid = false;
    } else {
      pwInput.classList.remove('error');
    }

    if (confirmInput.value !== pwInput.value || !confirmInput.value){
      confirmInput.classList.add('error');
      confirmError.textContent = 'Passwords do not match.';
      valid = false;
    } else {
      confirmInput.classList.remove('error');
      confirmError.textContent = '';
    }

    if (!termsInput.checked){
      showToast('Please accept the Terms of Service to continue.');
      return;
    }

    if (!valid) return;

    const first_name = document.getElementById('firstName').value;
    const last_name = document.getElementById('lastName').value;
    const email = emailVal;
    const password = pwInput.value;

    createBtn.disabled = true;
    createBtnText.textContent = 'Creating account...';

    try {
      const response = await fetch("http://localhost:8081/Bloomster/create-account", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ first_name, last_name, email, password }),
        redirect: "follow"
      });

      if (!response.ok) {
        throw new Error("create-account failed with status " + response.status);
      }

       Account created on the server -> ask backend to send the OTP mail
      const otpResp = await fetch("http://localhost:8081/Bloomster/send-otp", {
       method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email })
      });

      if (!otpResp.ok) {
        throw new Error("send-otp failed with status " + otpResp.status);
      }

      showToast(`OTP sent on your registered email: ${email}`);

       redirect to the separate OTP verification page, passing the email along
      window.location.href = "Verifyotp.jsp?email=" + encodeURIComponent(email);

    } catch (err) {
      console.error(err);
      showToast('Something went wrong while creating your account. Please try again.');
      createBtn.disabled = false;
      createBtnText.textContent = 'Create Account';
    }
  });

  document.getElementById('googleBtn').addEventListener('click', () => {
    showToast('Google sign-up would open here.');
  });
</script>

</body>
</html>
