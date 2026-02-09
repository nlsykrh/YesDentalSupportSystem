<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String staffName = (String) session.getAttribute("staffName");
    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";

    Patient patient = (Patient) request.getAttribute("patient");
    String error = (String) request.getAttribute("error");
    String popup = request.getParameter("popup"); // popup=updated

    SimpleDateFormat dateOnly = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat dateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    String dobStr = "";
    String createdStr = "N/A";
    if (patient != null) {
        if (patient.getPatientDob() != null) dobStr = dateOnly.format(patient.getPatientDob());
        if (patient.getPatientCrDate() != null) createdStr = dateTime.format(patient.getPatientCrDate());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Edit Patient</title>

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

        .top-right{
        display:flex;
        align-items:center;
        gap:12px;
        justify-content:flex-end;
        flex-wrap:wrap; /* ✅ prevent disappearing on smaller width */
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

        /* ✅ LOGOUT BUTTON like your design */
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
            cursor:pointer;
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

        /* FORM LAYOUT */
        form.flex-form{
            display:flex;
            flex-direction:column;
            height:100%;
            min-height:0;
        }

        .form-wrap{
            flex:1;
            min-height:0;
            overflow-y:auto;
            border:1px solid #d9d9d9;
            border-radius:12px;
            background:#fff;
            padding:18px;
        }

        .footer-actions{
            flex-shrink:0;
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

        .btn-outline-pill{
            border:1px solid #d9d9d9;
            background:#fff;
            border-radius:999px;
            padding:10px 18px;
            font-weight:800;
            color:#2f2f2f;
            text-decoration:none;
        }

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

        @media(max-width:992px){
            body{overflow:auto;}
            .layout{grid-template-columns:1fr;}
            .layout-wrap{height:auto; padding:20px;}
            .card-panel{height:auto;}
            .form-wrap{min-height:auto; overflow:visible;}
            .top-right{ flex-wrap:wrap; justify-content:flex-end; }
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

    <!-- ✅ RIGHT SIDE: chip + logout -->
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


    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link" href="/YesDentalSupportSystem/patient/patientDashboard.jsp">
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

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-pen-to-square"></i> Edit Patient
                        </h4>
                    </div>

                    <a class="back-pill" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                        <i class="fa-solid fa-arrow-left"></i> Back
                    </a>
                </div>

                <% if (error != null) { %>
                    <div class="alert alert-danger" style="border-radius:12px;">
                        <%= error %>
                    </div>
                <% } %>

                <% if (patient != null) { %>

                <form class="flex-form" action="<%=request.getContextPath()%>/PatientServlet" method="post" id="editPatientForm">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="patient_ic" value="<%= patient.getPatientIc() %>">

                    <div class="form-wrap">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">IC Number</label>
                                <input type="text" class="form-control" value="<%= patient.getPatientIc() %>" readonly>
                                <div class="help-note">IC cannot be changed.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" class="form-control" name="patient_name"
                                       value="<%= patient.getPatientName() != null ? patient.getPatientName() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" class="form-control" name="patient_phone" id="patientPhone"
                                       value="<%= patient.getPatientPhone() != null ? patient.getPatientPhone() : "" %>"
                                       inputmode="numeric" required>
                                <div class="help-note">Numbers only.</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="patient_email"
                                       value="<%= patient.getPatientEmail() != null ? patient.getPatientEmail() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Date of Birth</label>
                                <input type="date" class="form-control" name="patient_dob" value="<%= dobStr %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="patient_status" required>
                                    <option value="A" <%= "A".equalsIgnoreCase(patient.getPatientStatus()) ? "selected" : "" %>>Active</option>
                                    <option value="I" <%= "I".equalsIgnoreCase(patient.getPatientStatus()) ? "selected" : "" %>>Inactive</option>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <textarea class="form-control" name="patient_address" rows="3" required><%= patient.getPatientAddress() != null ? patient.getPatientAddress() : "" %></textarea>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Guardian Name (Optional)</label>
                                <input type="text" class="form-control" name="patient_guardian"
                                       value="<%= patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "" %>">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Guardian Phone (Optional)</label>
                                <input type="text" class="form-control" name="patient_guardian_phone" id="guardianPhone"
                                       value="<%= patient.getPatientGuardianPhone() != null ? patient.getPatientGuardianPhone() : "" %>"
                                       inputmode="numeric">
                                <div class="help-note">Numbers only.</div>
                            </div>

                            <div class="col-12 mt-2">
                                <hr>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Registration Date</label>
                                <input type="text" class="form-control" value="<%= createdStr %>" readonly>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">New Password (Optional)</label>
                                <input type="password" class="form-control" name="patient_password"
                                       placeholder="Leave empty to keep current password">
                                <div class="help-note">Leave empty if you don’t want to change.</div>
                            </div>
                        </div>

                    </div>

                    <div class="footer-actions">
                        <a class="btn-outline-pill" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                            Back to Patients
                        </a>

                        <button type="submit" class="btn-gold">
                            <i class="fa-solid fa-floppy-disk"></i> Update Patient
                        </button>
                    </div>
                </form>

                <% } else { %>
                    <div class="form-wrap">
                        <div class="alert alert-warning mb-0" style="border-radius:12px;">
                            No patient data found. Please select a patient to edit.
                        </div>
                    </div>

                    <div class="footer-actions">
                        <a class="btn-outline-pill" href="<%=request.getContextPath()%>/PatientServlet?action=list">
                            Back to Patients
                        </a>
                    </div>
                <% } %>

            </div>
        </div>
    </div>
</div>

<!-- SUCCESS POPUP -->
<div class="modal fade" id="updatedModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:14px;">
            <div class="modal-header">
                <h5 class="modal-title text-success">
                    <i class="fa-solid fa-circle-check"></i> Success
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                Patient successfully updated.
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
(() => {
    const popup = "<%= popup != null ? popup : "" %>";
    if (popup === "updated") {
        const modalEl = document.getElementById("updatedModal");
        const modal = new bootstrap.Modal(modalEl);
        modal.show();

        modalEl.addEventListener("hidden.bs.modal", function () {
            window.location.href = "<%=request.getContextPath()%>/PatientServlet?action=list";
        });
    }

    function numbersOnly(id){
        const el = document.getElementById(id);
        if(!el) return;
        el.addEventListener("input", () => {
            el.value = el.value.replace(/[^0-9]/g, "");
        });
    }

    numbersOnly("patientPhone");
    numbersOnly("guardianPhone");
})();
</script>

</body>
</html>
