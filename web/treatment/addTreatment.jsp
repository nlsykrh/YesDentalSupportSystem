<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Treatment - YesDental</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Bootstrap (for modal popup like previous) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root{
            --green-dark:#2f4a34;
            --green-deep:#264232;
            --gold-soft:#d7d1a6;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body, html {
            height: 100vh;
            overflow: hidden;
            font-family: "Segoe UI", sans-serif;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
        }

        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.38);
            backdrop-filter: blur(1.5px);
        }

        /* ===== TOP BAR (same as previous) ===== */
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

        /* ===== LAYOUT (same as previous) ===== */
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

        /* ===== SIDEBAR (same as previous) ===== */
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

        /* ===== CONTENT CARD (same as previous) ===== */
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

        .content-scroll{
            flex:1;
            min-height:0;
            overflow:auto;
            padding-right:4px;
        }

        /* Header inside content */
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

        /* ===== FORM CARD (match addPatient/editStaff feel) ===== */
        .form-card{
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:16px;
            padding:16px;
            box-shadow:0 10px 18px rgba(0,0,0,0.06);
        }

        .form-label{
            font-weight:700;
            color:#333;
            margin-bottom:6px;
            font-size:14px;
        }
        .required:after{
            content:" *";
            color:#dc3545;
            font-weight:900;
        }

        .form-control{
            border-radius:14px;
            border:1px solid #d7ddd9;
            font-size:14px;
            padding:10px 12px;
        }
        .form-control:focus{
            border-color:#3f9042;
            box-shadow:0 0 0 3px rgba(63,144,66,0.12);
        }
        textarea.form-control{
            resize:vertical;
            min-height:120px;
            line-height:1.5;
        }

        .input-group{
            border-radius:14px;
            overflow:hidden;
        }
        .input-group-text{
            background:#f3f3f3;
            border:1px solid #d7ddd9;
            font-weight:700;
            color:#4b4b4b;
        }

        .text-muted{
            font-size:12.5px;
            color:#7a7a7a;
            margin-top:6px;
            display:block;
        }

        /* Buttons same theme */
        .btn-save{
            background:var(--gold-soft);
            color:#3a382f;
            border:none;
            border-radius:18px;
            padding:10px 14px;
            font-weight:800;
            font-size:13px;
            display:inline-flex;
            align-items:center;
            gap:8px;
        }
        .btn-reset{
            border:1px solid #d9d9d9;
            background:#fff;
            border-radius:18px;
            padding:10px 14px;
            font-weight:800;
            font-size:13px;
            color:#2f2f2f;
            display:inline-flex;
            align-items:center;
            gap:8px;
        }
        .btn-reset:hover{
            background:#fafafa;
        }

        /* ===== MODAL TOAST STYLE (same like previous) ===== */
        .yd-toast-modal .modal-content{
            border-radius: 18px;
            border: none;
            box-shadow: 0 22px 55px rgba(0,0,0,0.18);
            background: rgba(255,255,255,0.96);
            overflow: hidden;
        }
        .yd-toast-modal .modal-header{
            border-bottom: 1px solid rgba(0,0,0,0.06);
            padding: 14px 18px;
        }
        .yd-toast-modal .modal-title{
            font-weight: 900;
            display:flex;
            align-items:center;
            gap:10px;
            margin:0;
        }
        .yd-toast-modal .modal-body{
            padding: 18px 18px 20px;
            font-size: 15px;
            color:#333;
        }
        .yd-title-danger{ color:#dc3545; }

        /* ===== RESET CONFIRM MODAL (same style, warning) ===== */
        .yd-confirm-modal .modal-content{
            border-radius: 18px;
            border: none;
            box-shadow: 0 22px 55px rgba(0,0,0,0.18);
            background: rgba(255,255,255,0.96);
            overflow: hidden;
        }
        .yd-confirm-modal .modal-header{
            padding: 14px 18px;
            border-bottom: 1px solid rgba(0,0,0,0.06);
            display:flex;
            align-items:center;
            justify-content:space-between;
        }
        .yd-confirm-modal .modal-title{
            font-weight: 900;
            margin:0;
            color:#7a5a00;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .yd-confirm-modal .modal-title i{ color:#ffc107; }

        .yd-confirm-modal .modal-body{
            padding: 22px 26px 24px;
            text-align:center;
        }
        .yd-confirm-badge{
            width:66px;height:66px;border-radius:999px;
            display:grid;place-items:center;
            margin:4px auto 14px;
            background: rgba(255, 193, 7, 0.14);
            border: 2px solid rgba(255, 193, 7, 0.25);
        }
        .yd-confirm-badge i{ font-size:28px;color:#ffc107; }
        .yd-confirm-text{
            margin:0 auto 18px;
            max-width:360px;
            font-size:14px;
            color:#4b4b4b;
            line-height:1.45;
        }
        .yd-confirm-actions{
            display:flex;
            justify-content:center;
            gap:10px;
            flex-wrap:wrap;
        }
        .yd-btn-cancel{
            border:1px solid #d9d9d9;
            background:#fff;
            border-radius:18px;
            padding:10px 18px;
            font-weight:800;
            color:#2f2f2f;
            font-size:14px;
        }
        .yd-btn-warning{
            background:#ffc107;
            color:#2f2f2f;
            border:none;
            border-radius:18px;
            padding:10px 18px;
            font-weight:900;
            font-size:14px;
            box-shadow:0 10px 18px rgba(0,0,0,0.10);
            transition:all .18s ease;
        }
        .yd-btn-warning:hover{
            transform:translateY(-1px);
            filter:brightness(0.98);
        }

        @media (max-width: 992px){
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
<%
    String staffName = (String) session.getAttribute("staffName");
    String staffId = (String) session.getAttribute("staffId");
    String staffRole = (String) session.getAttribute("staffRole");

    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
    if (staffId == null || staffId.trim().isEmpty()) staffId = "-";
    if (staffRole == null || staffRole.trim().isEmpty()) staffRole = "Staff";
%>

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

    <!-- LAYOUT -->
    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
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

                <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                    <i class="fa-solid fa-hospital-user"></i> Patients
                </a>

                <a class="side-link active" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                    <i class="fa-solid fa-tooth"></i> Treatments
                </a>
            </div>

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-plus"></i>
                            Add New Treatment
                        </h4>
                        <p class="panel-sub">Fill in the details below to add a new treatment to the system.</p>
                    </div>
                </div>

                <div class="content-scroll">
                    <div class="form-card">

                        <form action="${pageContext.request.contextPath}/TreatmentServlet" method="post" id="addTreatmentForm">
                            <input type="hidden" name="action" value="add">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label required">Treatment ID</label>
                                    <input type="text" class="form-control" name="treatment_id" required
                                           placeholder="e.g., TX001 or 2024001">
                                    <small class="text-muted">Enter a unique identifier for the treatment</small>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label required">Treatment Name</label>
                                    <input type="text" class="form-control" name="treatment_name" required
                                           placeholder="e.g., Dental Cleaning, Root Canal, Teeth Whitening">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label required">Treatment Price (RM)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">RM</span>
                                        <input type="number" class="form-control" name="treatment_price"
                                               step="0.01" min="0" required placeholder="0.00">
                                    </div>
                                    <small class="text-muted">Enter the price in Malaysian Ringgit (RM)</small>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label required">Description</label>
                                    <textarea class="form-control" name="treatment_desc" rows="5" required
                                              placeholder="Describe the treatment procedure, duration, benefits, and any special instructions..."></textarea>
                                    <small class="text-muted">Provide a clear description for patients and staff reference</small>
                                </div>
                            </div>

                            <div class="d-flex justify-content-end gap-2 mt-4">
                                <button type="submit" class="btn-save">
                                    <i class="fa-solid fa-floppy-disk"></i> Save Treatment
                                </button>

                                <button type="button" class="btn-reset" onclick="resetForm(event)">
                                    <i class="fa-solid fa-rotate-left"></i> Reset Form
                                </button>
                            </div>
                        </form>

                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<!-- ✅ ERROR POPUP MODAL (same style like previous) -->
<div class="modal fade yd-toast-modal" id="notifyModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title yd-title-danger" id="notifyTitle">
                    <i class="fa-solid fa-circle-xmark"></i> Error
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="notifyBody">
                Message here...
            </div>
        </div>
    </div>
</div>

<!-- ✅ RESET CONFIRM MODAL (same style as previous confirm) -->
<div class="modal fade yd-confirm-modal" id="resetConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-triangle-exclamation"></i> Confirm Reset
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="yd-confirm-badge">
                    <i class="fa-solid fa-rotate-left"></i>
                </div>

                <p class="yd-confirm-text">
                    Are you sure you want to reset the form? All entered data will be lost.
                </p>

                <div class="yd-confirm-actions">
                    <button type="button" class="yd-btn-cancel" data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="button" class="yd-btn-warning" id="confirmResetBtn">
                        Yes, Reset
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>

<script>
    // Keep same function name (no function changes)
    function resetForm(event) {
        event.preventDefault();
        const m = new bootstrap.Modal(document.getElementById("resetConfirmModal"));
        m.show();
    }

    document.addEventListener("DOMContentLoaded", function(){
        // Reset confirm submit
        const btn = document.getElementById("confirmResetBtn");
        if (btn) {
            btn.addEventListener("click", function(){
                document.getElementById("addTreatmentForm").reset();
                const modalEl = document.getElementById("resetConfirmModal");
                const modalInstance = bootstrap.Modal.getInstance(modalEl);
                if (modalInstance) modalInstance.hide();
            });
        }

        // Show error as modal popup (instead of inline alert)
        <% if (request.getAttribute("error") != null) { %>
            document.getElementById("notifyBody").innerHTML =
                "<%= String.valueOf(request.getAttribute("error")).replace("\"","\\\"") %>";
            new bootstrap.Modal(document.getElementById("notifyModal")).show();
        <% } %>
    });
</script>

</body>
</html>
