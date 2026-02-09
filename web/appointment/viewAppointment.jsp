<%@page import="java.text.SimpleDateFormat"%> 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="beans.Patient" %>
<%@ page import="beans.DigitalConsent" %>
<%@ page import="dao.PatientDAO" %>
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

    // ✅ messageType: book | cancel | edit
    String msgType = (String) request.getAttribute("messageType");
    if (msgType == null || msgType.trim().isEmpty()) msgType = "book";
%>

<%!
    private String escAttr(String s){
        if(s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;")
                .replace("\r","")
                .replace("\n","&#10;");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Appointments</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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
            color: #110f0f;
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
            color: #5a4f1a;
        }
        .action-edit {
            border-color: #e6dfb9;
            color: #5a4f1a;
        }
        .action-consent {
            border-color: #c9d8f2;
            color: #1b4b99;
        }
        .action-cancel {
            border-color: #f0c0c0;
            color: #5a4f1a;
        }

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
        
        .consent-view-btn{
            display:inline-flex;
            align-items:center;
            justify-content:center;

            padding:4px 10px;
            border-radius:999px;

            border:1px solid #cfe0d5;
            background:transparent;
            color:#2a6b48;

            font-size:12px;
            font-weight:700;

            cursor:pointer;
            transition:all .15s ease;
        }

        .consent-view-btn:hover{
            background:#e7f4ec;
        }

        .alert {
            border-radius: 10px;
            margin: 0 6% 12px;
        }

        .modal-content {
            border-radius: 16px;
            border: none;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        .modal-header {
            border-bottom: 2px solid #f0f0f0;
            padding: 20px 24px;
        }
        .modal-title {
            color: #9b2c2c;
            font-weight: 700;
        }
        .modal-body { padding: 24px; }
        .modal-footer {
            border-top: 2px solid #f0f0f0;
            padding: 20px 24px;
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

                    <a class="side-link" href="<%=request.getContextPath()%>/PatientBillingServlet?action=list"">
                        <i class="fa-solid fa-file-invoice-dollar"></i> My Billings
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

                    <a class="side-link active" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                        <i class="fa-solid fa-calendar-check"></i> Appointments
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                        <i class="fa-solid fa-hospital-user"></i> Patients
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
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

                <!-- Filter pills -->
                <div class="filter-pills mb-3">
                    <div class="pill active" data-status="all" onclick="setFilter('all', this)">All</div>
                    <div class="pill" data-status="Confirmed" onclick="setFilter('Confirmed', this)">Confirmed</div>
                    <div class="pill" data-status="Pending" onclick="setFilter('Pending', this)">Pending</div>
                    <div class="pill" data-status="Cancelled" onclick="setFilter('Cancelled', this)">Cancelled</div>
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
                            PatientDAO patientDao = new PatientDAO();
                            SimpleDateFormat signDf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

                            // ✅✅ NEW: sort descending by AppointmentID
                            if (appointments != null && !appointments.isEmpty()) {
                                Collections.sort(appointments, new Comparator<Appointment>() {
                                    @Override
                                    public int compare(Appointment a1, Appointment a2) {
                                        String id1 = (a1 != null && a1.getAppointmentId() != null) ? a1.getAppointmentId() : "";
                                        String id2 = (a2 != null && a2.getAppointmentId() != null) ? a2.getAppointmentId() : "";

                                        int n1 = extractNum(id1);
                                        int n2 = extractNum(id2);

                                        if (n1 != -1 && n2 != -1) {
                                            return Integer.compare(n2, n1); // DESC numeric
                                        }
                                        return id2.compareToIgnoreCase(id1); // DESC fallback
                                    }

                                    private int extractNum(String s) {
                                        try {
                                            String digits = s.replaceAll("\\D+", "");
                                            if (digits == null || digits.isEmpty()) return -1;
                                            return Integer.parseInt(digits);
                                        } catch (Exception e) {
                                            return -1;
                                        }
                                    }
                                });
                            }

                            if (appointments != null && !appointments.isEmpty()) {
                                for (Appointment a : appointments) {

                                    String id = a.getAppointmentId() != null ? a.getAppointmentId() : "";
                                    String dateStr = (a.getAppointmentDate() != null) ? df.format(a.getAppointmentDate()) : "";
                                    String timeStr = a.getAppointmentTime() != null ? a.getAppointmentTime() : "";
                                    if (timeStr.length() >= 5) timeStr = timeStr.substring(0,5);

                                    String ic = a.getPatientIc() != null ? a.getPatientIc() : "";
                                    String status = a.getAppointmentStatus() != null ? a.getAppointmentStatus() : "";
                                    String remarks = a.getRemarks() != null ? a.getRemarks() : "";

                                    boolean isConfirmed = "Confirmed".equalsIgnoreCase(status);
                                    boolean isPending = "Pending".equalsIgnoreCase(status);
                                    boolean isCancelled = "Cancelled".equalsIgnoreCase(status);

                                    // ✅ Updated edit rule: staff can edit Confirmed + Pending
                                    boolean canEdit = (isStaff && (isConfirmed || isPending)) || (isPatient && isConfirmed);

                                    boolean canCancel = !isCancelled && (isStaff || (isPatient && (isPending || isConfirmed)));

                                    String statusClass =
                                        isConfirmed ? "status-pill confirmed" :
                                        isPending ? "status-pill pending" :
                                        isCancelled ? "status-pill cancelled" : "status-pill";

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
                                    Patient p = patientDao.getPatientByIc(ic);
                                    DigitalConsent dc = consentDao.getConsentByAppointmentId(id);
                                    boolean isSigned = (dc != null && dc.getConsentSigndate() != null);
                                    
                                    String pName = (p != null && p.getPatientName() != null) ? p.getPatientName() : "-";
                                    String pPhone = (p != null && p.getPatientPhone() != null) ? p.getPatientPhone() : "-";
                                    String pGuardian = (p != null && p.getPatientGuardian() != null && !p.getPatientGuardian().trim().isEmpty())
                                            ? p.getPatientGuardian() : "-";

                                    String consentContext = (dc != null && dc.getConsentContext() != null) ? dc.getConsentContext() : "";
                                    String signDateStr = (dc != null && dc.getConsentSigndate() != null) ? signDf.format(dc.getConsentSigndate()) : "-";

                                    if (isSigned) {
                                %>
                                        <div style="display:flex;align-items:center;gap:6px;justify-content:center;">
                                            <span class="consent-badge consent-signed">
                                                <i class="fa-solid fa-circle-check me-1"></i> Signed
                                            </span>
                                            <button type="button"
                                                    class="consent-view-btn"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#consentViewModal"
                                                    onclick="openConsentView(this)"
                                                    data-pname="<%= escAttr(pName) %>"
                                                    data-pic="<%= escAttr(ic) %>"
                                                    data-pphone="<%= escAttr(pPhone) %>"
                                                    data-pguardian="<%= escAttr(pGuardian) %>"
                                                    data-ccontext="<%= escAttr(consentContext) %>"
                                                    data-adate="<%= escAttr(dateStr) %>"
                                                    data-atime="<%= escAttr(timeStr) %>"
                                                    data-signdate="<%= escAttr(signDateStr) %>">

                                                <i class="fa fa-info"></i>
                                            </button>
                                        </div>
                                <%
                                    } else {
                                        if (isConfirmed) {
                                            if (isPatient) {
                                %>
                                                <a href="<%=request.getContextPath()%>/AppointmentServlet?action=consent&appointment_id=<%= id %>"
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

                                    <% if (canCancel) { %>
                                        <button type="button" class="action-pill action-cancel"
                                                title="Cancel appointment"
                                                onclick="openCancelModal('<%= id %>', '<%= dateStr %>', '<%= timeStr %>')">
                                            <i class="fa-solid fa-ban"></i> Cancel
                                        </button>
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

<%
    // ✅ Dynamic modal title/subtitle based on msgType
    String modalTitle = "Booking Successful";
    String modalSubtitle = "Your appointment is now listed below.";

    if ("cancel".equalsIgnoreCase(msgType)) {
        modalTitle = "Appointment Cancelled";
        modalSubtitle = "Your appointment has been cancelled.";
    } else if ("edit".equalsIgnoreCase(msgType)) {
        modalTitle = "Edit Successful";
        modalSubtitle = "Your appointment details have been updated.";
    }
%>

<!-- ✅ SUCCESS MODAL (book / cancel / edit) -->
<div class="modal fade" id="successModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-circle-check text-success me-2"></i>
                    <%= modalTitle %>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body">
                <p class="mb-0" style="font-weight:600;">
                    <%= (msg != null ? msg : "") %>
                </p>

                <small class="text-muted d-block mt-2">
                    <%= modalSubtitle %>
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

<!-- CANCEL APPOINTMENT MODAL -->
<div class="modal fade" id="cancelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa-solid fa-triangle-exclamation me-2 text-danger"></i>
                    Cancel Appointment
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <form id="cancelForm" action="<%=request.getContextPath()%>/AppointmentServlet" method="post">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" id="cancelAppointmentId" name="appointment_id" value="">

                <div class="modal-body">
                    <div class="text-center mb-4">
                        <div class="mb-3">
                            <i class="fa-solid fa-calendar-xmark fa-3x text-danger mb-3"></i>
                        </div>
                        <h5 class="fw-bold mb-3">Are you sure you want to cancel this appointment?</h5>

                        <div class="card border-light mb-3">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-12 mb-2">
                                        <strong>Appointment ID:</strong>
                                        <span id="modalAppointmentId" class="badge bg-dark ms-2"></span>
                                    </div>
                                    <div class="col-12 mb-2">
                                        <strong>Date:</strong>
                                        <span id="modalAppointmentDate" class="ms-2"></span>
                                    </div>
                                    <div class="col-12">
                                        <strong>Time:</strong>
                                        <span id="modalAppointmentTime" class="ms-2"></span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="alert alert-warning">
                            <strong>Warning:</strong> This action cannot be undone.
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fa-solid fa-times me-2"></i> Keep Appointment
                    </button>
                    <button type="submit" class="btn btn-danger">
                        <i class="fa-solid fa-ban me-2"></i> Cancel Appointment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ✅ DIGITAL CONSENT VIEW MODAL (SIGNED ONLY) -->
<div class="modal fade" id="consentViewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content" style="border-radius:16px;">
      <div class="modal-header">
        <h5 class="modal-title fw-bold">
          <i class="fa-solid fa-file-signature me-2"></i> Digital Consent (Signed)
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <div class="modal-body">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label fw-semibold">Patient Name</label>
            <input class="form-control" id="mPatientName" readonly>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-semibold">Patient IC</label>
            <input class="form-control" id="mPatientIC" readonly>
          </div>

          <div class="col-md-6">
            <label class="form-label fw-semibold">Patient Phone</label>
            <input class="form-control" id="mPatientPhone" readonly>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-semibold">Guardian Name</label>
            <input class="form-control" id="mGuardian" readonly>
          </div>

          <div class="col-12">
            <label class="form-label fw-semibold">Consent Context</label>
            <textarea class="form-control" id="mConsentContext" rows="3" readonly></textarea>
          </div>

          <div class="col-12">
            <div class="p-3 rounded" style="background:#f8f9fa;border:1px solid #e6e6e6;">
              <p class="mb-2 fw-bold">Consent Statement</p>
              <p class="mb-0" style="line-height:1.6;">
                I, <span style="font-weight:800;" id="mNameInline"></span>
                (IC: <span style="font-weight:800;" id="mIcInline"></span>), hereby confirm that I understand
                the nature of the dental procedure(s) related to this appointment. I acknowledge that all
                dental procedures carry potential risks and outcomes, and I have had the opportunity to ask
                questions regarding my treatment.
                <br><br>
                I voluntarily agree to proceed with the dental appointment scheduled on
                <span style="font-weight:800;" id="mApptDate"></span> at
                <span style="font-weight:800;" id="mApptTime"></span>.
              </p>
            </div>
          </div>

          <div class="col-12">
            <div class="alert alert-success mb-0">
              <i class="fa-solid fa-circle-check me-1"></i>
              <b>Signed On:</b> <span id="mSignDate"></span>
            </div>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius:999px;">
          Close
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

    function openCancelModal(appointmentId, date, time) {
        document.getElementById('cancelAppointmentId').value = appointmentId;
        document.getElementById('modalAppointmentId').textContent = appointmentId;
        document.getElementById('modalAppointmentDate').textContent = date;
        document.getElementById('modalAppointmentTime').textContent = time;

        const cancelModal = new bootstrap.Modal(document.getElementById('cancelModal'));
        cancelModal.show();
    }
</script>

<script>
function openConsentView(btn){
    const get = (k) => btn.getAttribute("data-" + k) || "";

    const name = get("pname");
    const ic = get("pic");
    const phone = get("pphone");
    const guardian = get("pguardian");
    const context = get("ccontext");
    const adate = get("adate");
    const atime = get("atime");
    const signdate = get("signdate");

    document.getElementById("mPatientName").value = name;
    document.getElementById("mPatientIC").value = ic;
    document.getElementById("mPatientPhone").value = phone;
    document.getElementById("mGuardian").value = guardian;

    document.getElementById("mConsentContext").value = context;

    document.getElementById("mNameInline").textContent = name;
    document.getElementById("mIcInline").textContent = ic;
    document.getElementById("mApptDate").textContent = adate;
    document.getElementById("mApptTime").textContent = atime;

    document.getElementById("mSignDate").textContent = signdate;
}
</script>

</body>
</html>
