<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>

<%
    Object userIdObj = session.getAttribute("user_id");

    if (userIdObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Orders | Bloomster</title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #f5f6f7;
            color: #222;
        }


        /* =====================================================
           HEADER
           ===================================================== */

        .header {
            background: #fff;
            border-bottom: 1px solid #e5e5e5;
            padding: 20px 6%;
        }

        .header-inner {
            max-width: 1200px;
            margin: auto;
        }

        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .header p {
            color: #777;
            font-size: 14px;
        }


        /* =====================================================
           CONTAINER
           ===================================================== */

        .container {
            width: 90%;
            max-width: 1100px;
            margin: 30px auto;
        }


        /* =====================================================
           ORDER CARD
           ===================================================== */

        .order-card {
            background: #fff;
            border: 1px solid #e2e2e2;
            border-radius: 10px;
            margin-bottom: 22px;
            overflow: hidden;
        }


        /* =====================================================
           ORDER HEADER
           ===================================================== */

        .order-header {
            background: #fafafa;
            padding: 16px 20px;
            border-bottom: 1px solid #e5e5e5;

            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
        }


        .order-left {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .order-number {
            font-size: 15px;
            font-weight: bold;
        }

        .order-date {
            color: #777;
            font-size: 13px;
        }


        .success-badge {
            background: #e8f7ee;
            color: #16823b;
            border: 1px solid #bde8ca;
            padding: 7px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
            white-space: nowrap;
        }


        .failed-badge {
            background: #fdeaea;
            color: #d93025;
            border: 1px solid #f5bcbc;
            padding: 7px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }


        /* =====================================================
           PRODUCTS
           ===================================================== */

        .products {
            padding: 5px 20px;
        }


        .product-row {
            display: flex;
            gap: 18px;
            padding: 20px 0;
            border-bottom: 1px solid #eee;
        }

        .product-row:last-child {
            border-bottom: none;
        }


        .product-image {
            width: 100px;
            height: 100px;

            border-radius: 8px;

            border: 1px solid #ddd;

            object-fit: contain;

            background: #fff;

            flex-shrink: 0;
        }


        .product-info {
            flex: 1;

            display: flex;
            flex-direction: column;

            gap: 8px;
        }


        .product-name {
            font-size: 17px;
            font-weight: bold;
            color: #222;
        }


        .product-meta {
            color: #666;
            font-size: 14px;
        }


        .product-price {
            font-size: 17px;
            font-weight: bold;
            margin-top: 4px;
        }


        .quantity {
            color: #666;
            font-size: 14px;
        }


        /* =====================================================
           ORDER FOOTER
           ===================================================== */

        .order-footer {
            border-top: 1px solid #e5e5e5;
            padding: 18px 20px;

            display: flex;
            justify-content: space-between;

            gap: 30px;
        }


        .payment-info {
            display: flex;
            flex-direction: column;
            gap: 7px;
        }


        .payment-label {
            color: #777;
            font-size: 12px;
        }


        .payment-value {
            font-size: 13px;
            font-weight: 600;
            word-break: break-all;
        }


        .total-section {
            text-align: right;
            min-width: 180px;
        }


        .total-label {
            color: #777;
            font-size: 13px;
            margin-bottom: 5px;
        }


        .total-price {
            font-size: 25px;
            font-weight: bold;
        }


        /* =====================================================
           EMPTY / LOADING / ERROR
           ===================================================== */

        .empty,
        .loading,
        .error {
            background: #fff;
            border: 1px solid #e2e2e2;
            border-radius: 10px;

            padding: 60px 20px;

            text-align: center;
        }


        .empty h2,
        .loading h2,
        .error h2 {
            margin-bottom: 8px;
        }


        .empty p,
        .loading p {
            color: #777;
        }


        .error {
            color: #d93025;
        }


        /* =====================================================
           RESPONSIVE
           ===================================================== */

        @media (max-width: 650px) {

            .container {
                width: 94%;
                margin-top: 20px;
            }


            .header {
                padding: 18px 4%;
            }


            .header h1 {
                font-size: 23px;
            }


            .order-header {
                align-items: flex-start;
                flex-direction: column;
            }


            .product-row {
                gap: 12px;
            }


            .product-image {
                width: 80px;
                height: 80px;
            }


            .product-name {
                font-size: 15px;
            }


            .product-price {
                font-size: 15px;
            }


            .order-footer {
                flex-direction: column;
            }


            .total-section {
                text-align: left;
            }


            .total-price {
                font-size: 22px;
            }

        }

    </style>

</head>


<body>


<!-- =========================================================
     HEADER
     ========================================================= -->

<div class="header">

    <div class="header-inner">

        <h1>My Orders</h1>

        <p>
            Track and manage your Bloomster orders
        </p>

    </div>

</div>


<!-- =========================================================
     ORDERS
     ========================================================= -->

<div class="container">

    <div id="ordersContainer">

        <div class="loading">

            <h2>Loading orders...</h2>

            <p>
                Please wait
            </p>

        </div>

    </div>

</div>


<script>


/* ============================================================
   ACCESS TOKEN
   ============================================================ */

let accessToken =
    sessionStorage.getItem("accessToken");


/* ============================================================
   REFRESH ACCESS TOKEN
   ============================================================ */

async function refreshAccessToken() {

    try {

        const res =
            await fetch(
                "<%=request.getContextPath()%>/refresh-token",
                {
                    method: "POST",
                    credentials: "include"
                }
            );


        if (!res.ok) {

            sessionStorage.removeItem(
                "accessToken"
            );

            window.location.href =
                "login.jsp";

            return false;
        }


        const data =
            await res.json();


        if (!data.success ||
            !data.accessToken) {

            sessionStorage.removeItem(
                "accessToken"
            );

            window.location.href =
                "login.jsp";

            return false;
        }


        accessToken =
            data.accessToken;


        sessionStorage.setItem(
            "accessToken",
            accessToken
        );


        return true;


    } catch (error) {

        console.error(
            "Refresh error:",
            error
        );

        sessionStorage.removeItem(
            "accessToken"
        );

        window.location.href =
            "login.jsp";

        return false;
    }
}


/* ============================================================
   ESCAPE HTML
   ============================================================ */

function escapeHtml(value) {

    if (value === null ||
        value === undefined) {

        return "";
    }

    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}


/* ============================================================
   FORMAT MONEY
   ============================================================ */

function money(value) {

    const number =
        Number(value || 0);

    return "₹" +
        number.toLocaleString(
            "en-IN",
            {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2
            }
        );
}


/* ============================================================
   GROUP ORDERS
   ============================================================ */

function groupOrders(data) {

    const groups = {};

    data.forEach(order => {

        const orderId =
            order.order_id;

        if (!groups[orderId]) {

            groups[orderId] = {

                order_id:
                    order.order_id,

                payment_id:
                    order.payment_id,

                razorpay_order_id:
                    order.razorpay_order_id,

                amount:
                    Number(order.amount || 0),

                total_amount:
                    Number(order.total_amount || 0),

                created_at:
                    order.created_at,

                updated_at:
                    order.updated_at,

                status:
                    order.status,

                items: []
            };
        }


        groups[orderId].items.push({

            product_id:
                order.product_id,

            product_name:
                order.product_name ||
                "Product",

            img:
                order.img,

            quantity:
                Number(order.quantity || 0),

            price:
                Number(order.price || 0)
        });

    });


    return Object.values(groups);
}


/* ============================================================
   IMAGE URL
   ============================================================ */

function getImageUrl(img) {

    if (!img ||
        img === "null" ||
        img === "undefined") {

        return "";
    }


    /*
     * Agar database mein complete URL hai
     */

    if (
        img.startsWith("http://") ||
        img.startsWith("https://") ||
        img.startsWith("/")
    ) {

        return img;
    }


    /*
     * Agar sirf filename stored hai
     */

    return "<%=request.getContextPath()%>/" + img;
}


/* ============================================================
   LOAD ORDERS
   ============================================================ */

async function loadOrders() {

    const container =
        document.getElementById(
            "ordersContainer"
        );


    try {

        /*
         * ====================================================
         * FIRST REQUEST
         * ====================================================
         */

        let response =
            await fetch(
                "<%=request.getContextPath()%>/ordersverify",
                {
                    method: "GET",

                    headers: {

                        "Authorization":
                            "Bearer " +
                            accessToken
                    },

                    credentials:
                        "include"
                }
            );


        /*
         * ====================================================
         * TOKEN EXPIRED
         * ====================================================
         */

        if (response.status === 401) {

            const refreshed =
                await refreshAccessToken();


            if (!refreshed) {
                return;
            }


            response =
                await fetch(
                    "<%=request.getContextPath()%>/ordersverify",
                    {
                        method: "GET",

                        headers: {

                            "Authorization":
                                "Bearer " +
                                accessToken
                        },

                        credentials:
                            "include"
                    }
                );
        }


        const data =
            await response.json();


        /*
         * ====================================================
         * SERVER ERROR
         * ====================================================
         */

        if (!response.ok) {

            container.innerHTML =

                '<div class="error">' +

                    '<h2>Unable to Load Orders</h2>' +

                    '<p>' +
                        escapeHtml(
                            data.error ||
                            "Something went wrong."
                        ) +
                    '</p>' +

                '</div>';

            return;
        }


        /*
         * ====================================================
         * INVALID RESPONSE
         * ====================================================
         */

        if (!Array.isArray(data)) {

            container.innerHTML =

                '<div class="error">' +

                    '<h2>Unable to Load Orders</h2>' +

                    '<p>' +
                        escapeHtml(
                            data.error ||
                            "Invalid server response."
                        ) +
                    '</p>' +

                '</div>';

            return;
        }


        /*
         * ====================================================
         * EMPTY
         * ====================================================
         */

        if (data.length === 0) {

            container.innerHTML =

                '<div class="empty">' +

                    '<h2>No Orders Yet</h2>' +

                    '<p>' +
                        "You haven't placed any orders yet." +
                    '</p>' +

                '</div>';

            return;
        }


        /*
         * ====================================================
         * GROUP SAME RAZORPAY ORDER
         * ====================================================
         */

        const orders =
            groupOrders(data);


        container.innerHTML = "";


        /*
         * ====================================================
         * RENDER
         * ====================================================
         */

        orders.forEach(order => {


            const statusText =
                order.status
                    ? "Payment Successful"
                    : "Payment Failed";


            const statusClass =
                order.status
                    ? "success-badge"
                    : "failed-badge";


            /*
             * Total calculate from items.
             *
             * price × quantity
             */

            let calculatedTotal = 0;


            order.items.forEach(item => {

                calculatedTotal +=
                    item.price *
                    item.quantity;
            });


            /*
             * Payment total preferred.
             */

            const finalTotal =
                order.total_amount > 0
                    ? order.total_amount
                    : calculatedTotal;


            let productsHtml = "";


            /*
             * =================================================
             * PRODUCTS
             * =================================================
             */

            order.items.forEach(item => {

                const imageUrl =
                    getImageUrl(item.img);


                const imageHtml =
                    imageUrl

                        ?

                    '<img ' +
                        'class="product-image" ' +
                        'src="' +
                            escapeHtml(imageUrl) +
                        '" ' +
                        'alt="' +
                            escapeHtml(
                                item.product_name
                            ) +
                        '" ' +
                        'onerror="this.style.display=\'none\'"' +
                    '>'

                        :

                    '<div class="product-image"></div>';


                productsHtml +=

                    '<div class="product-row">' +

                        imageHtml +

                        '<div class="product-info">' +

                            '<div class="product-name">' +
                                escapeHtml(
                                    item.product_name
                                ) +
                            '</div>' +

                            '<div class="product-meta">' +
                                'Product ID: ' +
                                escapeHtml(
                                    item.product_id
                                ) +
                            '</div>' +

                            '<div class="quantity">' +
                                'Quantity: ' +
                                escapeHtml(
                                    item.quantity
                                ) +
                            '</div>' +

                            '<div class="product-price">' +
                                money(
                                    item.price *
                                    item.quantity
                                ) +
                            '</div>' +

                        '</div>' +

                    '</div>';

            });


            /*
             * =================================================
             * ORDER CARD
             * =================================================
             */

            container.innerHTML +=

                '<div class="order-card">' +


                    /*
                     * ORDER HEADER
                     */

                    '<div class="order-header">' +

                        '<div class="order-left">' +

                            '<div class="order-number">' +
                                'Order #' +
                                escapeHtml(
                                    order.order_id
                                ) +
                            '</div>' +

                            '<div class="order-date">' +
                                'Placed on ' +
                                escapeHtml(
                                    order.created_at ||
                                    "-"
                                ) +
                            '</div>' +

                        '</div>' +


                        '<div class="' +
                            statusClass +
                        '">' +

                            statusText +

                        '</div>' +

                    '</div>' +


                    /*
                     * PRODUCTS
                     */

                    '<div class="products">' +

                        productsHtml +

                    '</div>' +


                    /*
                     * FOOTER
                     */

                    '<div class="order-footer">' +


                        '<div class="payment-info">' +

                            '<div>' +

                                '<div class="payment-label">' +
                                    'Payment ID' +
                                '</div>' +

                                '<div class="payment-value">' +
                                    escapeHtml(
                                        order.payment_id ||
                                        "-"
                                    ) +
                                '</div>' +

                            '</div>' +


                            '<div>' +

                                '<div class="payment-label">' +
                                    'Razorpay Order ID' +
                                '</div>' +

                                '<div class="payment-value">' +
                                    escapeHtml(
                                        order.razorpay_order_id ||
                                        order.order_id ||
                                        "-"
                                    ) +
                                '</div>' +

                            '</div>' +

                        '</div>' +


                        '<div class="total-section">' +

                            '<div class="total-label">' +
                                'Total Amount' +
                            '</div>' +

                            '<div class="total-price">' +
                                money(finalTotal) +
                            '</div>' +

                        '</div>' +


                    '</div>' +


                '</div>';

        });


    } catch (error) {

        console.error(
            "Orders error:",
            error
        );


        container.innerHTML =

            '<div class="error">' +

                '<h2>Unable to Load Orders</h2>' +

                '<p>' +
                    'Server se orders load nahi ho paaye.' +
                '</p>' +

            '</div>';
    }
}


/* ============================================================
   START
   ============================================================ */

loadOrders();

</script>


</body>
</html>