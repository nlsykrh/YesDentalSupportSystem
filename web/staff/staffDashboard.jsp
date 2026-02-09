<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Staff Dashboard</title>

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
            background:#c96a6a; /* not too red */
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

        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,0.1);
            height:100%;
            display:flex;
            flex-direction:column;
            overflow:hidden; /* match viewPatients style */
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

        .info-card{
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:16px;
            padding:16px;
            box-shadow:0 10px 18px rgba(0,0,0,0.06);
        }

        .mini-title{
            font-weight:800;
            margin:0 0 8px;
            display:flex;
            align-items:center;
            gap:10px;
            color:#2f2f2f;
        }

        .muted{
            color:#6b6b6b;
            font-size:13px;
            margin:0;
        }

        .chip{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:8px 12px;
            border-radius:999px;
            background:rgba(215,209,166,0.55);
            color:#3a382f;
            font-size:13px;
            font-weight:700;
        }

        .quick-actions{
            display:grid;
            grid-template-columns:repeat(3, minmax(0, 1fr));
            gap:12px;
        }

        .qa{
            text-decoration:none;
            color:#2f2f2f;
            background:#fff;
            border:1px solid #e6e6e6;
            border-radius:14px;
            padding:12px 14px;
            display:flex;
            gap:10px;
            align-items:flex-start;
            box-shadow:0 10px 18px rgba(0,0,0,0.05);
            transition:transform .12s ease, box-shadow .12s ease;
        }

        .qa:hover{
            transform:translateY(-2px);
            box-shadow:0 16px 26px rgba(0,0,0,0.10);
        }

        .qa .ico{
            width:40px;
            height:40px;
            border-radius:12px;
            display:flex;
            align-items:center;
            justify-content:center;
            background:rgba(215,209,166,0.55);
            color:#3a382f;
            flex:0 0 auto;
        }

        .qa h6{
            margin:0;
            font-weight:800;
            font-size:14px;
        }

        .qa p{
            margin:4px 0 0;
            font-size:12.5px;
            color:#6b6b6b;
        }

        .list-clean{
            margin:0;
            padding-left:18px;
            font-size:13px;
            color:#555;
        }

        .announce{
            background:rgba(47,74,52,0.08);
            border:1px solid rgba(47,74,52,0.15);
            border-radius:14px;
            padding:12px 14px;
            font-size:13px;
            color:#2f3a34;
        }

        @media (max-width: 992px){
            body{ overflow:auto; }
            .layout{ grid-template-columns:1fr; }
            .layout-wrap{ padding:20px; height:auto; overflow:visible; }
            .top-nav{
                padding:18px 24px 8px;
                flex-wrap:wrap;
                gap:10px;
            }
            .quick-actions{ grid-template-columns:1fr; }
            .card-panel{ height:auto; overflow:visible; }
            .content-scroll{ overflow:visible; }
        }
    </style>
</head>

<body>
<%
    String staffName = (String) session.getAttribute("staffName");
    String staffId = (String) session.getAttribute("staffId");
    String staffRole = (String) session.getAttribute("staffRole");

    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
    if (staffId == null || staffId.trim().isEmpty()) staffId = "-";
    if (staffRole == null || staffRole.trim().isEmpty()) staffRole = "Staff";
%>

<div class="overlay">

    <!-- HEADER -->
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

            <!-- SIDEBAR (ADD DASHBOARD) -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>

                <a class="side-link active" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
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
            </div>

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <div>
                        <h4 class="panel-title">
                            <i class="fa-solid fa-house-medical"></i>
                            Hi! <%= staffName %>
                        </h4>
                    </div>

                    <div class="chip">
                        <i class="fa-solid fa-id-badge"></i>
                        ID: <%= staffId %> • <%= staffRole %>
                    </div>
                </div>

                <div class="content-scroll">

                    <!-- Announcement -->
                    <div class="announce mb-3">
                        <strong><i class="fa-solid fa-bullhorn"></i> Staff Notice:</strong>
                        Please confirm appointments early, update patient info accurately, and ensure billing is recorded after treatment.
                    </div>

                     <!-- STAFF PROFILE -->
                    <div class="info-card mb-3">

                        <p class="mini-title">
                            <i class="fa-solid fa-id-badge"></i>
                            Staff Profile Information
                        </p>

                        <div style="display:grid; grid-template-columns:180px 1fr; row-gap:10px; font-size:14px;">

                            <div style="font-weight:700;">Full Name</div>
                            <div>: <%= staffName %></div>

                            <div style="font-weight:700;">Staff ID</div>
                            <div>: <%= staffId %></div>

                            <div style="font-weight:700;">Role</div>
                            <div>: <%= staffRole %></div>

                            <div style="font-weight:700;">Department</div>
                            <div>: Dental Clinic Operations</div>

                            <div style="font-weight:700;">Clinic Email</div>
                            <div>: support@yesdental.com</div>

                            <div style="font-weight:700;">Access Level</div>
                            <div>: Authorized Staff</div>

                        </div>

                    </div>


                    <!-- Staff Responsibilities -->
                    <div class="info-card mb-3">
                        <p class="mini-title">
                            <i class="fa-solid fa-clipboard-list"></i> Today’s Staff Checklist
                        </p>

                        <ul class="list-clean">
                            <li>Check upcoming appointments and confirm patient attendance.</li>
                            <li>Verify patient IC & contact details before proceeding.</li>
                            <li>Update appointment status after treatment (Completed / Cancelled).</li>
                            <li>Record billing and payments for completed appointments.</li>
                            <li>Ensure treatment details are accurate for reporting.</li>
                        </ul>
                    </div>

                    <!-- Tips -->
                    <div class="info-card">
                        <p class="mini-title">
                            <i class="fa-solid fa-lightbulb"></i> Helpful Tips
                        </p>

                        <ul class="list-clean">
                            <li>Use the search bar in each module to quickly locate records.</li>
                            <li>Always double-check dates/time before confirming appointments.</li>
                            <li>For new patients, ensure guardian contact is recorded clearly.</li>
                            <li>Update staff role only if authorised by admin/manager.</li>
                        </ul>
                    </div>

                </div>

            </div>

        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>