<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - View Patient Details</title>

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
            background:rgba(255,255,255,0.38);
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

        .brand img{ height:48px; }

        .clinic-title{
            font-size:26px;
            font-weight:700;
            color:var(--green-dark);
            font-family:"Times New Roman",serif;
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
        }

        .logout-btn{
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:6px 16px;
            border-radius:999px;
            background:#c96a6a;
            color:white;
            font-size:13px;
            font-weight:600;
            text-decoration:none;
            box-shadow:0 6px 14px rgba(0,0,0,0.18);
            transition:all 0.2s ease;
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
            height:100%;
        }

        .sidebar{
            background:var(--green-deep);
            color:#fff;
            border-radius:14px;
            padding:20px 16px;
            overflow:auto;
        }

        .sidebar h6{
            font-size:20px;
            margin-bottom:12px;
            padding-bottom:10px;
            border-bottom:1px solid rgba(255,255,255,0.25);
        }

        .side-link{
            display:flex;
            align-items:center;
            gap:10px;
            color:white;
            padding:7px 10px;
            border-radius:8px;
            text-decoration:none;
            font-size: 14px;
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

        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
            padding:22px 24px 18px;
            box-shadow:0 14px 30px rgba(0,0,0,0.1);
            display:flex;
            flex-direction:column;
            overflow:hidden;
        }

        .panel-header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:12px;
        }

        .form-wrap{
            border:1px solid #d9d9d9;
            border-radius:10px;
            background:#fff;
            flex:1;
            min-height:0;
            overflow:auto;
            padding:20px;
        }

        .form-label{
            font-weight:600;
            margin-bottom:6px;
        }

        .form-control{
            background:#f6f6f6;
            border:1px solid #d9d9d9;
            border-radius:8px;
        }

        .footer-actions{
            display:flex;
            justify-content:space-between;
            padding-top:14px;
            border-top:1px solid rgba(0,0,0,0.08);
            margin-top:14px;
        }

        .btn-gold{
            background:var(--gold-soft);
            border:none;
            border-radius:18px;
            padding:8px 18px;
            font-weight:600;
        }

        @media(max-width:992px){
            body{overflow:auto;}
            .layout{grid-template-columns:1fr;}
            .layout-wrap{height:auto;overflow:visible;}
            .card-panel{overflow:visible;}
            .form-wrap{overflow:visible;}
        }
    </style>
</head>

<body>
<%
    Patient patient = (Patient) request.getAttribute("patient");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    SimpleDateFormat dateOnly = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat dateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<div class="overlay">

    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="top-right">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= session.getAttribute("staffName")!=null?session.getAttribute("staffName"):"Staff" %></span>
            </div>
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
        </div>
    </div>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                <a class="side-link" href="${pageContext.request.contextPath}/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>
                <a class="side-link" href="${pageContext.request.contextPath}/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>
                <a class="side-link" href="${pageContext.request.contextPath}/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>
                <a class="side-link active" href="${pageContext.request.contextPath}/PatientServlet?action=list">
                    <i class="fa-solid fa-hospital-user"></i> Patients
                </a>
                <a class="side-link" href="${pageContext.request.contextPath}/TreatmentServlet?action=list">
                    <i class="fa-solid fa-tooth"></i> Treatments
                </a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>View Patient Details</h4>
                </div>

                <% if (error != null) { %>
                    <div class="alert alert-danger"><%= error %></div>
                <% } %>

                <% if (success != null) { %>
                    <div class="alert alert-success"><%= success %></div>
                <% } %>

                <% if (patient != null) {
                    String dobStr = patient.getPatientDob() != null ? dateOnly.format(patient.getPatientDob()) : "";
                    String createdStr = patient.getPatientCrDate() != null ? dateTime.format(patient.getPatientCrDate()) : "N/A";
                %>

                <div class="form-wrap">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">IC Number</label>
                            <input type="text" class="form-control" value="<%= patient.getPatientIc() %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Full Name</label>
                            <input type="text" class="form-control" value="<%= patient.getPatientName() != null ? patient.getPatientName() : "" %>" readonly>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Phone</label>
                            <input type="text" class="form-control" value="<%= patient.getPatientPhone() != null ? patient.getPatientPhone() : "" %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" value="<%= patient.getPatientEmail() != null ? patient.getPatientEmail() : "" %>" readonly>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Date of Birth</label>
                            <input type="date" class="form-control" value="<%= dobStr %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Status</label>
                            <input type="text" class="form-control" value="<%= "A".equals(patient.getPatientStatus()) ? "Active" : "Inactive" %>" readonly>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <textarea class="form-control" rows="2" readonly><%= patient.getPatientAddress() != null ? patient.getPatientAddress() : "" %></textarea>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Guardian's Name</label>
                            <input type="text" class="form-control" value="<%= patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "" %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Guardian's Phone</label>
                            <input type="text" class="form-control" value="<%= patient.getPatientGuardianPhone() != null ? patient.getPatientGuardianPhone() : "" %>" readonly>
                        </div>
                    </div>

                    <div class="mb-3">
                        <h6 class="mb-2">System Information</h6>
                        <div class="row">
                            <div class="col-md-6">
                                <label class="form-label">Registration Date</label>
                                <input type="text" class="form-control" value="<%= createdStr %>" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Password</label>
                                <input type="text" class="form-control" value="<%= patient.getPatientPassword() != null ? patient.getPatientPassword() : "N/A" %>" readonly>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="footer-actions">
                    <a href="${pageContext.request.contextPath}/PatientServlet?action=list" class="btn btn-secondary">← Back to Patients</a>
                </div>

                <% } else { %>
                    <div class="form-wrap">
                        <div class="alert alert-warning mb-0">No patient data found.</div>
                    </div>
                    <div class="footer-actions">
                        <a href="${pageContext.request.contextPath}/PatientServlet?action=list" class="btn btn-secondary">← Back to Patients</a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>