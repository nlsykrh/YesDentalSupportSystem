<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="beans.AppointmentTreatment" %>
<%@ page import="dao.DigitalConsentDAO" %>
<%@ page import="beans.DigitalConsent" %>

<%
    String patientName = (String) session.getAttribute("patientName");
    String staffName = (String) session.getAttribute("staffName");
    boolean isPatient = (patientName != null);
    boolean isStaff = (staffName != null);
    
    if (!isPatient && !isStaff) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String displayName = isStaff ? staffName : patientName;
    Appointment appointment = (Appointment) request.getAttribute("appointment");
    List<AppointmentTreatment> treatments = (List<AppointmentTreatment>) request.getAttribute("treatments");
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd");
    DigitalConsentDAO consentDAO = new DigitalConsentDAO();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Appointment Details</title>
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
        .layout-wrap {
            width: 100%;
            padding: 30px 60px 40px;
            height: calc(100vh - 100px);
            overflow: hidden;
        }
        .layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            height: 100%;
            align-items: stretch;
        }
        .sidebar {
            background: var(--green-deep);
            color: #fff;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }
        .sidebar h6 {
            font-size: 20px;
            margin-bottom: 12px;
            color: white;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.25);
        }
        .side-link {
            display: flex;
            align-items: center;
            gap: 10px;
            color: white;
            padding: 9px 10px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .side-link.active, .side-link:hover {
            background: rgba(255, 255, 255, 0.14);
            color: #ffe69b;
        }
        
        /* FIXED CARD PANEL FOR SCROLLING */
        .card-panel {
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
            margin-bottom: 20px;
            align-items: center;
            flex-shrink: 0;
        }
        .panel-header h4 {
            margin: 0;
            font-weight: 700;
            color: #2f2f2f;
        }
        
        /* SCROLLABLE CONTENT AREA */
        .content-area {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            padding-right: 4px;
        }
        
        /* Custom scrollbar styling */
        .content-area::-webkit-scrollbar {
            width: 6px;
        }
        .content-area::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }
        .content-area::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 3px;
        }
        .content-area::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
        
        /* Detail cards styling */
        .detail-card {
            background: #fff;
            border: 1px solid #eaeaea;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        .detail-card h5 {
            color: var(--green-dark);
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--gold-soft);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        /* Info grid styling */
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
        }
        .info-item {
            padding: 12px;
            border-radius: 8px;
            background: #f9f9f9;
            border-left: 4px solid var(--green-deep);
        }
        .info-item label {
            display: block;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #666;
            margin-bottom: 6px;
            font-weight: 700;
        }
        .info-value {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            padding: 6px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        /* Badge styling */
        .badge-id {
            background: var(--green-dark);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        /* Status pills */
        .status-pill {
            padding: 8px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .status-pill.confirmed {
            background: #e7f4ec;
            color: #2a6b48;
            border: 1px solid #2a6b48;
        }
        .status-pill.pending {
            background: #fff8e6;
            color: #8a6d3b;
            border: 1px solid #8a6d3b;
        }
        .status-pill.cancelled {
            background: #f6e6e6;
            color: #9b2c2c;
            border: 1px solid #9b2c2c;
        }
        
        /* Table styling */
        .table-wrap {
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            overflow: auto;
            margin-top: 16px;
        }
        .table thead {
            background: #f1f5f9;
        }
        .table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .4px;
            color: #2b2b2b;
            position: sticky;
            top: 0;
            background: #f1f5f9;
            z-index: 5;
            padding: 14px 16px;
            border-bottom: 2px solid var(--gold-soft);
        }
        .table tbody td {
            font-size: 14px;
            vertical-align: middle;
            padding: 14px 16px;
            border-bottom: 1px solid #eee;
        }
        .table tbody tr:hover {
            background: #f9f9f9;
        }
        
        /* Consent status styling */
        .consent-status {
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }
        .consent-status.signed {
            background: #e7f4ec;
            color: #2a6b48;
            border: 2px solid #2a6b48;
        }
        .consent-status.unsigned {
            background: #fff8e6;
            color: #8a6d3b;
            border: 2px solid #8a6d3b;
        }
        
        /* Button styling */
        .btn-pill {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.2s;
        }
        .btn-secondary {
            background: #f3f3f3;
            color: #333;
            border: 2px solid #ddd;
        }
        .btn-secondary:hover {
            background: #e8e8e8;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .btn-primary {
            background: var(--green-dark);
            color: white;
            border: 2px solid var(--green-dark);
        }
        .btn-primary:hover {
            background: var(--green-deep);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(47, 74, 52, 0.2);
        }
        
        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 16px;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #eee;
            flex-wrap: wrap;
        }
        
        /* Alert styling */
        .alert {
            border-radius: 10px;
            margin-bottom: 20px;
            border: none;
            padding: 16px 20px;
            border-left: 4px solid;
        }
        .alert-success {
            background: #e7f4ec;
            color: #2a6b48;
            border-left-color: #2a6b48;
        }
        .alert-danger {
            background: #f6e6e6;
            color: #9b2c2c;
            border-left-color: #9b2c2c;
        }
        .alert-warning {
            background: #fff8e6;
            color: #8a6d3b;
            border-left-color: #8a6d3b;
        }
        .alert-info {
            background: #e0f2fe;
            color: #0369a1;
            border-left-color: #0369a1;
        }
        
        /* Icons */
        .icon-value {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        
        /* Remarks box */
        .remarks-box {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 16px;
            margin-top: 8px;
            font-size: 15px;
            line-height: 1.5;
            color: #495057;
        }
        
        /* Responsive */
        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .content-area {
                overflow: visible;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
            .action-buttons {
                flex-direction: column;
            }
            .action-buttons .btn-pill {
                width: 100%;
                text-align: center;
                justify-content: center;
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
            <span><%= displayName %></span>
        </div>
    </div>

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">${error}</div>
    <% } %>

    <div class="layout-wrap">
        <div class="layout">
            <div class="sidebar">
                <h6><%= isPatient ? "Patient" : "Staff" %> Dashboard</h6>
                <% if (isPatient) { %>
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

            <div class="card-panel">
                <div class="panel-header">
                    <h4><i class="fa-solid fa-calendar-check me-2"></i>Appointment Details</h4>
                    <a href="<%=request.getContextPath()%>/AppointmentServlet?action=list" class="btn-pill btn-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Back to List
                    </a>
                </div>

                <!-- SCROLLABLE CONTENT AREA -->
                <div class="content-area">
                    <% if (appointment == null) { %>
                        <div class="alert alert-warning">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>
                            Appointment not found.
                        </div>
                    <% } else { 
                        String status = appointment.getAppointmentStatus();
                        boolean isConfirmed = "Confirmed".equalsIgnoreCase(status);
                        boolean isPending = "Pending".equalsIgnoreCase(status);
                        boolean isCancelled = "Cancelled".equalsIgnoreCase(status);
                        
                        DigitalConsent consent = consentDAO.getConsentByAppointmentId(appointment.getAppointmentId());
                        boolean consentSigned = (consent != null && consent.getConsentSigndate() != null);
                        boolean canPatientSign = isPatient && isConfirmed && !consentSigned;
                        
                        // Format time for display (convert 24h to 12h)
                        String timeStr = appointment.getAppointmentTime();
                        String displayTime = "N/A";
                        if (timeStr != null && timeStr.length() >= 5) {
                            try {
                                String hourStr = timeStr.substring(0, 2);
                                String minuteStr = timeStr.substring(3, 5);
                                int hour = Integer.parseInt(hourStr);
                                String ampm = hour >= 12 ? "PM" : "AM";
                                hour = hour % 12;
                                hour = hour == 0 ? 12 : hour;
                                displayTime = String.format("%02d:%s %s", hour, minuteStr, ampm);
                            } catch (Exception e) {
                                displayTime = timeStr;
                            }
                        }
                    %>
                    
                    <!-- Appointment Information Card -->
                    <div class="detail-card">
                        <h5><i class="fa-solid fa-circle-info me-2"></i>Appointment Information</h5>
                        <div class="info-grid">
                            <div class="info-item">
                                <label>Appointment ID</label>
                                <div class="info-value">
                                    <span class="badge-id">
                                        <i class="fa-solid fa-hashtag"></i> <%= appointment.getAppointmentId() %>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <label>Date</label>
                                <div class="info-value">
                                    <i class="fa-solid fa-calendar-days text-primary"></i>
                                    <%= appointment.getAppointmentDate() != null ? dateFmt.format(appointment.getAppointmentDate()) : "N/A" %>
                                </div>
                            </div>
                            <div class="info-item">
                                <label>Time</label>
                                <div class="info-value">
                                    <i class="fa-solid fa-clock text-primary"></i>
                                    <%= displayTime %>
                                </div>
                            </div>
                            <div class="info-item">
                                <label>Status</label>
                                <div class="info-value">
                                    <span class="status-pill <%= isConfirmed ? "confirmed" : isPending ? "pending" : "cancelled" %>">
                                        <% if (isConfirmed) { %>
                                            <i class="fa-solid fa-check-circle"></i>
                                        <% } else if (isPending) { %>
                                            <i class="fa-solid fa-clock"></i>
                                        <% } else { %>
                                            <i class="fa-solid fa-ban"></i>
                                        <% } %>
                                        <%= status %>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <label>Patient IC</label>
                                <div class="info-value">
                                    <i class="fa-solid fa-id-card text-primary"></i>
                                    <%= appointment.getPatientIc() %>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Remarks Section -->
                        <% if (appointment.getRemarks() != null && !appointment.getRemarks().trim().isEmpty()) { %>
                        <div class="mt-4">
                            <label class="fw-bold text-dark mb-2">Remarks</label>
                            <div class="remarks-box">
                                <i class="fa-solid fa-comment-dots me-2 text-muted"></i>
                                <%= appointment.getRemarks() %>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <!-- Treatment Information Card -->
                    <div class="detail-card">
                        <h5><i class="fa-solid fa-tooth me-2"></i>Treatment Information</h5>
                        <% if (treatments != null && !treatments.isEmpty()) { %>
                            <div class="table-wrap">
                                <table class="table mb-0">
                                    <thead>
                                    <tr>
                                        <th><i class="fa-solid fa-hashtag me-1"></i> Treatment ID</th>
                                        <th><i class="fa-solid fa-tooth me-1"></i> Treatment Name</th>
                                        <th><i class="fa-solid fa-money-bill-wave me-1"></i> Price (RM)</th>
                                        <th><i class="fa-solid fa-calendar me-1"></i> Booked Date</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <% 
                                        double totalPrice = 0;
                                        for (AppointmentTreatment at : treatments) { 
                                            if (at.getTreatmentName() != null && at.getTreatmentPrice() > 0) {
                                                totalPrice += at.getTreatmentPrice();
                                            }
                                    %>
                                    <tr>
                                        <td><strong><%= at.getTreatmentId() %></strong></td>
                                        <td><%= at.getTreatmentName() != null ? at.getTreatmentName() : "-" %></td>
                                        <td>
                                            <% if (at.getTreatmentName() == null) { %>
                                                -
                                            <% } else { %>
                                                RM <%= String.format("%.2f", at.getTreatmentPrice()) %>
                                            <% } %>
                                        </td>
                                        <td><%= at.getAppointmentDate() != null ? dateFmt.format(at.getAppointmentDate()) : "N/A" %></td>
                                    </tr>
                                    <% } %>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="2" class="text-end fw-bold">Total:</td>
                                            <td class="fw-bold text-success">RM <%= String.format("%.2f", totalPrice) %></td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        <% } else { %>
                            <div class="alert alert-info mb-0">
                                <i class="fa-solid fa-circle-info me-2"></i>
                                No treatment details found for this appointment.
                            </div>
                        <% } %>
                    </div>

                    <!-- Digital Consent Status Card -->
                    <div class="detail-card">
                        <h5><i class="fa-solid fa-file-signature me-2"></i>Digital Consent Status</h5>
                        <% if (consentSigned) { %>
                            <div class="info-grid">
                                <div class="info-item">
                                    <label>Consent ID</label>
                                    <div class="info-value">
                                        <span class="badge-id">
                                            <i class="fa-solid fa-hashtag"></i> <%= consent.getConsentId() %>
                                        </span>
                                    </div>
                                </div>
                                <div class="info-item">
                                    <label>Status</label>
                                    <div class="info-value">
                                        <span class="consent-status signed">
                                            <i class="fa-solid fa-circle-check"></i> SIGNED
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <% } else if (isConfirmed) { %>
                            <div class="info-grid">
                                <div class="info-item">
                                    <label>Status</label>
                                    <div class="info-value">
                                        <span class="consent-status unsigned">
                                            <i class="fa-solid fa-triangle-exclamation"></i> UNSIGNED
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-4">
                                <% if (canPatientSign) { %>
                                    <a class="btn-pill btn-primary"
                                       href="<%=request.getContextPath()%>/AppointmentServlet?action=consent&appointment_id=<%= appointment.getAppointmentId() %>">
                                        <i class="fa-solid fa-file-signature me-2"></i> Sign Digital Consent
                                    </a>
                                <% } else { %>
                                    <div class="alert alert-warning mb-0">
                                        <i class="fa-solid fa-info-circle me-2"></i>
                                        Patient must sign the digital consent form.
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="alert alert-info mb-0">
                                <i class="fa-solid fa-circle-info me-2"></i>
                                Consent available when appointment is CONFIRMED.
                            </div>
                        <% } %>
                    </div>
                    <% } %>
                </div> <!-- End content-area -->
            </div> <!-- End card-panel -->
        </div> <!-- End layout -->
    </div> <!-- End layout-wrap -->
</div> <!-- End overlay -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>