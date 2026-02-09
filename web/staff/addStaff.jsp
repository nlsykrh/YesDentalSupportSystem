<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffName = (String) session.getAttribute("staffName");
    String staffId   = (String) session.getAttribute("staffId");
    String staffRoleSess = (String) session.getAttribute("staffRole");

    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
    if (staffId == null || staffId.trim().isEmpty()) staffId = "-";
    if (staffRoleSess == null || staffRoleSess.trim().isEmpty()) staffRoleSess = "Staff";

    // ✅ same idea like add/edit patient popup
    String popup = request.getParameter("popup"); // popup=added
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Add Staff</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root{
            --green-dark:#2f4a34;
            --green-deep:#264232;
            --gold-soft:#d7d1a6;
        }

        body{
            overflow:hidden;
            margin:0;
            min-height:100vh;
            background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size:cover;
            font-family:"Segoe UI", sans-serif;
        }

        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,0.38);
            backdrop-filter:blur(1.5px);
        }

        /* ===== TOP BAR ===== */
        .top-nav{
            display:flex;
            align-items:center;
            justify-content:space-between;
            padding:22px 60px 8px;
        }
        .brand{
            display:flex;
            align-items:center;
            gap:12px;
        }
        .brand img{ height:48px; }
        .clinic-title{
            font-size:26px;
            font-weight:700;
            color:var(--green-dark);
            font-family:"Times New Roman", serif;
        }
        .top-right{
            display:flex;
            align-items:center;
            gap:12px;
        }
        .user-chip{
            display:inline-flex;
            align-items:center;
            gap:8px;
            background:#f3f3f3;
            padding:6px 12px;
            border-radius:18px;
            font-size:13px;
            color:#2f3a34;
        }
        .logout-btn{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:6px 16px;
            border-radius:999px;
            background:#c96a6a;
            color:#fff;
            font-size:13px;
            font-weight:600;
            text-decoration:none;
            box-shadow:0 6px 14px rgba(0,0,0,0.18);
            transition:all .2s ease;
            border:none;
        }
        .logout-btn:hover{
            background:#b95a5a;
            transform:translateY(-1px);
        }

        /* ===== LAYOUT ===== */
        .layout-wrap{
            width:100%;
            padding:30px 60px 40px;
            height:calc(100vh - 100px);
            overflow:hidden;
        }
        .layout{
            display:grid;
            grid-template-columns:280px 1fr;
            gap:24px;
            width:100%;
            max-width:1400px;
            height:100%;
            align-items:stretch;
        }

        /* ===== SIDEBAR ===== */
        .sidebar{
            background:var(--green-deep);
            color:#fff;
            border-radius:14px;
            padding:20px 16px;
            height:100%;
            overflow:auto;
        }
        .sidebar h6{
            font-size:20px;
            margin-bottom:12px;
            color:#fff;
            padding-bottom:10px;
            border-bottom:1px solid rgba(255,255,255,0.25);
        }
        .side-link{
            display:flex;
            align-items:center;
            gap:10px;
            color:#fff;
            padding:9px 10px;
            border-radius:10px;
            text-decoration:none;
            font-size:14px;
            margin-bottom:6px;
        }
        .side-link i{
            width:18px;
            text-align:center;
            opacity:0.95;
        }
        .side-link:hover,
        .side-link.active{
            background:rgba(255,255,255,0.14);
            color:#ffe69b;
        }

        /* ===== CONTENT ===== */
        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:20px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,0.1);
            height:100%;
            display:flex;
            flex-direction:column;
            overflow:hidden;
        }
        .panel-header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:12px;
            margin-bottom:12px;
        }
        .panel-title{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .panel-sub{
            margin:0;
            color:#666;
            font-size:13px;
        }

        .content-scroll{
            flex:1;
            min-height:0;
            overflow:auto;
            padding-right:4px;
        }

        .form-card{
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:16px;
            padding:16px;
            box-shadow:0 10px 18px rgba(0,0,0,0.06);
        }

        /* ✅ show message ONLY when is-invalid exists */
        .invalid-feedback{ display:none; }
        .is-invalid ~ .invalid-feedback{ display:block; }

        .btn-save{
            background:var(--gold-soft);
            color:#3a382f;
            border:none;
            border-radius:18px;
            padding:10px 14px;
            font-weight:800;
            font-size:13px;
        }
        .btn-back{
            border-radius:18px;
            padding:10px 14px;
            font-weight:700;
            font-size:13px;
        }

        .alert{ border-radius:10px; margin:0 60px 12px; }

        @media(max-width:992px){
            body{ overflow:auto; }
            .layout{ grid-template-columns:1fr; }
            .layout-wrap{ padding:20px; height:auto; overflow:visible; }
            .top-nav{
                padding:18px 24px 8px;
                flex-wrap:wrap;
                gap:10px;
            }
            .card-panel{ height:auto; overflow:visible; }
            .content-scroll{ overflow:visible; }
        }
    </style>
</head>

<body>
<div class="overlay">

    <!-- TOP BAR -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="top-right">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= staffName %></span>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post" style="margin:0;">
                <button type="submit" class="logout-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </button>
            </form>
        </div>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">${error}</div>
    <% } %>

    <!-- LAYOUT -->
    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link active" href="<%=request.getContextPath()%>/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                    <i class="fa-solid fa-hospital-user"></i> Patients
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/TreatmentServlet?action=list">
                    <i class="fa-solid fa-tooth"></i> Treatments
                </a>
            </div>

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-user-plus"></i>
                            Add Staff
                        </h4>
                        <p class="panel-sub">Fill in the staff details to create a new account.</p>
                    </div>
                </div>

                <div class="content-scroll">
                    <div class="form-card">
                        <form id="addStaffForm" action="<%=request.getContextPath()%>/StaffServlet" method="post" novalidate>
                            <input type="hidden" name="action" value="add">

                            <div class="row g-3">

                                <!-- Row 1 -->
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Full Name *</label>
                                    <input id="staffNameInput" type="text" class="form-control" name="staff_name" required>
                                    <div class="invalid-feedback">Please enter staff full name.</div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Role *</label>
                                    <select id="staffRole" class="form-select" name="staff_role" required>
                                        <option value="">Select Role</option>
                                        <option value="Dentist">Dentist</option>
                                        <option value="Assistant">Assistant</option>
                                        <option value="Receptionist">Receptionist</option>
                                        <option value="Other">Other</option>
                                    </select>
                                    <div class="invalid-feedback">Please select a role.</div>
                                </div>

                                <!-- Row 2 OTHER ROLE (FULL WIDTH BUT RIGHT ALIGNED) -->
                                <div class="col-md-12" id="otherRoleWrap" style="display:none;">
                                    <div class="row">
                                        <div class="col-md-6"></div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold">Specify Role *</label>
                                            <input id="otherRoleInput" type="text" class="form-control" name="staff_role_other">
                                            <div class="invalid-feedback">Please specify the staff role.</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Row 3 -->
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Phone Number *</label>
                                    <input id="staffPhone" type="text" class="form-control" name="staff_phonenum" required>
                                    <div class="invalid-feedback">Please enter phone number.</div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email *</label>
                                    <input id="staffEmail" type="email" class="form-control" name="staff_email" required>
                                    <div class="invalid-feedback">Invalid email format. Example: name@gmail.com</div>
                                </div>

                                <!-- Row 4 -->
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Password *</label>
                                    <input id="pwd" type="password" class="form-control" name="staff_password" required>
                                    <div class="invalid-feedback">Please enter a password.</div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Confirm Password *</label>
                                    <input id="cpwd" type="password" class="form-control" name="confirm_password" required>
                                    <div class="invalid-feedback">Password and Confirm Password do not match.</div>
                                </div>

                            </div>

                            <div class="d-flex justify-content-between mt-4">
                                <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">
                                    <i class="fa-solid fa-arrow-left"></i> Back
                                </a>
                                <button type="submit" class="btn-save">
                                    <i class="fa-solid fa-check"></i> Create Staff
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- ✅ SUCCESS POPUP (same style as patient screenshot) -->
<div class="modal fade" id="addedModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:14px;">
            <div class="modal-header">
                <h5 class="modal-title text-success">
                    <i class="fa-solid fa-circle-check"></i> Success
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                Staff successfully added.
            </div>
        </div>
    </div>
