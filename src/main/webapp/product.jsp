<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Object userIdObj = session.getAttribute("user_id");
    int userId = (userIdObj != null) ? (int) userIdObj : -1;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Product Details - Bloomster</title>

<style>
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: 'Segoe UI', Arial, sans-serif;
    background: #f7f7f8;
    color: #222;
}

.topbar {
    background: #111;
    color: white;
    padding: 18px 40px;
}

.topbar h1 {
    font-size: 24px;
}

.back {
    max-width: 1200px;
    margin: 25px auto 0;
    padding: 0 20px;
}

.back a {
    text-decoration: none;
    color: #555;
    font-size: 15px;
}

.product-container {
    max-width: 1200px;
    margin: 20px auto 40px;
    padding: 30px;
    background: white;
    border-radius: 12px;

    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 50px;

    box-shadow: 0 3px 15px rgba(0,0,0,.06);
}

.product-image {
    width: 100%;
    height: 550px;
    background: #f3f3f3;
    border-radius: 10px;

    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}

.product-image img {
    width: 100%;
    height: 100%;
    object-fit: contain;
}

.product-category {
    color: #999;
    font-size: 13px;
    text-transform: uppercase;
    margin-bottom: 10px;
}

.product-name {
    font-size: 36px;
    margin-bottom: 15px;
}

.rating-row {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
}

.rating {
    color: #e69500;
    font-size: 20px;
}

.review-count {
    color: #777;
    font-size: 14px;
}

.price {
    font-size: 30px;
    font-weight: bold;
    margin-bottom: 25px;
}

.description-title {
    font-size: 20px;
    margin-bottom: 10px;
}

.description {
    color: #666;
    line-height: 1.7;
    font-size: 15px;
    margin-bottom: 30px;
}

.quantity-row {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 20px;
}

.quantity-row input {
    width: 65px;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    text-align: center;
}

.add-cart {
    width: 100%;
    padding: 15px;
    border: none;
    border-radius: 7px;
    background: #111;
    color: white;
    font-size: 17px;
    cursor: pointer;
}

.add-cart:hover {
    background: #333;
}

.reviews-section {
    max-width: 1200px;
    margin: 0 auto 50px;
    padding: 30px;
    background: white;
    border-radius: 12px;
}

.reviews-section h2 {
    margin-bottom: 25px;
}

.review-summary {
    padding: 20px;
    background: #f7f7f7;
    border-radius: 8px;
    margin-bottom: 20px;
}

.review {
    border-top: 1px solid #eee;
    padding: 20px 0;
}

.review-name {
    font-weight: 600;
    margin-bottom: 5px;
}

.review-rating {
    color: #e69500;
    margin-bottom: 8px;
}

.review-text {
    color: #666;
    line-height: 1.6;
}

.loading {
    text-align: center;
    padding: 100px;
    color: #777;
}

.error {
    text-align: center;
    padding: 100px;
    color: #d33;
}

@media(max-width: 800px) {

    .topbar {
        padding: 15px 20px;
    }

    .product-container {
        margin: 15px;
        padding: 20px;
        grid-template-columns: 1fr;
        gap: 25px;
    }

    .product-image {
        height: 400px;
    }

    .product-name {
        font-size: 28px;
    }

    .reviews-section {
        margin: 15px;
    }
}
</style>
</head>

<body>

<div class="topbar">
    <h1>BLOOMSTER</h1>
</div>

<div class="back">
    <a href="javascript:history.back()">← Back to Collection</a>
</div>

<div id="productContainer">
    <div class="loading">
        Loading product...
    </div>
</div>

<div id="reviewsSection"></div>


<script>

const params = new URLSearchParams(window.location.search);
const productId = params.get("id");
const userId = <%= userId %>;

