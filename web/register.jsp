<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - Yes Dental</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
        }

        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.40);
            backdrop-filter: blur(2px);
            display: flex;
            flex-direction: column;
        }

        .navbar-custom {
            padding: 18px 50px;
        }

        .logo {
            height: 55px;
            margin-right: 12px;
        }

        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: #2f4a34;
            font-family: "Times New Roman", serif;
        }

        .page-wrap {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 30px 12px;
        }

        .reg-card {
            width: min(860px, 96%);
            background: linear-gradient(135deg, rgba(72, 110, 86, 0.97), rgba(52, 88, 66, 0.97));
            border-radius: 28px;
            padding: 42px 38px;
            color: white;
            box-shadow:
                0 25px 60px rgba(0, 0, 0, 0.35),
                0 10px 25px rgba(0, 0, 0, 0.25);
        }

        .reg-title {
            font-family: "Times New Roman", serif;
            font-size: 30px;
            font-weight: 800;
            text-align: center;
            margin-bottom: 6px;
        }

        .reg-sub {
            text-align: center;
            margin-bottom: 20px;
            opacity: 0.95;
        }

        .form-control,
        textarea.form-control {
            border-radius: 12px;
            border: none;
            padding: 11px;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.15);
        }

        .form-label {
            font-weight: 600;
        }

        .info-box {
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.20);
            padding: 14px;
            border-radius: 14px;
            font-size: 14px;
            margin-bottom: 20px;
            line-height: 1.5;
        }

        .btn-submit {
            background: white;
            color: #2f4a34;
            font-weight: 800;
            border-radius: 40px;
            padding: 10px 22px;
            border: none;
            width: 220px;
            display: block;
            margin: 0 auto;
            box-shadow:
                0 8px 18px rgba(0, 0, 0, 0.30),
                0 3px 8px rgba(0, 0, 0, 0.20);
            transition: all 0.25s ease;
        }

        .btn-submit:hover {
            background: #eef6f1;
            transform: translateY(-3px);
        }

        .btn-submit:disabled {
            opacity: .65;
            cursor: not-allowed;
            transform: none;
        }

        .btn-verify {
            border-radius: 40px;
            font-weight: 800;
            padding: 10px 18px;
            border: none;
            background: #ffffff;
            color: #2f4a34;
            box-shadow:
                0 8px 18px rgba(0, 0, 0, 0.30),
                0 3px 8px rgba(0, 0, 0, 0.20);
            transition: all 0.25s ease;
            width: 100%;
        }

        .btn-verify:hover {
            background: #eef6f1;
            transform: translateY(-2px);
        }

        .bottom-link {
            text-align: center;
            margin-top: 18px;
            font-weight: 600;
        }

        .bottom-link a {
            color: white;
            text-decoration: underline;
        }

        /* IC message */
        .ic-msg {
            display: none;
            margin-top: 10px;
            font-size: 13px;
            font-weight: 700;
            padding: 10px 12px;
            border-radius: 12px;
        }

        .ic-msg.ok {
            display: block;
            background: rgba(210, 255, 222, 0.16);
            border: 1px solid rgba(210, 255, 222, 0.32);
            color: #d7ffe1;
        }

        .ic-msg.bad {
            display: block;
            background: rgba(255, 214, 214, 0.16);
            border: 1px solid rgba(255, 214, 214, 0.32);
            color: #ffd6d6;
        }

        /* hidden form area */
        .hide {
            display: none !important;
        }
    </style>
</head>

