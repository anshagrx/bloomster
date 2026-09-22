<!DOCTYPE html>
<%@ page isELIgnored="true" %>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Denim Co. | Premium Denim Built for Comfort</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  :root{
    --navy:#16213e;
    --navy-soft:#1f2c52;
    --cream:#fafaf8;
    --paper:#ffffff;
    --grey-bg:#f4f5f7;
    --line:#e7e7ea;
    --gold:#f0a93b;
    --olive:#5c5f4a;
    --text:#1c1c22;
    --text-muted:#6b6f7a;
  }
  *{margin:0;padding:0;box-sizing:border-box;}
  html{scroll-behavior:smooth;}
  body{
    font-family:'Inter',sans-serif;
    color:var(--text);
    background:var(--paper);
    line-height:1.5;
    -webkit-font-smoothing:antialiased;
  }
  h1,h2,h3,h4{font-family:'Oswald',sans-serif;text-transform:uppercase;letter-spacing:.5px;}
  a{text-decoration:none;color:inherit;}
  ul{list-style:none;}
  img{display:block;max-width:100%;}
  button{font-family:inherit;cursor:pointer;border:none;background:none;}
  .container{max-width:1240px;margin:0 auto;padding:0 32px;}
  .visually-hidden{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);}

  /* ---------- Buttons ---------- */
  .btn{
    display:inline-flex;align-items:center;justify-content:center;gap:8px;
    padding:14px 30px;font-family:'Oswald',sans-serif;font-size:13px;
    letter-spacing:1.5px;font-weight:600;text-transform:uppercase;
    border-radius:2px;transition:transform .18s ease, box-shadow .18s ease, background .18s ease, color .18s ease;
    white-space:nowrap;
  }
  .btn:focus-visible{outline:3px solid var(--gold);outline-offset:2px;}
  .btn-primary{background:var(--navy);color:#fff;}
  .btn-primary:hover{background:var(--navy-soft);transform:translateY(-1px);}
  .btn-outline{background:transparent;color:var(--navy);border:1.5px solid var(--navy);}
  .btn-outline:hover{background:var(--navy);color:#fff;}
  .btn-light{background:#fff;color:var(--navy);}
  .btn-light:hover{background:var(--gold);color:#fff;}
  .btn-cart{
    width:100%;background:var(--navy);color:#fff;padding:11px 16px;
    font-size:11.5px;letter-spacing:1.2px;border-radius:2px;
  }
  .btn-cart:hover{background:var(--gold);}

  /* ---------- Header ---------- */
  header{
    position:sticky;top:0;z-index:100;background:rgba(255,255,255,.92);
    backdrop-filter:blur(8px);border-bottom:1px solid var(--line);
  }
  .nav-wrap{display:flex;align-items:center;justify-content:space-between;height:84px;}
  .logo{display:flex;flex-direction:column;line-height:1.1;}
  .logo .name{font-family:'Oswald',sans-serif;font-weight:700;font-size:22px;letter-spacing:1px;color:var(--navy);}
  .logo .est{font-size:9.5px;letter-spacing:2px;color:var(--text-muted);margin-top:2px;}
  .nav-links{display:flex;gap:40px;font-size:13px;letter-spacing:.8px;font-weight:500;}
  .nav-links a{position:relative;padding:6px 0;color:var(--text);}
  .nav-links a::after{
    content:"";position:absolute;left:0;bottom:0;width:0;height:2px;background:var(--navy);
    transition:width .2s ease;
  }
  .nav-links a:hover::after{width:100%;}
  .nav-icons{display:flex;align-items:center;gap:22px;}
  .icon-btn{position:relative;color:var(--navy);display:flex;}
  .icon-btn svg{width:20px;height:20px;}
  .cart-badge{
    position:absolute;top:-8px;right:-9px;background:var(--gold);color:#fff;
    font-size:10px;font-weight:700;width:17px;height:17px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
  }
  .menu-toggle{display:none;color:var(--navy);}

  /* ---------- Hero ---------- */
  .hero{
    position:relative;overflow:hidden;
    background:linear-gradient(180deg,#bcd4e8 0%, #d9e6ef 55%, #eef2f4 100%);
    min-height:560px;
  }
  .hero-skyline{
    position:absolute;bottom:0;left:0;right:0;height:140px;opacity:.55;
  }
  .hero-grid{
    position:relative;display:grid;grid-template-columns:1.1fr .9fr;
    align-items:center;min-height:560px;gap:30px;
  }
  .hero-copy{position:relative;z-index:3;padding:60px 0;}
  .hero-eyebrow{font-size:12px;letter-spacing:2px;color:var(--navy-soft);font-weight:600;margin-bottom:14px;}
  .hero-copy h1{
    font-size:clamp(40px,6vw,64px);line-height:1.02;color:var(--navy);font-weight:700;
  }
  .hero-copy h2{
    font-size:clamp(22px,3vw,30px);line-height:1.2;color:var(--navy);font-weight:500;margin-top:6px;
  }
  .hero-copy p{
    max-width:430px;margin-top:22px;color:var(--text-muted);font-size:15.5px;
  }
  .hero-actions{display:flex;gap:16px;margin-top:34px;}
  .hero-visual{
    position:relative;height:100%;display:flex;align-items:flex-end;justify-content:center;z-index:2;
  }
  .hero-visual .img-frame{
    width:100%;max-width:460px;aspect-ratio:3/4;border-radius:10px 10px 0 0;overflow:hidden;
    box-shadow:0 30px 60px -25px rgba(22,33,62,.45);
  }
  .img-frame img{width:100%;height:100%;object-fit:cover;}

  /* ---------- Section heading ---------- */
  .section-head{text-align:center;margin-bottom:48px;}
  .section-eyebrow{
    font-size:12px;letter-spacing:2px;color:var(--text-muted);font-weight:600;margin-bottom:8px;
  }
  .section-head h2{
    font-size:28px;color:var(--navy);font-weight:700;position:relative;display:inline-block;padding-bottom:14px;
  }
  .section-head h2::after{
    content:"";position:absolute;left:50%;bottom:0;width:46px;height:3px;background:var(--gold);
    transform:translateX(-50%);
  }

  /* ---------- Categories ---------- */
  .categories{padding:84px 0 70px;}
  .cat-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:24px;}
  .cat-card{
    position:relative;border-radius:6px;overflow:hidden;background:var(--grey-bg);
    aspect-ratio:4/5;display:flex;flex-direction:column;justify-content:flex-end;
  }
  .cat-card img{
    position:absolute;inset:0;width:100%;height:100%;object-fit:cover;
    transition:transform .5s ease;
  }
  .cat-card:hover img{transform:scale(1.06);}
  .cat-card::before{
    content:"";position:absolute;inset:0;background:linear-gradient(180deg,transparent 45%, rgba(20,25,40,.65) 100%);
  }
  .cat-info{position:relative;z-index:2;padding:24px;color:#fff;}
  .cat-info h3{font-size:18px;font-weight:600;margin-bottom:8px;}
  .cat-info a{font-size:12.5px;letter-spacing:1px;font-weight:600;display:inline-flex;gap:6px;align-items:center;}
  .cat-info a svg{width:14px;height:14px;transition:transform .2s ease;}
  .cat-card:hover .cat-info a svg{transform:translateX(4px);}

  /* ---------- Best sellers ---------- */
  .bestsellers{padding:20px 0 90px;}
  .product-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:24px;}
  .product-card{
    background:#fff;border:1px solid var(--line);border-radius:6px;overflow:hidden;
    display:flex;flex-direction:column;transition:box-shadow .2s ease, transform .2s ease;
  }
  .product-card:hover{box-shadow:0 18px 34px -22px rgba(22,33,62,.35);transform:translateY(-3px);}
  .product-media{position:relative;aspect-ratio:1/1.15;background:var(--grey-bg);}
  .product-media img{width:100%;height:100%;object-fit:cover;}
  .wish-btn{
    position:absolute;top:12px;right:12px;width:32px;height:32px;border-radius:50%;
    background:#fff;display:flex;align-items:center;justify-content:center;
    box-shadow:0 4px 10px rgba(0,0,0,.12);color:var(--navy);transition:color .2s ease;
  }
  .wish-btn svg{width:16px;height:16px;}
  .wish-btn.active{color:#e0445b;}
  .wish-btn.active svg{fill:#e0445b;}
  .product-info{padding:16px 16px 18px;display:flex;flex-direction:column;gap:8px;}
  .product-info h4{font-family:'Inter',sans-serif;text-transform:none;font-size:14.5px;font-weight:600;letter-spacing:0;}
  .rating{display:flex;align-items:center;gap:6px;font-size:12px;color:var(--text-muted);}
  .stars{color:var(--gold);font-size:13px;letter-spacing:1px;}
  .price{font-family:'Oswald',sans-serif;font-size:17px;font-weight:600;color:var(--navy);}

  /* ---------- Features bar ---------- */
  .features{background:var(--grey-bg);padding:46px 0;border-top:1px solid var(--line);border-bottom:1px solid var(--line);}
  .feature-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:24px;text-align:center;}
  .feature-item{display:flex;flex-direction:column;align-items:center;gap:12px;}
  .feature-item svg{width:30px;height:30px;color:var(--navy);}
  .feature-item h5{font-size:13px;letter-spacing:1px;font-weight:700;color:var(--navy);}
  .feature-item p{font-size:12px;color:var(--text-muted);margin-top:2px;}

  /* ---------- Testimonials ---------- */
  .testimonials{padding:90px 0;}
  .test-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:24px;max-width:880px;margin:0 auto;}
  .test-card{
    background:var(--grey-bg);border-radius:8px;padding:28px 30px;display:flex;flex-direction:column;gap:14px;
  }
  .test-top{display:flex;align-items:center;gap:14px;}
  .avatar{width:46px;height:46px;border-radius:50%;overflow:hidden;flex-shrink:0;background:#ddd;}
  .avatar img{width:100%;height:100%;object-fit:cover;}
  .test-card .stars{font-size:14px;}
  .test-card blockquote{font-size:14.5px;color:var(--text);font-style:italic;line-height:1.6;}
  .test-card cite{font-size:13px;font-weight:600;color:var(--navy);font-style:normal;}
  .dots{display:flex;justify-content:center;gap:8px;margin-top:34px;}
  .dot{width:8px;height:8px;border-radius:50%;background:var(--line);border:none;padding:0;}
  .dot.active{background:var(--navy);}

  /* ---------- Offer banner ---------- */
  .offer{
    position:relative;background:var(--navy);color:#fff;padding:80px 24px;text-align:center;overflow:hidden;
  }
  .offer-texture{
    position:absolute;inset:0;width:100%;height:100%;object-fit:cover;opacity:.34;mix-blend-mode:luminosity;
  }
  .offer-content{position:relative;z-index:2;}
  .offer-eyebrow{font-size:13px;letter-spacing:3px;font-weight:600;color:var(--gold);}
  .offer-content h2{font-size:clamp(34px,5vw,52px);font-weight:700;margin-top:10px;}
  .offer-content h3{font-size:15px;font-weight:500;letter-spacing:1px;margin-top:8px;color:#dfe3ee;}
  .promo-code{
    display:inline-block;margin:28px 0 24px;padding:10px 26px;border:1.5px dashed rgba(255,255,255,.55);
    border-radius:3px;font-family:'Oswald',sans-serif;font-size:13px;letter-spacing:2px;font-weight:600;
  }
  .promo-code b{color:var(--gold);}

  /* ---------- Instagram ---------- */
  .instagram{padding:90px 0 80px;}
  .insta-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;}
  .insta-item{position:relative;aspect-ratio:1/1;overflow:hidden;border-radius:4px;}
  .insta-item img{width:100%;height:100%;object-fit:cover;transition:transform .4s ease;}
  .insta-item:hover img{transform:scale(1.08);}
  .insta-overlay{
    position:absolute;inset:0;background:rgba(22,33,62,.55);display:flex;align-items:center;justify-content:center;
    opacity:0;transition:opacity .25s ease;color:#fff;
  }
  .insta-item:hover .insta-overlay{opacity:1;}
  .insta-overlay svg{width:22px;height:22px;}

  /* ---------- Newsletter ---------- */
  .newsletter{background:var(--grey-bg);}
  .news-grid{display:grid;grid-template-columns:.9fr 1.1fr;align-items:center;min-height:300px;}
  .news-media{height:100%;min-height:300px;overflow:hidden;}
  .news-media img{width:100%;height:100%;object-fit:cover;}
  .news-copy{padding:50px 60px;}
  .news-copy h2{font-size:24px;color:var(--navy);font-weight:700;}
  .news-copy p{margin-top:10px;color:var(--text-muted);font-size:14.5px;max-width:420px;}
  .news-form{display:flex;gap:0;margin-top:24px;max-width:430px;}
  .news-form input{
    flex:1;padding:14px 16px;border:1px solid var(--line);border-right:none;font-size:14px;
    border-radius:2px 0 0 2px;background:#fff;
  }
  .news-form input:focus-visible{outline:2px solid var(--navy);outline-offset:-2px;}
  .news-form button{
    padding:14px 26px;background:var(--navy);color:#fff;font-family:'Oswald',sans-serif;
    font-size:12.5px;letter-spacing:1.5px;font-weight:600;border-radius:0 2px 2px 0;
  }
  .news-form button:hover{background:var(--gold);}
  .news-note{font-size:12px;color:var(--text-muted);margin-top:10px;min-height:16px;}

  /* ---------- Footer ---------- */
  footer{background:var(--navy);color:#cdd2e0;padding:70px 0 0;}
  .footer-grid{display:grid;grid-template-columns:1.4fr 1fr 1fr 1fr 1fr;gap:30px;padding-bottom:50px;}
  .footer-brand .name{font-family:'Oswald',sans-serif;color:#fff;font-size:20px;font-weight:700;letter-spacing:1px;}
  .footer-brand p{font-size:13.5px;margin-top:14px;color:#9aa0b8;max-width:240px;line-height:1.6;}
  .social-row{display:flex;gap:14px;margin-top:20px;}
  .social-row a{
    width:34px;height:34px;border-radius:50%;border:1px solid rgba(255,255,255,.25);
    display:flex;align-items:center;justify-content:center;transition:background .2s ease, border-color .2s ease;
  }
  .social-row a:hover{background:var(--gold);border-color:var(--gold);}
  .social-row svg{width:15px;height:15px;}
  footer h4{color:#fff;font-size:13px;letter-spacing:1px;margin-bottom:18px;}
  footer ul li{margin-bottom:11px;}
  footer ul li a{font-size:13.5px;color:#9aa0b8;transition:color .2s ease;}
  footer ul li a:hover{color:#fff;}
  .contact-item{display:flex;gap:10px;align-items:flex-start;font-size:13.5px;color:#9aa0b8;margin-bottom:14px;}
  .contact-item svg{width:15px;height:15px;flex-shrink:0;margin-top:1px;color:var(--gold);}
  .footer-bottom{
    border-top:1px solid rgba(255,255,255,.12);padding:22px 0;
    display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:14px;
  }
  .footer-bottom p{font-size:12.5px;color:#8b91a8;}
  .pay-icons{display:flex;gap:10px;}
  .pay-icons span{
    font-size:10.5px;font-weight:700;letter-spacing:.5px;color:var(--navy);background:#fff;
    padding:5px 10px;border-radius:3px;
  }

  /* ---------- Responsive ---------- */
  @media (max-width:980px){
    .nav-links{display:none;}
    .menu-toggle{display:flex;}
    .hero-grid{grid-template-columns:1fr;}
    .hero-visual{order:-1;height:280px;}
    .hero-visual .img-frame{max-width:320px;}
    .cat-grid{grid-template-columns:1fr 1fr;}
    .product-grid{grid-template-columns:1fr 1fr;}
    .feature-grid{grid-template-columns:1fr 1fr;gap:30px;}
    .test-grid{grid-template-columns:1fr;}
    .insta-grid{grid-template-columns:repeat(3,1fr);}
    .news-grid{grid-template-columns:1fr;}
    .news-media{min-height:220px;}
    .footer-grid{grid-template-columns:1fr 1fr;}
  }
  @media (max-width:560px){
    .container{padding:0 20px;}
    .cat-grid{grid-template-columns:1fr;}
    .product-grid{grid-template-columns:1fr 1fr;}
    .hero-actions{flex-direction:column;}
    .news-form{flex-direction:column;}
    .news-form input{border-right:1px solid var(--line);border-radius:2px;}
    .news-form button{border-radius:2px;margin-top:10px;}
    .footer-grid{grid-template-columns:1fr;}
    .footer-bottom{flex-direction:column;text-align:center;}
  }
</style>
</head>
<body>

<!-- ================= HEADER ================= -->
<header>
  <div class="container nav-wrap">
    <a href="#" class="logo">
      <span class="name">DENIM CO.</span>
      <span class="est">EST. 2020</span>
    </a>

    <nav>
      <ul class="nav-links">
        <li><a href="#">Home</a></li>
       <li>
    <a href="<%= request.getContextPath() %>/collection.jsp">
        Collection
    </a>
</li>
        <li><a href="#">About Us</a></li>
        <li><a href="#">Lookbook</a></li>
        <li><a href="#footer">Contact</a></li>
      </ul>
    </nav>

    <div class="nav-icons">
      <button class="icon-btn" aria-label="Search">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
      </button>
      <a href="login.jsp" class="icon-btn" aria-label="Account">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>
      </a>
      <button class="icon-btn" aria-label="Cart" id="cartBtn">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h2l2.4 12.4a2 2 0 002 1.6h8.4a2 2 0 002-1.7L20 9H6"/><circle cx="9" cy="21" r="1"/><circle cx="18" cy="21" r="1"/></svg>
        <span class="cart-badge" id="cartCount">0</span>
      </button>
      <button class="menu-toggle icon-btn" aria-label="Menu" id="menuToggle">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 6h18M3 12h18M3 18h18"/></svg>
      </button>
    </div>
  </div>
</header>

<!-- ================= HERO ================= -->
<section class="hero">
  <svg class="hero-skyline" viewBox="0 0 1200 200" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="40" y="90" width="50" height="110" fill="#16213e"/>
    <rect x="110" y="60" width="36" height="140" fill="#16213e"/>
    <rect x="160" y="110" width="60" height="90" fill="#16213e"/>
    <rect x="900" y="40" width="40" height="160" fill="#16213e"/>
    <rect x="960" y="80" width="55" height="120" fill="#16213e"/>
    <rect x="1030" y="100" width="34" height="100" fill="#16213e"/>
    <rect x="1090" y="55" width="46" height="145" fill="#16213e"/>
  </svg>

  <div class="container hero-grid">
    <div class="hero-copy">
      <h1>Premium Denim</h1>
      <h2>Built for comfort.<br>Made to last.</h2>
      <p>Discover our latest collection of premium jeans crafted for style, comfort and durability.</p>
      <div class="hero-actions">
        <a href="#collection" class="btn btn-primary">Shop Now</a>
        <a href="#collection" class="btn btn-outline">Explore Collection</a>
      </div>
    </div>

    <div class="hero-visual">
      <div class="img-frame">
        <img src="https://placehold.co/600x800/9fb8cf/16213e?text=Hero+Model+Photo" alt="Man wearing a denim jacket and sunglasses, sitting on a rooftop ledge with a city skyline behind him">
      </div>
    </div>
  </div>
</section>

<!-- ================= CATEGORIES ================= -->
<section class="categories" id="collection">
  <div class="container">
    <div class="section-head">
      <p class="section-eyebrow">Shop by Category</p>
      <h2>Find Your Perfect Fit</h2>
    </div>

    <div class="cat-grid">
      <a class="cat-card" href="#">
        <img src="https://placehold.co/640x800/d8d8d8/16213e?text=Skinny+Fit" alt="Model wearing skinny fit jeans">
        <div class="cat-info">
          <h3>Skinny Fit</h3>
          <a href="#">Shop Now <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M13 6l6 6-6 6"/></svg></a>
        </div>
      </a>
      <a class="cat-card" href="#">
        <img src="https://placehold.co/640x800/d8d8d8/16213e?text=Regular+Fit" alt="Model wearing regular fit jeans">
        <div class="cat-info">
          <h3>Regular Fit</h3>
          <a href="#">Shop Now <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M13 6l6 6-6 6"/></svg></a>
        </div>
      </a>
      <a class="cat-card" href="#">
        <img src="https://placehold.co/640x800/d3d6c9/5c5f4a?text=Cargo+Jeans" alt="Model wearing olive cargo jeans">
        <div class="cat-info">
          <h3>Cargo Jeans</h3>
          <a href="#">Shop Now <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M13 6l6 6-6 6"/></svg></a>
        </div>
      </a>
    </div>
  </div>
</section>

<!-- ================= BEST SELLERS ================= -->
<section class="bestsellers">
  <div class="container">
    <div class="section-head">
      <h2>Best Sellers</h2>
    </div>

    <div class="product-grid" id="productGrid">
      <!-- product cards injected by JS from PRODUCTS array -->
    </div>
  </div>
</section>

<!-- ================= FEATURES ================= -->
<section class="features">
  <div class="container feature-grid">
    <div class="feature-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 16V6a1 1 0 011-1h9v11"/><path d="M13 9h4l4 4v3a1 1 0 01-1 1h-2"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="18" r="2"/></svg>
      <h5>Free Shipping</h5>
      <p>On all orders above ₹999</p>
    </div>
    <div class="feature-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 12a9 9 0 1015-6.7"/><path d="M21 4v5h-5"/></svg>
      <h5>Easy Returns</h5>
      <p>30 days return policy</p>
    </div>
    <div class="feature-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
      <h5>Secure Payment</h5>
      <p>100% secure transactions</p>
    </div>
    <div class="feature-item">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><circle cx="12" cy="9" r="5"/><path d="M9 13.5L7 21l5-2.5L17 21l-2-7.5"/></svg>
      <h5>Premium Quality</h5>
      <p>Finest denim materials</p>
    </div>
  </div>
</section>

<!-- ================= TESTIMONIALS ================= -->
<section class="testimonials">
  <div class="container">
    <div class="section-head">
      <h2>What Our Customers Say</h2>
    </div>

    <div class="test-grid" id="testGrid">
      <div class="test-card">
        <div class="test-top">
          <div class="avatar"><img src="https://placehold.co/100x100/cccccc/333333?text=RS" alt="Rahul Sharma"></div>
          <div class="stars">★★★★★</div>
        </div>
        <blockquote>“The best jeans I've ever worn. Perfect fit and amazing quality!”</blockquote>
        <cite>— Rahul Sharma</cite>
      </div>
      <div class="test-card">
        <div class="test-top">
          <div class="avatar"><img src="https://placehold.co/100x100/cccccc/333333?text=AV" alt="Ankit Verma"></div>
          <div class="stars">★★★★★</div>
        </div>
        <blockquote>“Stylish, comfortable and worth every penny. Highly recommended!”</blockquote>
        <cite>— Ankit Verma</cite>
      </div>
    </div>

    <div class="dots" id="dots">
      <button class="dot active" aria-label="Slide 1"></button>
      <button class="dot" aria-label="Slide 2"></button>
      <button class="dot" aria-label="Slide 3"></button>
    </div>
  </div>
</section>

<!-- ================= OFFER BANNER ================= -->
<section class="offer">
  <img class="offer-texture" src="https://placehold.co/1400x500/0c1326/16213e?text=Denim+Texture" alt="">
  <div class="offer-content">
    <p class="offer-eyebrow">Special Offer</p>
    <h2>Flat 20% Off</h2>
    <h3>On your first order</h3>
    <div class="promo-code">USE CODE: <b>DENIM20</b></div>
    <div>
      <a href="#collection" class="btn btn-light">Shop Now</a>
    </div>
  </div>
</section>

<!-- ================= INSTAGRAM ================= -->
<section class="instagram">
  <div class="container">
    <div class="section-head">
      <h2>Follow Us on Instagram</h2>
    </div>

    <div class="insta-grid">
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=01" alt="Instagram post 1"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=02" alt="Instagram post 2"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=03" alt="Instagram post 3"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=04" alt="Instagram post 4"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=05" alt="Instagram post 5"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
      <a class="insta-item" href="#"><img src="https://placehold.co/400x400/c7c7c7/16213e?text=06" alt="Instagram post 6"><span class="insta-overlay"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></span></a>
    </div>
  </div>
</section>

<!-- ================= NEWSLETTER ================= -->
<section class="newsletter">
  <div class="news-grid">
    <div class="news-media">
      <img src="https://placehold.co/700x600/8fa3c0/16213e?text=Folded+Denim" alt="Stack of folded denim fabric">
    </div>
    <div class="news-copy">
      <h2>Join the Denim Family</h2>
      <p>Subscribe to get special offers, free giveaways, and once-in-a-lifetime deals.</p>
      <form class="news-form" id="newsForm">
        <label for="newsEmail" class="visually-hidden">Email address</label>
        <input type="email" id="newsEmail" placeholder="Enter your email address" required>
        <button type="submit">Subscribe</button>
      </form>
      <p class="news-note" id="newsNote"></p>
    </div>
  </div>
</section>

<!-- ================= FOOTER ================= -->
<footer id="footer">
  <div class="container">
    <div class="footer-grid">
      <div class="footer-brand">
        <p class="name">DENIM CO.</p>
        <p>Premium denim clothing crafted for comfort, style and durability.</p>
        <div class="social-row">
          <a href="#" aria-label="Facebook"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M13 22v-9h3l1-4h-4V7c0-1 .3-2 2-2h2V1.2C16.5 1 15.4 1 14 1c-3 0-5 1.8-5 5v3H6v4h3v9h4z"/></svg></a>
          <a href="#" aria-label="Instagram"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1"/></svg></a>
          <a href="#" aria-label="Twitter"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M22 5.9c-.7.3-1.5.6-2.3.7.8-.5 1.4-1.3 1.7-2.3-.8.5-1.7.8-2.6 1A4 4 0 0012 8.6c0 .3 0 .6.1.9C8.7 9.3 5.8 7.6 3.8 5c-.4.7-.6 1.4-.6 2.2 0 1.6.8 3 2 3.8-.7 0-1.4-.2-2-.5 0 2.2 1.6 4 3.6 4.4-.4.1-.8.2-1.2.2-.3 0-.6 0-.9-.1.6 1.8 2.2 3.1 4.2 3.1A8 8 0 012 19.5 11.2 11.2 0 008 21c7.2 0 11.1-6 11.1-11.2v-.5c.8-.6 1.5-1.3 1.9-2.4z"/></svg></a>
          <a href="#" aria-label="YouTube"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M22 8.4s-.2-1.5-.8-2.2c-.8-.8-1.7-.8-2.1-.9C16 5 12 5 12 5h0s-4 0-7.1.3c-.4 0-1.3.1-2.1.9C2.2 6.9 2 8.4 2 8.4S1.8 10.2 1.8 12v1.5c0 1.8.2 3.6.2 3.6s.2 1.5.8 2.2c.8.9 1.9.8 2.4.9C6.8 20.3 12 20.3 12 20.3s4 0 7.1-.3c.4 0 1.3-.1 2.1-.9.6-.7.8-2.2.8-2.2s.2-1.8.2-3.6V12c0-1.8-.2-3.6-.2-3.6zM9.8 15.5V9l5.6 3.3-5.6 3.2z"/></svg></a>
        </div>
      </div>

      <div>
        <h4>Shop</h4>
        <ul>
          <li><a href="#">Men</a></li>
          <li><a href="#">Women</a></li>
          <li><a href="#">New Arrivals</a></li>
          <li><a href="#">Best Sellers</a></li>
          <li><a href="#">Sale</a></li>
        </ul>
      </div>

      <div>
        <h4>Customer Care</h4>
        <ul>
          <li><a href="#">Shipping &amp; Delivery</a></li>
          <li><a href="#">Returns &amp; Exchanges</a></li>
          <li><a href="#">Size Guide</a></li>
          <li><a href="#">FAQ</a></li>
          <li><a href="#">Track Order</a></li>
        </ul>
      </div>

      <div>
        <h4>Company</h4>
        <ul>
          <li><a href="#">About Us</a></li>
          <li><a href="#">Lookbook</a></li>
          <li><a href="#">Sustainability</a></li>
          <li><a href="#">Careers</a></li>
          <li><a href="#">Contact Us</a></li>
        </ul>
      </div>

      <div>
        <h4>Contact</h4>
        <div class="contact-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 4h16v16H4z" opacity="0"/><path d="M3 6l9 7 9-7"/><rect x="3" y="5" width="18" height="14" rx="2"/></svg>
          <span>hello@denimco.com</span>
        </div>
        <div class="contact-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 015 6a2 2 0 012-2z"/></svg>
          <span>+91 98765 43210</span>
        </div>
        <div class="contact-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 21s7-6.5 7-11.5A7 7 0 005 9.5C5 14.5 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.3"/></svg>
          <span>123 Denim Street,<br>New Delhi, India</span>
        </div>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2024 Denim Co. All Rights Reserved.</p>
      <div class="pay-icons">
        <span>VISA</span><span>MC</span><span>PayPal</span><span>UPI</span>
      </div>
    </div>
  </div>
</footer>

</body>
</html>