<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="beans.Installment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String staffName = (String) session.getAttribute("staffName");
    if(staffName == null){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Billing Details</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root {
            --green-dark: #2f4a34;
            --green-deep: #264232;
            --gold-soft: #d7d1a6;
        }
        
        /* ===== BODY ===== */
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
        
        /* ===== HEADER ===== */
        .top-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
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
        
        /* USER AREA */
        .user-area {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-chip {
            background: #f3f3f3;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .logout-btn {
            background: #d96c6c;
            color: white;
            border: none;
            border-radius: 40px;
            padding: 7px 18px;
            font-weight: 600;
            box-shadow: 0 6px 14px rgba(0,0,0,0.2);
        }
        
        /* ===== LAYOUT ===== */
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
        
        /* ===== SIDEBAR ===== */
        .sidebar {
            background: var(--green-deep);
            color: white;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }
        
        .sidebar h6 {
            font-size: 20px;
            margin-bottom: 12px;
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
        }
        
        .side-link:hover,
        .side-link.active {
            background: rgba(255,255,255,0.14);
            color: #ffe69b;
        }
        
        /* ===== MAIN PANEL ===== */
        .card-panel {
            background: rgba(255,255,255,0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0,0,0,0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        /* HEADER TEXT */
        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .panel-header h4 {
            font-weight: 700;
            margin: 0;
        }
        
        .billing-details-content {
            flex: 1;
            overflow-y: auto;
            padding-right: 5px;
        }
        
        .billing-details-content h2 {
            color: var(--green-dark);
            font-weight: 700;
            margin-bottom: 24px;
            font-size: 24px;
        }
        
        .details-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e0e0e0;
            margin-bottom: 24px;
            overflow: hidden;
        }
        
        .details-card-header {
            background: var(--green-deep);
            color: white;
            padding: 16px 24px;
            font-size: 16px;
            font-weight: 600;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .details-card-body {
            padding: 24px;
        }
        
        .info-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .info-table tr {
            border-bottom: 1px solid #f0f0f0;
        }
        
        .info-table tr:last-child {
            border-bottom: none;
        }
        
        .info-table th {
            text-align: left;
            padding: 12px 16px;
            width: 35%;
            font-weight: 600;
            color: var(--green-dark);
            background-color: #f8f9fa;
            border-right: 1px solid #e0e0e0;
        }
        
        .info-table td {
            padding: 12px 16px;
            color: #333;
        }
        
        .row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -12px;
        }
        
        .col-md-6 {
            flex: 0 0 50%;
            max-width: 50%;
            padding: 0 12px;
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: bold;
            display: inline-block;
        }
        
        .badge-success {
            background-color: #28a745;
            color: white;
        }
        
        .badge-warning {
            background-color: #ffc107;
            color: #212529;
        }
        
        .badge-info {
            background-color: #17a2b8;
            color: white;
        }
        
        .badge-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .badge-dark {
            background-color: #343a40;
            color: white;
        }
        
        .badge-danger {
            background-color: #dc3545;
            color: white;
        }
        
        .action-buttons-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
        }
        
        .btn {
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            border: none;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #212529;
            border: none;
        }
        
        .btn-info {
            background: #17a2b8;
            color: white;
            border: none;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
            border: none;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        
        .btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
        
        .text-danger {
            color: #dc3545 !important;
        }
        
        .text-success {
            color: #28a745 !important;
        }
        
        .fw-bold {
            font-weight: bold;
        }
        
        .fs-5 {
            font-size: 1.25rem;
        }
        
        .fs-6 {
            font-size: 1rem;
        }
        
        .amount-text {
            font-size: 18px;
            font-weight: bold;
            color: var(--green-dark);
        }
        
        .table-wrap {
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
            overflow: auto;
        }
        
        .table thead {
            background: #dcdcdc;
        }
        
        .table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .4px;
            color: #2b2b2b;
            position: sticky;
            top: 0;
            background: #dcdcdc;
            z-index: 5;
        }
        
        .table tbody td {
            font-size: 14px;
            vertical-align: middle;
        }
        
        .actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .action-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 999px;
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
            white-space: nowrap;
        }
        
        .action-pill i {
            font-size: 14px;
        }
        
        .action-pill:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }
        
        .action-view {
            border-color: #cfe0d5;
            color: #264232;
        }
        
        .action-edit {
            border-color: #e6dfb9;
            color: #5a4f1a;
        }
        
        .alert {
            border-radius: 10px;
            margin: 0 6% 12px;
        }

        @media (max-width: 992px) {
            .layout {
                grid-template-columns: 1fr;
            }
            
            .layout-wrap {
                padding: 20px;
            }
            
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            
            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }
            
            .action-buttons-container {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
            }
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

        <div class="user-area">
            <div class="user-chip">
                <i class="fa fa-user"></i>
                <%= staffName %>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post">
                <button class="logout-btn">
                    <i class="fa fa-right-from-bracket"></i> Logout
                </button>
            </form>
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
                <h6>Staff Dashboard</h6>
                
                <a class="side-link"href="/YesDentalSupportSystem/patient/patientDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>

                <a class="side-link active" href="/YesDentalSupportSystem/BillingServlet?action=list">
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
                    <h4>Billing Details</h4>
                </div>
                
                <div class="billing-details-content">
                    <% 
                        Billing billing = (Billing) request.getAttribute("billing");
                        List<Installment> installments = (List<Installment>) request.getAttribute("installments");
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                    %>
                    
                    <% if (billing == null) { %>
                        <div class="alert alert-warning">
                            Billing not found.
                        </div>
                    <% } else { %>
                    
                    <div class="details-card">
                        <div class="details-card-header">
                            Billing Information
                        </div>
                        <div class="details-card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <table class="info-table">
                                        <tr>
                                            <th>Billing ID:</th>
                                            <td><span class="badge badge-dark fs-6"><%= billing.getBillingId() %></span></td>
                                        </tr>
                                        <tr>
                                            <th>Amount:</th>
                                            <td class="amount-text"><%= currencyFormat.format(billing.getBillingAmount()) %></td>
                                        </tr>
                                        <tr>
                                            <th>Due Date:</th>
                                            <td><%= dateFormat.format(billing.getBillingDuedate()) %></td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="col-md-6">
                                    <table class="info-table">
                                        <tr>
                                            <th>Status:</th>
                                            <td>
                                                <span class="badge <%= "Paid".equals(billing.getBillingStatus()) ? "badge-success" : "badge-warning" %> fs-6">
                                                    <%= billing.getBillingStatus() %>
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Payment Method:</th>
                                            <td>
                                                <span class="badge <%= "Installment".equals(billing.getBillingMethod()) ? "badge-info" : "badge-secondary" %>">
                                                    <%= billing.getBillingMethod() %>
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Appointment ID:</th>
                                            <td><%= billing.getAppointmentId() %></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod()) && installments != null && !installments.isEmpty()) { %>
                    <div class="details-card">
                        <div class="details-card-header" style="background: #17a2b8;">
                            Installment Details
                        </div>
                        <div class="details-card-body">
                            <div class="table-wrap">
                                <table class="table mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 120px;">Installment</th>
                                            <th style="width: 140px;">Payment Date</th>
                                            <th style="width: 140px;">Amount</th>
                                            <th style="width: 140px;">Paid Amount</th>
                                            <th style="width: 140px;">Remaining</th>
                                            <th style="width: 100px;">Status</th>
                                            <th style="width: 100px; text-align:center;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Installment installment : installments) { 
                                            int installmentNum = installments.indexOf(installment) + 1;
                                        %>
                                        <tr>
                                            <td><%= installmentNum %>/<%= installment.getNumofinstallment() %></td>
                                            <td><%= installment.getPaymentDate() %></td>
                                            <td class="fw-bold"><%= currencyFormat.format(installment.getPaymentAmount()) %></td>
                                            <td><%= currencyFormat.format(installment.getPaidAmount()) %></td>
                                            <td class="<%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-danger fw-bold" : "text-success fw-bold" %>">
                                                <%= currencyFormat.format(installment.getRemainingAmount()) %>
                                            </td>
                                            <td>
                                                <span class="badge <%= "Paid".equals(installment.getPaymentStatus()) ? "badge-success" : 
                                                                "Partial".equals(installment.getPaymentStatus()) ? "badge-warning" : "badge-danger" %>">
                                                    <%= installment.getPaymentStatus() %>
                                                </span>
                                            </td>
                                            <td style="text-align:center;">
                                                <% if (!"Paid".equals(installment.getPaymentStatus())) { %>
                                                <a href="BillingServlet?action=make_payment_form&installment_id=<%= installment.getInstallmentId() %>"
                                                   class="btn btn-success btn-sm">
                                                    <i class="fa-solid fa-money-bill-wave"></i> Pay
                                                </a>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <div class="action-buttons-container">
                        <div class="actions">
                            <% if ("Pending".equals(billing.getBillingStatus())) { %>
                            <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>"
                               class="action-pill action-edit" title="Edit billing">
                                <i class="fa-solid fa-pen"></i> Edit
                            </a>
                            <% } %>
                            
                            <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) { %>
                            <a href="BillingServlet?action=view_installments&billing_id=<%= billing.getBillingId() %>"
                               class="action-pill action-view" title="View installments">
                                <i class="fa-solid fa-coins"></i> Installments
                            </a>
                            <% } %>
                        </div>
                    </div>
                    
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>