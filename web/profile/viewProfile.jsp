<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="beans.Staff" %>

<%
    String userType = (String) request.getAttribute("userType");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    boolean isEditMode = "true".equals(request.getParameter("edit"));
    boolean isChangePassword = "true".equals(request.getParameter("changepassword"));

    Patient p = null;
    Staff s = null;

    String displayName = "User";
    String roleLabel = "User";

    if ("patient".equals(userType)) {
        p = (Patient) request.getAttribute("patient");
        if (p != null && p.getPatientName() != null) displayName = p.getPatientName();
        roleLabel = "Patient";
    } else if ("staff".equals(userType)) {
        s = (Staff) request.getAttribute("staff");
        if (s != null && s.getStaffName() != null) displayName = s.getStaffName();

        Object sr = request.getAttribute("staffRole");
        roleLabel = (sr != null) ? sr.toString() : (s != null && s.getStaffRole() != null ? s.getStaffRole() : "Staff");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile - YesDental</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
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

        /* ===== HEADER ===== */
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
            color:white;
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
            color:white;
            padding-bottom:10px;
            border-bottom:1px solid rgba(255,255,255,0.25);
        }

        .side-link{
            display:flex;
            align-items:center;
            gap:10px;
            color:white;
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

        /* ===== CONTENT PANEL ===== */
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

        .panel-header h4{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
            display:flex;
            align-items:center;
            gap:10px;
        }

        .header-actions{
            display:flex;
            gap:10px;
            flex-wrap:wrap;
        }

        .pill-btn{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:7px 14px;
            border-radius:999px;
            font-weight:700;
            font-size:13px;
            text-decoration:none;
            border:1px solid #d9d9d9;
            background:#fff;
            color:#2f2f2f;
            transition:transform .08s ease, box-shadow .12s ease, background .12s ease;
        }
        .pill-btn:hover{
            transform:translateY(-1px);
            box-shadow:0 10px 18px rgba(0,0,0,0.08);
            background:#fafafa;
        }

        .pill-primary{
            border:none;
            background:var(--gold-soft);
            color:#3a382f;
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
            box-shadow:0 10px 18px rgba(0,0,0,0.06);
            overflow:hidden;
            margin-bottom:14px;
        }

        .info-card .card-head{
            background:#f4f4f4;
            border-bottom:1px solid #e9ecef;
            padding:12px 14px;
            font-weight:800;
            display:flex;
            align-items:center;
            gap:10px;
            color:#2f2f2f;
        }

        .info-card .card-body-inner{
            padding:14px;
        }

        .row-line{
            padding:10px 0;
            border-bottom:1px solid #f0f0f0;
        }
        .row-line:last-child{
            border-bottom:none;
        }

        .readonly-field{
            background:#f8f9fa;
        }

        .badge-soft{
            background:rgba(215,209,166,0.55);
            color:#3a382f;
            font-weight:800;
        }

        .alert{
            border-radius:10px;
            margin:0 60px 12px;
        }

        @media (max-width: 992px){
            body{ overflow:auto; }
            .layout{ grid-template-columns:1fr; }
            .layout-wrap{
                padding:20px;
                height:auto;
                overflow:visible;
            }
            .top-nav{
                padding:18px 24px 8px;
                flex-wrap:wrap;
                gap:10px;
            }
            .card-panel{
                height:auto;
                overflow:visible;
            }
            .content-scroll{ overflow:visible; }
            .alert{ margin:0 20px 12px; }
        }
    </style>
</head>

<body>
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
                <span><%= displayName %></span>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post" style="margin:0;">
                <button type="submit" class="logout-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </button>
            </form>
        </div>
    </div>

    <!-- Success / Error -->
    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- MAIN LAYOUT -->
    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6><%= "patient".equals(userType) ? "Patient Dashboard" : "Staff Dashboard" %></h6>

                <% if ("patient".equals(userType)) { %>
                    <a class="side-link" href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>
                    <a class="side-link" href="<%=request.getContextPath()%>/appointment/viewAppointment.jsp">
                        <i class="fa-solid fa-calendar-check"></i> View Appointment
                    </a>
                    <a class="side-link" href="<%=request.getContextPath()%>/PatientBillingServlet?action=list"">
                        <i class="fa-solid fa-file-invoice-dollar"></i> My Billings
                    </a>
                    <a class="side-link active" href="<%=request.getContextPath()%>/ProfileServlet">
                        <i class="fa-solid fa-user"></i> My Profile
                    </a>
                <% } else { %>
                    <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
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
                    <a class="side-link active" href="<%=request.getContextPath()%>/ProfileServlet">
                        <i class="fa-solid fa-user"></i> My Profile
                    </a>
                <% } %>
            </div>

            <!-- CONTENT PANEL -->
            <div class="card-panel">

                <div class="panel-header">
                    <h4>
                        <i class="fa-solid <%= "patient".equals(userType) ? "fa-user-injured" : "fa-user-doctor" %>"></i>
                        My Profile
                    </h4>

                    <div class="header-actions">
                        <% if (!isEditMode && !isChangePassword) { %>
                            <a class="pill-btn pill-primary" href="<%=request.getContextPath()%>/ProfileServlet?edit=true">
                                <i class="fa-solid fa-pen"></i> Edit Profile
                            </a>
                            <a class="pill-btn" href="<%=request.getContextPath()%>/ProfileServlet?changepassword=true">
                                <i class="fa-solid fa-key"></i> Change Password
                            </a>
                        <% } else { %>
                            <a class="pill-btn" href="<%=request.getContextPath()%>/ProfileServlet">
                                <i class="fa-solid fa-xmark"></i> Cancel
                            </a>
                        <% } %>
                    </div>
                </div>

                <p class="panel-sub">Hi <strong><%= displayName %></strong></p>

                <div class="content-scroll">

                    <!-- CHANGE PASSWORD -->
                    <% if (isChangePassword) { %>

                        <div class="info-card">
                            <div class="card-head">
                                <i class="fa-solid fa-key"></i> Change Password
                            </div>
                            <div class="card-body-inner">
                                <form action="<%=request.getContextPath()%>/ProfileServlet" method="post" style="max-width:420px; margin:0 auto;">
                                    <input type="hidden" name="action" value="changePassword">

                                    <div class="mb-3">
                                        <label class="form-label">Current Password</label>
                                        <input type="password" name="current_password" class="form-control" required>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">New Password</label>
                                        <input type="password" name="new_password" class="form-control" required minlength="6" placeholder="Minimum 6 characters">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Confirm New Password</label>
                                        <input type="password" name="confirm_password" class="form-control" required>
                                    </div>

                                    <div class="text-center">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa-solid fa-floppy-disk"></i> Change Password
                                        </button>
                                        <a href="<%=request.getContextPath()%>/ProfileServlet" class="btn btn-outline-secondary ms-2">
                                            Cancel
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>

                    <!-- EDIT MODE -->
                    <% } else if (isEditMode) { %>

                        <form action="<%=request.getContextPath()%>/ProfileServlet" method="post" id="profileForm">
                            <input type="hidden" name="action" value="update">

                            <% if ("patient".equals(userType) && p != null) { %>

                                <div class="info-card">
                                    <div class="card-head">
                                        <i class="fa-solid fa-id-card"></i> Personal Information
                                    </div>
                                    <div class="card-body-inner">

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">IC Number</div>
                                            <div class="col-md-9">
                                                <input type="text" class="form-control readonly-field" value="<%= p.getPatientIc() %>" readonly>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Full Name</div>
                                            <div class="col-md-9">
                                                <input type="text" name="patient_name" class="form-control"
                                                       value="<%= p.getPatientName() != null ? p.getPatientName() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Email</div>
                                            <div class="col-md-9">
                                                <input type="email" name="patient_email" class="form-control"
                                                       value="<%= p.getPatientEmail() != null ? p.getPatientEmail() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Phone</div>
                                            <div class="col-md-9">
                                                <input type="tel" name="patient_phone" class="form-control"
                                                       value="<%= p.getPatientPhone() != null ? p.getPatientPhone() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Date of Birth</div>
                                            <div class="col-md-9">
                                                <input type="date" name="patient_dob" class="form-control"
                                                       value="<%= p.getPatientDob() != null ? sdf.format(p.getPatientDob()) : "" %>">
                                            </div>
                                        </div>

                                    </div>
                                </div>

                                <div class="info-card">
                                    <div class="card-head">
                                        <i class="fa-solid fa-address-book"></i> Contact Information
                                    </div>
                                    <div class="card-body-inner">

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Address</div>
                                            <div class="col-md-9">
                                                <textarea name="patient_address" class="form-control" rows="3"><%= p.getPatientAddress() != null ? p.getPatientAddress() : "" %></textarea>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Guardian Name</div>
                                            <div class="col-md-9">
                                                <input type="text" name="patient_guardian" class="form-control"
                                                       value="<%= p.getPatientGuardian() != null ? p.getPatientGuardian() : "" %>">
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Guardian Phone</div>
                                            <div class="col-md-9">
                                                <input type="tel" name="patient_guardian_phone" class="form-control"
                                                       value="<%= p.getPatientGuardianPhone() != null ? p.getPatientGuardianPhone() : "" %>">
                                            </div>
                                        </div>

                                    </div>
                                </div>

                            <% } else if ("staff".equals(userType) && s != null) { %>

                                <div class="info-card">
                                    <div class="card-head">
                                        <i class="fa-solid fa-id-badge"></i> Staff Information
                                    </div>
                                    <div class="card-body-inner">

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Staff ID</div>
                                            <div class="col-md-9">
                                                <input type="text" class="form-control readonly-field" value="<%= s.getStaffId() %>" readonly>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Full Name</div>
                                            <div class="col-md-9">
                                                <input type="text" name="staff_name" class="form-control"
                                                       value="<%= s.getStaffName() != null ? s.getStaffName() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Email</div>
                                            <div class="col-md-9">
                                                <input type="email" name="staff_email" class="form-control"
                                                       value="<%= s.getStaffEmail() != null ? s.getStaffEmail() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Phone Number</div>
                                            <div class="col-md-9">
                                                <input type="tel" name="staff_phonenum" class="form-control"
                                                       value="<%= s.getStaffPhonenum() != null ? s.getStaffPhonenum() : "" %>" required>
                                            </div>
                                        </div>

                                        <div class="row row-line align-items-center">
                                            <div class="col-md-3 fw-bold">Role</div>
                                            <div class="col-md-9">
                                                <span class="badge badge-soft">
                                                    <%= s.getStaffRole() != null ? s.getStaffRole() : "Not assigned" %>
                                                </span>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                            <% } %>

                            <div class="info-card">
                                <div class="card-body-inner text-center">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa-solid fa-floppy-disk"></i> Save
                                    </button>
                                    <a href="<%=request.getContextPath()%>/ProfileServlet" class="btn btn-outline-secondary ms-2">
                                        <i class="fa-solid fa-xmark"></i> Cancel
                                    </a>
                                </div>
                            </div>

                        </form>

                    <!-- VIEW MODE -->
                    <% } else { %>

                        <% if ("patient".equals(userType) && p != null) { %>

                            <div class="info-card">
                                <div class="card-head">
                                    <i class="fa-solid fa-id-card"></i> Personal Information
                                </div>
                                <div class="card-body-inner">
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">IC Number</div>
                                        <div class="col-md-9"><%= p.getPatientIc() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Full Name</div>
                                        <div class="col-md-9"><%= p.getPatientName() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Email</div>
                                        <div class="col-md-9"><%= p.getPatientEmail() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Phone</div>
                                        <div class="col-md-9"><%= p.getPatientPhone() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Date of Birth</div>
                                        <div class="col-md-9"><%= p.getPatientDob() != null ? sdf.format(p.getPatientDob()) : "Not set" %></div>
                                    </div>
                                </div>
                            </div>

                            <div class="info-card">
                                <div class="card-head">
                                    <i class="fa-solid fa-address-book"></i> Contact Information
                                </div>
                                <div class="card-body-inner">
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Address</div>
                                        <div class="col-md-9"><%= p.getPatientAddress() != null ? p.getPatientAddress().replace("\n", "<br>") : "Not set" %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Guardian Name</div>
                                        <div class="col-md-9"><%= p.getPatientGuardian() != null ? p.getPatientGuardian() : "Not set" %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Guardian Phone</div>
                                        <div class="col-md-9"><%= p.getPatientGuardianPhone() != null ? p.getPatientGuardianPhone() : "Not set" %></div>
                                    </div>
                                </div>
                            </div>

                            <div class="info-card">
                                <div class="card-head">
                                    <i class="fa-solid fa-user-shield"></i> Account Information
                                </div>
                                <div class="card-body-inner">
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Status</div>
                                        <div class="col-md-9">
                                            <span class="badge <%= "A".equals(p.getPatientStatus()) ? "bg-success" : "bg-secondary" %>">
                                                <%= "A".equals(p.getPatientStatus()) ? "Active" : "Inactive" %>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Registration Date</div>
                                        <div class="col-md-9"><%= p.getPatientCrDate() != null ? sdf.format(p.getPatientCrDate()) : "N/A" %></div>
                                    </div>
                                </div>
                            </div>

                        <% } else if ("staff".equals(userType) && s != null) { %>

                            <div class="info-card">
                                <div class="card-head">
                                    <i class="fa-solid fa-id-badge"></i> Staff Information
                                </div>
                                <div class="card-body-inner">
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Staff ID</div>
                                        <div class="col-md-9"><%= s.getStaffId() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Full Name</div>
                                        <div class="col-md-9"><%= s.getStaffName() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Email</div>
                                        <div class="col-md-9"><%= s.getStaffEmail() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Phone Number</div>
                                        <div class="col-md-9"><%= s.getStaffPhonenum() %></div>
                                    </div>
                                    <div class="row row-line">
                                        <div class="col-md-3 fw-bold">Role</div>
                                        <div class="col-md-9">
                                            <span class="badge badge-soft"><%= s.getStaffRole() != null ? s.getStaffRole() : "Not assigned" %></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        <% } %>

                    <% } %>

                </div>
            </div>

        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.getElementById('profileForm')?.addEventListener('submit', function(e) {
        const emailInput = this.querySelector('input[type="email"]');
        const phoneInput = this.querySelector('input[type="tel"]');

        if (emailInput && !isValidEmail(emailInput.value)) {
            e.preventDefault();
            alert('Please enter a valid email address.');
            emailInput.focus();
            return false;
        }

        if (phoneInput && !isValidPhone(phoneInput.value)) {
            e.preventDefault();
            alert('Please enter a valid phone number.');
            phoneInput.focus();
            return false;
        }

        return true;
    });

    function isValidEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }

    function isValidPhone(phone) {
        const re = /^[\\+]?[0-9\\s\\-\\(\\)]{10,}$/;
        return re.test(phone);
    }
</script>

</body>
</html>