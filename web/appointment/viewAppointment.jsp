<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="dao.DigitalConsentDAO" %>

<%
    // Detect role for sidebar + permission
    String patientName = (String) session.getAttribute("patientName");
    String staffName = (String) session.getAttribute("staffName");

    boolean isPatient = (patientName != null);
    boolean isStaff = (staffName != null);

    if (!isPatient && !isStaff) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Use this for top header display name
    String displayName = isStaff ? staffName : patientName;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Appointments</title>

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
            font-family:"Segoe UI",sans-serif;
        }
        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,.38);
            backdrop-filter:blur(1.5px);
        }
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
        .brand img{height:48px;}
        .clinic-title{
            font-size:26px;
            font-weight:700;
            color:var(--green-dark);
            font-family:"Times New Roman",serif;
        }
        .user-area{
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
            border-bottom:1px solid rgba(255,255,255,.25);
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
            opacity:.95;
        }
        .side-link.active,.side-link:hover{
            background:rgba(255,255,255,.14);
            color:#ffe69b;
        }

        .card-panel{
            background:rgba(255,255,255,.92);
            border-radius:16px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,.1);
            height:100%;
            display:flex;
            flex-direction:column;
            overflow:hidden;
        }
        .panel-header{
            display:flex;
            justify-content:space-between;
            gap:14px;
            align-items:center;
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

        /* SAME search style like viewStaff */
        .search-wrap{
            display:flex;
            align-items:center;
            gap:10px;
        }
        .search-input{
            border:1px solid #d7ddd9;
            border-radius:18px;
            padding:7px 12px;
            font-size:13px;
            width:260px;
        }

        /* Filter pills (neat, like tabs but same page vibe) */
        .filter-pills{
            display:flex;
            gap:8px;
            flex-wrap:wrap;
        }
        .pill{
            border:1px solid #d9d9d9;
            background:#fff;
            color:#2f2f2f;
            border-radius:999px;
            padding:7px 12px;
            font-size:13px;
            font-weight:800;
            cursor:pointer;
            user-select:none;
        }
        .pill.active{
            background:rgba(215,209,166,0.55);
            border-color:#e6dfb9;
            color:#3a382f;
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
        .table{margin:0;}
        .table thead{background:#dcdcdc;}
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

        .badge-status{
            border-radius:999px;
            padding:6px 10px;
            font-weight:800;
            font-size:12px;
            display:inline-block;
        }

        /* Action pills like viewStaff */
        .actions{
            display:flex;
            gap:10px;
            justify-content:center;
            flex-wrap:wrap;
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
        .action-pill i{font-size:14px;}
        .action-pill:hover{
            transform:translateY(-1px);
            box-shadow:0 10px 18px rgba(0,0,0,.08);
            background:#fafafa;
        }
        .action-view{border-color:#cfe0d5;color:#264232;}
        .action-edit{border-color:#e6dfb9;color:#5a4f1a;}
        .action-consent{border-color:#c9d8f2;color:#1b4b99;}

        .alert{border-radius:10px;margin-bottom:12px;}

        @media(max-width:992px){
            body{overflow:auto;}
            .layout{grid-template-columns:1fr;}
            .layout-wrap{padding:20px;height:auto;overflow:visible;}
            .top-nav{padding:18px 24px 8px;flex-wrap:wrap;gap:10px;}
            .card-panel{height:auto;overflow:visible;}
            .table-wrap{overflow:auto;}
            .search-input{width:180px;}
        }
    </style>
</head>

<body>
<div class="overlay">

    <!-- TOP HEADER -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-area">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= displayName %></span>
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

            <!-- SIDEBAR -->
            <div class="sidebar">
                <% if (isPatient) { %>
                    <h6>Patient Dashboard</h6>

                    <a class="side-link" href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>

                    <a class="side-link active" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                        <i class="fa-solid fa-calendar-check"></i> View Appointment
                    </a>

                    <a class="side-link" href="<%=request.getContextPath()%>/billing/viewBilling.jsp">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                    </a>

                    <a class="side-link" href="<%=request.getContextPath()%>/ProfileServlet">
                        <i class="fa-solid fa-user"></i> My Profile
                    </a>
                <% } else { %>
                    <h6>Staff Dashboard</h6>

                    <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>

                    <a class="side-link active" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
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
                <% } %>
            </div>

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <h4><i class="fa-solid fa-calendar-check"></i> Manage Appointments</h4>

                    <div class="search-wrap">
                        <input id="apptSearch" type="text" class="search-input" placeholder="Search by ID / Date / IC / Status...">
                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=add" class="btn-add">
                            <i class="fa-solid fa-plus"></i> Add Appointment
                        </a>
                    </div>
                </div>

                <!-- Filter pills row (same neat style) -->
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                    <div class="filter-pills">
                        <div class="pill active" data-status="all" onclick="setFilter('all', this)">
                            <i class="fa-solid fa-list me-1"></i> All
                        </div>
                        <div class="pill" data-status="Confirmed" onclick="setFilter('Confirmed', this)">
                            <i class="fa-solid fa-circle-check me-1"></i> Confirmed
                        </div>
                        <div class="pill" data-status="Pending" onclick="setFilter('Pending', this)">
                            <i class="fa-solid fa-clock me-1"></i> Pending
                        </div>
                        <div class="pill" data-status="Cancelled" onclick="setFilter('Cancelled', this)">
                            <i class="fa-solid fa-circle-xmark me-1"></i> Cancelled
                        </div>
                    </div>

                    <a href="<%=request.getContextPath()%>/AppointmentServlet?action=list" class="action-pill" title="Refresh list">
                        <i class="fa-solid fa-rotate"></i> Refresh
                    </a>
                </div>

                <% if (request.getAttribute("message") != null) { %>
                    <div class="alert alert-success"><%= request.getAttribute("message") %></div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                <% } %>

                <div class="table-wrap">
                    <table class="table table-hover mb-0">
                        <thead>
                        <tr>
                            <th style="width:170px;">Appointment ID</th>
                            <th style="width:140px;">Date</th>
                            <th style="width:120px;">Time</th>
                            <th style="width:180px;">Patient IC</th>
                            <th style="width:150px;">Status</th>
                            <th>Remarks</th>
                            <th style="width:320px; text-align:center;">Actions</th>
                        </tr>
                        </thead>

                        <tbody id="apptBody">
                        <%
                            List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
                            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                            DigitalConsentDAO consentDao = new DigitalConsentDAO();

                            if (appointments != null && !appointments.isEmpty()) {
                                for (Appointment a : appointments) {
                                    String id = a.getAppointmentId() != null ? a.getAppointmentId() : "";
                                    String dateStr = (a.getAppointmentDate() != null) ? df.format(a.getAppointmentDate()) : "";
                                    String timeStr = a.getAppointmentTime() != null ? a.getAppointmentTime() : "";
                                    if (timeStr.length() >= 5) timeStr = timeStr.substring(0,5);

                                    String ic = a.getPatientIc() != null ? a.getPatientIc() : "";
                                    String status = a.getAppointmentStatus() != null ? a.getAppointmentStatus() : "";
                                    String remarks = a.getRemarks() != null ? a.getRemarks() : "";

                                    boolean canEdit = "Confirmed".equalsIgnoreCase(status); // as you requested
                                    boolean showConsentBtn = "Confirmed".equalsIgnoreCase(status) && !consentDao.hasConsentForAppointment(id);

                                    String statusClass =
                                            "Confirmed".equalsIgnoreCase(status) ? "bg-success" :
                                            "Pending".equalsIgnoreCase(status) ? "bg-warning text-dark" :
                                            "Cancelled".equalsIgnoreCase(status) ? "bg-danger" : "bg-secondary";

                                    String searchText = (id + " " + dateStr + " " + timeStr + " " + ic + " " + status + " " + remarks).toLowerCase();
                        %>
                        <tr class="appt-row"
                            data-status="<%= status %>"
                            data-search="<%= searchText %>">

                            <td><strong><%= id %></strong></td>
                            <td><%= dateStr %></td>
                            <td><%= timeStr %></td>
                            <td><%= ic %></td>
                            <td>
                                <span class="badge-status <%= statusClass %>">
                                    <%= status %>
                                </span>
                            </td>
                            <td><%= remarks %></td>

                            <td>
                                <div class="actions">
                                    <a href="<%=request.getContextPath()%>/AppointmentServlet?action=view&appointment_id=<%= id %>"
                                       class="action-pill action-view">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>

                                    <% if (canEdit) { %>
                                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=edit&appointment_id=<%= id %>"
                                           class="action-pill action-edit">
                                            <i class="fa-solid fa-pen"></i> Edit
                                        </a>
                                    <% } %>

                                    <% if (showConsentBtn) { %>
                                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=consent&appointment_id=<%= id %>"
                                           class="action-pill action-consent">
                                            <i class="fa-solid fa-file-signature"></i> Consent
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr id="noDataRow">
                            <td colspan="7" class="text-center py-4">No appointments found.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div id="noMatchRow" class="text-center py-4 text-muted" style="display:none;">
                    No appointments match your filter/search.
                </div>

            </div>
        </div>
    </div>
</div>

<script>
    let activeStatus = "all";

    const searchInput = document.getElementById("apptSearch");
    const body = document.getElementById("apptBody");
    const noMatchRow = document.getElementById("noMatchRow");
    const noDataRow = document.getElementById("noDataRow");

    function setFilter(status, el){
        activeStatus = status;

        document.querySelectorAll(".pill").forEach(p => p.classList.remove("active"));
        el.classList.add("active");

        applyFilterSearch();
    }

    function applyFilterSearch(){
        const q = (searchInput?.value || "").trim().toLowerCase();
        let shown = 0;

        const rows = document.querySelectorAll(".appt-row");
        rows.forEach(row => {
            const rowStatus = (row.getAttribute("data-status") || "").toLowerCase();
            const matchesStatus = (activeStatus === "all") || (rowStatus === activeStatus.toLowerCase());

            const text = (row.getAttribute("data-search") || "");
            const matchesSearch = (!q) || text.includes(q);

            const show = matchesStatus && matchesSearch;
            row.style.display = show ? "" : "none";
            if (show) shown++;
        });

        // only show "no match" if there are rows but filtered to zero
        const hasAnyRow = document.querySelectorAll(".appt-row").length > 0;
        if (noMatchRow) noMatchRow.style.display = (hasAnyRow && shown === 0) ? "block" : "none";

        // noDataRow is for "no appointments at all" (server side), keep it as is
        if (noDataRow) {
            // don't auto hide it here
        }
    }

    if (searchInput) {
        searchInput.addEventListener("input", applyFilterSearch);
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>