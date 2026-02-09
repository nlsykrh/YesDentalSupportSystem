<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="beans.Installment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String staffName = (String) session.getAttribute("staffName");
    String staffId = (String) session.getAttribute("staffId");

    if(staffName == null){
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Installment Details</title>

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
        .brand img { height: 48px; }
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
        .search-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .search-input {
            border: 1px solid #d7ddd9;
            border-radius: 18px;
            padding: 6px 12px;
            font-size: 13px;
            width: 220px;
        }
        .btn-add {
            background: var(--gold-soft);
            color: #3a382f;
            border: none;
            border-radius: 18px;
            padding: 6px 14px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
        }

        .table-wrap{
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;   
            overflow: auto;   
        }

        .table thead { background: #dcdcdc; }
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

        .status-pill {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            background: #e7f4ec;
            color: #2a6b48;
            display: inline-block;
            font-weight: 600;
        }
        .status-pill.inactive{
            background: #f6e6e6;
            color: #9b2c2c;
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
        .action-pill i { font-size: 14px; }
        .action-pill:hover{
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }
        .action-view { border-color: #cfe0d5; color: #264232; }
        .action-edit { border-color: #e6dfb9; color: #5a4f1a; }

        .alert { border-radius: 10px; margin: 0 6% 12px; }

        /* Custom Installment Styling */
        .installment-container {
            overflow-y: auto;
            height: 100%;
            padding-right: 5px;
        }
        
        .summary-card {
            background: white;
            border-radius: 10px;
            border: 1px solid #d9d9d9;
            margin-bottom: 20px;
            overflow: hidden;
        }
        
        .summary-header {
            background: var(--green-deep);
            color: white;
            padding: 16px 20px;
        }
        
        .summary-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }
        
        .summary-body {
            padding: 20px;
        }
        
        .summary-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .summary-table th {
            text-align: left;
            padding: 10px 15px;
            color: var(--green-dark);
            font-weight: 600;
            width: 25%;
        }
        
        .summary-table td {
            padding: 10px 15px;
            color: #333;
        }
        
        .progress-container {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #eaeaea;
        }
        
        .progress {
            height: 10px;
            border-radius: 5px;
            background-color: #e9ecef;
            margin: 15px 0;
        }
        
        .progress-bar {
            background: linear-gradient(90deg, var(--green-deep), #3a5c3a);
            border-radius: 5px;
            transition: width 0.5s ease;
        }
        
        .progress-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 20px;
            text-align: center;
        }
        
        .progress-stat-item {
            padding: 12px;
            border-radius: 8px;
            background: white;
            border: 1px solid #eaeaea;
        }
        
        .installment-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1000px;
        }
        
        .installment-table thead {
            background: #dcdcdc;
        }
        
        .installment-table th {
            padding: 12px;
            text-align: center;
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #2b2b2b;
        }
        
        .installment-table tbody tr {
            border-bottom: 1px solid #eaeaea;
        }
        
        .installment-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .installment-table td {
            padding: 12px;
            font-size: 14px;
            color: #333;
            vertical-align: middle;
            text-align: center;
        }
        
        .badge {
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .badge-success {
            background-color: #e7f4ec;
            color: #2a6b48;
        }
        
        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .badge-danger {
            background-color: #f6e6e6;
            color: #9b2c2c;
        }
        
        .badge-dark {
            background-color: #2f4a34;
            color: white;
        }
        
        .badge-info {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        
        .amount-paid {
            color: #2a6b48;
            font-weight: 600;
        }
        
        .amount-remaining {
            color: #9b2c2c;
            font-weight: 600;
        }
        
        .amount-total {
            color: var(--green-dark);
            font-weight: 700;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin: 20px 0;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            border: 1px solid #eaeaea;
        }
        
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            margin: 10px 0 5px;
        }
        
        .action-buttons-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eaeaea;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 18px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
            font-weight: 500;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
            border-radius: 999px;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-info {
            background-color: #cfe0d5;
            color: #264232;
        }
        
        .btn-warning {
            background-color: var(--gold-soft);
            color: #5a4f1a;
        }
        
        .btn-primary {
            background-color: var(--green-dark);
            color: white;
        }
        
        .btn-success {
            background-color: #2a6b48;
            color: white;
        }
        
        .btn-danger {
            background-color: #9b2c2c;
            color: white;
        }
        
        .no-data {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            font-style: italic;
        }

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .actions { justify-content: flex-start; }
            .search-input { width: 180px; }
            .stats-container { grid-template-columns: 1fr; }
            .progress-stats { grid-template-columns: 1fr; }
        }
    </style>
</head>

<body>
<div class="overlay">
    <!-- HEADER -->
    <div class="top-nav">

        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png">
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

            <div class="card-panel">
                <div class="panel-header">
                    <h4>Installment Details</h4>
                </div>

                <div class="installment-container">
                    <% 
                        Billing billing = (Billing) request.getAttribute("billing");
                        List<Installment> installments = (List<Installment>) request.getAttribute("installments");
                        DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                        
                        BigDecimal totalAmount = BigDecimal.ZERO;
                        BigDecimal totalPaid = BigDecimal.ZERO;
                        BigDecimal totalRemaining = BigDecimal.ZERO;
                        int paidCount = 0;
                        int totalCount = 0;
                        
                        if (billing != null) {
                            totalAmount = billing.getBillingAmount();
                        }
                        
                        if (installments != null && !installments.isEmpty()) {
                            totalCount = installments.size();
                            for (Installment inst : installments) {
                                totalPaid = totalPaid.add(inst.getPaidAmount());
                                if ("Paid".equals(inst.getPaymentStatus())) {
                                    paidCount++;
                                }
                            }
                        }
                        
                        totalRemaining = totalAmount.subtract(totalPaid);
                        
                        int paymentProgress = 0;
                        if (totalAmount.compareTo(BigDecimal.ZERO) > 0) {
                            paymentProgress = (int) ((totalPaid.doubleValue() / totalAmount.doubleValue()) * 100);
                            if (paymentProgress > 100) paymentProgress = 100;
                            if (paymentProgress < 0) paymentProgress = 0;
                        }
                    %>
                    
                    <% if (billing == null) { %>
                        <div class="alert alert-warning">
                            Billing information not found.
                        </div>
                    <% } else { %>
                    
                    <!-- Billing Summary Card -->
                    <div class="summary-card">
                        <div class="summary-header">
                            <h3>Billing Summary</h3>
                        </div>
                        <div class="summary-body">
                            <table class="summary-table">
                                <tr>
                                    <th>Billing ID:</th>
                                    <td><span class="badge badge-dark"><%= billing.getBillingId() %></span></td>
                                    <th>Appointment ID:</th>
                                    <td><%= billing.getAppointmentId() %></td>
                                </tr>
                                <tr>
                                    <th>Total Amount:</th>
                                    <td class="amount-total"><%= currencyFormat.format(totalAmount) %></td>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge <%= "Paid".equals(billing.getBillingStatus()) ? "badge-success" : "badge-warning" %>">
                                            <%= billing.getBillingStatus() %>
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Installments:</th>
                                    <td><%= totalCount %> installment(s)</td>
                                    <th>Method:</th>
                                    <td>
                                        <span class="badge badge-info">
                                            <%= billing.getBillingMethod() %>
                                        </span>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    
                    <!-- Payment Progress -->
                    <div class="progress-container">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
                            <div>
                                <h4 style="margin: 0; color: var(--green-dark);">Payment Progress</h4>
                                <div style="color: #666; margin-top: 5px;">
                                    <%= paidCount %> of <%= totalCount %> installments paid
                                </div>
                            </div>
                            <div style="text-align: right;">
                                <h4 style="margin: 0; color: var(--green-dark);">
                                    <%= currencyFormat.format(totalPaid) %> / <%= currencyFormat.format(totalAmount) %>
                                </h4>
                                <div style="color: #666; margin-top: 5px;">
                                    <%= paymentProgress %>% completed
                                </div>
                            </div>
                        </div>
                        
                        <div class="progress">
                            <div class="progress-bar" role="progressbar" 
                                 style="width: <%= paymentProgress %>%;" 
                                 aria-valuenow="<%= paymentProgress %>" 
                                 aria-valuemin="0" 
                                 aria-valuemax="100">
                            </div>
                        </div>
                        
                        <div class="progress-stats">
                            <div class="progress-stat-item">
                                <div style="font-size: 18px; color: #2a6b48;">✓</div>
                                <div style="font-weight: bold; font-size: 16px;"><%= currencyFormat.format(totalPaid) %></div>
                                <div style="color: #666;">Paid</div>
                            </div>
                            <div class="progress-stat-item">
                                <div style="font-size: 18px; color: #856404;">⏱️</div>
                                <div style="font-weight: bold; font-size: 16px;"><%= currencyFormat.format(totalRemaining) %></div>
                                <div style="color: #666;">Remaining</div>
                            </div>
                            <div class="progress-stat-item">
                                <div style="font-size: 18px; color: var(--green-dark);">💰</div>
                                <div style="font-weight: bold; font-size: 16px;"><%= currencyFormat.format(totalAmount) %></div>
                                <div style="color: #666;">Total</div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Installments Table -->
                    <div class="table-wrap" style="margin-top: 20px;">
                        <table class="table mb-0 installment-table">
                            <thead>
                                <tr>
                                    <th>No</th>
                                    <th>Due Date</th>
                                    <th>Installment Amount</th>
                                    <th>Paid Amount</th>
                                    <th>Remaining</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    if (installments != null && !installments.isEmpty()) {
                                        int installmentNumber = 1;
                                        for (Installment installment : installments) {
                                %>
                                <tr>
                                    <td style="font-weight: bold;"><%= installmentNumber++ %></td>
                                    <td><%= installment.getPaymentDate() %></td>
                                    <td style="font-weight: bold;"><%= currencyFormat.format(installment.getPaymentAmount()) %></td>
                                    <td>
                                        <span class="<%= installment.getPaidAmount().compareTo(BigDecimal.ZERO) > 0 ? "amount-paid" : "" %>">
                                            <%= currencyFormat.format(installment.getPaidAmount()) %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="<%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "amount-remaining" : "amount-paid" %>">
                                            <%= currencyFormat.format(installment.getRemainingAmount()) %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= 
                                            "Paid".equals(installment.getPaymentStatus()) ? "badge-success" : 
                                            "Partial".equals(installment.getPaymentStatus()) ? "badge-warning" : "badge-danger" 
                                        %>">
                                            <%= installment.getPaymentStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <% if (!"Paid".equals(installment.getPaymentStatus())) { %>
                                            <a href="BillingServlet?action=make_payment_form&installment_id=<%= installment.getInstallmentId() %>"
                                               class="action-pill action-view">
                                                <i class="fa-solid fa-money-bill"></i> Make Payment
                                            </a>
                                            <% } else { %>
                                            <span class="badge badge-success">
                                                Fully Paid
                                            </span>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3" style="text-align: right; font-weight: bold;">Billing Total:</td>
                                    <td class="amount-total"><%= currencyFormat.format(totalAmount) %></td>
                                    <td class="amount-paid"><%= currencyFormat.format(totalPaid) %></td>
                                    <td class="amount-remaining"><%= currencyFormat.format(totalRemaining) %></td>
                                    <td colspan="2">
                                        <span class="badge badge-info">
                                            <%= paidCount %> paid / <%= totalCount %> total
                                        </span>
                                    </td>
                                </tr>
                            </tfoot>
                            <% } else { %>
                            <tbody>
                                <tr>
                                    <td colspan="7" class="no-data">
                                        <div style="font-size: 48px; margin-bottom: 15px;">📄</div>
                                        <h5>No Installments Found</h5>
                                        <p style="color: #666; margin: 10px 0 20px 0;">
                                            This billing does not have any installment records.
                                        </p>
                                        <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>" 
                                           class="btn btn-primary">
                                            <i class="fa-solid fa-plus"></i> Add Installments
                                        </a>
                                    </td>
                                </tr>
                            </tbody>
                            <% } %>
                        </table>
                    </div>
                    
                    <% if (installments != null && !installments.isEmpty()) { %>
                    <!-- Payment Statistics -->
                    <div class="stats-container">
                        <div class="stat-card">
                            <div style="font-size: 24px; color: #2a6b48;">✓</div>
                            <div class="stat-value"><%= paidCount %></div>
                            <div>Installments Paid</div>
                        </div>
                        <div class="stat-card">
                            <div style="font-size: 24px; color: #856404;">⏱️</div>
                            <div class="stat-value"><%= totalCount - paidCount %></div>
                            <div>Pending/Partial</div>
                        </div>
                        <div class="stat-card">
                            <div style="font-size: 24px; color: var(--green-dark);">%</div>
                            <div class="stat-value"><%= paymentProgress %>%</div>
                            <div>Payment Completed</div>
                        </div>
                    </div>
                    <% } %>
                    
                    <!-- Action Buttons -->
                    <div class="action-buttons-container">
                        <div class="actions">
                            <a href="BillingServlet?action=view&billing_id=<%= billing.getBillingId() %>"
                               class="action-pill action-view">
                                <i class="fa-solid fa-eye"></i> View Billing
                            </a>
                            
                            <% if ("Pending".equals(billing.getBillingStatus())) { %>
                            <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>"
                               class="action-pill action-edit">
                                <i class="fa-solid fa-pen"></i> Edit
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

<script>
    function toggleQuickActions() {
        var dropdown = document.getElementById('quickActionsDropdown');
        dropdown.style.display = dropdown.style.display === 'block' ? 'none' : 'block';
    }
    
    function markAllAsPaid(billingId) {
        if (confirm('Mark all installments as fully paid? This will update the billing status to Paid.')) {
            window.location.href = 'BillingServlet?action=pay_all&billing_id=' + billingId;
        }
    }
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
        var dropdown = document.getElementById('quickActionsDropdown');
        var button = document.querySelector('.action-pill');
        if (dropdown && !dropdown.contains(event.target) && !button.contains(event.target)) {
            dropdown.style.display = 'none';
        }
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>