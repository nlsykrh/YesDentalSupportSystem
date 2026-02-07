<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Logged-in staff (topbar)
    String staffNameSess = (String) session.getAttribute("staffName");
    String staffIdSess   = (String) session.getAttribute("staffId");
    String staffRoleSess = (String) session.getAttribute("staffRole");

    if (staffNameSess == null || staffNameSess.trim().isEmpty()) staffNameSess = "Staff";
    if (staffIdSess == null || staffIdSess.trim().isEmpty()) staffIdSess = "-";
    if (staffRoleSess == null || staffRoleSess.trim().isEmpty()) staffRoleSess = "Staff";

    // Staff to edit
    Staff staff = (Staff) request.getAttribute("staff");
    if (staff == null) {
        response.sendRedirect(request.getContextPath() + "/StaffServlet?action=list");
        return;
    }

    String dbRole = staff.getStaffRole() != null ? staff.getStaffRole().trim() : "";
    boolean isPresetRole = dbRole.equals("Dentist") || dbRole.equals("Assistant") || dbRole.equals("Receptionist") || dbRole.equals("Other");
    String roleSelectValue = isPresetRole ? dbRole : "Other";
    String otherRoleValue  = (!isPresetRole && !dbRole.isEmpty()) ? dbRole : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Edit Staff</title>

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

        /* TOP BAR */
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
            box-shadow:0 6px 14px rgba(0,0,0,0.18);
            transition:all .2s ease;
            border:none;
        }
        .logout-btn:hover{
            background:#b95a5a;
            transform:translateY(-1px);
        }

        /* LAYOUT */
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

        /* SIDEBAR */
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

        /* CONTENT */
        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
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

        /* ✅ only show error when is-invalid exists */
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
                <span><%= staffNameSess %></span>
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
                            <i class="fa-solid fa-pen-to-square"></i>
                            Edit Staff
                        </h4>
                        <p class="panel-sub">Update staff details. Only change password if needed.</p>
                    </div>
                </div>

                <div class="content-scroll">
                    <div class="form-card">

                        <form id="editStaffForm" action="<%=request.getContextPath()%>/StaffServlet" method="post" novalidate>
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="staff_id" value="<%= staff.getStaffId() %>">

                            <div class="row g-3">
                                <!-- Row 1 -->
                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">Staff ID</label>
                                  <input type="text" class="form-control" value="<%= staff.getStaffId() %>" readonly>
                                </div>

                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">Full Name *</label>
                                  <input id="staffNameInput" type="text" class="form-control" name="staff_name"
                                         value="<%= staff.getStaffName() != null ? staff.getStaffName() : "" %>" required>
                                  <div class="invalid-feedback">Please enter staff full name.</div>
                                </div>

                                <!-- Row 2 -->
                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">Phone Number *</label>
                                  <input id="staffPhone" type="text" class="form-control" name="staff_phonenum"
                                         value="<%= staff.getStaffPhonenum() != null ? staff.getStaffPhonenum() : "" %>" required>
                                  <div class="invalid-feedback">Please enter phone number.</div>
                                </div>

                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">Email *</label>
                                  <input id="staffEmail" type="email" class="form-control" name="staff_email"
                                         value="<%= staff.getStaffEmail() != null ? staff.getStaffEmail() : "" %>" required>
                                  <div class="invalid-feedback">Invalid email format. Example: name@gmail.com</div>
                                </div>

                                <!-- Row 3 -->
                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">Role *</label>
                                  <select id="staffRole" class="form-select" name="staff_role" required>
                                    <option value="">Select Role</option>
                                    <option value="Dentist" <%= "Dentist".equals(roleSelectValue) ? "selected" : "" %>>Dentist</option>
                                    <option value="Assistant" <%= "Assistant".equals(roleSelectValue) ? "selected" : "" %>>Assistant</option>
                                    <option value="Receptionist" <%= "Receptionist".equals(roleSelectValue) ? "selected" : "" %>>Receptionist</option>
                                    <option value="Other" <%= "Other".equals(roleSelectValue) ? "selected" : "" %>>Other</option>
                                  </select>
                                  <div class="invalid-feedback">Please select a role.</div>
                                </div>

                                <div class="col-md-6">
                                  <label class="form-label fw-semibold">New Password (Optional)</label>
                                  <input id="pwd" type="password" class="form-control" name="staff_password"
                                         placeholder="Leave empty to keep current password">
                                  <div class="invalid-feedback">Password must be at least 6 characters.</div>
                                </div>

                                <!-- Row 4 (TWO columns in one row) -->
                                <div class="col-md-6" id="otherRoleWrap" style="display:none;">
                                  <label class="form-label fw-semibold">Specify Role *</label>
                                  <input id="otherRoleInput" type="text" class="form-control" name="staff_role_other"
                                         value="<%= otherRoleValue %>">
                                  <div class="invalid-feedback">Please specify the staff role.</div>
                                </div>

                                <div class="col-md-6" id="confirmPwdWrap" style="display:none;">
                                  <label class="form-label fw-semibold">Confirm Password *</label>
                                  <input id="cpwd" type="password" class="form-control" name="confirm_password">
                                  <div class="invalid-feedback">Password and Confirm Password do not match.</div>
                                </div>

                              </div>

                            <div class="d-flex justify-content-between mt-4">
                                <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">
                                    <i class="fa-solid fa-arrow-left"></i> Back
                                </a>
                                <button type="submit" class="btn-save">
                                    <i class="fa-solid fa-check"></i> Update Staff
                                </button>
                            </div>

                        </form>

                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<script>
    const form = document.getElementById("editStaffForm");

    const staffNameInput = document.getElementById("staffNameInput");
    const staffPhone = document.getElementById("staffPhone");
    const staffEmail = document.getElementById("staffEmail");

    const staffRole = document.getElementById("staffRole");
    const otherRoleWrap = document.getElementById("otherRoleWrap");
    const otherRoleInput = document.getElementById("otherRoleInput");

    const pwd = document.getElementById("pwd");
    const confirmWrap = document.getElementById("confirmPwdWrap");
    const cpwd = document.getElementById("cpwd");

    function setInvalid(el){ el.classList.add("is-invalid"); }
    function clearInvalid(el){ el.classList.remove("is-invalid"); }

    function isEmailValid(email){
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }

    // Email: show invalid only if user typed AND invalid
    function validateEmailFormatOnly(){
        const v = (staffEmail.value || "").trim();
        if (v === "") { clearInvalid(staffEmail); return true; }
        if (isEmailValid(v)) { clearInvalid(staffEmail); return true; }
        setInvalid(staffEmail);
        return false;
    }

    // Role other toggle
    function toggleOtherRole(){
        if (staffRole.value === "Other") {
            otherRoleWrap.style.display = "";
            otherRoleInput.required = true;
        } else {
            otherRoleWrap.style.display = "none";
            otherRoleInput.required = false;
            clearInvalid(otherRoleInput);
        }
    }

    // Password confirm toggle (only show confirm if user types password)
    function toggleConfirmPassword(){
        const p = (pwd.value || "").trim();
        if (p !== "") {
            confirmWrap.style.display = "";
            cpwd.required = true;
        } else {
            confirmWrap.style.display = "none";
            cpwd.required = false;
            cpwd.value = "";
            clearInvalid(pwd);
            clearInvalid(cpwd);
        }
    }

    // Confirm check (only if confirm has value)
    function validateConfirmMatchOnly(){
        const p = (pwd.value || "");
        const c = (cpwd.value || "");
        if (c.trim() === "") { clearInvalid(cpwd); return true; }
        if (p === c) { clearInvalid(cpwd); return true; }
        setInvalid(cpwd);
        return false;
    }

    // Password rule: only validate if user typed password
    function validatePasswordRuleOnly(){
        const p = (pwd.value || "").trim();
        if (p === "") { clearInvalid(pwd); return true; } // user not changing password
        if (p.length >= 6) { clearInvalid(pwd); return true; }
        setInvalid(pwd);
        return false;
    }

    // clear red once user starts typing (required fields)
    function clearIfTyping(el){
        const v = (el.value || "").trim();
        if (v !== "") clearInvalid(el);
    }

    // events
    staffEmail.addEventListener("input", validateEmailFormatOnly);
    staffEmail.addEventListener("blur", validateEmailFormatOnly);

    staffNameInput.addEventListener("input", () => clearIfTyping(staffNameInput));
    staffPhone.addEventListener("input", () => clearIfTyping(staffPhone));

    staffRole.addEventListener("change", () => {
        toggleOtherRole();
        if (staffRole.value === "") setInvalid(staffRole);
        else clearInvalid(staffRole);
    });

    otherRoleInput.addEventListener("input", () => {
        if (staffRole.value === "Other" && (otherRoleInput.value||"").trim() !== "") clearInvalid(otherRoleInput);
    });

    pwd.addEventListener("input", () => {
        toggleConfirmPassword();
        validatePasswordRuleOnly();
        validateConfirmMatchOnly();
    });

    cpwd.addEventListener("input", validateConfirmMatchOnly);
    cpwd.addEventListener("blur", validateConfirmMatchOnly);

    // init on load
    toggleOtherRole();
    toggleConfirmPassword();
    validateEmailFormatOnly();

    // submit checks
    form.addEventListener("submit", function(e){
        let ok = true;

        if ((staffNameInput.value||"").trim() === "") { setInvalid(staffNameInput); ok=false; }
        if ((staffPhone.value||"").trim() === "") { setInvalid(staffPhone); ok=false; }

        if ((staffEmail.value||"").trim() === "") { setInvalid(staffEmail); ok=false; }
        else if (!validateEmailFormatOnly()) ok=false;

        if ((staffRole.value||"").trim() === "") { setInvalid(staffRole); ok=false; }

        if (staffRole.value === "Other" && (otherRoleInput.value||"").trim() === "") {
            setInvalid(otherRoleInput); ok=false;
        }

        // password: only enforce if user typed password
        if (!validatePasswordRuleOnly()) ok=false;

        if ((pwd.value||"").trim() !== "") {
            if ((cpwd.value||"").trim() === "") { setInvalid(cpwd); ok=false; }
            else if (!validateConfirmMatchOnly()) ok=false;
        }

        if (!ok) {
            e.preventDefault();
            const firstInvalid = document.querySelector(".is-invalid");
            if (firstInvalid) firstInvalid.focus();
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
