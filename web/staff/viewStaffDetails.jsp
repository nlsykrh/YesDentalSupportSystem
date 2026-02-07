<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Staff staff = (Staff) request.getAttribute("staff");
    if (staff == null) {
        response.sendRedirect(request.getContextPath() + "/StaffServlet?action=list");
        return;
    }

    String id = staff.getStaffId() != null ? staff.getStaffId() : "";
    String name = staff.getStaffName() != null ? staff.getStaffName() : "";
    String role = staff.getStaffRole() != null ? staff.getStaffRole() : "";
    String email = staff.getStaffEmail() != null ? staff.getStaffEmail() : "";
    String phone = staff.getStaffPhonenum() != null ? staff.getStaffPhonenum() : "";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Staff Details</title>

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
            display:block;
            color:#fff;
            padding:7px 10px;
            border-radius:8px;
            text-decoration:none;
            font-size:14px;
            margin-bottom:6px;
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
            align-items:center;
            gap:12px;
            margin-bottom:12px;
        }
        .panel-header h4{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
        }
        .role-pill{
            padding:6px 12px;
            border-radius:999px;
            font-size:12px;
            background:#e7f4ec;
            color:#2a6b48;
            display:inline-block;
            font-weight:800;
        }

        .details-wrap{
            border:1px solid #d9d9d9;
            border-radius:10px;
            background:#fff;
            flex:1;
            min-height:0;
            overflow:auto;
            padding:18px;
        }

        .info-grid{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:14px;
        }
        .info-card{
            border:1px solid #e6e6e6;
            border-radius:12px;
            padding:14px 14px;
            background:#fff;
        }
        .label{
            font-size:12px;
            color:#6b6b6b;
            text-transform:uppercase;
            letter-spacing:.35px;
            margin-bottom:6px;
            font-weight:800;
        }
        .value{
            font-size:15px;
            font-weight:700;
            color:#2f2f2f;
            word-break:break-word;
        }

        .btn-row{
            display:flex;
            justify-content:space-between;
            gap:10px;
            margin-top:16px;
        }
        .btn-back{
            border-radius:18px;
            padding:10px 14px;
            font-weight:800;
            font-size:13px;
        }
        .btn-edit{
            background:var(--gold-soft);
            color:#3a382f;
            border:none;
            border-radius:18px;
            padding:10px 14px;
            font-weight:900;
            font-size:13px;
            text-decoration:none;
            display:inline-flex;
            align-items:center;
            gap:8px;
            white-space:nowrap;
        }

        @media(max-width:992px){
            .layout{grid-template-columns:1fr;}
            .layout-wrap{padding:20px;}
            .top-nav{padding:18px 24px 8px;flex-wrap:wrap;gap:10px;}
            .info-grid{grid-template-columns:1fr;}
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
            <span><%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Staff" %></span>
        </div>
    </div>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                <a class="side-link active" href="<%=request.getContextPath()%>/StaffServlet?action=list">Staff</a>
                <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">Appointments</a>
                <a class="side-link" href="<%=request.getContextPath()%>/BillingServlet?action=list">Billing</a>
                <a class="side-link" href="<%=request.getContextPath()%>/PatientServlet?action=list">Patients</a>
                <a class="side-link" href="<%=request.getContextPath()%>/TreatmentServlet?action=list">Treatments</a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <div>
                        <h4>Staff Details</h4>
                        <div class="mt-2"><span class="role-pill"><%= role %></span></div>
                    </div>
                </div>

                <div class="details-wrap">
                    <div class="info-grid">
                        <div class="info-card">
                            <div class="label">Staff ID</div>
                            <div class="value"><%= id %></div>
                        </div>

                        <div class="info-card">
                            <div class="label">Name</div>
                            <div class="value"><%= name %></div>
                        </div>

                        <div class="info-card">
                            <div class="label">Email</div>
                            <div class="value"><%= email %></div>
                        </div>

                        <div class="info-card">
                            <div class="label">Phone</div>
                            <div class="value"><%= phone %></div>
                        </div>
                    </div>

                    <div class="btn-row">
                        <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">Back</a>
                        <a class="btn-edit" href="<%=request.getContextPath()%>/StaffServlet?action=edit&staff_id=<%= id %>">
                            <i class="fa-solid fa-pen"></i> Edit Staff
                        </a>
                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
