<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="beans.Appointment" %>

<%
    if (session == null || session.getAttribute("patientIc") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Digital Consent</title>

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
            color: white;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.25);
        }
        .side-link {
            display: block;
            color: white;
            padding: 7px 10px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, 0.14);
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

        .content-wrap{
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
            overflow: auto;
            padding: 18px 18px;
        }

        .field-grid{
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 14px;
        }
        .field label{
            font-size: 12px;
            color: #5b5b5b;
            margin-bottom: 6px;
        }
        .field .form-control{
            border-radius: 12px;
            font-size: 14px;
        }

        .consent-box{
            border: 1px solid #d9d9d9;
            border-radius: 12px;
            padding: 14px;
            background: #fafafa;
            white-space: pre-line;
            font-size: 14px;
            line-height: 1.5;
        }

        .btn-row{
            display: flex;
            gap: 12px;
            margin-top: 14px;
        }
        .btn-sign{
            background: var(--gold-soft);
            border: none;
            border-radius: 18px;
            padding: 10px 14px;
            font-weight: 700;
            font-size: 13px;
            color: #3a382f;
            flex: 1;
        }
        .btn-decline{
            background: #b42318;
            border: none;
            border-radius: 18px;
            padding: 10px 14px;
            font-weight: 700;
            font-size: 13px;
            color: #fff;
            flex: 1;
        }

        .alert { border-radius: 10px; }

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav { padding: 18px 24px 8px; flex-wrap: wrap; gap: 10px; }
            .field-grid { grid-template-columns: 1fr; }
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
            <span><%= session.getAttribute("patientName") != null ? session.getAttribute("patientName") : "Patient" %></span>
        </div>
    </div>

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success mx-5">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger mx-5">${error}</div>
    <% } %>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Patient Dashboard</h6>
                <a class="side-link" href="<%=request.getContextPath()%>/ManageProfileServlet">Profile</a>
                <a class="side-link active" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">Appointments</a>
                <a class="side-link" href="<%=request.getContextPath()%>/billing/viewBill.jsp">Billing</a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>Digital Consent Form</h4>
                </div>

                <div class="content-wrap">
                    <%
                        Patient patient = (Patient) request.getAttribute("patient");
                        Appointment appointment = (Appointment) request.getAttribute("appointment");

                        String patientIc = (patient != null && patient.getPatientIc() != null) ? patient.getPatientIc() : "";
                        String patientName = (patient != null && patient.getPatientName() != null) ? patient.getPatientName() : "";
                        String patientPhone = (patient != null && patient.getPatientPhone() != null) ? patient.getPatientPhone() : "";
                        String treatmentText = request.getAttribute("treatmentText") != null ? request.getAttribute("treatmentText").toString() : "";
                        String consentContext = request.getAttribute("consentContext") != null ? request.getAttribute("consentContext").toString() : "";
                        String appointmentId = (appointment != null && appointment.getAppointmentId() != null) ? appointment.getAppointmentId() : "";
                        String consentHidden = consentContext.replace("\"", "&quot;");
                    %>

                    <div class="field-grid">
                        <div class="field">
                            <label>Patient Name</label>
                            <input class="form-control" value="<%= patientName %>" readonly>
                        </div>
                        <div class="field">
                            <label>Patient IC</label>
                            <input class="form-control" value="<%= patientIc %>" readonly>
                        </div>
                        <div class="field">
                            <label>Contact Number</label>
                            <input class="form-control" value="<%= patientPhone %>" readonly>
                        </div>
                        <div class="field">
                            <label>Treatment(s)</label>
                            <input class="form-control" value="<%= treatmentText %>" readonly>
                        </div>
                    </div>

                    <div class="mb-2" style="font-weight:700;">Consent Context</div>
                    <div class="consent-box"><%= consentContext %></div>

                    <form method="post" action="<%=request.getContextPath()%>/AppointmentServlet" class="mt-3">
                        <input type="hidden" name="appointment_id" value="<%= appointmentId %>">
                        <input type="hidden" name="consent_text" value="<%= consentHidden %>">

                        <div class="btn-row">
                            <button type="submit" name="action" value="sign_consent" class="btn-sign">
                                Sign Digital Consent
                            </button>

                            <button type="submit" name="action" value="decline_consent" class="btn-decline"
                                    onclick="return confirm('Declining consent will cancel your appointment. Continue?');">
                                Decline Consent
                            </button>
                        </div>
                    </form>

                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
 
