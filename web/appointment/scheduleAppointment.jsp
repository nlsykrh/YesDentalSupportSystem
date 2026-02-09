<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.TreatmentDAO" %>
<%@ page import="beans.Treatment" %>
<%@ page import="java.util.List" %>

<%
    // ===== ROLE SAFE SESSION CHECK =====
    String patientName = (String) session.getAttribute("patientName");
    String patientId   = (String) session.getAttribute("patientId");  // PATIENT_IC

    String staffName = (String) session.getAttribute("staffName");
    String staffId   = (String) session.getAttribute("staffId");

    boolean isPatient = (patientId != null);
    boolean isStaff   = (staffId != null);

    if (!isPatient && !isStaff) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = isStaff ? staffName : patientName;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Schedule Appointment</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <!-- Flatpickr -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

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

        /* ===== Card panel styling ===== */
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
        .content-scroll {
            flex: 1;
            min-height: 0;
            overflow: auto;
            padding-right: 4px;
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
        .panel-sub {
            margin: 6px 0 0;
            font-size: 0.95rem;
            color: #6b7280;
            font-weight: 500;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 18px;
            border: 1px solid #d7ddd9;
            background: #fff;
            color: #3a382f;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            transition: transform .08s ease, box-shadow .12s ease;
        }
        .btn-back:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }

        /* ===== Form styling ===== */
        .form-wrap {
            background: #fff;
            border: 1px solid #d9d9d9;
            border-radius: 14px;
            box-shadow: 0 10px 18px rgba(0, 0, 0, 0.06);
            padding: 20px;
        }
        .section-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--green-dark);
            margin-bottom: 16px;
            padding-bottom: 8px;
            border-bottom: 2px solid var(--gold-soft);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .form-label {
            font-weight: 700;
            color: var(--green-dark);
            margin-bottom: 6px;
            font-size: 0.95rem;
        }
        .input-group-text {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            color: var(--green-dark);
            font-weight: 600;
        }
        .form-control,
        .form-select {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 10px 12px;
            font-size: 0.95rem;
            transition: all 0.2s ease;
        }
        .form-control:focus,
        .form-select:focus {
            border-color: var(--green-deep);
            box-shadow: 0 0 0 3px rgba(38, 66, 50, 0.1);
        }

        /* ===== Calendar styling ===== */
        .calendar-card {
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            height: 100%;
        }
        /* ===== Improved Calendar styling ===== */
        .flatpickr-calendar-container {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .flatpickr-calendar {
            width: 100% !important;
            max-width: 100% !important;
            box-shadow: none !important;
            border: none !important;
            margin: 0 !important;
            padding: 0 !important;
            background: transparent !important;
        }
        .flatpickr-innerContainer {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .flatpickr-rContainer {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .flatpickr-days {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .dayContainer {
            width: 100% !important;
            max-width: 100% !important;
            min-width: 100% !important;
            padding: 0 !important;
            margin: 0 !important;
        }
        .flatpickr-day {
            height: 40px !important;
            line-height: 40px !important;
            max-width: 100% !important;
            margin: 0 !important;
        }
        .flatpickr-months {
            background: #f8f9fa !important;
            border-radius: 10px 10px 0 0 !important;
            padding: 12px 0 !important;
            border-bottom: 1px solid #e5e7eb !important;
            margin-bottom: 8px !important;
        }
        .flatpickr-current-month {
            font-size: 1.1rem !important;
            font-weight: 700 !important;
            color: var(--green-dark) !important;
        }
        .flatpickr-weekdays {
            background: #f1f5f9 !important;
            padding: 8px 0 !important;
            margin-bottom: 4px !important;
        }
        .flatpickr-weekday {
            font-weight: 700 !important;
            color: #4b5563 !important;
            font-size: 0.9rem !important;
        }
        .flatpickr-day {
            font-weight: 500 !important;
            color: #374151 !important;
            border-radius: 6px !important;
            border: 1px solid transparent !important;
            font-size: 0.9rem !important;
        }
        .flatpickr-day:hover {
            background: #f3f4f6 !important;
            border-color: #d1d5db !important;
        }
        .flatpickr-day.selected {
            background: var(--gold-soft) !important;
            border-color: var(--green-deep) !important;
            color: var(--green-dark) !important;
            font-weight: 700 !important;
        }
        .flatpickr-day.today {
            border: 2px solid var(--green-dark) !important;
            background: transparent !important;
        }
        .flatpickr-day.flatpickr-disabled {
            background: #f1f5f9 !important;
            color: #cbd5e1 !important;
            cursor: not-allowed !important;
            border-color: #e5e7eb !important;
        }

        /* ===== Time slots ===== */
        .time-slots-card {
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            height: 100%;
            padding: 20px;
        }
        .time-slots-header {
            font-weight: 700;
            color: var(--green-dark);
            margin-bottom: 16px;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .time-slots-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
            margin-bottom: 20px;
        }
        .time-slot {
            padding: 14px 12px;
            text-align: center;
            border-radius: 10px;
            background: #fff;
            border: 2px solid #e5e7eb;
            cursor: pointer;
            font-weight: 600;
            color: #374151;
            transition: all 0.2s ease;
            user-select: none;
        }
        .time-slot:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
            border-color: var(--green-deep);
            background: #f8fafc;
        }
        .time-slot.selected {
            background: var(--gold-soft);
            border-color: var(--green-dark);
            color: var(--green-dark);
            font-weight: 700;
            box-shadow: 0 4px 8px rgba(39, 66, 50, 0.15);
        }
        .time-empty {
            grid-column: 1 / -1;
            padding: 24px;
            border-radius: 12px;
            background: #f8fafc;
            border: 2px dashed #cbd5e1;
            color: #64748b;
            font-weight: 500;
            text-align: center;
        }
        .selected-time-display {
            padding: 16px;
            background: #f8fafc;
            border-radius: 10px;
            border: 1px solid #e5e7eb;
            margin-top: 20px;
        }
        .selected-time-text {
            font-weight: 600;
            color: var(--green-dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .date-selection-info {
            padding: 12px 16px;
            background: #f8fafc;
            border-radius: 10px;
            border: 1px solid #e5e7eb;
            margin-top: 15px;
        }
        .selected-date-display {
            font-weight: 600;
            color: var(--green-dark);
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
        }
        .selected-date-text {
            font-weight: 700;
            color: var(--green-deep);
        }

        /* ===== Treatment checkbox styling ===== */
        .treatment-box {
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            background: #fff;
            padding: 16px;
            max-height: 300px;
            overflow-y: auto;
        }
        .treatment-item {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 12px;
            border-radius: 8px;
            transition: background 0.2s ease;
            cursor: pointer;
        }
        .treatment-item:hover {
            background: #f8fafc;
        }
        .treatment-item.selected {
            background: rgba(215, 209, 166, 0.2);
            border: 1px solid var(--gold-soft);
        }
        .treatment-check {
            margin-top: 3px;
        }
        .treatment-details {
            flex: 1;
        }
        .treatment-title {
            font-weight: 700;
            color: var(--green-dark);
            margin: 0;
            font-size: 0.95rem;
        }
        .treatment-desc {
            color: #6b7280;
            font-size: 0.85rem;
            margin: 4px 0;
            line-height: 1.4;
        }
        .treatment-price {
            font-weight: 700;
            color: #2a6b48;
            font-size: 0.85rem;
        }

        /* ===== Alert styling ===== */
        .alert {
            border-radius: 10px;
            border: none;
            padding: 16px 20px;
            margin-bottom: 16px;
        }
        .alert-success {
            background: #e7f4ec;
            color: #2a6b48;
            border-left: 4px solid #2a6b48;
        }
        .alert-danger {
            background: #f6e6e6;
            color: #9b2c2c;
            border-left: 4px solid #9b2c2c;
        }
        .alert-info {
            background: #e0f2fe;
            color: #0369a1;
            border-left: 4px solid #0369a1;
        }
        .alert-warning {
            background: #fff8e6;
            color: #8a6d3b;
            border-left: 4px solid #8a6d3b;
        }

        /* ===== Button styling ===== */
        .btn-pill {
            border-radius: 50px;
            padding: 10px 24px;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.2s ease;
        }
        .btn-success {
            background: var(--green-dark);
            border: 2px solid var(--green-dark);
        }
        .btn-success:hover {
            background: var(--green-deep);
            border-color: var(--green-deep);
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(39, 66, 50, 0.2);
        }
        .btn-outline-secondary {
            border: 2px solid #6c757d;
            color: #6c757d;
        }
        .btn-outline-secondary:hover {
            background: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        .action-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
        }

        /* ===== Verification badge ===== */
        .verification-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 700;
        }
        .verified {
            background: #e7f4ec;
            color: #2a6b48;
        }
        .not-verified {
            background: #fff8e6;
            color: #8a6d3b;
        }

        /* ===== Responsive ===== */
        @media (max-width: 992px) {
            body {
                overflow: auto;
            }
            .layout {
                grid-template-columns: 1fr;
            }
            .layout-wrap {
                padding: 20px;
                height: auto;
                overflow: visible;
            }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .card-panel {
                height: auto;
                overflow: visible;
            }
            .content-scroll {
                overflow: visible;
            }
            .calendar-time-row {
                flex-direction: column;
            }
            .time-slots-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 768px) {
            .time-slots-grid {
                grid-template-columns: 1fr;
            }
        }
        @media (max-width: 576px) {
            .btn-pill {
                padding: 8px 20px;
                font-size: 0.9rem;
            }
            .action-buttons {
                flex-direction: column;
                width: 100%;
            }
            .action-buttons .btn {
                width: 100%;
                text-align: center;
            }
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

                <div class="content-scroll">
                    <div class="panel-header">
                        <div>
                            <h4><i class="fa-solid fa-calendar-plus"></i> Schedule Appointment</h4>
                            <% if (isPatient) { %>
                                <p class="panel-sub">
                                    <i class="fa-solid fa-id-card"></i> IC: <strong><%= patientId %></strong>
                                </p>
                            <% } else { %>
                                <p class="panel-sub">
                                    <i class="fa-solid fa-id-card"></i> Enter patient IC to book appointment
                                </p>
                            <% } %>
                        </div>
                        <a href="<%=request.getContextPath()%>/AppointmentServlet?action=list" class="btn-back">
                            <i class="fa-solid fa-arrow-left"></i> Back
                        </a>
                    </div>

                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <%= request.getAttribute("error") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>
                    <% if (request.getAttribute("message") != null) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <%= request.getAttribute("message") %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    <% } %>

                    <form action="<%= request.getContextPath() %>/AppointmentServlet" method="post" id="scheduleForm">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="appointment_time" id="appointmentTimeHidden">

                        <div class="form-wrap mb-3 p-4">
                            <div class="section-title mb-4">
                                <i class="fa-solid fa-clipboard-list"></i> Appointment Details
                            </div>

                            <!-- Patient IC for staff -->
                            <% if (isStaff) { %>
                            <div class="mb-4">
                                <label class="form-label fw-bold">
                                    Patient IC <span class="text-danger">*</span>
                                    <span id="verificationStatus" class="verification-badge not-verified ms-2" style="display: none;">
                                        <i class="fa-solid fa-times-circle"></i> Not Verified
                                    </span>
                                </label>
                                <div class="input-group" style="max-width: 360px;">
                                    <span class="input-group-text"><i class="fa-solid fa-id-card"></i></span>
                                    <input type="text" class="form-control" name="patient_ic" id="patientIcInput" 
                                           placeholder="Enter Patient IC" required>
                                    <button type="button" class="btn btn-outline-secondary" onclick="verifyPatientIC()">
                                        <i class="fa-solid fa-check"></i> Verify
                                    </button>
                                </div>
                                <small id="icVerifyMsg" class="text-muted d-block mt-2">
                                    Enter patient IC and click Verify to check if patient exists
                                </small>
                                <input type="hidden" id="icVerified" value="false">
                            </div>
                            <% } else { %>
                                <input type="hidden" name="patient_ic" value="<%= patientId %>">
                            <% } %>

                            <!-- Date Selection -->
                            <div class="mb-4">
                                <label class="form-label fw-bold">Appointment Date <span class="text-danger">*</span></label>
                                <div class="input-group" style="max-width: 300px;">
                                    <span class="input-group-text"><i class="fa-solid fa-calendar-days"></i></span>
                                    <input type="text" class="form-control" id="appointmentDate"
                                           name="appointment_date" placeholder="Select date"
                                           value="<%= request.getParameter("appointment_date") != null ? request.getParameter("appointment_date") : "" %>"
                                           required readonly>
                                </div>
                                <small class="text-muted d-block mt-1">
                                    Select a date from the calendar below
                                </small>
                            </div>

                            <!-- Calendar and Time Slots -->
                            <div class="row calendar-time-row g-4 mb-4">
                                <!-- Calendar Column -->
                                <div class="col-lg-7">
                                    <div class="calendar-card p-3">
                                        <div id="calendarWrap" class="flatpickr-calendar-container" 
                                             style="width: 100%; overflow: hidden; margin: 0; padding: 0;">
                                        </div>
                                        
                                        <!-- Date Selection Info -->
                                        <div class="date-selection-info mt-3">
                                            <div class="selected-date-display">
                                                <i class="fa-solid fa-calendar-check"></i>
                                                <span>Selected Date:</span>
                                                <span id="selectedDateText" class="selected-date-text">None</span>
                                            </div>
                                            <small class="text-muted">
                                                <i class="fa-solid fa-info-circle me-1"></i>
                                                Grey dates = fully booked (all slots confirmed)
                                            </small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Time Slots Column -->
                                <div class="col-lg-5">
                                    <div class="time-slots-card">
                                        <div class="time-slots-header">
                                            <i class="fa-solid fa-clock"></i>
                                            Available Time Slots
                                        </div>
                                        
                                        <div id="timeSlotsContainer" class="time-slots-grid"></div>
                                        
                                        <!-- Selected Time Display -->
                                        <div id="selectedTimeDisplay" class="selected-time-display" style="display: none;">
                                            <div class="selected-time-text">
                                                <i class="fa-solid fa-check-circle text-success"></i>
                                                <span>Selected Time:</span>
                                                <span id="selectedTimeText" class="selected-date-text"></span>
                                            </div>
                                        </div>
                                        
                                        <small class="text-muted d-block mt-3">
                                            <i class="fa-solid fa-lightbulb me-1"></i>
                                            Click on a time slot to select your preferred appointment time
                                        </small>
                                    </div>
                                </div>
                            </div>

                            <!-- Treatments and Remarks -->
                            <div class="row g-4">
                                <div class="col-lg-6">
                                    <div class="mb-4">
                                        <label class="form-label fw-bold">
                                            Treatment Required <span class="text-danger">*</span>
                                            <small class="text-muted">(Select one or more)</small>
                                        </label>
                                        
                                        <div class="treatment-box">
                                            <%
                                                TreatmentDAO treatmentDAO = new TreatmentDAO();
                                                List<Treatment> treatments = treatmentDAO.getAllTreatments();
                                                if (treatments != null && !treatments.isEmpty()) {
                                                    for (Treatment t : treatments) {
                                            %>
                                            <div class="treatment-item" onclick="toggleTreatment(this)">
                                                <div class="treatment-check">
                                                    <input type="checkbox" class="form-check-input" 
                                                           name="treatment_ids" value="<%= t.getTreatmentId() %>"
                                                           id="treatment_<%= t.getTreatmentId() %>">
                                                </div>
                                                <div class="treatment-details">
                                                    <div class="treatment-title">
                                                        <%= t.getTreatmentId() %> - <%= t.getTreatmentName() %>
                                                    </div>
                                                    <div class="treatment-desc">
                                                        <%= (t.getTreatmentDesc() != null && !t.getTreatmentDesc().trim().isEmpty())
                                                                ? t.getTreatmentDesc()
                                                                : "No description available" %>
                                                    </div>
                                                    <div class="treatment-price">
                                                        RM <%= String.format("%.2f", t.getTreatmentPrice()) %>
                                                    </div>
                                                </div>
                                            </div>
                                            <%
                                                    }
                                                } else {
                                            %>
                                            <div class="text-center text-muted py-4">
                                                <i class="fa-solid fa-clipboard-list fa-2x mb-2"></i>
                                                <p>No treatments available</p>
                                            </div>
                                            <% } %>
                                        </div>
                                        
                                        <small class="text-muted d-block mt-2">
                                            <i class="fa-solid fa-info-circle me-1"></i>
                                            Select one or more treatments for this appointment
                                        </small>
                                    </div>
                                </div>
                                
                                <div class="col-lg-6">
                                    <div class="mb-4">
                                        <label class="form-label fw-bold">Remarks</label>
                                        <div class="input-group">
                                            <span class="input-group-text"><i class="fa-solid fa-comment-dots"></i></span>
                                            <textarea class="form-control" name="remarks" rows="3"
                                                      placeholder="Any special notes or requirements for your appointment"><%= request.getParameter("remarks") != null ? request.getParameter("remarks") : "" %></textarea>
                                        </div>
                                        <small class="text-muted">Optional: Add any notes about your dental needs</small>
                                    </div>
                                </div>
                            </div>

                            <div class="alert alert-info mt-4 mb-0">
                                <strong><i class="fa-solid fa-lightbulb me-2"></i>Note:</strong>
                                Fully booked dates are disabled. Confirmed slots cannot be booked again.
                            </div>
                        </div>

                        <!-- Action buttons -->
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mt-4 pt-3 border-top">
                            <div>
                                <a href="<%=request.getContextPath()%>/AppointmentServlet?action=list"
                                   class="btn btn-outline-secondary btn-pill px-4">
                                    <i class="fa-solid fa-xmark me-2"></i> Cancel
                                </a>
                            </div>
                            <div>
                                <button type="submit" class="btn btn-success btn-pill px-4">
                                    <i class="fa-solid fa-calendar-check me-2"></i> Schedule Appointment
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const ALL_SLOTS = [
        {value: "09:00", label: "09:00 AM"},
        {value: "10:00", label: "10:00 AM"},
        {value: "11:00", label: "11:00 AM"},
        {value: "14:00", label: "02:00 PM"},
        {value: "15:00", label: "03:00 PM"},
        {value: "16:00", label: "04:00 PM"}
    ];

    async function verifyPatientIC() {
        const icInput = document.getElementById("patientIcInput");
        const msg = document.getElementById("icVerifyMsg");
        const verifiedFlag = document.getElementById("icVerified");
        const statusBadge = document.getElementById("verificationStatus");

        if (!icInput) return;

        const ic = (icInput.value || "").trim();
        if (!ic) {
            msg.innerHTML = "<span class='text-danger fw-semibold'>Please enter Patient IC.</span>";
            verifiedFlag.value = "false";
            statusBadge.className = "verification-badge not-verified ms-2";
            statusBadge.innerHTML = "<i class='fa-solid fa-times-circle'></i> Not Verified";
            statusBadge.style.display = "inline-flex";
            return;
        }

        try {
            const url = "<%=request.getContextPath()%>/PatientServlet?action=checkIc&patient_ic=" + encodeURIComponent(ic);
            const res = await fetch(url);
            const data = await res.json();

            if (data.exists) {
                msg.innerHTML = "<span class='text-success fw-semibold'>✓ Patient IC verified and exists in system.</span>";
                verifiedFlag.value = "true";
                statusBadge.className = "verification-badge verified ms-2";
                statusBadge.innerHTML = "<i class='fa-solid fa-check-circle'></i> Verified";
                statusBadge.style.display = "inline-flex";
            } else {
                msg.innerHTML = "<span class='text-danger fw-semibold'>✗ Patient IC not found in system.</span>";
                verifiedFlag.value = "false";
                statusBadge.className = "verification-badge not-verified ms-2";
                statusBadge.innerHTML = "<i class='fa-solid fa-times-circle'></i> Not Verified";
                statusBadge.style.display = "inline-flex";
            }
        } catch (e) {
            msg.innerHTML = "<span class='text-danger fw-semibold'>Error verifying IC. Please try again.</span>";
            verifiedFlag.value = "false";
            statusBadge.className = "verification-badge not-verified ms-2";
            statusBadge.innerHTML = "<i class='fa-solid fa-times-circle'></i> Not Verified";
            statusBadge.style.display = "inline-flex";
        }
    }

    function toggleTreatment(element) {
        const checkbox = element.querySelector('input[type="checkbox"]');
        checkbox.checked = !checkbox.checked;
        if (checkbox.checked) {
            element.classList.add('selected');
        } else {
            element.classList.remove('selected');
        }
    }

    function rebuildTimeSlots(bookedSet, selectedDate = null) {
        const container = document.getElementById("timeSlotsContainer");
        const hiddenInput = document.getElementById("appointmentTimeHidden");
        const selectedTimeDisplay = document.getElementById("selectedTimeDisplay");
        const selectedTimeText = document.getElementById("selectedTimeText");
        const selectedDateText = document.getElementById("selectedDateText");

        container.innerHTML = "";
        hiddenInput.value = "";
        selectedTimeDisplay.style.display = "none";

        if (selectedDate) {
            const dateObj = new Date(selectedDate);
            const formattedDate = dateObj.toLocaleDateString('en-US', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
            });
            selectedDateText.textContent = formattedDate;
        } else {
            selectedDateText.textContent = "None";
        }

        let count = 0;

        for (const s of ALL_SLOTS) {
            if (!bookedSet.has(s.value)) {
                const btn = document.createElement("div");
                btn.className = "time-slot";
                btn.textContent = s.label;

                btn.addEventListener("click", function () {
                    document.querySelectorAll(".time-slot").forEach(el => el.classList.remove("selected"));
                    btn.classList.add("selected");
                    hiddenInput.value = s.value;
                    
                    selectedTimeText.textContent = s.label;
                    selectedTimeDisplay.style.display = "block";
                });

                container.appendChild(btn);
                count++;
            }
        }

        if (count === 0 && selectedDate) {
            const msg = document.createElement("div");
            msg.className = "time-empty";
            msg.textContent = "No available time slots for this date";
            container.appendChild(msg);
        } else if (!selectedDate) {
            const msg = document.createElement("div");
            msg.className = "time-empty";
            msg.textContent = "Select a date to see available time slots";
            container.appendChild(msg);
        }
    }

    async function fetchFullyBooked(monthStr) {
        const url = "<%= request.getContextPath() %>/AvailabilityServlet?action=fullyBooked&month=" + encodeURIComponent(monthStr);
        const res = await fetch(url);
        const arr = await res.json();
        return new Set(arr);
    }

    async function fetchBookedTimes(dateYmd) {
        const url = "<%= request.getContextPath() %>/AvailabilityServlet?date=" + encodeURIComponent(dateYmd);
        const res = await fetch(url);
        const booked = await res.json();
        return new Set(booked);
    }

    function hasAtLeastOneTreatment() {
        const checks = document.querySelectorAll('input[name="treatment_ids"]:checked');
        return checks && checks.length > 0;
    }

    (async function init() {
        let disabledDates = new Set();

        const now = new Date();
        const curMonth = now.getFullYear() + "-" + String(now.getMonth() + 1).padStart(2, "0");
        disabledDates = await fetchFullyBooked(curMonth);

        rebuildTimeSlots(new Set());

        flatpickr("#appointmentDate", {
            dateFormat: "Y-m-d",
            minDate: "today",
            inline: true,
            appendTo: document.getElementById("calendarWrap"),
            disable: [
                function (date) {
                    const ymd = date.toISOString().slice(0, 10);
                    return disabledDates.has(ymd);
                }
            ],
            onMonthChange: async function (selectedDates, dateStr, instance) {
                const y = instance.currentYear;
                const m = String(instance.currentMonth + 1).padStart(2, "0");
                disabledDates = await fetchFullyBooked(`${y}-${m}`);
                instance.redraw();
            },
            onChange: async function (selectedDates, dateStr) {
                if (!dateStr) {
                    rebuildTimeSlots(new Set());
                    return;
                }
                const bookedSet = await fetchBookedTimes(dateStr);
                rebuildTimeSlots(bookedSet, dateStr);
            }
        });

        document.getElementById("scheduleForm").addEventListener("submit", function (e) {
            const icInput = document.getElementById("patientIcInput");
            const verifiedFlag = document.getElementById("icVerified");
            
            // Staff: must verify patient IC first
            if (icInput && verifiedFlag && verifiedFlag.value !== "true") {
                e.preventDefault();
                alert("Please verify Patient IC before scheduling.");
                icInput.focus();
                return;
            }

            // Must pick time
            const hiddenTime = document.getElementById("appointmentTimeHidden").value;
            if (!hiddenTime) {
                e.preventDefault();
                alert("Please select an appointment time slot.");
                document.getElementById("timeSlotsContainer").scrollIntoView({behavior: "smooth", block: "center"});
                return;
            }

            // Must pick at least one treatment
            if (!hasAtLeastOneTreatment()) {
                e.preventDefault();
                alert("Please select at least ONE treatment.");
                document.querySelector('.treatment-box').scrollIntoView({behavior: "smooth", block: "center"});
                return;
            }
        });
    })();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>