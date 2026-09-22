<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Collection - Bloomster</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',Arial,sans-serif;background:#f7f7f8;color:#222}
.topbar{display:flex;justify-content:space-between;align-items:center;padding:18px 40px;background:#111;color:#fff}
.layout{display:flex;max-width:1300px;margin:auto;padding:24px 20px;gap:28px}
.filters{width:240px;flex-shrink:0;background:#fff;border:1px solid #e5e5e5;border-radius:10px;padding:20px;height:fit-content;position:sticky;top:20px}
.filter-group{margin-bottom:22px}
.filter-group h4{font-size:13px;text-transform:uppercase;color:#777;margin-bottom:10px}
.filter-group label{display:flex;gap:8px;margin-bottom:8px;cursor:pointer}
.price-inputs{display:flex;gap:8px}
.price-inputs input{width:70px;padding:6px}
#clearFilters{width:100%;padding:8px;cursor:pointer}
.content{flex:1}
.toolbar{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;flex-wrap:wrap}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:20px}
.card{background:#fff;border:1px solid #e5e5e5;border-radius:10px;overflow:hidden}
.card:hover{box-shadow:0 4px 14px rgba(0,0,0,.08)}
.card img{width:100%;height:260px;object-fit:cover;background:#eee}
.card-body{padding:12px 14px 16px}
.card {cursor: pointer;}
.cat{font-size:11px;color:#999;text-transform:uppercase}
.name{display:block;font-weight:600;margin-top:4px}
.price{display:block;font-weight:700;margin-top:4px}
.rating{display:block;color:#e69500;margin-top:4px}
.reviews{display:block;font-size:12px;color:#888}
.empty-state{text-align:center;padding:60px;color:#888;grid-column:1/-1}
@media(max-width:800px){.layout{flex-direction:column}.filters{width:100%;position:static}}
</style>
</head>
<body>

<div class="topbar"><h1>BLOOMSTER</h1></div>

<div class="layout">

<aside class="filters">
<h3>Filters</h3>

<div class="filter-group">
<h4>Category</h4>
<div id="categoryFilters"></div>
</div>

<div class="filter-group">
<h4>Price</h4>
<div class="price-inputs">
<input id="minPrice" type="number" placeholder="Min">
<span>-</span>
<input id="maxPrice" type="number" placeholder="Max">
</div>
</div>

<div class="filter-group">
<h4>Rating</h4>
<label><input type="checkbox" class="ratingFilter" value="4">4★ & above</label>
<label><input type="checkbox" class="ratingFilter" value="3">3★ & above</label>
</div>

<button id="clearFilters">Clear Filters</button>
</aside>

<main class="content">
<div class="toolbar">
<span id="resultCount">Loading...</span>
<select id="sortSelect">
<option value="default">Default</option>
<option value="price-asc">Price ↑</option>
<option value="price-desc">Price ↓</option>
<option value="rating-desc">Rating ↓</option>
</select>
</div>

<div class="grid" id="productGrid">
<div class="empty-state">Loading products...</div>
</div>
</main>

</div>

<script>

const API_URL = "<%=request.getContextPath()%>/get-products";
let ALL_PRODUCTS = [];

function esc(s) {
  return String(s ?? "").replace(
    /[&<>"']/g,
    (m) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        m
      ],
  );
}
function openProduct(id) {
    window.location.href = "product.jsp?id=" + encodeURIComponent(id);
}

async function loadProducts() {
  try {
    const r = await fetch(API_URL);
    if (!r.ok) throw new Error("HTTP " + r.status);
    const d = await r.json();
    if (!Array.isArray(d)) throw new Error("API must return array");
    ALL_PRODUCTS = d.map((p) => ({
      id: p.id ?? 0,

      name: p.name && p.name !== "null" ? p.name : "Unnamed Product",

      category:
        p.category && p.category !== "null" ? p.category : "No Category",

      price: p.price == null || p.price === "null" ? 0 : Number(p.price),

      rating: p.rating == null || p.rating === "null" ? 0 : Number(p.rating),

      reviews:
        p.reviews == null || p.reviews === "null" ? 0 : Number(p.reviews),

      description:
        p.description && p.description !== "null"
          ? p.description
          : "No description available.",

      image: p.img && p.img !== "null" ? p.img : null,
    }));
    buildCategories();
    renderProducts();
  } catch (e) {
    console.error(e);
    productGrid.innerHTML =
      '<div class="empty-state">Unable to load products.</div>';
    resultCount.textContent = "0 Products";
  }
}

function buildCategories() {
  const c = [...new Set(ALL_PRODUCTS.map((x) => x.category))];
  categoryFilters.innerHTML = "";
  c.forEach((cat) => {
    const l = document.createElement("label");
    l.innerHTML =
      '<input type="checkbox" class="categoryFilter" value="' +
      esc(cat) +
      '"> ' +
      esc(cat);
    categoryFilters.appendChild(l);
  });
  document
    .querySelectorAll(".categoryFilter")
    .forEach((x) => x.addEventListener("change", renderProducts));
}

function renderProducts() {
  let p = [...ALL_PRODUCTS];

  const cats = [...document.querySelectorAll(".categoryFilter:checked")].map(
    (x) => x.value,
  );
  if (cats.length) p = p.filter((x) => cats.includes(x.category));

  const min = parseFloat(minPrice.value);
  const max = parseFloat(maxPrice.value);
  if (!isNaN(min)) p = p.filter((x) => x.price >= min);
  if (!isNaN(max)) p = p.filter((x) => x.price <= max);

  const rs = [...document.querySelectorAll(".ratingFilter:checked")].map((x) =>
    Number(x.value),
  );
  if (rs.length) {
    const r = Math.min(...rs);
    p = p.filter((x) => x.rating >= r);
  }

  switch (sortSelect.value) {
    case "price-asc":
      p.sort((a, b) => a.price - b.price);
      break;
    case "price-desc":
      p.sort((a, b) => b.price - a.price);
      break;
    case "rating-desc":
      p.sort((a, b) => b.rating - a.rating);
      break;
  }

  resultCount.textContent = p.length + " Product" + (p.length !== 1 ? "s" : "");

  if (!p.length) {
    productGrid.innerHTML = '<div class="empty-state">No products found.</div>';
    return;
  }

  productGrid.innerHTML = p.map(function (x) {

    const image = x.image;

    const rating =
        x.rating > 0
            ? "★".repeat(Math.round(x.rating)) + " (" + x.rating + ")"
            : "No Rating";

    const reviews =
        x.reviews > 0
            ? x.reviews + " Reviews"
            : "No Reviews";

    return (
        '<div class="card" onclick="openProduct(\'' + esc(x.id) + '\')">' +

            '<img src="' + image + '"' +
            ' alt="' + esc(x.name) + '"' +
            ' onerror="this.src=\'https://placehold.co/400x500?text=No+Image\'">' +

            '<div class="card-body">' +

                '<span class="cat">' + esc(x.category) + '</span>' +

                '<span class="name">' + esc(x.name) + '</span>' +

                '<span class="price">Rs. ' + x.price + '</span>' +

                '<span class="rating">' + rating + '</span>' +

                '<span class="reviews">' + reviews + '</span>' +

            '</div>' +

        '</div>'
    );

}).join("");
}

minPrice.addEventListener("input", renderProducts);
maxPrice.addEventListener("input", renderProducts);
sortSelect.addEventListener("change", renderProducts);
document
  .querySelectorAll(".ratingFilter")
  .forEach((x) => x.addEventListener("change", renderProducts));

clearFilters.addEventListener("click", function () {
  document
    .querySelectorAll("input[type=checkbox]")
    .forEach((x) => (x.checked = false));
  minPrice.value = "";
  maxPrice.value = "";
  sortSelect.value = "default";
  renderProducts();
});

loadProducts();

</script>    
</body>
</html>