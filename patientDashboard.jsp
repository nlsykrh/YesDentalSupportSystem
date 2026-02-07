<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Patient Dashboard</title>

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
        
        .welcome-header {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 25px;
        }
        
        .welcome-header h2 {
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .dashboard-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            border: none;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        
        .card-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 15px;
        }
        
        .icon-appointment {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .icon-billing {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
        }
        
        .icon-profile {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
        }
        
        .icon-calendar {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            color: white;
        }
        
        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: #555;
            margin-bottom: 8px;
        }
        
        .card-value {
            font-size: 28px;
            font-weight: 700;
            color: #2f4a34;
            margin-bottom: 5px;
        }
        
        .card-subtext {
            font-size: 13px;
            color: #777;
        }
        
        .quick-actions {
            margin-top: 20px;
        }
        
        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
            color: white;
            border: none;
        }
        
        .btn-info {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            border: none;
        }

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .dashboard-cards {
                grid-template-columns: 1fr;
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
            <span><%= session.getAttribute("patientName") != null ? session.getAttribute("patientName") : "Patient" %> (Patient)</span>
        </div>
    </div>

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success" style="margin: 0 60px 12px; border-radius: 10px;">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger" style="margin: 0 60px 12px; border-radius: 10px;">${error}</div>
    <% } %>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Patient Dashboard</h6>
                <a class="side-link active" href="/YesDentalSupportSystem/patient/patientDashboard.jsp">Dashboard</a>
                <a class="side-link" href="/YesDentalSupportSystem/PatientAppointmentServlet?action=list">My Appointments</a>
                <a class="side-link" href="/YesDentalSupportSystem/PatientBillingServlet?action=list">My Billings</a>
                <a class="side-link" href="/YesDentalSupportSystem/PatientProfileServlet?action=view">My Profile</a>
                <a class="side-link" href="/YesDentalSupportSystem/LogoutServlet">Logout</a>
            </div>

            <div class="card-panel">
                <div class="welcome-header">
                    <h2><i class="fas fa-tooth"></i> Welcome back, <%= session.getAttribute("patientName") != null ? session.getAttribute("patientName") : "Patient" %>!</h2>
                    <p class="mb-0">Manage your dental appointments and billing information</p>
                </div>
                
                <div class="dashboard-cards">
                    <div class="dashboard-card">
                        <div class="card-icon icon-appointment">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <div class="card-title">Appointments</div>
                        <div class="card-value">-</div>
                        <div class="card-subtext">View and manage appointments</div>
                        <div class="quick-actions">
                            <a href="/YesDentalSupportSystem/PatientAppointmentServlet?action=list" class="action-btn btn-primary">
                                <i class="fas fa-eye"></i> View Appointments
                            </a>
                        </div>
                    </div>
                    
                    <div class="dashboard-card">
                        <div class="card-icon icon-billing">
                            <i class="fas fa-file-invoice-dollar"></i>
                        </div>
                        <div class="card-title">Billings</div>
                        <div class="card-value">-</div>
                        <div class="card-subtext">View billing records and payments</div>
                        <div class="quick-actions">
                            <a href="/YesDentalSupportSystem/PatientBillingServlet?action=list" class="action-btn btn-success">
                                <i class="fas fa-receipt"></i> View Billings
                            </a>
                        </div>
                    </div>
                    
                    <div class="dashboard-card">
                        <div class="card-icon icon-profile">
                            <i class="fas fa-user-circle"></i>
                        </div>
                        <div class="card-title">Profile</div>
                        <div class="card-value">-</div>
                        <div class="card-subtext">Update personal information</div>
                        <div class="quick-actions">
                            <a href="/YesDentalSupportSystem/PatientProfileServlet?action=view" class="action-btn btn-info">
                                <i class="fas fa-user-edit"></i> View Profile
                            </a>
                        </div>
                    </div>
                    
                    <div class="dashboard-card">
                        <div class="card-icon icon-calendar">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="card-title">Upcoming</div>
                        <div class="card-value">-</div>
                        <div class="card-subtext">Check upcoming schedules</div>
                        <div class="quick-actions">
                            <a href="/YesDentalSupportSystem/PatientAppointmentServlet?action=upcoming" class="action-btn btn-primary">
                                <i class="fas fa-calendar-alt"></i> Check Schedule
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Activity Section -->
                <div style="margin-top: auto;">
                    <h5 style="color: #2f4a34; margin-bottom: 15px; font-weight: 600;">
                        <i class="fas fa-history"></i> Quick Links
                    </h5>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="list-group">
                                <a href="/YesDentalSupportSystem/PatientAppointmentServlet?action=list" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span><i class="fas fa-calendar text-primary"></i> Appointment History</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                                <a href="/YesDentalSupportSystem/PatientBillingServlet?action=list" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span><i class="fas fa-receipt text-success"></i> Billing History</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="list-group">
                                <a href="/YesDentalSupportSystem/PatientProfileServlet?action=edit" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span><i class="fas fa-user-edit text-info"></i> Update Profile</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                                <a href="/YesDentalSupportSystem/PatientProfileServlet?action=change_password" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span><i class="fas fa-lock text-warning"></i> Change Password</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="list-group">
                                <a href="#" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                    <span><i class="fas fa-question-circle text-secondary"></i> Help & Support</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                                <a href="/YesDentalSupportSystem/LogoutServlet" class="list-group-item list-group-item-action d-flex justify-content-between align-items-center text-danger">
                                    <span><i class="fas fa-sign-out-alt"></i> Logout</span>
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </div>
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