<body>
<div class="overlay">

    <!-- NAVBAR -->
    <nav class="navbar navbar-custom">
        <div class="d-flex align-items-center">
            <img src="<%=request.getContextPath()%>/images/Logo.png" class="logo" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>
    </nav>

    <!-- CONTENT -->
    <div class="page-wrap">
        <div class="reg-card">

            <div class="reg-title">Create Patient Account</div>
            <div class="reg-sub">Verify IC first. If not registered, you can continue.</div>

            <div class="info-box">
                <strong>Important:</strong> Your first login password will be your
                <strong>registered phone number</strong>.
            </div>

            <!-- ✅ SAME FORM, BUT DETAILS HIDDEN UNTIL IC VERIFIED -->
            <form id="registerForm"
                  action="<%=request.getContextPath()%>/RegisterServlet"
                  method="post"
                  novalidate>

                <input type="hidden" name="action" value="add">
                <input type="hidden" name="patient_status" value="A">

                <!-- STEP 1: IC VERIFY -->
                <div class="row g-3 align-items-end">

                    <div class="col-md-8">
                        <label class="form-label">IC Number (12 digits)</label>
                        <input type="text"
                               class="form-control"
                               id="patientIc"
                               name="patient_ic"
                               placeholder="e.g. 041023100460"
                               maxlength="12"
                               inputmode="numeric"
                               autocomplete="off"
                               required>
                        <div id="icBox" class="ic-msg"></div>
                    </div>

                    <div class="col-md-4">
                        <button type="button" class="btn-verify" id="btnVerifyIc">
                            Verify IC
                        </button>
                    </div>

                </div>

                <!-- STEP 2: DETAILS (HIDDEN UNTIL IC OK) -->
                <div id="detailsSection" class="hide" style="margin-top:16px;">
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label">Full Name</label>
                            <input type="text"
                                   class="form-control"
                                   name="patient_name"
                                   placeholder="e.g. Nur Aisyah Binti Ahmad"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Phone Number</label>
                            <input type="tel"
                                   class="form-control"
                                   id="patientPhone"
                                   name="patient_phone"
                                   placeholder="e.g. 0123456789"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email"
                                   class="form-control"
                                   name="patient_email"
                                   placeholder="e.g. example@gmail.com"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Date of Birth</label>
                            <input type="date"
                                   class="form-control"
                                   name="patient_dob"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Guardian Contact Name</label>
                            <input type="text"
                                   class="form-control"
                                   name="patient_guardian"
                                   placeholder="e.g. Father / Mother / Spouse"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Guardian Contact Phone</label>
                            <input type="tel"
                                   class="form-control"
                                   id="guardianPhone"
                                   name="patient_guardian_phone"
                                   placeholder="e.g. 0198765432"
                                   required>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <textarea class="form-control"
                                      name="patient_address"
                                      rows="2"
                                      placeholder="e.g. No 12, Jalan Seri Putra, Kajang"
                                      required></textarea>
                        </div>

                        <div class="col-12 mt-4 pt-2">
                            <button type="submit" class="btn btn-submit" id="btnRegister" disabled>
                                Register
                            </button>
                        </div>

                    </div>
                </div>
            </form>

            <div class="bottom-link">
                Already have account? <a href="login.jsp">Login Here</a>
            </div>

        </div>
    </div>

</div>

<!-- ✅ Info Modal -->
<div class="modal fade" id="infoModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="infoTitle">Notice</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="infoBody">Message</div>
            <div class="modal-footer" id="infoFooter">
                <button class="btn btn-secondary" data-bs-dismiss="modal">OK</button>
            </div>
        </div>
    </div>
</div>

<!-- ✅ Success Modal -->
<div class="modal fade" id="successModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title text-success">Successfully Registered</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                Your account has been created. Click OK to login.
            </div>
            <div class="modal-footer">
                <button class="btn btn-success" id="btnSuccessOk">OK</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
