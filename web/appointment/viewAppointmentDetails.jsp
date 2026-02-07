<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@page import="java.util.*"%>
<%@page import="beans.Appointment"%>
<%@page import="beans.AppointmentTreatment"%>
<%@page import="dao.DigitalConsentDAO"%>
<%@page import="beans.DigitalConsent"%>

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

        /* TOP NAV */
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

        .brand img {
            height: 48px;
        }

        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: var(--green-dark);
            font-family: "Times New Roman", serif;
        }

        .top-right {
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
            color: white;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            box-shadow: 0 6px 14px rgba(0,0,0,0.18);
            transition: all 0.2s ease;
        }

        .logout-btn:hover {
            background: #b95a5a;
            transform: translateY(-1px);
        }

        /* LAYOUT */
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

        /* SIDEBAR */
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
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }

        .side-link i {
            width: 18px;
            text-align: center;
            opacity: 0.95;
        }

        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, 0.14);
            color: #ffe69b;
        }

        /* PANEL */
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
            margin-bottom: 12px;
            align-items: center;
        }

        .panel-header h4 {
            margin: 0;
            font-weight: 800;
            color: #2f2f2f;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .content-wrap {
            flex: 1;
            min-height: 0;
            overflow: auto;
            padding-right: 6px;
        }

        /* INNER CARDS */
        .info-card {
            background: #fff;
            border: 1px solid #e6e6e6;
            border-radius: 14px;
            padding: 16px;
            box-shadow: 0 10px 18px rgba(0,0,0,0.06);
        }

        .badge-soft {
            border-radius: 999px;
            padding: 6px 12px;
            font-weight: 700;
        }

        /* CENTER BUTTONS */
        .action-center {
            display: flex;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 14px;
        }

        .action-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            border-radius: 999px;
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
        }

        .action-pill:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }

        .pill-edit {
            border-color: #e6dfb9;
            color: #5a4f1a;
        }

        .pill-cancel {
            border-color: #f5c2c7;
            color: #9b2c2c;
            background: #fff6f6;
        }

        .pill-back {
            border-color: #cfe0d5;
            color: #264232;
        }

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
        }
    </style>
</head>

<body>
<%
    Appointment appointment = (Appointment) request.getAttribute("appointment");
    List<AppointmentTreatment> treatments =
            (List<AppointmentTreatment>) request.getAttribute("treatments");

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    DigitalConsentDAO consentDAO = new DigitalConsentDAO();
    DigitalConsent consent = null;

    if (appointment != null) {
        consent = consentDAO.getConsentByAppointmentId(appointment.getAppointmentId());
    }

    boolean hasConsent = (consent != null);
    String status = (appointment != null && appointment.getAppointmentStatus() != null)
            ? appointment.getAppointmentStatus()
            : "";
    boolean isCancelled = "Cancelled".equalsIgnoreCase(status) || "Canceled".equalsIgnoreCase(status);

    String staffName = (String) session.getAttribute("staffName");
    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
%>

