<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Treatment" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Treatments - YesDental</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Bootstrap (needed for modal popup like add patient) -->
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

        /* ===== TOP BAR (same as add patient/editStaff) ===== */
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

        /* ===== SIDEBAR (same style) ===== */
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

        /* ===== CONTENT CARD ===== */
        .card-panel{
            background:rgba(255, 255, 255, 0.92);
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

        .panel-header h4{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
            display:flex;
            align-items:center;
            gap:10px;
        }

        .controls-row{
            display:flex;
            align-items:center;
            justify-content:flex-end;
            gap:12px;
        }

        .search-wrapper{
            width: 300px;
        }

        .search-input{
            width:100%;
            padding:10px 15px;
            border:1px solid #d7ddd9;
            border-radius:18px;
            font-size:13px;
            outline:none;
            color:#555;
            background:#fff;
        }
        .search-input::placeholder{ color:#aaa; }

        /* Add button (match theme like other pages) */
        .btn-add-custom{
            background:var(--gold-soft);
            color:#3a382f;
            border:none;
            border-radius:18px;
            padding:8px 14px;
            font-weight:800;
            font-size:13px;
            text-decoration:none;
            display:inline-flex;
            align-items:center;
            gap:8px;
            white-space:nowrap;
            transition:all .18s ease;
        }
        .btn-add-custom:hover{
            transform:translateY(-1px);
            filter:brightness(0.98);
            color:#3a382f;
            text-decoration:none;
        }

        /* TABLE */
        .table-container {
            overflow-y: auto;       
            overflow-x: auto;      
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
        }


        .treatment-table{
            width:100%;
            border-collapse:collapse;
            min-width:800px;
        }

        .treatment-table thead{
            background:#dcdcdc;
        }

        .treatment-table th{
            padding:16px 12px;
            text-align:center;
            font-weight:700;
            font-size:12px;
            text-transform:uppercase;
            letter-spacing:.4px;
            color:#2b2b2b;
            border-bottom:1px solid #ccc;
            position:sticky;
            top:0;
            background:#dcdcdc;
            z-index:5;
        }

        .treatment-table td{
            padding:14px 12px;
            font-size:14px;
            color:#333;
            vertical-align:middle;
            text-align:center;
            border-bottom:1px solid #eee;
        }

        .treatment-table tbody tr:hover{
            background:#f8f9fa;
        }

        .price-cell{
            font-weight:700;
            color:#198754;
        }

        .description-cell{
            text-align:left !important;
            max-width:400px;
            word-wrap:break-word;
            line-height:1.4;
        }

        .description-preview{
            display:-webkit-box;
            -webkit-line-clamp:2;
            -webkit-box-orient:vertical;
            overflow:hidden;
            text-overflow:ellipsis;
            max-height:2.8em;
        }

        .actions{
            display:flex;
            gap:10px;
            justify-content:center;
        }

        .action-pill{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:7px 12px;
            border-radius:999px;
            border:1px solid #d9d9d9;
            background:#fff;
            color:#2f2f2f;
            text-decoration:none;
            font-size:13px;
            font-weight:700;
            white-space:nowrap;
            transition:transform .08s ease, box-shadow .12s ease, background .12s ease;
        }

        .action-pill:hover{
            transform:translateY(-1px);
            box-shadow:0 10px 18px rgba(0,0,0,0.08);
            background:#fafafa;
        }

        .action-edit{
            border-color:#e6dfb9;
            color:#5a4f1a;
        }

        .action-delete{
            border-color:#f0c7c7;
            color:#9b2c2c;
        }

        /* Records count */
        .records-count{
            padding:15px;
            text-align:center;
            color:#888;
            font-size:12px;
            background:#fafafa;
            border-top:1px solid #eaeaea;
        }

        /* Empty state */
        .no-treatments{
            text-align:center;
            padding:60px 20px;
            background:#f9f9f9;
            border-radius:8px;
            margin:20px;
            border:2px dashed #ddd;
        }

        .form-inline{ display:inline; margin:0; }

        /* ===== SUCCESS/ERROR POPUP (same feel like add patient screenshot) ===== */
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

        .yd-title-success{ color:#198754; }
        .yd-title-danger{ color:#dc3545; }
        .yd-title-warning{ color:#b58100; }
        .yd-title-info{ color:#0c5460; }

        /* ===== DELETE CONFIRM MODAL (RED, like editStaff confirm) ===== */
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
            color:#9b2c2c;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .yd-confirm-modal .modal-title i{ color:#dc3545; }

        .yd-confirm-modal .modal-body{
            padding: 22px 26px 24px;
            text-align:center;
        }
        .yd-confirm-badge{
            width:66px;height:66px;border-radius:999px;
            display:grid;place-items:center;
            margin:4px auto 14px;
            background: rgba(220, 53, 69, 0.12);
            border: 2px solid rgba(220, 53, 69, 0.25);
        }
        .yd-confirm-badge i{ font-size:28px;color:#dc3545; }
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
        .yd-btn-danger{
            background:#dc3545;
            color:#fff;
            border:none;
            border-radius:18px;
            padding:10px 18px;
            font-weight:900;
            font-size:14px;
            box-shadow:0 10px 18px rgba(0,0,0,0.10);
            transition:all .18s ease;
        }
        .yd-btn-danger:hover{
            transform:translateY(-1px);
            filter:brightness(0.98);
        }

        @media (max-width: 992px) {
            body{ overflow:auto; }
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; height:auto; overflow:visible; }
            .top-nav{
                padding:18px 24px 8px;
                flex-wrap:wrap;
                gap:10px;
            }
            .search-wrapper { width: 250px; }
            .actions { justify-content: flex-start; }
        }

        @media (max-width: 768px) {
            .controls-row { flex-wrap: wrap; justify-content:flex-start; }
            .search-wrapper { width: 100%; }
            .treatment-table { min-width: 600px; }
            .description-cell { max-width: 250px; }
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

    <div class="layout-wrap">
        <div class="layout">

            <!-- UPDATED SIDEBAR -->
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

            <div class="card-panel">
                <div class="panel-header">
                    <h4>
                        <i class="fa-solid fa-tooth"></i>
                        Manage Treatments
                    </h4>

                    <div class="controls-row">
                        <div class="search-wrapper">
                            <input type="text" id="searchInput" class="search-input" placeholder="Search treatments...">
                        </div>

                        <a href="/YesDentalSupportSystem/treatment/addTreatment.jsp" class="btn-add-custom">
                            <i class="fa-solid fa-plus"></i>
                            Add Treatment
                        </a>
                    </div>
                </div>

                <div class="table-container">
                    <%
                        List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");

                        if (treatments != null && !treatments.isEmpty()) {
                    %>
                    <table class="treatment-table" id="treatmentTable">
                        <thead>
                        <tr>
                            <th width="15%">TREATMENT ID</th>
                            <th width="20%">TREATMENT NAME</th>
                            <th width="40%">DESCRIPTION</th>
                            <th width="10%">PRICE (RM)</th>
                            <th width="15%">ACTIONS</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Treatment treatment : treatments) { %>
                        <tr>
                            <td><%= treatment.getTreatmentId() %></td>
                            <td><%= treatment.getTreatmentName() %></td>
                            <td class="description-cell">
                                <div class="description-preview" title="<%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "No description" %>">
                                    <%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "-" %>
                                </div>
                            </td>
                            <td class="price-cell"><%= String.format("%.2f", treatment.getTreatmentPrice()) %></td>
                            <td>
                                <div class="actions">
                                    <a href="TreatmentServlet?action=edit&treatment_id=<%= treatment.getTreatmentId() %>"
                                       class="action-pill action-edit" title="Edit Treatment">
                                        <i class="fa-solid fa-pen"></i> Edit
                                    </a>

                                    <form action="TreatmentServlet" method="post" class="form-inline"
                                          onsubmit="return confirmDelete(this)">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="treatment_id" value="<%= treatment.getTreatmentId() %>">
                                        <button type="submit" class="action-pill action-delete" title="Delete Treatment">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>

                    <div class="records-count">
                        Total Records: <%= treatments.size() %>
                    </div>
                    <% } else { %>
                    <div class="no-treatments">
                        <i class="fas fa-tooth" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                        <h5 style="color: #666; margin-bottom: 10px;">No treatments found</h5>
                        <a href="/YesDentalSupportSystem/treatment/addTreatment.jsp" class="btn-add-custom">
                            <i class="fa-solid fa-plus"></i> Add Your First Treatment
                        </a>
                    </div>
                    <% } %>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- ✅ MESSAGE POPUP MODAL (same like add patient screenshot) -->
<div class="modal fade yd-toast-modal" id="notifyModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="notifyTitle">
                    <i class="fa-solid fa-circle-check"></i> Success
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="notifyBody">
                Message here...
            </div>
        </div>
    </div>
</div>

<!-- ✅ DELETE CONFIRM MODAL (red like editStaff) -->
<div class="modal fade yd-confirm-modal" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-circle-exclamation"></i> Confirm Delete
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="yd-confirm-badge">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                </div>

                <p class="yd-confirm-text">
                    Are you sure you want to delete this treatment? This action cannot be undone.
                </p>

                <div class="yd-confirm-actions">
                    <button type="button" class="yd-btn-cancel" data-bs-dismiss="modal">
                        Cancel
                    </button>
                    <button type="button" class="yd-btn-danger" id="confirmDeleteBtn">
                        Yes, Delete
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // ✅ Keep your old function name (so no logic breaks), but now opens modal
    let deleteFormToSubmit = null;

    function confirmDelete(formEl) {
        deleteFormToSubmit = formEl;
        const m = new bootstrap.Modal(document.getElementById("deleteConfirmModal"));
        m.show();
        return false;
    }

    // Search Functionality (UNCHANGED)
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById("searchInput");
        const table = document.getElementById("treatmentTable");

        if (searchInput && table) {
            searchInput.addEventListener("input", function () {
                const keyword = this.value.trim().toLowerCase();
                const rows = table.querySelectorAll("tbody tr");

                rows.forEach(row => {
                    const cells = row.querySelectorAll("td");
                    let found = false;

                    cells.forEach(cell => {
                        const cellText = cell.textContent || cell.innerText;
                        if (cellText.toLowerCase().includes(keyword)) {
                            found = true;
                        }
                    });

                    row.style.display = (!keyword || found) ? "" : "none";
                });
            });
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function(){
    // Confirm delete click -> submit stored form
    const confirmBtn = document.getElementById("confirmDeleteBtn");
    if (confirmBtn) {
        confirmBtn.addEventListener("click", function(){
            if (deleteFormToSubmit) deleteFormToSubmit.submit();
        });
    }

    // ✅ Show popup message (same idea, but using modal now)
    <% if (request.getAttribute("message") != null) { %>
        document.getElementById("notifyTitle").innerHTML =
            '<i class="fa-solid fa-circle-check"></i> Success';
        document.getElementById("notifyTitle").className = "modal-title yd-title-success";
        document.getElementById("notifyBody").innerHTML = "<%= String.valueOf(request.getAttribute("message")).replace("\"","\\\"") %>";
        new bootstrap.Modal(document.getElementById("notifyModal")).show();
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
        document.getElementById("notifyTitle").innerHTML =
            '<i class="fa-solid fa-circle-xmark"></i> Error';
        document.getElementById("notifyTitle").className = "modal-title yd-title-danger";
        document.getElementById("notifyBody").innerHTML = "<%= String.valueOf(request.getAttribute("error")).replace("\"","\\\"") %>";
        new bootstrap.Modal(document.getElementById("notifyModal")).show();
    <% } %>

    <% if (request.getAttribute("warning") != null) { %>
        document.getElementById("notifyTitle").innerHTML =
            '<i class="fa-solid fa-triangle-exclamation"></i> Warning';
        document.getElementById("notifyTitle").className = "modal-title yd-title-warning";
        document.getElementById("notifyBody").innerHTML = "<%= String.valueOf(request.getAttribute("warning")).replace("\"","\\\"") %>";
        new bootstrap.Modal(document.getElementById("notifyModal")).show();
    <% } %>

    <% if (request.getAttribute("info") != null) { %>
        document.getElementById("notifyTitle").innerHTML =
            '<i class="fa-solid fa-circle-info"></i> Info';
        document.getElementById("notifyTitle").className = "modal-title yd-title-info";
        document.getElementById("notifyBody").innerHTML = "<%= String.valueOf(request.getAttribute("info")).replace("\"","\\\"") %>";
        new bootstrap.Modal(document.getElementById("notifyModal")).show();
    <% } %>
});
</script>

</body>
</html>
