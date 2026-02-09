<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String staffName = (String) session.getAttribute("staffName");
    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";

    String popup = request.getParameter("popup"); // popup=added
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Add Patient</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root{
            --green-dark:#2f4a34;
            --green-deep:#264232;
            --gold-soft:#d7d1a6;
        }

        body{
            margin:0;
            min-height:100vh;
            background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size:cover;
            font-family:"Segoe UI",sans-serif;
            overflow:hidden;
        }

        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,0.38);
            backdrop-filter:blur(1.5px);
        }

        /* HEADER */
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
            font-family:"Times New Roman",serif;
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

        /* LAYOUT */
        .layout-wrap{
            width:100%;
            padding:30px 60px 40px;
            height:calc(100vh - 100px);
        }

        .layout{
            display:grid;
            grid-template-columns:280px 1fr;
            gap:24px;
            height:100%;
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
            padding-bottom:10px;
            border-bottom:1px solid rgba(255,255,255,0.25);
            color:#fff;
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

        .side-link i{ width:18px; text-align:center; opacity:.95; }

        .side-link:hover,
        .side-link.active{
            background:rgba(255,255,255,0.14);
            color:#ffe69b;
        }

        /* CARD PANEL */
        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
            padding:22px 24px 18px;
            box-shadow:0 14px 30px rgba(0,0,0,0.10);
            height:100%;
            display:flex;
            flex-direction:column;
            overflow:hidden;
        }

        .panel-header{
            display:flex;
            align-items:flex-start;
            justify-content:space-between;
            gap:12px;
            margin-bottom:12px;
            flex-shrink:0;
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
            margin:4px 0 0;
            font-size:13px;
            color:#6b6b6b;
        }

        .back-pill{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:8px 14px;
            border-radius:999px;
            border:1px solid #d9d9d9;
            background:#fff;
            text-decoration:none;
            color:#2f2f2f;
            font-weight:700;
            font-size:13px;
            white-space:nowrap;
        }

        /* FORM WRAPPER (important) */
        form.flex-form{
            display:flex;
            flex-direction:column;
            height:100%;
            min-height:0; /* ✅ super important */
        }

        /* SCROLL AREA */
        .form-wrap{
            flex:1;
            min-height:0;          /* ✅ allow scroll area */
            overflow-y:auto;
            border:1px solid #d9d9d9;
            border-radius:12px;
            background:#fff;
            padding:18px;
        }

        /* FOOTER ALWAYS VISIBLE */
        .footer-actions{
            flex-shrink:0;         /* ✅ never collapse */
            display:flex;
            justify-content:space-between;
            align-items:center;
            padding-top:14px;
            margin-top:12px;
            border-top:1px solid rgba(0,0,0,0.08);
        }

        .btn-gold{
            background:var(--gold-soft);
            border:none;
            border-radius:999px;
            padding:10px 18px;
            font-weight:800;
            color:#3a382f;
        }

        .btn-gold:disabled{ opacity:.55; cursor:not-allowed; }

        .btn-outline-pill{
            border:1px solid #d9d9d9;
            background:#fff;
            border-radius:999px;
            padding:10px 18px;
            font-weight:800;
            color:#2f2f2f;
            text-decoration:none;
        }

        /* Inputs */
        .form-label{
            font-weight:800;
            font-size:12px;
            text-transform:uppercase;
            letter-spacing:.4px;
            color:#2b2b2b;
        }

        .form-control, .form-select{
            border:1px solid #d9d9d9;
            border-radius:12px;
            padding:10px 12px;
            background:#fbfbfb;
        }

        .help-note{
            font-size:12px;
            color:#6b6b6b;
            margin-top:6px;
        }

        /* IC search bar - UPDATED FOR HORIZONTAL ALIGNMENT */
        .ic-bar{
            display:flex;
            gap:10px;
            align-items:flex-end;
            flex-wrap:wrap;
            margin-bottom:14px;
            padding-bottom:14px;
            border-bottom:1px solid rgba(0,0,0,0.08);
        }

        .ic-bar .ic-input-wrap{
            flex:1;
            min-width:260px;
        }

        /* NEW: Button aligned in same row as input */
        .ic-input-group {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .ic-input-group .form-control {
            flex: 1;
        }

        .ic-input-group .btn-check-ic {
            border-radius: 12px;
            padding: 10px 20px;
            font-weight: 800;
            background: #2f4a34;
            color: white;
            border: none;
            white-space: nowrap;
            height: fit-content;
            margin-bottom: 0;
        }

        .ic-input-group .btn-check-ic:hover {
            background: #264232;
        }

        .ic-msg{
            display:none;
            margin-top:8px;
            font-size:13px;
            font-weight:700;
            padding:10px 12px;
            border-radius:12px;
        }

        .ic-msg.ok{
            display:block;
            background:#e7f4ec;
            color:#2a6b48;
            border:1px solid #cfe7d7;
        }

        .ic-msg.bad{
            display:block;
            background:#f6e6e6;
            color:#9b2c2c;
            border:1px solid #f0c9c9;
        }

        @media(max-width:992px){
            body{overflow:auto;}
            .layout{grid-template-columns:1fr;}
            .layout-wrap{height:auto; padding:20px;}
            .card-panel{height:auto;}
            .form-wrap{min-height:auto; overflow:visible;}
            .ic-input-group {
                flex-direction: column;
                align-items: stretch;
            }
            .ic-input-group .btn-check-ic {
                width: 100%;
            }
        }
    </style>
</head>

<body>
<div class="overlay">

    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-chip">
            <i class="fa-solid fa-user"></i>
            <span><%= staffName %></span>
        </div>
    </div>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                
                <a class="side-link"href="/YesDentalSupportSystem/patient/patientDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>

                <a class="side-link active" href="/YesDentalSupportSystem/PatientServlet?action=list">
                    <i class="fa-solid fa-hospital-user"></i> Patients
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                    <i class="fa-solid fa-tooth"></i> Treatments
                </a>
            </div>

            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-user-plus"></i> Add Patient
                        </h4>
                        <p class="panel-sub">Search IC first. If not registered, you can add a new patient.</p>
                    </div>

                    <a class="back-pill" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                        <i class="fa-solid fa-arrow-left"></i> Back
                    </a>
                </div>

                <form class="flex-form" action="<%=request.getContextPath()%>/PatientServlet" method="post" id="addPatientForm">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="patient_status" value="A">
                    <input type="hidden" name="patient_crdate" value="<%= new java.sql.Timestamp(System.currentTimeMillis()) %>">

                    <div class="form-wrap">

                        <!-- IC SEARCH - UPDATED LAYOUT -->
                        <div class="ic-bar">
                            <div class="ic-input-wrap">
                                <label class="form-label">Search / Check IC Number</label>
                                
                                <!-- NEW: Input and button in same row -->
                                <div class="ic-input-group">
                                    <input type="text"
                                           class="form-control"
                                           id="icSearch"
                                           name="patient_ic"
                                           placeholder="e.g. 010203040506"
                                           maxlength="12"
                                           inputmode="numeric"
                                           autocomplete="off"
                                           required>
                                    
                                    <button type="button" class="btn btn-check-ic" id="btnCheckIc">
                                        <i class="fa-solid fa-magnifying-glass"></i> Check
                                    </button>
                                </div>
                                
                                <div class="help-note">Enter 12-digit IC, then click "Check".</div>

                                <div id="icMsg" class="ic-msg"></div>
                            </div>
                        </div>

                        <!-- DETAILS -->
                        <div id="detailsSection" style="display:none;">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" class="form-control" name="patient_name" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Phone</label>
                                    <input type="text"
                                           class="form-control"
                                           name="patient_phone"
                                           id="patientPhone"
                                           placeholder="e.g. 0123456789"
                                           inputmode="numeric"
                                           required>
                                    <div class="help-note">Numbers only.</div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" name="patient_email" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Date of Birth</label>
                                    <input type="date" class="form-control" name="patient_dob" required>
                                </div>

                                <div class="col-12">
                                    <label class="form-label">Address</label>
                                    <textarea class="form-control" name="patient_address" rows="3" required></textarea>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Guardian Name (Optional)</label>
                                    <input type="text" class="form-control" name="patient_guardian">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Guardian Phone (Optional)</label>
                                    <input type="text"
                                           class="form-control"
                                           name="patient_guardian_phone"
                                           id="guardianPhone"
                                           inputmode="numeric">
                                </div>

                                <div class="col-12">
                                    <div class="help-note">
                                        Status is auto set to <b>Active</b>. Password will be auto set by servlet (phone number).
                                    </div>
                                </div>
                            </div>

                        </div>

                    </div>

                    <!-- FOOTER ALWAYS VISIBLE -->
                    <div class="footer-actions">
                        <a class="btn-outline-pill" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                            Back to Patients
                        </a>

                        <button type="submit" class="btn-gold" id="btnAdd" disabled>
                            <i class="fa-solid fa-circle-plus"></i> Add Patient
                        </button>
                    </div>
                </form>

            </div>
        </div>
    </div>
</div>

<!-- SUCCESS POPUP -->
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
                Patient successfully added.
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
(() => {
    const popup = "<%= popup != null ? popup : "" %>";
    if (popup === "added") {
        new bootstrap.Modal(document.getElementById("addedModal")).show();
    }

    const icInput = document.getElementById("icSearch");
    const btnCheck = document.getElementById("btnCheckIc");
    const msg = document.getElementById("icMsg");
    const details = document.getElementById("detailsSection");
    const btnAdd = document.getElementById("btnAdd");

    const phone = document.getElementById("patientPhone");
    const gphone = document.getElementById("guardianPhone");

    function setMsg(text, type){
        msg.className = "ic-msg " + (type || "");
        msg.textContent = text || "";
        msg.style.display = text ? "block" : "none";
    }

    function lockForm(){
        details.style.display = "none";
        btnAdd.disabled = true;
    }

    function unlockForm(){
        details.style.display = "block";
        btnAdd.disabled = false;
    }

    lockForm();

    // numbers-only input (phone & guardian phone)
    function numbersOnly(el){
        if(!el) return;
        el.addEventListener("input", () => {
            el.value = el.value.replace(/[^0-9]/g, "");
        });
    }
    numbersOnly(phone);
    numbersOnly(gphone);

    async function checkIc(){
        const ic = (icInput.value || "").trim();

        if (!/^\d{12}$/.test(ic)){
            setMsg("IC must be 12 digits.", "bad");
            lockForm();
            return;
        }

        setMsg("Checking IC...", "");
        lockForm();

        try{
            const url = "<%=request.getContextPath()%>/PatientServlet?action=checkIc&patient_ic=" + encodeURIComponent(ic);
            const res = await fetch(url, { headers: { "Accept": "application/json" } });

            if(!res.ok){
                setMsg("Unable to check IC. Please try again.", "bad");
                return;
            }

            const data = await res.json();

            if (data.exists){
                setMsg("This IC is already registered.", "bad");
                lockForm();
            } else {
                setMsg("IC is available. You can proceed.", "ok");
                unlockForm();
            }
        }catch(e){
            setMsg("Unable to check IC. Please try again.", "bad");
        }
    }

    btnCheck.addEventListener("click", checkIc);

    icInput.addEventListener("keydown", (e) => {
        if(e.key === "Enter"){
            e.preventDefault();
            checkIc();
        }
    });

    icInput.addEventListener("input", () => {
        setMsg("", "");
        lockForm();
    });
})();
</script>
</body>
</html>