<div class="overlay">

    <!-- TOP NAV -->
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

            <a href="<%=request.getContextPath()%>/LogoutServlet" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
        </div>
    </div>

    <!-- LAYOUT -->
    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link" href="<%=request.getContextPath()%>/StaffServlet?action=list">
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
            </div>

            <!-- PANEL -->
            <div class="card-panel">

                <div class="panel-header">
                    <h4>
                        <i class="fa-solid fa-clipboard-list"></i>
                        Appointment Details
                    </h4>
                </div>

                <div class="content-wrap">

                    <% if (appointment == null) { %>

                        <div class="alert alert-warning">
                            Appointment not found.
                        </div>

                        <div class="action-center">
                            <a class="action-pill pill-back"
                               href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                                <i class="fa-solid fa-arrow-left"></i> Back to Appointments
                            </a>
                        </div>

                    <% } else { %>

                        <div class="row g-3">

                            <!-- LEFT: appointment + treatment -->
                            <div class="col-lg-8">

                                <div class="info-card mb-3">
                                    <h5 class="mb-3">
                                        <i class="fa-solid fa-circle-info"></i> Appointment Information
                                    </h5>

                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <strong>Appointment ID</strong><br>
                                            <span class="badge bg-dark"><%= appointment.getAppointmentId() %></span>
                                        </div>

                                        <div class="col-md-3">
                                            <strong>Date</strong><br>
                                            <%= dateFormat.format(appointment.getAppointmentDate()) %>
                                        </div>

                                        <div class="col-md-3">
                                            <strong>Time</strong><br>
                                            <%= appointment.getAppointmentTime() %>
                                        </div>

                                        <div class="col-md-3">
                                            <strong>Status</strong><br>
                                            <span class="badge
                                                <%= "Confirmed".equalsIgnoreCase(status) ? "bg-success" :
                                                    "Pending".equalsIgnoreCase(status) ? "bg-warning text-dark" :
                                                    "Cancelled".equalsIgnoreCase(status) || "Canceled".equalsIgnoreCase(status) ? "bg-danger" :
                                                    "bg-secondary" %>">
                                                <%= status.toUpperCase() %>
                                            </span>
                                        </div>
                                    </div>

                                    <hr>

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <strong>Patient IC</strong><br>
                                            <%= appointment.getPatientIc() %>
                                        </div>

                                        <div class="col-md-6">
                                            <strong>Remarks</strong><br>
                                            <%= (appointment.getRemarks() != null && !appointment.getRemarks().trim().isEmpty())
                                                    ? appointment.getRemarks()
                                                    : "No remarks" %>
                                        </div>
                                    </div>
                                </div>

                                <div class="info-card">
                                    <h5 class="mb-3">
                                        <i class="fa-solid fa-tooth"></i> Treatment Information
                                    </h5>

                                    <% if (treatments != null && !treatments.isEmpty()) { %>
                                        <div class="table-responsive">
                                            <table class="table table-bordered mb-0">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th style="width: 220px;">Treatment ID</th>
                                                        <th>Date</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <% for (AppointmentTreatment t : treatments) { %>
                                                        <tr>
                                                            <td><%= t.getTreatmentId() %></td>
                                                            <td><%= dateFormat.format(t.getAppointmentDate()) %></td>
                                                        </tr>
                                                    <% } %>
                                                </tbody>
                                            </table>
                                        </div>
                                    <% } else { %>
                                        <p class="text-muted mb-0">No treatments recorded for this appointment.</p>
                                    <% } %>
                                </div>

                            </div>

                            <!-- RIGHT: digital consent column -->
                            <div class="col-lg-4">

                                <div class="info-card">
                                    <h5 class="mb-3">
                                        <i class="fa-solid fa-file-contract text-success"></i> Digital Consent
                                    </h5>

                                    <% if (consent != null) {
                                        SimpleDateFormat ts = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                    %>

                                        <div class="mb-2">
                                            <strong>Consent ID:</strong><br>
                                            <span class="badge bg-dark"><%= consent.getConsentId() %></span>
                                        </div>

                                        <div class="mb-2">
                                            <strong>Signed Date:</strong><br>
                                            <%= ts.format(consent.getConsentSigndate()) %>
                                        </div>

                                        <div class="mb-2">
                                            <strong>Status:</strong><br>
                                            <span class="badge bg-success">SIGNED</span>
                                        </div>

                                        <div class="mt-3">
                                            <strong>Consent Context:</strong><br>
                                            <div class="text-muted" style="font-size: 13px;">
                                                <%= consent.getConsentContext() %>
                                            </div>
                                        </div>

                                    <% } else if ("Confirmed".equalsIgnoreCase(status)) { %>

                                        <div class="alert alert-warning mb-2">
                                            <i class="fa-solid fa-triangle-exclamation"></i>
                                            <strong>Consent pending!</strong>
                                        </div>

                                        <a class="btn btn-success w-100"
                                           href="<%=request.getContextPath()%>/AppointmentServlet?action=consent&appointment_id=<%= appointment.getAppointmentId() %>">
                                            <i class="fa-solid fa-file-signature"></i> Sign Consent Now
                                        </a>

                                    <% } else { %>

                                        <p class="text-muted mb-0">
                                            Digital consent will be available once appointment is confirmed.
                                        </p>

                                    <% } %>
                                </div>

                            </div>

                        </div>

                        <!-- BUTTONS CENTER -->
                        <div class="action-center">

                            <a class="action-pill pill-back"
                               href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                                <i class="fa-solid fa-arrow-left"></i> Back
                            </a>

                            <a class="action-pill pill-edit"
                               href="<%=request.getContextPath()%>/AppointmentServlet?action=edit&appointment_id=<%= appointment.getAppointmentId() %>">
                                <i class="fa-solid fa-pen"></i> Edit Appointment
                            </a>

                            <% if (!isCancelled && !hasConsent) { %>
                                <form action="<%=request.getContextPath()%>/AppointmentServlet"
                                      method="post"
                                      style="display:inline;"
                                      onsubmit="return confirmCancel();">

                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">

                                    <button type="submit" class="action-pill pill-cancel">
                                        <i class="fa-solid fa-ban"></i> Cancel Appointment
                                    </button>
                                </form>
                            <% } else if (isCancelled) { %>
                                <span class="badge bg-secondary badge-soft">
                                    <i class="fa-solid fa-xmark"></i> Already Cancelled
                                </span>
                            <% } else if (hasConsent) { %>
                                <span class="badge bg-info badge-soft" title="Cannot cancel after consent is signed">
                                    <i class="fa-solid fa-lock"></i> Appointment Locked
                                </span>
                            <% } %>

                            <%-- Optional delete (only cancelled) --%>
                            <% if (isCancelled) { %>
                                <form action="<%=request.getContextPath()%>/AppointmentServlet"
                                      method="post"
                                      style="display:inline;"
                                      onsubmit="return confirmDelete();">

                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">

                                    <button type="submit" class="action-pill">
                                        <i class="fa-solid fa-trash"></i> Delete
                                    </button>
                                </form>
                            <% } %>

                        </div>

                    <% } %>

                </div>
            </div>

        </div>
    </div>
</div>

<script>
    function confirmCancel() {
        return confirm('Are you sure you want to cancel this appointment?');
    }
    function confirmDelete() {
        return confirm('Are you sure you want to delete this appointment?');
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>