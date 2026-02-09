<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.DigitalConsent" %>
<%@ page import="beans.Patient" %>
<%@ page import="beans.Appointment" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String patientNameSess = (String) session.getAttribute("patientName");
    String patientIdSess   = (String) session.getAttribute("patientId");

    if (patientNameSess == null || patientIdSess == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Patient patient = (Patient) request.getAttribute("patient");
    Appointment appt = (Appointment) request.getAttribute("appointment");
    DigitalConsent consent = (DigitalConsent) request.getAttribute("consent");

    if (patient == null || appt == null || consent == null) {
        response.sendRedirect(request.getContextPath() + "/AppointmentServlet?action=list");
        return;
    }

    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

    String apptDate = (appt.getAppointmentDate() != null) ? df.format(appt.getAppointmentDate()) : "-";
    String apptTime = (appt.getAppointmentTime() != null) ? appt.getAppointmentTime() : "-";
    if (apptTime.length() >= 5) apptTime = apptTime.substring(0,5);

    String apptStatus = (appt.getAppointmentStatus() != null) ? appt.getAppointmentStatus() : "-";

    boolean isConfirmed = "Confirmed".equalsIgnoreCase(apptStatus);
    boolean isSigned = (consent.getConsentSigndate() != null);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Yes Dental Clinic - Digital Consent</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    :root{
        --green-dark:#2f4a34;
        --green-deep:#264232;
        --gold-soft:#d7d1a6;
        --accent:#C79D0C;
        --accent2:#D1AC2A;
    }
    body{
        overflow:hidden;
        margin:0;
        min-height:100vh;
        background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
        background-size:cover;
        font-family:"Segoe UI", sans-serif;
    }
    .overlay{min-height:100vh;background:rgba(255,255,255,0.38);backdrop-filter:blur(1.5px);}

    .top-nav{display:flex;justify-content:space-between;align-items:center;padding:22px 60px 8px;}
    .brand{display:flex;align-items:center;gap:12px;}
    .brand img{height:48px;}
    .clinic-title{font-size:26px;font-weight:700;color:var(--green-dark);font-family:"Times New Roman", serif;}
    .user-area{display:flex;align-items:center;gap:15px;}
    .user-chip{background:#f3f3f3;padding:6px 14px;border-radius:20px;font-size:13px;display:flex;align-items:center;gap:6px;}
    .logout-btn{background:#d96c6c;color:white;border:none;border-radius:40px;padding:7px 18px;font-weight:600;box-shadow:0 6px 14px rgba(0,0,0,0.2);}

    .layout-wrap{width:100%;padding:30px 60px 40px;height:calc(100vh - 100px);overflow:hidden;}
    .layout{display:grid;grid-template-columns:280px 1fr;gap:24px;height:100%;max-width:1400px;}

    .sidebar{background:var(--green-deep);color:white;border-radius:14px;padding:20px 16px;height:100%;}
    .sidebar h6{font-size:20px;margin-bottom:12px;padding-bottom:10px;border-bottom:1px solid rgba(255,255,255,0.25);}
    .side-link{display:flex;align-items:center;gap:10px;color:white;padding:9px 10px;border-radius:10px;text-decoration:none;font-size:14px;margin-bottom:6px;}
    .side-link i{width:18px;text-align:center;}
    .side-link:hover,.side-link.active{background:rgba(255,255,255,0.14);color:#ffe69b;}

    .card-panel{background:rgba(255,255,255,0.92);border-radius:16px;padding:22px 24px 26px;box-shadow:0 14px 30px rgba(0,0,0,0.1);height:100%;display:flex;flex-direction:column;overflow:hidden;}
    .panel-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;}
    .panel-header h4{font-weight:800;margin:0;color:#2f2f2f;}
    .content-scroll{flex:1;min-height:0;overflow:auto;padding-right:4px;}
    .form-card{background:#fff;border:1px solid #e6e6e6;border-radius:16px;padding:16px;box-shadow:0 10px 18px rgba(0,0,0,0.06);}
    .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:14px;}
    .small-note{font-size:12px;color:#666;}
    .consent-highlight{
        color: var(--accent);
        font-weight: 800;
    }
    .consent-highlight2{
        color: var(--accent2);
        font-weight: 800;
    }

    .btn-sign{background:#3a9b5a;color:white;border:none;border-radius:999px;padding:10px 16px;font-weight:700;}
    .btn-reject{background:#d96c6c;color:white;border:none;border-radius:999px;padding:10px 16px;font-weight:700;}
    .btn-back{border-radius:999px;padding:10px 16px;font-weight:700;}
    /* PRINT BUTTON (match your UI style) */
.btn-print{
    display:inline-flex;
    align-items:center;
    gap:8px;

    background: rgba(255,255,255,0.92);
    color: var(--green-deep);

    border: 1px solid rgba(38,66,50,0.18);
    border-radius: 999px;

    padding: 9px 14px;
    font-weight: 800;
    font-size: 13px;

    box-shadow: 0 10px 18px rgba(0,0,0,0.08);
    transition: all 0.18s ease;
    cursor: pointer;
}

.btn-print i{
    font-size: 14px;
    opacity: 0.9;
}

.btn-print:hover{
    transform: translateY(-1px);
    background: rgba(215,209,166,0.35); /* gold-soft tint */
    border-color: rgba(215,209,166,0.85);
}

.btn-print:active{
    transform: translateY(0px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.08);
}


/* PRINT */
@media print {
  body { overflow: visible !important; background: none !important; }
  .overlay { background: #fff !important; }
  .top-nav, .sidebar { display: none !important; }

  /* hide action buttons when printing */
  .btn-sign, .btn-reject, .btn-back, .btn-print { display: none !important; }
  .small-note { display:none !important; }

  .layout-wrap { padding: 0 !important; height: auto !important; overflow: visible !important; }
  .layout { grid-template-columns: 1fr !important; max-width: 100% !important; height:auto !important; }
  .card-panel { box-shadow: none !important; height: auto !important; overflow: visible !important; }
  .content-scroll { overflow: visible !important; }
}
@media(max-width:992px){
    body{overflow:auto;}
    .layout{grid-template-columns:1fr;}
    .layout-wrap{padding:20px;height:auto;overflow:visible;}
    .card-panel{height:auto;overflow:visible;}
    .content-scroll{overflow:visible;}
    .top-nav{padding:18px 24px 8px;flex-wrap:wrap;gap:10px;}
    .grid-2{grid-template-columns:1fr;}
}
</style>
</head>

<body>
<div class="overlay">

    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-area">
            <div class="user-chip">
                <i class="fa fa-user"></i>
                <%= patientNameSess %>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post">
                <button class="logout-btn">
                    <i class="fa fa-right-from-bracket"></i> Logout
                </button>
            </form>
        </div>
    </div>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
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
            </div>

            <div class="card-panel">

                <div class="panel-header">
                    <h4><i class="fa-solid fa-file-signature me-2"></i>Digital Consent Form</h4>
                    <button type="button" class="btn-print" onclick="window.print()">
                        <!-- You want w3school fa fa style -->
                        <i class="fa fa-print"></i>
                        Print
                    </button>
                </div>

                <div class="content-scroll">
                    <div class="form-card">

                        <% if (!isConfirmed) { %>
                            <div class="alert alert-warning mb-3">
                                You can only sign digital consent when the appointment is <b>Confirmed</b>.
                                Current status: <b><%= apptStatus %></b>
                            </div>
                        <% } %>

                        <% if (isSigned) { %>
                            <div class="alert alert-success mb-3">
                                <i class="fa-solid fa-circle-check me-1"></i>
                                Consent already signed.
                            </div>
                        <% } %>

                        <div class="grid-2 mb-3">
                            <div>
                                <label class="form-label fw-semibold">Patient Name</label>
                                <input class="form-control" value="<%= patient.getPatientName() %>" readonly>
                            </div>
                            <div>
                                <label class="form-label fw-semibold">Patient IC</label>
                                <input class="form-control" value="<%= patient.getPatientIc() %>" readonly>
                            </div>

                            <div>
                                <label class="form-label fw-semibold">Patient Phone</label>
                                <input class="form-control" value="<%= patient.getPatientPhone() %>" readonly>
                            </div>
                            <div>
                                <label class="form-label fw-semibold">Guardian Name</label>
                                <input class="form-control" value="<%= (patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "-") %>" readonly>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Consent Context</label>
                            <textarea class="form-control auto-grow" readonly><%= (consent.getConsentContext() != null ? consent.getConsentContext() : "") %></textarea>
                        </div>

                        <div class="p-3 rounded" style="background:#f8f9fa; border:1px solid #e6e6e6;">
                            <p class="mb-2" style="font-weight:700;">Consent Statement</p>
                            <p class="mb-0" style="line-height:1.6;">
                                I, <span class="consent-highlight"><%= patient.getPatientName() %></span> (IC: <span class="consent-highlight"><%= patient.getPatientIc() %></span>), hereby confirm that I understand
                                the nature of the dental procedure(s) related to this appointment. I acknowledge that all
                                dental procedures carry potential risks and outcomes, and I have had the opportunity to ask
                                questions regarding my treatment.
                                <br><br>
                                I voluntarily agree to proceed with the dental appointment scheduled on
                                <span class="consent-highlight2"><%= apptDate %></span> at <span class="consent-highlight2"><%= apptTime %></span>.
                            </p>
                        </div>

                        <div class="d-flex justify-content-between flex-wrap gap-2 mt-4">
                            <a class="btn btn-secondary btn-back"
                               href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                                <i class="fa-solid fa-arrow-left"></i> Back
                            </a>

                            <div class="d-flex gap-2">
                                <form action="<%=request.getContextPath()%>/AppointmentServlet" method="post"
                                      onsubmit="return confirmReject();" style="margin:0;">
                                    <input type="hidden" name="action" value="decline_consent">
                                    <input type="hidden" name="appointment_id" value="<%= consent.getAppointmentId() %>">
                                    <button type="submit" class="btn-reject">
                                        <i class="fa-solid fa-ban me-1"></i> Reject
                                    </button>
                                </form>

                                <form action="<%=request.getContextPath()%>/AppointmentServlet" method="post"
                                      onsubmit="return confirmSign();" style="margin:0;">
                                    <input type="hidden" name="action" value="sign_consent">
                                    <input type="hidden" name="appointment_id" value="<%= consent.getAppointmentId() %>">
                                    <button type="submit" class="btn-sign" <%= (!isConfirmed || isSigned) ? "disabled" : "" %>>
                                        <i class="fa-solid fa-pen-nib me-1"></i> Sign Digital Consent
                                    </button>
                                </form>
                            </div>
                        </div>

                        <div class="small-note mt-3">
                            * Rejecting consent will cancel the appointment automatically.
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>

</div>

<script>
function confirmSign(){
    return confirm("Confirm to SIGN the digital consent?");
}
function confirmReject(){
    return confirm("Rejecting consent will CANCEL your appointment. Continue?");
}
</script>
<script>
document.querySelectorAll(".auto-grow").forEach(function(el){
    el.style.height = "auto";
    el.style.height = el.scrollHeight + "px";
});
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
