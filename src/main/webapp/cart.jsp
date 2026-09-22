<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Object userIdObj = session.getAttribute("user_id");
    if (userIdObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userId = (int) userIdObj;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Cart</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
        }

        h1 {
            font-size: 22px;
            margin-bottom: 20px;
        }

        .cart-item {
            display: flex;
            align-items: center;
            background: #fff;
            border-radius: 10px;
            padding: 12px;
            margin-bottom: 12px;
            box-shadow: 0 1px 5px rgba(0,0,0,0.08);
        }

        .cart-item img {
            width: 70px;
            height: 70px;
            object-fit: contain;
            border-radius: 8px;
            margin-right: 12px;
        }

        .item-info {
            flex: 1;
        }

        .item-info h3 {
            margin: 0 0 5px;
            font-size: 15px;
        }

        .item-info .price {
            color: #388e3c;
            font-weight: bold;
            font-size: 14px;
        }

        .qty-selector {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .qty-btn {
            width: 30px;
            height: 30px;
            font-size: 16px;
            border: none;
            border-radius: 6px;
            background: #eee;
            cursor: pointer;
        }

        .qty-btn:hover {
            background: #ddd;
        }

        .qty-value {
            min-width: 20px;
            text-align: center;
        }

        .remove-btn {
            background: none;
            border: none;
            color: #d32f2f;
            font-size: 13px;
            cursor: pointer;
            margin-top: 6px;
        }

        .summary {
            background: #fff;
            border-radius: 10px;
            padding: 15px;
            margin-top: 15px;
            display: flex;
            justify-content: space-between;
            font-weight: bold;
            font-size: 16px;
        }

        .checkout-btn {
            width: 100%;
            padding: 14px;
            background: #388e3c;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            margin-top: 15px;
            cursor: pointer;
        }

        .checkout-btn:disabled {
            background: #999;
            cursor: not-allowed;
        }

        #emptyMsg,
        #loadingMsg,
        #errorMsg {
            text-align: center;
            padding: 40px 0;
            color: #666;
        }

        #errorMsg {
            color: #d32f2f;
        }
    </style>
</head>

<body>

<div class="container">

    <h1>My Cart</h1>

    <div id="loadingMsg">
        Loading cart...
    </div>

    <div id="cartItems"></div>

    <div id="summary" class="summary" style="display:none;">
        <span>Total</span>
        <span id="totalPrice">₹0</span>
    </div>

    <button
        class="checkout-btn"
        id="checkoutBtn"
        style="display:none;"
        onclick="goToCheckout()">
        Proceed to Checkout
    </button>

</div>

