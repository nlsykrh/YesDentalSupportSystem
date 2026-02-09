<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="beans.Installment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    String patientName = (String) session.getAttribute("patientName");
    String patientId = (String) session.getAttribute("patientId");

    if(patientName == null){
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
        
        /* ===== BODY ===== */
        body{
            margin:0;
            min-height:100vh;
            background:url("<%=request.getContextPath()%>/YesDentalPic/Background.png") no-repeat center center fixed;
            background-size:cover;
            font-family:"Segoe UI",sans-serif;
        }

        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,0.38);
            backdrop-filter:blur(1.5px);
        }

        /* ===== HEADER ===== */
        .top-nav{
            display:flex;
            justify-content:space-between;
            align-items:center;
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

        /* USER AREA */
        .user-area{
            display:flex;
            align-items:center;
            gap:15px;
        }

        .user-chip{
            background:#f3f3f3;
            padding:6px 14px;
            border-radius:20px;
            font-size:13px;
            display:flex;
            align-items:center;
            gap:6px;
        }

        .logout-btn{
            background:#d96c6c;
            color:white;
            border:none;
            border-radius:40px;
            padding:7px 18px;
            font-weight:600;
            box-shadow:0 6px 14px rgba(0,0,0,0.2);
        }

        /* ===== LAYOUT ===== */
        .layout-wrap{
            width:100%;
            padding:30px 60px 40px;
        }

        .layout{
            display:grid;
            grid-template-columns:280px 1fr;
            gap:24px;
        }

        /* ===== SIDEBAR ===== */
        .sidebar{
            background:var(--green-deep);
            color:white;
            border-radius:14px;
            padding:20px 16px;
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
            padding:9px 10px;
            border-radius:10px;
            text-decoration:none;
            font-size:14px;
            margin-bottom:6px;
        }

        .side-link i{
            width:18px;
            text-align:center;
        }

        .side-link:hover,
        .side-link.active{
            background:rgba(255,255,255,0.14);
            color:#ffe69b;
        }

        /* ===== MAIN PANEL ===== */
        .card-panel{
            background:rgba(255,255,255,0.92);
            border-radius:16px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,0.1);
        }

        /* HEADER TEXT */
        .panel-header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:15px;
        }

        .panel-header h4{
            font-weight:700;
            margin:0;
        }

        /* Custom styles for installment details page */
        .installment-details-content {
            overflow-y: auto;
            padding-right: 5px;
        }
        
        .installment-details-content h2 {
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
        
        /* Installment specific styles */
        .installment-card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 15px;
            transition: transform 0.3s ease;
        }
        
        .installment-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        
        .installment-number {
            width: 40px;
            height: 40px;
            background: var(--green-deep);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 18px;
        }
        
        .progress-container {
            margin: 20px 0;
        }
        
        .summary-card {
            background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .payment-status-badge {
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .timeline {
            position: relative;
            padding-left: 30px;
            margin: 20px 0;
        }
        
        .timeline::before {
            content: '';
            position: absolute;
            left: 15px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #dee2e6;
        }
        
        .timeline-item {
            position: relative;
            margin-bottom: 20px;
        }
        
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -31px;
            top: 5px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #4facfe;
            border: 3px solid white;
            box-shadow: 0 0 0 3px #4facfe;
        }
        
        .timeline-item.paid::before {
            background: #28a745;
            box-shadow: 0 0 0 3px #28a745;
        }
        
        .timeline-item.partial::before {
            background: #ffc107;
            box-shadow: 0 0 0 3px #ffc107;
        }
        
        .timeline-item.overdue::before {
            background: #dc3545;
            box-shadow: 0 0 0 3px #dc3545;
        }

        .alert { border-radius: 10px; margin: 0 6% 12px; }

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

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
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
        <img src="<%=request.getContextPath()%>/YesDentalPic/Logo.png">
        <div class="clinic-title">Yes Dental Clinic</div>
    </div>

    <div class="user-area">

        <div class="user-chip">
            <i class="fa fa-user"></i>
            <%= patientName %>
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

<!-- SIDEBAR -->
<div class="sidebar">

    <h6>Patient Dashboard</h6>

    <a class="side-link"
       href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
        <i class="fa-solid fa-chart-line"></i> Dashboard
    </a>

    <a class="side-link"
       href="<%=request.getContextPath()%>/appointment/viewAppointment.jsp">
        <i class="fa-solid fa-calendar-check"></i> View Appointment
    </a>

    <a class="side-link active"
       href="<%=request.getContextPath()%>/billing/viewBilling.jsp">
        <i class="fa-solid fa-file-invoice-dollar"></i> Billing
    </a>

    <a class="side-link"
       href="<%=request.getContextPath()%>/ProfileServlet">
        <i class="fa-solid fa-user"></i> My Profile
    </a>

</div>

<!-- CONTENT -->
<div class="card-panel">

    <div class="panel-header">
        <h4>
            Hi! <%= patientName %>
        </h4>

        <div style="font-size:13px;color:#666;">
            <i class="fa fa-id-card"></i>
            IC: <%= patientId %>
        </div>
    </div>
    
    <div class="installment-details-content">
        <% 
            Billing billing = (Billing) request.getAttribute("billing");
            List<Installment> installments = (List<Installment>) request.getAttribute("installments");
            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            
            if (billing == null || installments == null || installments.isEmpty()) {
        %>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i> No installment plan found for this billing.
            </div>
            <a href="/YesDentalSupportSystem/PatientBillingServlet?action=list" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to My Billings
            </a>
        <% } else { 
            BigDecimal totalAmount = BigDecimal.ZERO;
            BigDecimal totalPaid = BigDecimal.ZERO;
            BigDecimal totalRemaining = BigDecimal.ZERO;
            int totalInstallments = installments.size();
            int paidInstallments = 0;
            int pendingInstallments = 0;
            int overdueInstallments = 0;
            
            for (Installment inst : installments) {
                totalAmount = totalAmount.add(inst.getPaymentAmount());
                totalPaid = totalPaid.add(inst.getPaidAmount());
                totalRemaining = totalRemaining.add(inst.getRemainingAmount());
                
                if ("Paid".equals(inst.getPaymentStatus())) {
                    paidInstallments++;
                } else if ("Overdue".equals(inst.getPaymentStatus())) {
                    overdueInstallments++;
                } else {
                    pendingInstallments++;
                }
            }
        %>
        
        <div class="details-card">
            <div class="details-card-header" style="background: #17a2b8;">
                Billing & Installment Overview
            </div>
            <div class="details-card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h5><i class="fas fa-file-invoice text-primary"></i> Billing Summary</h5>
                        <table class="info-table">
                            <tr>
                                <th>Billing ID:</th>
                                <td><span class="badge badge-dark"><%= billing.getBillingId() %></span></td>
                            </tr>
                            <tr>
                                <th>Total Amount:</th>
                                <td class="fw-bold text-primary"><%= currencyFormat.format(billing.getBillingAmount()) %></td>
                            </tr>
                            <tr>
                                <th>Due Date:</th>
                                <td><%= billing.getBillingDuedate() != null ? dateFormat.format(billing.getBillingDuedate()) : "Not Set" %></td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h5><i class="fas fa-chart-pie text-info"></i> Installment Overview</h5>
                        <table class="info-table">
                            <tr>
                                <th>Total Installments:</th>
                                <td><span class="badge bg-info"><%= totalInstallments %></span></td>
                            </tr>
                            <tr>
                                <th>Completed:</th>
                                <td><span class="badge bg-success"><%= paidInstallments %></span></td>
                            </tr>
                            <tr>
                                <th>Pending:</th>
                                <td><span class="badge bg-warning"><%= pendingInstallments %></span></td>
                            </tr>
                            <tr>
                                <th>Overdue:</th>
                                <td><span class="badge bg-danger"><%= overdueInstallments %></span></td>
                            </tr>
                        </table>
                    </div>
                </div>
                
                <!-- Payment Progress -->
                <div class="progress-container">
                    <div class="d-flex justify-content-between mb-2">
                        <span>Payment Progress</span>
                        <span><%= paidInstallments %>/<%= totalInstallments %> (<%= totalInstallments > 0 ? (paidInstallments * 100) / totalInstallments : 0 %>%)</span>
                    </div>
                    <div class="progress" style="height: 25px;">
                        <div class="progress-bar bg-success" role="progressbar" 
                             style="width: <%= totalInstallments > 0 ? (paidInstallments * 100) / totalInstallments : 0 %>%">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Installment Timeline View -->
        <div class="details-card">
            <div class="details-card-header">
                <i class="fas fa-stream"></i> Installment Timeline
            </div>
            <div class="details-card-body">
                <div class="timeline">
                    <%
                        int installmentNum = 0;
                        for (Installment installment : installments) {
                            installmentNum++;
                            String statusClass = "";
                            if ("Paid".equals(installment.getPaymentStatus())) {
                                statusClass = "paid";
                            } else if ("Partial".equals(installment.getPaymentStatus())) {
                                statusClass = "partial";
                            } else if ("Overdue".equals(installment.getPaymentStatus())) {
                                statusClass = "overdue";
                            }
                    %>
                    <div class="timeline-item <%= statusClass %>">
                        <div class="installment-card">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <div class="col-md-1">
                                        <div class="installment-number"><%= installmentNum %></div>
                                    </div>
                                    <div class="col-md-3">
                                        <h6 class="mb-1"><i class="fas fa-calendar-day"></i> <%= installment.getPaymentDate() %></h6>
                                        <small class="text-muted">Due Date</small>
                                    </div>
                                    <div class="col-md-2">
                                        <h6 class="mb-1"><%= currencyFormat.format(installment.getPaymentAmount()) %></h6>
                                        <small class="text-muted">Amount</small>
                                    </div>
                                    <div class="col-md-2">
                                        <h6 class="mb-1 text-success"><%= currencyFormat.format(installment.getPaidAmount()) %></h6>
                                        <small class="text-muted">Paid</small>
                                    </div>
                                    <div class="col-md-2">
                                        <h6 class="mb-1 <%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-danger" : "text-success" %>">
                                            <%= currencyFormat.format(installment.getRemainingAmount()) %>
                                        </h6>
                                        <small class="text-muted">Remaining</small>
                                    </div>
                                    <div class="col-md-2">
                                        <span class="badge <%= "Paid".equals(installment.getPaymentStatus()) ? "badge-success" : 
                                                           "Partial".equals(installment.getPaymentStatus()) ? "badge-warning" : 
                                                           "Overdue".equals(installment.getPaymentStatus()) ? "badge-danger" : "badge-secondary" %>">
                                            <i class="fas fa-circle"></i> <%= installment.getPaymentStatus() %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Total Summary -->
        <div class="details-card">
            <div class="details-card-header" style="background: #343a40;">
                <i class="fas fa-calculator"></i> Payment Summary
            </div>
            <div class="details-card-body">
                <div class="row">
                    <div class="col-md-4 text-center">
                        <h6>Total Installment Amount</h6>
                        <h3 class="text-primary"><%= currencyFormat.format(totalAmount) %></h3>
                    </div>
                    <div class="col-md-4 text-center">
                        <h6>Total Paid Amount</h6>
                        <h3 class="text-success"><%= currencyFormat.format(totalPaid) %></h3>
                    </div>
                    <div class="col-md-4 text-center">
                        <h6>Total Remaining Amount</h6>
                        <h3 class="<%= totalRemaining.compareTo(BigDecimal.ZERO) > 0 ? "text-danger" : "text-success" %>">
                            <%= currencyFormat.format(totalRemaining) %>
                        </h3>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Important Information -->
        <div class="alert alert-info">
            <h5><i class="fas fa-info-circle"></i> Important Information</h5>
            <ul class="mb-0">
                <li>All payments are to be made at the clinic counter during operating hours</li>
                <li>Late payments may incur additional charges</li>
                <li>Please bring your billing ID for reference when making payments</li>
                <li>Contact 03-1234 5678 for any payment-related inquiries</li>
            </ul>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons-container">
            <a href="/YesDentalSupportSystem/PatientBillingServlet?action=view&billing_id=<%= billing.getBillingId() %>" 
               class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Billing Details
            </a>
            
            <div class="actions">
                <a href="/YesDentalSupportSystem/PatientBillingServlet?action=list" 
                   class="action-pill">
                   <i class="fas fa-list"></i> All Billings
                </a>
                
<!--                <button onclick="window.print()" class="action-pill">
                    <i class="fas fa-print"></i> Print Schedule
                </button>-->
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