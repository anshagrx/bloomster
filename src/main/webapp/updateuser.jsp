<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
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
    <title>Update Profile</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }
        .card {
            max-width: 450px; margin: 60px auto; background: #fff;
            border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); padding: 25px;
        }
        h2 { margin-bottom: 20px; font-size: 20px; }
        label {
            display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px;
            margin-top: 15px; color: #333;
        }
        input, textarea {
            width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 8px;
            font-size: 14px; font-family: inherit;
        }
        textarea { min-height: 70px; resize: vertical; }
        .row {
            display: flex; gap: 10px;
        }
        .row .field { flex: 1; }
        .save-btn {
            width: 100%; padding: 14px; background: #388e3c; color: #fff;
            border: none; border-radius: 8px; font-size: 16px; margin-top: 20px; cursor: pointer;
        }
        .save-btn:disabled { background: #999; cursor: not-allowed; }
        #message { margin-top: 12px; font-size: 14px; }
        .error { color: #d32f2f; }
        .success { color: #388e3c; }
    </style>
</head>
<body>

<div class="card">
    <h2>Delivery Address</h2>

    <label for="addressLine">House No. / Street / Locality</label>
    <textarea id="addressLine" placeholder="e.g. 123, MG Road, Sector 5"></textarea>

    <div class="row">
        <div class="field">
            <label for="city">City</label>
            <input type="text" id="city" placeholder="e.g. Delhi">
        </div>
        <div class="field">
            <label for="state">State</label>
            <input type="text" id="state" placeholder="e.g. Delhi">
        </div>
    </div>

    <label for="pincode">Pincode</label>
    <input type="text" id="pincode" placeholder="e.g. 110001" maxlength="6">

    <button class="save-btn" id="saveBtn" onclick="saveDetails()">Save Changes</button>
    <div id="message"></div>
</div>

<script>
    const userId = <%= userId %>;
    const params = new URLSearchParams(window.location.search);
    const productId = params.get("product_id");
    const quantity = params.get("quantity");

    // Existing address ko fields me todke prefill karo (agar pehle se save hai)
    async function loadCurrentAddress() {
        try {
            const res = await fetch("<%=request.getContextPath()%>/get_address?user_id=" + userId);
            const data = await res.json();

            if (data.address) {
                // Format: "addressLine, city, state - pincode"
                const parts = data.address.split(",");
                if (parts.length >= 1) document.getElementById("addressLine").value = parts[0].trim();
                if (parts.length >= 2) document.getElementById("city").value = parts[1].trim();
                if (parts.length >= 3) {
                    const stateAndPin = parts[2].trim().split("-");
                    document.getElementById("state").value = stateAndPin[0] ? stateAndPin[0].trim() : "";
                    document.getElementById("pincode").value = stateAndPin[1] ? stateAndPin[1].trim() : "";
                }
            }
        } catch (err) {
            console.error("Failed to load current address:", err);
        }
    }

async function saveDetails() {

    const addressLine =
        document.getElementById("addressLine").value.trim();

    const city =
        document.getElementById("city").value.trim();

    const state =
        document.getElementById("state").value.trim();

    const pincode =
        document.getElementById("pincode").value.trim();

    const msg =
        document.getElementById("message");

    const btn =
        document.getElementById("saveBtn");


    // Validation
    if (!addressLine || !city || !state || !pincode) {

        msg.className = "error";
        msg.textContent = "Please fill all fields";

        return;
    }


    if (!/^\d{6}$/.test(pincode)) {

        msg.className = "error";
        msg.textContent =
            "Enter a valid 6-digit pincode";

        return;
    }


    // Full address
    const fullAddress =
        addressLine +
        ", " +
        city +
        ", " +
        state +
        " - " +
        pincode;


    btn.disabled = true;
    btn.textContent = "Saving...";


    try {

        console.log("Saving address...");
        console.log("userId =", userId);
        console.log("address =", fullAddress);


        const res = await fetch(
            "<%=request.getContextPath()%>/update_user",
            {
                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    user_id: userId,
                    address: fullAddress
                })
            }
        );


        console.log("update_user status =", res.status);


        const data = await res.json();

        console.log("update_user response =", data);


        if (data.success) {

            msg.className = "success";
            msg.textContent =
                "Address saved successfully!";


            if (productId && quantity) {

                setTimeout(() => {

                    window.location.href =
                        "<%=request.getContextPath()%>/payment.jsp" +
                        "?product_id=" +
                        encodeURIComponent(productId) +
                        "&quantity=" +
                        encodeURIComponent(quantity);

                }, 800);

            } else {

                btn.disabled = false;
                btn.textContent = "Save Changes";
            }


        } else {

            msg.className = "error";

            msg.textContent =
                data.error || "Failed to save address";

            btn.disabled = false;
            btn.textContent = "Save Changes";
        }


    } catch (err) {

        console.error("UPDATE USER ERROR:", err);

        msg.className = "error";

        msg.textContent =
            "Network error, please try again";

        btn.disabled = false;
        btn.textContent = "Save Changes";
    }
}

    // Page load pe current address load karo
    loadCurrentAddress();
</script>

</body>
</html>