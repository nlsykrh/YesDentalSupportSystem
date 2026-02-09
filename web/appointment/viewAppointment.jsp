<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="beans.DigitalConsent" %>
<%@ page import="dao.DigitalConsentDAO" %>

<%
    // ===== Session / Role detect =====
    String patientName = (String) session.getAttribute("patientName");
    String patientId   = (String) session.getAttribute("patientId"); // PATIENT_IC in your system

    String staffName   = (String) session.getAttribute("staffName");
    String staffId     = (String) session.getAttribute("staffId");

    boolean isPatient  = (patientId != null);
    boolean isStaff    = (staffId != null);

    if (!isPatient && !isStaff) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = isStaff ? staffName : patientName;

    String msg = (String) request.getAttribute("message");
    String err = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Appointments</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- ✅ Chart.js for hardcoded chart -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        :root {
            --green-dark: #2f4a34;
            --green-deep: #264232;
            --gold-soft: #d7d1a6;
        }
        body {
            overflow: hidden;
            margin: 0;
            min-height: 100vh;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
            font-family: "Segoe UI", sans-serif;
        }
        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.38);
            backdrop-filter: blur(1.5px);
        }
        .top-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 60px 8px;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .brand img { height: 48px; }
        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: var(--green-dark);
            font-family: "Times New Roman", serif;
        }
        .user-area {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f3f3f3;
            padding: 6px 12px;
            border-radius: 18px;
            font-size: 13px;
            color: #2f3a34;
        }
        .logout-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            border-radius: 999px;
            background: #c96a6a;
            color: #fff;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            box-shadow: 0 6px 14px rgba(0,0,0,0.18);
            transition: all .2s ease;
            border: none;
            cursor: pointer;
        }
        .logout-btn:hover {
            background: #b95a5a;
            transform: translateY(-1px);
        }

        .layout-wrap {
            width: 100%;
            padding: 30px 60px 40px;
            height: calc(100vh - 100px);
            overflow: hidden;
        }
        .layout{
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            height: 100%;
            align-items: stretch;
        }
        .sidebar{
            background: var(--green-deep);
            color: #fff;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }
        .sidebar h6{
            font-size: 20px;
            margin-bottom: 12px;
            color: #fff;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,.25);
        }
        .side-link {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #fff;
            padding: 9px 10px;
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .side-link i{
            width: 18px;
            text-align: center;
            opacity: .95;
        }
        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, .14);
            color: #ffe69b;
        }

        .card-panel{
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .panel-header {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
            align-items: center;
        }
        .panel-header h4 {
            margin: 0;
            font-weight: 700;
            color: #2f2f2f;
        }
        .search-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .search-input {
            border: 1px solid #d7ddd9;
            border-radius: 18px;
            padding: 6px 12px;
            font-size: 13px;
            width: 220px;
        }
        .btn-add {
            background: var(--gold-soft);
            color: #3a382f;
            border: none;
            border-radius: 18px;
            padding: 6px 14px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .filter-pills {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .pill {
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            border-radius: 999px;
            padding: 7px 12px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            user-select: none;
            transition: all 0.2s ease;
        }
        .pill.active {
            background: rgba(215, 209, 166, 0.55);
            border-color: #e6dfb9;
            color: #3a382f;
        }
        .pill:hover:not(.active) {
            background: #f5f5f5;
        }

        /* ✅ SUMMARY CARD + CHART */
        .summary-card{
            border: 1px solid #d9d9d9;
            border-radius: 14px;
            background: #fff;
            padding: 14px 16px;
            margin-bottom: 14px;
        }
        .summary-top{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap:12px;
            flex-wrap:wrap;
            margin-bottom: 10px;
        }
        .summary-title{
            font-weight:800;
            color:#2f2f2f;
            display:flex;
            align-items:center;
            gap:8px;
        }
        .summary-tabs{
            display:flex;
            gap:8px;
            flex-wrap:wrap;
        }
        .tab-btn{
            border: 1px solid #d9d9d9;
            background:#fff;
            border-radius:999px;
            padding:6px 12px;
            font-size: 12px;
            font-weight: 700;
            cursor:pointer;
            user-select:none;
        }
        .tab-btn.active{
            background: rgba(215, 209, 166, 0.55);
            border-color:#e6dfb9;
            color:#3a382f;
        }
        .summary-grid{
            display:grid;
            grid-template-columns: repeat(4, minmax(140px, 1fr));
            gap: 10px;
            margin-bottom: 12px;
        }
        .kpi{
            border: 1px solid #ececec;
            border-radius: 12px;
            padding: 10px 12px;
            background: #fafafa;
        }
        .kpi .label{
            font-size: 12px;
            color:#6b7280;
            font-weight:700;
        }
        .kpi .value{
            font-size: 20px;
            font-weight: 900;
            color:#264232;
            margin-top: 2px;
        }
        .chart-wrap{
            border:1px solid #efefef;
            border-radius: 12px;
            padding: 10px;
            background:#ffffff;
            height: 260px;
        }
        .chart-wrap canvas{
            width:100% !important;
            height:100% !important;
        }

        .table-wrap{
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
            overflow: auto;
        }
        .table thead { background: #dcdcdc; }
        .table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .4px;
            color: #2b2b2b;
            position: sticky;
            top: 0;
            background: #dcdcdc;
            z-index: 5;
            padding: 12px 14px;
        }
        .table tbody td {
            font-size: 14px;
            vertical-align: middle;
            padding: 12px 14px;
        }
        .status-pill {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            background: #e7f4ec;
            color: #2a6b48;
            display: inline-block;
            font-weight: 600;
        }
        .status-pill.pending {
            background: #fff8e6;
            color: #8a6d3b;
        }
        .status-pill.cancelled {
            background: #f6e6e6;
            color: #9b2c2c;
        }

        .actions {
            display: flex;
            gap: 8px;
            justify-content: center;
            flex-wrap: nowrap;
        }
        .action-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
            white-space: nowrap;
            min-width: 70px;
            justify-content: center;
            cursor: pointer;
        }
        .action-pill i {
            font-size: 12px;
            width: 14px;
            text-align: center;
        }
        .action-pill:hover{
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }
        .action-view {
            border-color: #cfe0d5;
            color: #264232;
        }
        .action-edit {
            border-color: #e6dfb9;
            color: #5a4f1a;
        }
        .action-consent {
            border-color: #c9d8f2;
            color: #1b4b99;
        }

        /* Consent badge styling */
        .consent-badge {
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 700;
            display: inline-block;
        }
        .consent-signed { background: #e7f4ec; color: #2a6b48; }
        .consent-unsigned { background: #fff8e6; color: #8a6d3b; }
        .consent-pending { background: #e0f2fe; color: #0369a1; }
        .consent-cancelled { background: #f6e6e6; color: #9b2c2c; }
        .consent-na { background: #f3f4f6; color: #6b7280; }

        .alert {
            border-radius: 10px;
            margin: 0 6% 12px;
        }

        @media (max-width: 992px) {
            body { overflow: auto; }
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; height: auto; overflow: visible; }
            .top-nav { padding: 18px 24px 8px; flex-wrap: wrap; gap: 10px; }
            .actions { justify-content: flex-start; }
            .search-input { width: 180px; }
            .card-panel { height: auto; overflow: visible; }
            .table-wrap { overflow: visible; }
            .summary-grid{ grid-template-columns: 1fr 1fr; }
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
                <span><%= displayName != null ? displayName : "-" %></span>
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
                        
                    <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
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
                    <h4>Manage Appointments</h4>
                    <div class="search-wrap">
                        <input id="apptSearch" type="text" class="search-input" placeholder="Search by ID / Date / IC / Status...">
                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=add" class="btn-add">
                            <i class="fa-solid fa-plus"></i>
                            <%= isStaff ? "Book for Patient" : "Add Appointment" %>
                        </a>
                    </div>
                </div>

                <!-- ✅ HARD-CODED SUMMARY + CHART -->
                <div class="summary-card">
                    <div class="summary-top">
                        <div class="summary-title">
                            <i class="fa-solid fa-chart-column"></i>
                            Appointment Summary
                        </div>

                        <div class="summary-tabs">
                            <button type="button" class="tab-btn active" onclick="switchSummary('day', this)">Day</button>
                            <button type="button" class="tab-btn" onclick="switchSummary('week', this)">Week</button>
                            <button type="button" class="tab-btn" onclick="switchSummary('month', this)">Month</button>
                            <button type="button" class="tab-btn" onclick="switchSummary('year', this)">Year</button>
                        </div>
                    </div>

                    <div class="summary-grid">
                        <div class="kpi">
                            <div class="label">Total</div>
                            <div class="value" id="kpiTotal">0</div>
                        </div>
                        <div class="kpi">
                            <div class="label">Confirmed</div>
                            <div class="value" id="kpiConfirmed">0</div>
                        </div>
                        <div class="kpi">
                            <div class="label">Pending</div>
                            <div class="value" id="kpiPending">0</div>
                        </div>
                        <div class="kpi">
                            <div class="label">Cancelled</div>
                            <div class="value" id="kpiCancelled">0</div>
                        </div>
                    </div>

                    <div class="chart-wrap">
                        <canvas id="apptChart"></canvas>
                    </div>
                </div>

                <!-- Error inline -->
                <% if (err != null && !err.trim().isEmpty()) { %>
                    <div class="alert alert-danger"><%= err %></div>
                <% } %>

                <div class="table-wrap">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th style="width:150px;">Appointment ID</th>
                            <th style="width:120px;">Date</th>
                            <th style="width:100px;">Time</th>
                            <th style="width:160px;">Patient IC</th>
                            <th style="width:120px;">Status</th>
                            <th style="width:150px;">Digital Consent</th>
                            <th style="width:200px; text-align:center;">Actions</th>
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

                                    boolean canEdit = "Confirmed".equalsIgnoreCase(status);

                                    String statusClass =
                                        "Confirmed".equalsIgnoreCase(status) ? "status-pill confirmed" :
                                        "Pending".equalsIgnoreCase(status) ? "status-pill pending" :
                                        "Cancelled".equalsIgnoreCase(status) ? "status-pill cancelled" : "status-pill";

                                    // Consent for search keywords
                                    DigitalConsent dcSearch = consentDao.getConsentByAppointmentId(id);
                                    boolean signedSearch = (dcSearch != null && dcSearch.getConsentSigndate() != null);
                                    String consentSearch = signedSearch ? "signed" : "unsigned";

                                    String searchText = (id + " " + dateStr + " " + timeStr + " " + ic + " " + status + " " + remarks + " " + consentSearch).toLowerCase();
                        %>
                        <tr class="appt-row" data-status="<%= status %>" data-search="<%= searchText %>">
                            <td><strong><%= id %></strong></td>
                            <td><%= dateStr %></td>
                            <td><%= timeStr %></td>
                            <td><%= ic %></td>

                            <td>
                                <span class="<%= statusClass %>"><%= status %></span>
                            </td>

                            <!-- DIGITAL CONSENT COLUMN -->
                            <td>
                                <%
                                    DigitalConsent dc = consentDao.getConsentByAppointmentId(id);
                                    boolean isSigned = (dc != null && dc.getConsentSigndate() != null);

                                    boolean isConfirmed = "Confirmed".equalsIgnoreCase(status);
                                    boolean isPending   = "Pending".equalsIgnoreCase(status);
                                    boolean isCancelled = "Cancelled".equalsIgnoreCase(status);

                                    if (isSigned) {
                                %>
                                        <span class="consent-badge consent-signed">
                                            <i class="fa-solid fa-circle-check me-1"></i> Signed
                                        </span>
                                <%
                                    } else {
                                        if (isConfirmed) {
                                            if (isPatient) {
                                %>
                                                <a href="<%=request.getContextPath()%>/appointment/digitalConsent.jsp?appointment_id=<%= id %>"
                                                   class="action-pill action-consent" style="min-width: 80px;">
                                                    <i class="fa-solid fa-file-signature"></i> Sign
                                                </a>
                                <%
                                            } else {
                                %>
                                                <span class="consent-badge consent-unsigned">
                                                    <i class="fa-solid fa-clock me-1"></i> Unsigned
                                                </span>
                                <%
                                            }
                                        } else if (isPending) {
                                %>
                                            <span class="consent-badge consent-pending">
                                                <i class="fa-solid fa-hourglass-half me-1"></i> Pending
                                            </span>
                                <%
                                        } else if (isCancelled) {
                                %>
                                            <span class="consent-badge consent-cancelled">
                                                <i class="fa-solid fa-ban me-1"></i> Cancelled
                                            </span>
                                <%
                                        } else {
                                %>
                                            <span class="consent-badge consent-na">
                                                <i class="fa-solid fa-circle-info me-1"></i> N/A
                                            </span>
                                <%
                                        }
                                    }
                                %>
                            </td>

                            <!-- ACTIONS -->
                            <td>
                                <div class="actions">
                                    <a href="<%=request.getContextPath()%>/AppointmentServlet?action=view&appointment_id=<%= id %>"
                                       class="action-pill action-view" title="View appointment">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>

                                    <% if (canEdit) { %>
                                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=edit&appointment_id=<%= id %>"
                                           class="action-pill action-edit" title="Edit appointment">
                                            <i class="fa-solid fa-pen"></i> Edit
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
                            <td colspan="7" class="text-center">No appointments found.</td>
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

<!-- SUCCESS MODAL (shows after booking) -->
<div class="modal fade" id="successModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-circle-check text-success me-2"></i>
                    Booking Successful
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <p class="mb-0" style="font-weight:600;">
                    <%= (msg != null ? msg : "") %>
                </p>
                <small class="text-muted d-block mt-2">
                    Your appointment is now listed below.
                </small>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-success" data-bs-dismiss="modal" style="border-radius:999px;">
                    OK
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    let activeStatus = "all";

    const searchInput = document.getElementById("apptSearch");
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

        const hasAnyRow = document.querySelectorAll(".appt-row").length > 0;
        if (noMatchRow) noMatchRow.style.display = (hasAnyRow && shown === 0) ? "block" : "none";
    }

    if (searchInput) {
        searchInput.addEventListener("input", applyFilterSearch);
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Auto-show success modal when message exists
    document.addEventListener("DOMContentLoaded", function () {
        <% if (msg != null && !msg.trim().isEmpty()) { %>
            const modalEl = document.getElementById("successModal");
            if (modalEl) {
                const modal = new bootstrap.Modal(modalEl);
                modal.show();
            }
        <% } %>
    });
</script>

<!-- ✅ HARD-CODED CHART SCRIPT -->
<script>
/* ===============================
   HARDCODED DATASETS (EDIT HERE)
   =============================== */
const summaryData = {
  day: {
    title: "Total Appointments (Daily)",
    labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    totals:  [2, 3, 4, 1, 5, 2, 0],
    kpi: { total: 17, confirmed: 10, pending: 5, cancelled: 2 }
  },
  week: {
    title: "Total Appointments (Weekly)",
    labels: ["Week 1", "Week 2", "Week 3", "Week 4"],
    totals:  [8, 12, 9, 6],
    kpi: { total: 35, confirmed: 20, pending: 10, cancelled: 5 }
  },
  month: {
    title: "Total Appointments (Monthly)",
    labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    totals:  [10, 14, 18, 12, 9, 7, 11, 13, 8, 6, 5, 4],
    kpi: { total: 117, confirmed: 70, pending: 32, cancelled: 15 }
  },
  year: {
    title: "Total Appointments (Yearly)",
    labels: ["2023", "2024", "2025", "2026"],
    totals:  [90, 120, 140, 55],
    kpi: { total: 405, confirmed: 260, pending: 110, cancelled: 35 }
  }
};

let apptChart = null;

function setActiveTab(btn){
  document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
}

function updateKPI(kpi){
  document.getElementById("kpiTotal").textContent = kpi.total;
  document.getElementById("kpiConfirmed").textContent = kpi.confirmed;
  document.getElementById("kpiPending").textContent = kpi.pending;
  document.getElementById("kpiCancelled").textContent = kpi.cancelled;
}

function renderChart(mode){
  const d = summaryData[mode];
  if (!d) return;

  updateKPI(d.kpi);

  const canvas = document.getElementById("apptChart");
  if (!canvas) return;

  const ctx = canvas.getContext("2d");

  if (apptChart) apptChart.destroy();

  apptChart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: d.labels,
      datasets: [{
        label: d.title,
        data: d.totals,
        borderWidth: 1,
        borderRadius: 10
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        title: {
          display: true,
          text: d.title,
          font: { size: 14, weight: "bold" }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { precision: 0 }
        }
      }
    }
  });
}

function switchSummary(mode, btn){
  setActiveTab(btn);
  renderChart(mode);
}

document.addEventListener("DOMContentLoaded", function(){
  renderChart("day"); // default
});
</script>

</body>
</html>
