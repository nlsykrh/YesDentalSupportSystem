<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String staffName = (String) session.getAttribute("staffName");
    String staffId   = (String) session.getAttribute("staffId");
    String staffRole = (String) session.getAttribute("staffRole");

    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
    if (staffId == null || staffId.trim().isEmpty()) staffId = "-";
    if (staffRole == null || staffRole.trim().isEmpty()) staffRole = "Staff";
%>
<%
    String msg = request.getParameter("msg");
%>

<% if (msg != null && !msg.trim().isEmpty()) { %>
<script>
    alert("<%= msg.replace("\"", "\\\"") %>");
</script>
<% } %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Manage Staff</title>

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

        /* ===== TOP BAR (match friend) ===== */
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

        /* ===== LAYOUT (match friend) ===== */
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

        /* ===== SIDEBAR (match friend) ===== */
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

        /* ===== CONTENT CARD (match friend) ===== */
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
        /* ===== TABLE AREA (your staff list) ===== */
        .toolbar{
            display:flex;
            gap:10px;
            align-items:center;
            justify-content:space-between;
            margin-bottom:12px;
        }
        .search-input{
            border:1px solid #d7ddd9;
            border-radius:18px;
            padding:7px 12px;
            font-size:13px;
            width:260px;
        }
        .btn-add{
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
        }

        .table-wrap{
            border:1px solid #d9d9d9;
            border-radius:10px;
            background:#fff;
            flex:1;
            min-height:0;
            overflow:auto;
        }
        .table{ margin:0; }
        .table thead{ background:#dcdcdc; }
        .table thead th{
            font-size:12px;
            text-transform:uppercase;
            letter-spacing:.4px;
            color:#2b2b2b;
            position:sticky;
            top:0;
            background:#dcdcdc;
            z-index:5;
            padding:12px 14px;
        }
        .table tbody td{
            font-size:14px;
            vertical-align:middle;
            padding:12px 14px;
        }

        .role-pill{
            padding:5px 12px;
            border-radius:999px;
            font-size:12px;
            background:#e7f4ec;
            color:#2a6b48;
            display:inline-block;
            font-weight:700;
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
            height:36px;
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
            box-shadow:0 10px 18px rgba(0,0,0,.08);
            background:#fafafa;
        }
        .action-view{border-color:#cfe0d5;color:#264232;}
        .action-edit{border-color:#e6dfb9;color:#5a4f1a;}
        .action-del{border-color:#f0c7c7;color:#9b2c2c;}

        /* ===== DELETE MODAL (SAME STYLE LIKE editStaff, BUT RED) ===== */
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

        .yd-confirm-modal .modal-title i{
            color:#dc3545;
        }

        .yd-confirm-modal .modal-body{
            padding: 22px 26px 24px;
            text-align: center;
        }

        .yd-confirm-badge{
            width: 66px;
            height: 66px;
            border-radius: 999px;
            display: grid;
            place-items: center;
            margin: 4px auto 14px;
            background: rgba(220, 53, 69, 0.12);
            border: 2px solid rgba(220, 53, 69, 0.25);
        }

        .yd-confirm-badge i{
            font-size: 28px;
            color: #dc3545;
        }

        .yd-confirm-title{
            font-weight: 900;
            margin: 0 0 6px;
            color: #9b2c2c;
        }

        .yd-confirm-text{
            margin: 0 auto 18px;
            max-width: 360px;
            font-size: 14px;
            color: #4b4b4b;
            line-height: 1.45;
        }

        .yd-confirm-actions{
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .yd-btn-cancel{
            border: 1px solid #d9d9d9;
            background: #fff;
            border-radius: 18px;
            padding: 10px 18px;
            font-weight: 800;
            color: #2f2f2f;
            font-size: 14px;
        }

        .yd-btn-danger{
            background: #dc3545;
            color: #fff;
            border: none;
            border-radius: 18px;
            padding: 10px 18px;
            font-weight: 900;
            font-size: 14px;
            box-shadow: 0 10px 18px rgba(0,0,0,0.10);
            transition: all .18s ease;
        }

        .yd-btn-danger:hover{
            transform: translateY(-1px);
            filter: brightness(0.98);
        }

        /* ===== SUCCESS MODAL (same style like your success screenshot) ===== */
        .yd-success-modal .modal-content{
            border-radius: 18px;
            border: none;
            box-shadow: 0 22px 55px rgba(0,0,0,0.18);
            background: rgba(255,255,255,0.96);
            overflow: hidden;
        }
        .yd-success-modal .modal-header{
            padding: 14px 18px;
            border-bottom: 1px solid rgba(0,0,0,0.06);
            display:flex;
            align-items:center;
            justify-content:space-between;
        }
        .yd-success-modal .modal-title{
            font-weight: 900;
            margin:0;
            color:#198754;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .yd-success-modal .modal-title i{ color:#198754; }
        .yd-success-modal .modal-body{
            padding: 18px 18px 20px;
            font-size: 15px;
            color:#333;
        }

        .alert{ border-radius:10px; margin:0 60px 12px; }

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
            .table-wrap{ overflow:visible; }
            .search-input{ width:180px; }
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

    <%-- if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">${error}</div>
    <% } --%>

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
                    <h4 class="panel-title">
                        <i class="fa-solid fa-user-doctor"></i>
                        Manage Staff
                    </h4>
                </div>

                <div class="toolbar">
                    <input id="staffSearch" type="text" class="search-input" placeholder="Search by ID / Name / Role...">

                    <a href="<%=request.getContextPath()%>/StaffServlet?action=add" class="btn-add">
                        <i class="fa-solid fa-plus"></i> Add Staff
                    </a>
                </div>

                <div class="table-wrap">
                    <table class="table table-hover mb-0">
                        <thead>
                        <tr>
                            <th style="width:220px;">Staff ID</th>
                            <th>Name</th>
                            <th style="width:220px;">Role</th>
                            <th style="width:260px; text-align:center;">Actions</th>
                        </tr>
                        </thead>
                        <tbody id="staffTableBody">
                        <%
                            List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
                            if (staffList != null && !staffList.isEmpty()) {
                                for (Staff s : staffList) {
                                    String id = s.getStaffId() != null ? s.getStaffId() : "";
                                    String name = s.getStaffName() != null ? s.getStaffName() : "";
                                    String role = s.getStaffRole() != null ? s.getStaffRole() : "";
                        %>
                        <tr data-search="<%= (id + " " + name + " " + role).toLowerCase() %>">
                            <td><strong><%= id %></strong></td>
                            <td><%= name %></td>
                            <td><span class="role-pill"><%= role %></span></td>
                            <td>
                                <div class="actions">
                                    <a href="<%=request.getContextPath()%>/StaffServlet?action=view&staff_id=<%= id %>"
                                       class="action-pill action-view">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>

                                    <a href="<%=request.getContextPath()%>/StaffServlet?action=edit&staff_id=<%= id %>"
                                       class="action-pill action-edit">
                                        <i class="fa-solid fa-pen"></i> Edit
                                    </a>

                                    <form action="<%=request.getContextPath()%>/StaffServlet" method="post"
                                           style="display:inline;" onsubmit="return confirmDelete(this)">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="staff_id" value="<%= id %>">
                                        <button type="submit" class="action-pill action-del">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" class="text-center py-4">No staff found.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </div>
</div>

<!-- ✅ DELETE CONFIRM MODAL (STYLE LIKE editStaff, BUT RED + X BUTTON) -->
<div class="modal fade yd-confirm-modal" id="deleteConfirmModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">

      <!-- ✅ added header with X button (no removing anything else) -->
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

        <h5 class="yd-confirm-title">Confirm Delete</h5>

        <p class="yd-confirm-text">
          Are you sure you want to delete this staff? This action cannot be undone.
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

<!-- ✅ SUCCESS DELETE MODAL -->
<div class="modal fade yd-success-modal" id="deleteSuccessModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          <i class="fa-solid fa-circle-check"></i> Success
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        Staff deleted successfully.
      </div>
    </div>
  </div>
</div>

<script>
    const staffSearch = document.getElementById("staffSearch");
    const staffBody = document.getElementById("staffTableBody");

    if (staffSearch && staffBody) {
        staffSearch.addEventListener("input", function () {
            const keyword = this.value.trim().toLowerCase();
            const rows = staffBody.querySelectorAll("tr");

            rows.forEach(row => {
                const searchText = (row.getAttribute("data-search") || "");
                row.style.display = (!keyword || searchText.includes(keyword)) ? "" : "none";
            });
        });
    }

    let deleteFormToSubmit = null;

    function confirmDelete(formEl) {
        deleteFormToSubmit = formEl;
        const m = new bootstrap.Modal(document.getElementById("deleteConfirmModal"));
        m.show();
        return false; // stop normal submit
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function(){
    const btn = document.getElementById("confirmDeleteBtn");
    if (btn) {
        btn.addEventListener("click", function(){
            // close confirm modal first, then show success, then submit after short delay
            const confirmEl = document.getElementById("deleteConfirmModal");
            const confirmInstance = bootstrap.Modal.getInstance(confirmEl);
            if (confirmInstance) confirmInstance.hide();

            const successModal = new bootstrap.Modal(document.getElementById("deleteSuccessModal"));
            successModal.show();

            // after success popup shown briefly -> submit delete
            setTimeout(function(){
                if (deleteFormToSubmit) deleteFormToSubmit.submit();
            }, 700);
        });
    }

    // OPTIONAL: show success modal after redirect using ?popup=deleted
    // (won't affect anything if you don't use it)
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get("popup") === "deleted") {
        const successModal = new bootstrap.Modal(document.getElementById("deleteSuccessModal"));
        successModal.show();

        document.getElementById("deleteSuccessModal").addEventListener("hidden.bs.modal", function(){
            // remove popup param by going back to list cleanly
            window.location.href = "<%=request.getContextPath()%>/StaffServlet?action=list";
        });
    }
});
</script>

</body>
</html>