(function () {
    const form = document.getElementById("registerForm");
    const icInput = document.getElementById("patientIc");
    const btnVerify = document.getElementById("btnVerifyIc");
    const details = document.getElementById("detailsSection");
    const btnRegister = document.getElementById("btnRegister");
    const icBox = document.getElementById("icBox");

    const phone = document.getElementById("patientPhone");
    const gphone = document.getElementById("guardianPhone");

    let icOk = false;

    function digitsOnly(el, maxLen){
        if(!el) return;
        el.addEventListener("input", function(){
            this.value = this.value.replace(/\D/g, "");
            if(maxLen) this.value = this.value.slice(0, maxLen);
        });
    }

    // ✅ digits only
    digitsOnly(icInput, 12);
    digitsOnly(phone);
    digitsOnly(gphone);

    function setIcMsg(text, type){
        icBox.className = "ic-msg " + (type || "");
        icBox.textContent = text || "";
        icBox.style.display = text ? "block" : "none";
    }

    function lockAll(){
        icOk = false;
        details.classList.add("hide");
        btnRegister.disabled = true;
    }

    function unlockForm(){
        icOk = true;
        details.classList.remove("hide");
        btnRegister.disabled = false;
    }

    lockAll();

    async function verifyIc(){
        const ic = (icInput.value || "").trim();
        lockAll();
        setIcMsg("", "");

        if(!/^\d{12}$/.test(ic)){
            setIcMsg("IC must be exactly 12 digits.", "bad");
            return;
        }

        setIcMsg("Checking IC...", "");

        try{
            const url = "<%=request.getContextPath()%>/RegisterServlet?action=checkIc&patient_ic=" + encodeURIComponent(ic);
            const res = await fetch(url, { headers: { "Accept": "application/json" } });

            if(!res.ok){
                setIcMsg("Unable to verify IC. Please try again.", "bad");
                return;
            }

            const data = await res.json();

            if(data.exists){
                setIcMsg("IC already registered. Please login.", "bad");
                lockAll();
            }else{
                setIcMsg("IC verified ✅ You can now fill the registration form.", "ok");
                unlockForm();
            }
        }catch(e){
            setIcMsg("Unable to verify IC. Please try again.", "bad");
        }
    }

    btnVerify.addEventListener("click", verifyIc);

    icInput.addEventListener("keydown", (e) => {
        if(e.key === "Enter"){
            e.preventDefault();
            verifyIc();
        }
    });

    icInput.addEventListener("input", () => {
        // if IC changed, hide form again until verify
        setIcMsg("", "");
        lockAll();
    });

    function showInfo(title, body, withLoginBtn){
        document.getElementById("infoTitle").textContent = title || "Notice";
        document.getElementById("infoBody").textContent = body || "Message";

        const footer = document.getElementById("infoFooter");
        footer.innerHTML = '<button class="btn btn-secondary" data-bs-dismiss="modal">OK</button>';

        if(withLoginBtn){
            footer.innerHTML += ' <a class="btn btn-success" href="login.jsp">Go to Login</a>';
        }

        new bootstrap.Modal(document.getElementById("infoModal")).show();
    }

    // ✅ submit: block if hidden / not verified
    form.addEventListener("submit", function(e){
        if(!icOk){
            e.preventDefault();
            showInfo("IC Not Verified", "Please verify your IC first before registering.");
            return;
        }

        if(!form.checkValidity()){
            e.preventDefault();
            const firstInvalid = form.querySelector(":invalid");
            const group = firstInvalid.closest(".col-md-6, .col-12");
            const label = group ? group.querySelector(".form-label") : null;

            showInfo("Missing Information", "Please fill: " + (label ? label.textContent : "required fields"));
        }
    });

    // ✅ handle servlet redirects:
    // ?popup=success  -> success modal -> OK redirect login.jsp
    // ?err=exists     -> show exists
    // ?err=invalid    -> invalid
    // ?err=fail       -> fail
    const params = new URLSearchParams(window.location.search);
    const err = params.get("err");
    const popup = params.get("popup");

    if(err){
        if(err === "exists"){
            showInfo("Account Already Exists", "This IC is already registered. Please login instead.", true);
        }else if(err === "invalid"){
            showInfo("Invalid Data", "Please check your IC / form details and try again.");
        }else if(err === "fail"){
            showInfo("Registration Failed", "Unable to register. Please try again.");
        }
        history.replaceState({}, document.title, "register.jsp");
    }

    if(popup === "success"){
        const m = new bootstrap.Modal(document.getElementById("successModal"));
        m.show();

        document.getElementById("btnSuccessOk").addEventListener("click", () => {
            window.location.href = "login.jsp";
        });

        history.replaceState({}, document.title, "register.jsp");
    }

})();
</script>

</body>
</html>
