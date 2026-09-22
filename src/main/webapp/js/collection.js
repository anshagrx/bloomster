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

async function loadProducts() {
  try {
    const r = await fetch(API_URL);
    if (!r.ok) throw new Error("HTTP " + r.status);
    const d = await r.json();
    if (!Array.isArray(d)) throw new Error("API must return array");
    ALL_PRODUCTS = data.map((p) => ({
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

  productGrid.innerHTML = p
    .map((x) => {
      const image = x.image
        ? `<%=request.getContextPath()%>/images/${x.image}`
        : "https://placehold.co/400x500?text=No+Image";

      return `
    <div class="card">

        <img
            src="${image}"
            alt="${esc(x.name)}"
            onerror="this.src='https://placehold.co/400x500?text=No+Image'">

        <div class="card-body">

            <span class="cat">${esc(x.category)}</span>

            <span class="name">${esc(x.name)}</span>

            <span class="price">
                Rs. ${x.price}
            </span>

            <span class="rating">
                ${
                  x.rating > 0
                    ? "★".repeat(Math.round(x.rating)) + ` (${x.rating})`
                    : "No Rating"
                }
            </span>

            <span class="reviews">
                ${x.reviews > 0 ? `${x.reviews} Reviews` : "No Reviews"}
            </span>

        </div>

    </div>
    `;
    })
    .join("");
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
