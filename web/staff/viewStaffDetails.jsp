<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Logged-in staff (for topbar chip)
    String staffNameSess = (String) session.getAttribute("staffName");
    String staffIdSess   = (String) session.getAttribute("staffId");
    String staffRoleSess = (String) session.getAttribute("staffRole");

    if (staffNameSess == null || staffNameSess.trim().isEmpty()) staffNameSess = "Staff";
    if (staffIdSess == null || staffIdSess.trim().isEmpty()) staffIdSess = "-";
    if (staffRoleSess == null || staffRoleSess.trim().isEmpty()) staffRoleSess = "Staff";

    // Viewed staff details
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
            font-family:"Segoe UI", sans-serif;
        }

        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,0.38);
            backdrop-filter:blur(1.5px);
        }

        /* ===== TOP BAR (align with dashboard) ===== */
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
            font-family:"Times New Roman", serif;
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

        /* ===== LAYOUT ===== */
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

        /* ===== SIDEBAR (align with dashboard) ===== */
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
            border-bottom:1px solid rgba(255,255,255,0.25);
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
            opacity:0.95;
        }
        .side-link:hover,
        .side-link.active{
            background:rgba(255,255,255,0.14);
            color:#ffe69b;
        }

        /* ===== CONTENT CARD ===== */
        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,0.1);
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
        .panel-title{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
            display:flex;
            align-items:center;
            gap:10px;
        }
        .panel-sub{
            margin:0;
            color:#666;
            font-size:13px;
        }
        .content-scroll{
            flex:1;
            min-height:0;
            overflow:auto;
            padding-right:4px;
        }

        /* ===== DETAILS CARD ===== */
        .info-card{
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:16px;
            padding:16px;
            box-shadow:0 10px 18px rgba(0,0,0,0.06);
        }

        .info-grid{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:14px;
        }
        .field{
            border:1px solid #efefef;
            border-radius:14px;
            padding:14px;
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

        .role-pill{
            padding:6px 12px;
            border-radius:999px;
            font-size:12px;
            background:#e7f4ec;
            color:#2a6b48;
            display:inline-block;
            font-weight:800;
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
            body{ overflow:auto; }
            .layout{ grid-template-columns:1fr; }
            .layout-wrap{ padding:20px; height:auto; overflow:visible; }
            .top-nav{
                padding:18px 24px 8px;
                flex-wrap:wrap;
                gap:10px;
            }
            .card-panel{ height:auto; overflow:visible; }
            .content-scroll{ overflow:visible; }
            .info-grid{ grid-template-columns:1fr; }
        }
    </style>
</head>

<body>
<div class="overlay">

    <!-- TOP BAR -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="top-right">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= staffNameSess %></span>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post" style="margin:0;">
                <button type="submit" class="logout-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </button>
            </form>
        </div>
    </div>

    <!-- LAYOUT -->
    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link active" href="<%=request.getContextPath()%>/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
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

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-id-badge"></i>
                            Staff Details
                        </h4>
                        <p class="panel-sub">
                            <span class="role-pill"><%= role %></span>
                        </p>
                    </div>
                </div>

                <div class="content-scroll">
                    <div class="info-card">
                        <div class="info-grid">
                            <div class="field">
                                <div class="label">Staff ID</div>
                                <div class="value"><%= id %></div>
                            </div>

                            <div class="field">
                                <div class="label">Name</div>
                                <div class="value"><%= name %></div>
                            </div>

                            <div class="field">
                                <div class="label">Email</div>
                                <div class="value"><%= email %></div>
                            </div>

                            <div class="field">
                                <div class="label">Phone</div>
                                <div class="value"><%= phone %></div>
                            </div>
                        </div>

                        <div class="btn-row">
                            <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">
                                <i class="fa-solid fa-arrow-left"></i> Back
                            </a>

                            <a class="btn-edit" href="<%=request.getContextPath()%>/StaffServlet?action=edit&staff_id=<%= id %>">
                                <i class="fa-solid fa-pen"></i> Edit Staff
                            </a>
                        </div>
                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