function esc(s) {
    return String(s ?? "").replace(
        /[&<>"']/g,
        function(m) {
            return {
                "&": "&amp;",
                "<": "&lt;",
                ">": "&gt;",
                '"': "&quot;",
                "'": "&#39;"
            }[m];
        }
    );
}

async function loadProduct() {

    if (!productId) {
        document.getElementById("productContainer").innerHTML =
            '<div class="error">Product ID not found.</div>';
        return;
    }

    try {

        const response = await fetch(
            "<%=request.getContextPath()%>/product?id=" +
            encodeURIComponent(productId)
        );

        if (!response.ok) {
            throw new Error("HTTP " + response.status);
        }

        const product = await response.json();

        console.log("PRODUCT:", product);

        if (!product || product.error) {
            document.getElementById("productContainer").innerHTML =
                '<div class="error">Product not found.</div>';
            return;
        }

        const name =
            product.name && product.name !== "null"
                ? product.name
                : "Unnamed Product";

        const category =
            product.category && product.category !== "null"
                ? product.category
                : "No Category";

        const price =
            product.price == null
                ? 0
                : Number(product.price);

        const rating =
            product.rating == null
                ? 0
                : Number(product.rating);

        const reviews =
            product.reviews == null
                ? 0
                : Number(product.reviews);

        const description =
            product.description
                ? product.description
                : "No description available.";

        const image =
            product.img
                ? product.img
                : "https://placehold.co/600x700?text=No+Image";

        const stars =
            rating > 0
                ? "★".repeat(Math.round(rating))
                : "No Rating";

        document.getElementById("productContainer").innerHTML =
            '<div class="product-image">' +

                '<img ' +
                    'src="' + esc(image) + '" ' +
                    'alt="' + esc(name) + '" ' +
                    'onerror="this.src=\'https://placehold.co/600x700?text=No+Image\'">' +

            '</div>' +

            '<div class="product-details">' +

                '<div class="product-category">' +
                    esc(category) +
                '</div>' +

                '<h1 class="product-name">' +
                    esc(name) +
                '</h1>' +

                '<div class="rating-row">' +

                    '<span class="rating">' +
                        stars +
                    '</span>' +

                    '<span class="review-count">' +
                        reviews + ' Reviews' +
                    '</span>' +

                '</div>' +

                '<div class="price">' +
                    'Rs. ' + price +
                '</div>' +

                '<h2 class="description-title">' +
                    'Description' +
                '</h2>' +

                '<p class="description">' +
                    esc(description) +
                '</p>' +

                '<div class="quantity-row">' +

                    '<strong>Quantity:</strong>' +

                    '<input ' +
                        'type="number" ' +
                        'id="quantity" ' +
                        'value="1" ' +
                        'min="1">' +

                '</div>' +

                '<button ' +
                    'class="add-cart" ' +
                    'onclick="addToCart(' + product.id + ')">' +
                    'Add to Cart' +
                '</button>' +

                '<button ' +
                    'class="add-cart" ' +
                    'style="margin-top:12px;background:#e69500;" ' +
                    'onclick="buyNow(' + product.id + ')">' +
                    'Buy Now' +
                '</button>' +

            '</div>';

    } catch (error) {

        console.error("PRODUCT API ERROR:", error);

        document.getElementById("productContainer").innerHTML =
            '<div class="error">Unable to load product.</div>';
    }
}


async function addToCart(id) {

    const quantity = parseInt(document.getElementById("quantity").value);

    if (!quantity || quantity <= 0) {
        alert("Please enter a valid quantity");
        return;
    }

    if (userId === -1) {
        window.location.href = "login.jsp";
        return;
    }

    try {
        const response = await fetch(
            "<%=request.getContextPath()%>/add_cart",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    user_id: userId,
                    product_id: id,
                    quantity: quantity
                })
            }
        );

        const data = await response.json();

        if (data.success) {
            window.location.href = "<%=request.getContextPath()%>/cart.jsp";
        } else {
            alert(data.error || "Failed to add to cart");
        }

    } catch (error) {
        console.error("ADD TO CART ERROR:", error);
        alert("Network error, please try again");
    }
}


async function buyNow(id) {
    const quantity = parseInt(document.getElementById("quantity").value);

    if (!quantity || quantity <= 0) {
        alert("Please enter a valid quantity");
        return;
    }

    if (userId === -1) {
        window.location.href = "login.jsp";
        return;
    }

    try {
        const res = await fetch("<%=request.getContextPath()%>/get_address?user_id=" + userId);
        const data = await res.json();

        const query = "?product_id=" + id + "&quantity=" + quantity;

        if (data.address) {
            window.location.href = "<%=request.getContextPath()%>/payment.jsp" + query;
        } else {
            window.location.href = "<%=request.getContextPath()%>/updateuser.jsp" + query;
        }

    } catch (error) {
        console.error("BUY NOW ERROR:", error);
        alert("Something went wrong, please try again");
    }
}

loadProduct();

</script>

</body>
</html>