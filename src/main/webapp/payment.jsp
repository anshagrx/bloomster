<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>

<%
    Object userIdObj = session.getAttribute("user_id");

    if (userIdObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = ((Number) userIdObj).intValue();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <title>Payment - Bloomster</title>

    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>

    <style>

        body {
            font-family: Arial, sans-serif;
            background: #f5f5f5;
            margin: 0;
            padding: 20px;
        }

        .card {
            max-width: 450px;
            margin: 60px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
            text-align: center;
        }

        h2 {
            margin-bottom: 10px;
            font-size: 22px;
        }

        .subtitle {
            color: #666;
            margin-bottom: 20px;
        }

        .info {
            background: #f8f8f8;
            border-radius: 8px;
            padding: 15px;
            margin: 15px 0;
            text-align: left;
        }

        .info p {
            margin: 8px 0;
        }

        .confirm-btn {
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

        .confirm-btn:hover {
            background: #2e7d32;
        }

        .confirm-btn:disabled {
            background: #999;
            cursor: not-allowed;
        }

        #message {
            margin-top: 15px;
            font-size: 14px;
            min-height: 20px;
        }

        .error {
            color: #d32f2f;
        }

        .success {
            color: #388e3c;
        }

        .loading {
            color: #555;
        }

    </style>

</head>

<body>

<div class="card">

    <h2>Confirm Your Order</h2>

    <div class="subtitle">
        Your cart items will be placed in one order.
    </div>

    <div class="info">

        <p>
            <strong>Checkout:</strong>
            All cart items
        </p>

        <p>
            <strong>Payment:</strong>
            Razorpay Secure Payment
        </p>

    </div>

    <button
        class="confirm-btn"
        id="confirmBtn"
        onclick="startPayment()">

        Confirm & Pay

    </button>

    <div id="message"></div>

</div>


<script>

    const userId = <%= userId %>;

    /*
     * =========================================================
     * ACCESS TOKEN
     * =========================================================
     */

    let accessToken =
        sessionStorage.getItem("accessToken");


    /*
     * =========================================================
     * REFRESH ACCESS TOKEN
     * =========================================================
     */

    async function refreshAccessToken() {

        try {

            const res = await fetch(
                "<%=request.getContextPath()%>/refresh-token",
                {
                    method: "POST",
                    credentials: "include"
                }
            );


            if (!res.ok) {

                console.error(
                    "Refresh token failed:",
                    res.status
                );

                sessionStorage.removeItem(
                    "accessToken"
                );

                window.location.href = "login.jsp";

                return false;
            }


            const data = await res.json();


            if (!data.success ||
                !data.accessToken) {

                sessionStorage.removeItem(
                    "accessToken"
                );

                window.location.href = "login.jsp";

                return false;
            }


            accessToken =
                data.accessToken;


            sessionStorage.setItem(
                "accessToken",
                accessToken
            );


            return true;


        } catch (err) {

            console.error(
                "Refresh token error:",
                err
            );

            sessionStorage.removeItem(
                "accessToken"
            );

            window.location.href =
                "login.jsp";

            return false;
        }
    }


    /*
     * =========================================================
     * START PAYMENT
     * =========================================================
     */

    async function startPayment() {

        const btn =
            document.getElementById(
                "confirmBtn"
            );

        const msg =
            document.getElementById(
                "message"
            );


        btn.disabled = true;

        btn.textContent =
            "Processing...";

        msg.className = "loading";

        msg.textContent =
            "Creating secure payment...";


        try {

            /*
             * =================================================
             * CREATE RAZORPAY ORDER
             *
             * IMPORTANT:
             * Empty JSON bhej rahe hain.
             *
             * Backend khud logged-in user ki cart
             * se products + quantity + price nikalega.
             * =================================================
             */

            let orderRes =
                await fetch(
                    "<%=request.getContextPath()%>/create_razorpay_order",
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/json",

                            "Authorization":
                                "Bearer " +
                                accessToken
                        },

                        credentials: "include",

                        body: JSON.stringify({})
                    }
                );


            /*
             * =================================================
             * ACCESS TOKEN EXPIRED
             * =================================================
             */

            if (orderRes.status === 401) {

                const refreshed =
                    await refreshAccessToken();


                if (!refreshed) {
                    return;
                }


                orderRes =
                    await fetch(
                        "<%=request.getContextPath()%>/create_razorpay_order",
                        {
                            method: "POST",

                            headers: {
                                "Content-Type":
                                    "application/json",

                                "Authorization":
                                    "Bearer " +
                                    accessToken
                            },

                            credentials: "include",

                            body: JSON.stringify({})
                        }
                    );
            }


            const orderData =
                await orderRes.json();


            console.log(
                "Create order response:",
                orderData
            );


            if (!orderData.success) {

                msg.className =
                    "error";

                msg.textContent =
                    orderData.error ||
                    "Failed to create payment";


                btn.disabled = false;

                btn.textContent =
                    "Confirm & Pay";

                return;
            }


            /*
             * =================================================
             * RAZORPAY CHECKOUT
             * =================================================
             */

            const options = {

                key:
                    orderData.key_id,

                amount:
                    orderData.amount,

                currency:
                    orderData.currency,

                name:
                    "Bloomster",

                description:
                    "Cart Order Payment",

                order_id:
                    orderData.order_id,


                handler:
                    async function(
                        razorpayResponse
                    ) {

                        console.log(
                            "Razorpay success:",
                            razorpayResponse
                        );

                        await verifyPayment(
                            razorpayResponse
                        );
                    },


                modal: {

                    ondismiss:
                        function() {

                            btn.disabled =
                                false;

                            btn.textContent =
                                "Confirm & Pay";

                            msg.className =
                                "error";

                            msg.textContent =
                                "Payment cancelled";
                        }
                },


                theme: {
                    color: "#388e3c"
                }
            };


            const rzp =
                new Razorpay(options);


            /*
             * =================================================
             * PAYMENT FAILED
             * =================================================
             */

            rzp.on(
                "payment.failed",
                function(response) {

                    console.error(
                        "Payment failed:",
                        response
                    );

                    msg.className =
                        "error";

                    msg.textContent =
                        "Payment failed: " +
                        (
                            response.error &&
                            response.error.description
                                ? response.error.description
                                : "Unknown error"
                        );

                    btn.disabled =
                        false;

                    btn.textContent =
                        "Confirm & Pay";
                }
            );


            rzp.open();


        } catch (err) {

            console.error(
                "START PAYMENT ERROR:",
                err
            );

            msg.className =
                "error";

            msg.textContent =
                "Network error, please try again";

            btn.disabled =
                false;

            btn.textContent =
                "Confirm & Pay";
        }
    }


    /*
     * =========================================================
     * VERIFY PAYMENT
     * =========================================================
     */

    async function verifyPayment(
        razorpayResponse
    ) {

        const msg =
            document.getElementById(
                "message"
            );

        const btn =
            document.getElementById(
                "confirmBtn"
            );


        msg.className =
            "loading";

        msg.textContent =
            "Verifying payment...";


        try {

            /*
             * =================================================
             * FIRST REQUEST
             *
             * ONLY RAZORPAY DATA SEND KARO.
             *
             * user_id/product_id/quantity frontend se
             * nahi bhejna hai.
             *
             * Backend session + cart se khud data nikalega.
             * =================================================
             */

            let res =
                await fetch(
                    "<%=request.getContextPath()%>/verify_payment",
                    {
                        method: "POST",

                        headers: {
                            "Content-Type":
                                "application/json",

                            "Authorization":
                                "Bearer " +
                                accessToken
                        },

                        credentials: "include",

                        body: JSON.stringify({

                            razorpay_order_id:
                                razorpayResponse
                                    .razorpay_order_id,

                            razorpay_payment_id:
                                razorpayResponse
                                    .razorpay_payment_id,

                            razorpay_signature:
                                razorpayResponse
                                    .razorpay_signature
                        })
                    }
                );


            /*
             * =================================================
             * ACCESS TOKEN EXPIRED
             * =================================================
             */

            if (res.status === 401) {

                const refreshed =
                    await refreshAccessToken();


                if (!refreshed) {
                    return;
                }


                res =
                    await fetch(
                        "<%=request.getContextPath()%>/verify_payment",
                        {
                            method: "POST",

                            headers: {
                                "Content-Type":
                                    "application/json",

                                "Authorization":
                                    "Bearer " +
                                    accessToken
                            },

                            credentials: "include",

                            body: JSON.stringify({

                                razorpay_order_id:
                                    razorpayResponse
                                        .razorpay_order_id,

                                razorpay_payment_id:
                                    razorpayResponse
                                        .razorpay_payment_id,

                                razorpay_signature:
                                    razorpayResponse
                                        .razorpay_signature
                            })
                        }
                    );
            }


            const data =
                await res.json();


            console.log(
                "Verify payment response:",
                data
            );


            /*
             * =================================================
             * SUCCESS
             * =================================================
             */

            if (data.success) {

                msg.className =
                    "success";

                msg.textContent =
                    "Payment successful! Order placed.";


                btn.disabled = true;

                btn.textContent =
                    "Order Placed";


                setTimeout(
                    function() {

                        window.location.href =
                            "orders.jsp";

                    },
                    1200
                );


            } else {

                msg.className =
                    "error";

                msg.textContent =
                    data.error ||
                    "Payment verification failed";


                btn.disabled =
                    false;

                btn.textContent =
                    "Confirm & Pay";
            }


        } catch (err) {

            console.error(
                "VERIFY PAYMENT ERROR:",
                err
            );

            msg.className =
                "error";

            msg.textContent =
                "Verification failed. If amount was deducted, please contact support.";

            btn.disabled =
                false;

            btn.textContent =
                "Confirm & Pay";
        }
    }

</script>

</body>
</html>