</div>

<script>
    const staffRole = document.getElementById("staffRole");
    const otherRoleWrap = document.getElementById("otherRoleWrap");
    const otherRoleInput = document.getElementById("otherRoleInput");

    const addStaffForm = document.getElementById("addStaffForm");
    const staffNameInput = document.getElementById("staffNameInput");
    const staffPhone = document.getElementById("staffPhone");
    const staffEmail = document.getElementById("staffEmail");
    const pwd = document.getElementById("pwd");
    const cpwd = document.getElementById("cpwd");

    function isEmailValid(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }


    function setInvalid(el) { el.classList.add("is-invalid"); }
    function clearInvalid(el) { el.classList.remove("is-invalid"); }

    function toggleOtherRole() {
        if (staffRole.value === "Other") {
            otherRoleWrap.style.display = "";
            otherRoleInput.required = true;
        } else {
            otherRoleWrap.style.display = "none";
            otherRoleInput.required = false;
            otherRoleInput.value = "";
            clearInvalid(otherRoleInput);
        }
    }

    function validateEmailFormatOnly() {
        const v = (staffEmail.value || "").trim();
        if (v === "") { clearInvalid(staffEmail); return true; }
        if (isEmailValid(v)) { clearInvalid(staffEmail); return true; }
        setInvalid(staffEmail);
        return false;
    }

    function validateConfirmMatchOnly() {
        const p = (pwd.value || "");
        const c = (cpwd.value || "");
        if (c.trim() === "") { clearInvalid(cpwd); return true; }
        if (p === c) { clearInvalid(cpwd); return true; }
        setInvalid(cpwd);
        return false;
    }

    function clearIfTyping(el) {
        const v = (el.value || "").trim();
        if (v !== "") clearInvalid(el);
    }

    toggleOtherRole();

    staffRole.addEventListener("change", () => {
        toggleOtherRole();
        if (staffRole.value === "") setInvalid(staffRole);
        else clearInvalid(staffRole);
    });

    staffNameInput.addEventListener("input", () => clearIfTyping(staffNameInput));
    staffPhone.addEventListener("input", () => clearIfTyping(staffPhone));
    pwd.addEventListener("input", () => {
        clearIfTyping(pwd);
        validateConfirmMatchOnly();
    });

    staffEmail.addEventListener("input", validateEmailFormatOnly);
    staffEmail.addEventListener("blur", validateEmailFormatOnly);

    cpwd.addEventListener("input", validateConfirmMatchOnly);
    cpwd.addEventListener("blur", validateConfirmMatchOnly);

    otherRoleInput.addEventListener("input", () => {
        if (staffRole.value === "Other") clearIfTyping(otherRoleInput);
    });

    addStaffForm.addEventListener("submit", function(e){
        let ok = true;

        if ((staffNameInput.value||"").trim() === "") { setInvalid(staffNameInput); ok=false; }
        if ((staffRole.value||"").trim() === "") { setInvalid(staffRole); ok=false; }
        if ((staffPhone.value||"").trim() === "") { setInvalid(staffPhone); ok=false; }

        if ((staffEmail.value||"").trim() === "") { setInvalid(staffEmail); ok=false; }
        else if (!validateEmailFormatOnly()) ok=false;

        if ((pwd.value||"").trim() === "") { setInvalid(pwd); ok=false; }

        if ((cpwd.value||"").trim() === "") { setInvalid(cpwd); ok=false; }
        else if (!validateConfirmMatchOnly()) ok=false;

        if (staffRole.value === "Other" && (otherRoleInput.value||"").trim() === "") {
            setInvalid(otherRoleInput); ok=false;
        }

        if (!ok) {
            e.preventDefault();
            const firstInvalid = document.querySelector(".is-invalid");
            if (firstInvalid) firstInvalid.focus();
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
(() => {
    // ✅ show popup if redirected with ?popup=added
    const popup = "<%= popup != null ? popup : "" %>";
    if (popup === "added") {
        const m = new bootstrap.Modal(document.getElementById("addedModal"));
        m.show();

        // ✅ when modal closes → go list
        document.getElementById("addedModal").addEventListener("hidden.bs.modal", function(){
            window.location.href = "<%=request.getContextPath()%>/StaffServlet?action=list";
        });
    }
})();
</script>

</body>
</html>