<script>

    const userId = <%= userId %>;

    let cartData = [];

    /*
     * Access token browser ke sessionStorage me rahega.
     *
     * Refresh token yahan nahi rakha gaya hai.
     * Refresh token HttpOnly cookie me hai,
     * isliye JavaScript usko read nahi kar sakta.
     */
    let accessToken = sessionStorage.getItem("accessToken");


    /*
     * ============================================================
     * REFRESH ACCESS TOKEN
     * ============================================================
     */

    async function refreshAccessToken() {

        try {

            const res = await fetch('/Bloomster/refresh-token', {
                method: 'POST',

                /*
                 * Browser refreshToken HttpOnly cookie
                 * automatically request ke saath bhejega.
                 */
                credentials: 'include'
            });


            if (!res.ok) {

                console.error(
                    "Refresh token failed:",
                    res.status
                );

                sessionStorage.removeItem("accessToken");

                window.location.href = 'login.jsp';

                return false;
            }


            const data = await res.json();


            if (!data.success || !data.accessToken) {

                console.error(
                    "No new access token received"
                );

                sessionStorage.removeItem("accessToken");

                window.location.href = 'login.jsp';

                return false;
            }


            /*
             * New access token save karo
             */
            accessToken = data.accessToken;

            sessionStorage.setItem(
                "accessToken",
                accessToken
            );


            console.log(
                "Access token refreshed successfully"
            );

            return true;

        } catch (err) {

            console.error(
                "Refresh token error:",
                err
            );

            sessionStorage.removeItem("accessToken");

            window.location.href = 'login.jsp';

            return false;
        }
    }



    /*
     * ============================================================
     * LOAD CART
     * ============================================================
     */

    async function loadCart() {

        try {

            let res = await fetch(
                '/Bloomster/get_cart?user_id=' + userId,
                {
                    headers: {
                        'Authorization':
                            'Bearer ' + accessToken
                    },

                    credentials: 'include'
                }
            );


            /*
             * Access token expire ho gaya
             */
            if (res.status === 401) {

                console.log(
                    "Access token expired. Refreshing..."
                );


                const refreshed =
                    await refreshAccessToken();


                if (!refreshed) {
                    return;
                }


                /*
                 * New token ke saath request dobara
                 */
                res = await fetch(
                    '/Bloomster/get_cart?user_id=' + userId,
                    {
                        headers: {
                            'Authorization':
                                'Bearer ' + accessToken
                        },

                        credentials: 'include'
                    }
                );
            }


            const data = await res.json();


            document.getElementById(
                'loadingMsg'
            ).style.display = 'none';


            if (!res.ok) {

                document.getElementById(
                    'cartItems'
                ).innerHTML =
                    '<div id="errorMsg">' +
                    (data.error ||
                        'Failed to load cart') +
                    '</div>';

                return;
            }


            cartData = data;


            if (cartData.length === 0) {

                document.getElementById(
                    'cartItems'
                ).innerHTML =
                    '<div id="emptyMsg">' +
                    'Your cart is empty' +
                    '</div>';

                return;
            }


            renderCart(cartData);


        } catch (err) {

            document.getElementById(
                'loadingMsg'
            ).style.display = 'none';


            document.getElementById(
                'cartItems'
            ).innerHTML =
                '<div id="errorMsg">' +
                'Network error, please try again' +
                '</div>';


            console.error(
                'Error loading cart:',
                err
            );
        }
    }



    /*
     * ============================================================
     * RENDER CART
     * ============================================================
     */

    function renderCart(data) {

        const container =
            document.getElementById(
                'cartItems'
            );


        container.innerHTML =
            data.map(function(item) {

                return (

                    '<div class="cart-item" id="item-' +
                    item.product_id +
                    '">' +

                        '<img src="' +
                        item.img +
                        '" alt="' +
                        item.product_name +
                        '">' +

                        '<div class="item-info">' +

                            '<h3>' +
                            item.product_name +
                            '</h3>' +

                            '<div class="price">' +
                            '₹' +
                            item.price +
                            '</div>' +

                            '<div class="qty-selector">' +

                                '<button ' +
                                'class="qty-btn" ' +
                                'onclick="changeQty(' +
                                item.product_id +
                                ', -1)">' +
                                '-' +
                                '</button>' +

                                '<span ' +
                                'class="qty-value" ' +
                                'id="qty-' +
                                item.product_id +
                                '">' +
                                item.quantity +
                                '</span>' +

                                '<button ' +
                                'class="qty-btn" ' +
                                'onclick="changeQty(' +
                                item.product_id +
                                ', 1)">' +
                                '+' +
                                '</button>' +

                            '</div>' +

                            '<button ' +
                            'class="remove-btn" ' +
                            'onclick="removeItem(' +
                            item.product_id +
                            ')">' +
                            'Remove' +
                            '</button>' +

                        '</div>' +

                    '</div>'

                );

            }).join('');


        updateSummary();
    }



    /*
     * ============================================================
     * UPDATE SUMMARY
     * ============================================================
     */

    function updateSummary() {

        const total =
            cartData.reduce(
                (sum, item) =>
                    sum +
                    (item.price *
                    item.quantity),
                0
            );


        document.getElementById(
            'totalPrice'
        ).textContent =
            '₹' +
            total.toFixed(2);


        document.getElementById(
            'summary'
        ).style.display = 'flex';


        document.getElementById(
            'checkoutBtn'
        ).style.display = 'block';
    }



    /*
     * ============================================================
     * CHANGE QUANTITY
     * ============================================================
     */

    async function changeQty(
        productId,
        delta
    ) {

        const item =
            cartData.find(
                i =>
                    i.product_id ===
                    productId
            );


        if (!item) {
            return;
        }


        const newQty =
            item.quantity + delta;


        if (newQty > 100) {
            return;
        }


        await updateCartOnServer(
            productId,
            newQty
        );
    }



    /*
     * ============================================================
     * REMOVE ITEM
     * ============================================================
     */

    async function removeItem(
        productId
    ) {

        await updateCartOnServer(
            productId,
            0
        );
    }



    /*
     * ============================================================
     * UPDATE CART ON SERVER
     * ============================================================
     */

    async function updateCartOnServer(
        productId,
        newQty
    ) {

        try {

            let res = await fetch(
                '/Bloomster/update_cart',
                {
                    method: 'POST',

                    headers: {
                        'Content-Type':
                            'application/json',

                        'Authorization':
                            'Bearer ' +
                            accessToken
                    },

                    credentials: 'include',

                    body: JSON.stringify({
                        user_id: userId,
                        product_id: productId,
                        quantity: newQty
                    })
                }
            );


            /*
             * Access token expired
             */
            if (res.status === 401) {

                console.log(
                    "Access token expired. Refreshing..."
                );


                const refreshed =
                    await refreshAccessToken();


                if (!refreshed) {
                    return;
                }


                /*
                 * New access token ke saath
                 * update request dobara
                 */
                res = await fetch(
                    '/Bloomster/update_cart',
                    {
                        method: 'POST',

                        headers: {
                            'Content-Type':
                                'application/json',

                            'Authorization':
                                'Bearer ' +
                                accessToken
                        },

                        credentials: 'include',

                        body: JSON.stringify({
                            user_id: userId,
                            product_id: productId,
                            quantity: newQty
                        })
                    }
                );
            }


            const data =
                await res.json();


            if (!data.success) {

                alert(
                    data.error ||
                    'Failed to update cart'
                );

                return;
            }


            /*
             * Local cart update
             */
            if (newQty <= 0) {

                cartData =
                    cartData.filter(
                        i =>
                            i.product_id !==
                            productId
                    );

            } else {

                const item =
                    cartData.find(
                        i =>
                            i.product_id ===
                            productId
                    );


                if (item) {
                    item.quantity =
                        newQty;
                }
            }


            /*
             * Cart empty
             */
            if (cartData.length === 0) {

                document.getElementById(
                    'cartItems'
                ).innerHTML =
                    '<div id="emptyMsg">' +
                    'Your cart is empty' +
                    '</div>';


                document.getElementById(
                    'summary'
                ).style.display = 'none';


                document.getElementById(
                    'checkoutBtn'
                ).style.display = 'none';

            } else {

                renderCart(
                    cartData
                );
            }


        } catch (err) {

            alert(
                'Network error, please try again'
            );

            console.error(
                'Error updating cart:',
                err
            );
        }
    }



    /*
     * ============================================================
     * CHECKOUT / PAYMENT
     * ============================================================
     */

    function goToCheckout() {

    if (cartData.length === 0) {
        alert("Your cart is empty");
        return;
    }

    const btn = document.getElementById("checkoutBtn");

    btn.disabled = true;
    btn.textContent = "Opening checkout...";

    // Backend current logged-in user's cart khud read karega.
    window.location.href =
        "<%=request.getContextPath()%>/payment.jsp";
}


    /*
     * ============================================================
     * START
     * ============================================================
     */

    loadCart();

</script>

</body>
</html>