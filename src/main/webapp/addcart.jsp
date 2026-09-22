<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Session se user_id check karo, login nahi hai toh redirect kar do
    Object userIdObj = session.getAttribute("user_id");
    if (userIdObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (int) userIdObj;

    String productId = request.getParameter("product_id");
    if (productId == null || productId.isEmpty()) {
        response.sendRedirect("collection.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add to Cart</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
        }
        .card {
            max-width: 400px;
            margin: 40px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
            text-align: center;
        }
        .card img {
            width: 100%;
            max-height: 250px;
            object-fit: contain;
            border-radius: 8px;
        }
        .card h2 {
            margin: 15px 0 5px;
            font-size: 20px;
        }
        .price {
            color: #388e3c;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .qty-selector {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        .qty-btn {
            width: 40px;
            height: 40px;
            font-size: 20px;
            border: none;
            border-radius: 8px;
            background: #eee;
            cursor: pointer;
        }
        .qty-btn:hover {
            background: #ddd;
        }
        #qtyValue {
            font-size: 18px;
            min-width: 30px;
        }
        .add-btn {
            width: 100%;
            padding: 14px;
            background: #388e3c;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        .add-btn:disabled {
            background: #999;
            cursor: not-allowed;
        }
        #message {
            margin-top: 15px;
            font-size: 14px;
        }
        .success { color: #388e3c; }
        .error { color: #d32f2f; }
        .loading { color: #666; }
    </style>
</head>
<body>

<div class="card" id="productCard">
    <p class="loading">Loading product...</p>
</div>

<script>
    const userId = <%= userId %>;
    const productId = <%= productId %>;
    let quantity = 1;

    // Product details fetch karo
    async function loadProduct() {
        try {
            const res = await fetch('/Bloomster/product?id=' + productId);
            const data = await res.json();

            if (!res.ok || data.error) {
                document.getElementById('productCard').innerHTML =
                    '<p class="error">' + (data.error || 'Product not found') + '</p>';
                return;
            }

            renderProduct(data);

        } catch (err) {
            document.getElementById('productCard').innerHTML =
                '<p class="error">Failed to load product. Check your connection.</p>';
            console.error('Error loading product:', err);
        }
    }

    function renderProduct(product) {
        document.getElementById('productCard').innerHTML = `
            <img src="${product.img}" alt="${product.name}">
            <h2>${product.name}</h2>
            <div class="price">₹${product.price}</div>

            <div class="qty-selector">
                <button class="qty-btn" onclick="changeQty(-1)">-</button>
                <span id="qtyValue">1</span>
                <button class="qty-btn" onclick="changeQty(1)">+</button>
            </div>

            <button class="add-btn" id="addBtn" onclick="addToCart()">Add to Cart</button>
            <div id="message"></div>
        `;
    }

    function changeQty(delta) {
        const newQty = quantity + delta;
        if (newQty < 1) return;
        if (newQty > 100) return;
        quantity = newQty;
        document.getElementById('qtyValue').textContent = quantity;
    }

    async function addToCart() {
        const btn = document.getElementById('addBtn');
        const msg = document.getElementById('message');

        btn.disabled = true;
        btn.textContent = 'Adding...';
        msg.textContent = '';

        try {
            const res = await fetch('/Bloomster/add_cart', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    user_id: userId,
                    product_id: productId,
                    quantity: quantity
                })
            });

            const data = await res.json();

            if (data.success) {
                msg.className = 'success';
                msg.textContent = 'Added to cart successfully!';
                btn.textContent = 'Added ✓';
                setTimeout(() => { window.location.href = 'cart.jsp'; }, 1200);
            } else {
                msg.className = 'error';
                msg.textContent = data.error || 'Failed to add to cart';
                btn.disabled = false;
                btn.textContent = 'Add to Cart';
            }

        } catch (err) {
            msg.className = 'error';
            msg.textContent = 'Network error, please try again';
            btn.disabled = false;
            btn.textContent = 'Add to Cart';
            console.error('Error adding to cart:', err);
        }
    }

    loadProduct();
</script>

</body>
</html>