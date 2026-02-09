<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="beans.Installment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    // ===== Session / Role detect =====
    String patientName = (String) session.getAttribute("patientName");
    String patientId   = (String) session.getAttribute("patientId");

    boolean isPatient  = (patientId != null);

    if (!isPatient) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String displayName = patientName;
%>

<%!
    private String escAttr(String s){
        if(s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;")
                .replace("\r","")
                .replace("\n","&#10;");
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
        .user-area {
            display: flex;
            align-items: center;
            gap: 12px;
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
        .logout-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            border-radius: 999px;
            background: #c96a6a;
            color: #fff;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            box-shadow: 0 6px 14px rgba(0,0,0,0.18);
            transition: all .2s ease;
            border: none;
            cursor: pointer;
        }
        .logout-btn:hover {
            background: #b95a5a;
            transform: translateY(-1px);
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
            color: #fff;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,.25);
        }
        .side-link {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #fff;
            padding: 9px 10px;
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .side-link i{
            width: 18px;
            text-align: center;
            opacity: .95;
        }
        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, .14);
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
            padding: 12px 14px;
        }
        .table tbody td {
            font-size: 14px;
            vertical-align: middle;
            padding: 12px 14px;
        }

        /* Status pills */
        .status-pill {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            background: #e7f4ec;
            color: #2a6b48;
            display: inline-block;
            font-weight: 600;
        }
        .status-pill.pending {
            background: #fff8e6;
            color: #8a6d3b;
        }
        .status-pill.overdue {
            background: #f6e6e6;
            color: #9b2c2c;
        }
        .status-pill.installment {
            background: #e0f2fe;
            color: #0369a1;
        }
        .status-pill.partial {
            background: #fff3cd;
            color: #856404;
        }

        .actions {
            display: flex;
            gap: 8px;
            justify-content: flex-start;
            flex-wrap: nowrap;
        }
        .action-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
            white-space: nowrap;
            min-width: 70px;
            justify-content: center;
            cursor: pointer;
        }
        .action-pill i {
            font-size: 12px;
            width: 14px;
            text-align: center;
        }
        .action-pill:hover{
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }
        .action-view {
            border-color: #cfe0d5;
            color: #5a4f1a;
        }
        .action-edit {
            border-color: #e6dfb9;
            color: #5a4f1a;
        }
        .action-installment {
            border-color: #c9d8f2;
            color: #1b4b99;
        }
        .action-back {
            border-color: #e0e0e0;
            color: #5a4f1a;
        }

        .alert {
            border-radius: 10px;
            margin: 0 6% 12px;
        }

        /* Custom styles for billing details page */
        .billing-details-content {
            flex: 1;
            overflow-y: auto;
            padding-right: 5px;
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

        /* Updated status pills to match appointment page style */
        .billing-status {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .billing-status.paid {
            background: #e7f4ec;
            color: #2a6b48;
        }
        
        .billing-status.pending {
            background: #fff8e6;
            color: #8a6d3b;
        }
        
        .billing-status.overdue {
            background: #f6e6e6;
            color: #9b2c2c;
        }
        
        .billing-status.cancelled {
            background: #f6e6e6;
            color: #110f0f;
        }

        .installment-status {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .installment-status.paid {
            background: #e7f4ec;
            color: #2a6b48;
        }
        
        .installment-status.partial {
            background: #fff8e6;
            color: #8a6d3b;
        }
        
        .installment-status.overdue {
            background: #f6e6e6;
            color: #9b2c2c;
        }
        
        .installment-status.pending {
            background: #e0f2fe;
            color: #0369a1;
        }

        @media (max-width: 992px) {
            body { overflow: auto; }
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; height: auto; overflow: visible; }
            .top-nav { padding: 18px 24px 8px; flex-wrap: wrap; gap: 10px; }
            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }
            .action-buttons-container {
                flex-direction: column;
                gap: 12px;
                align-items: flex-start;
            }
            .actions {
                justify-content: flex-start;
                flex-wrap: wrap;
            }
            .card-panel { height: auto; overflow: visible; }
        }
    </style>
</head>

<body>
<div class="overlay">

    <!-- TOP HEADER - Same as appointment page -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-area">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= displayName != null ? displayName : "-" %></span>
            </div>

            <form action="<%=request.getContextPath()%>/LogoutServlet" method="post" style="margin:0;">
                <button type="submit" class="logout-btn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
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

            <!-- SIDEBAR - Same as appointment page -->
            <div class="sidebar">
                <h6>Patient Dashboard</h6>

                <a class="side-link" href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> View Appointment
                </a>

                <a class="side-link active" href="<%=request.getContextPath()%>/PatientBillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> My Billings
                </a>

                <a class="side-link" href="<%=request.getContextPath()%>/ProfileServlet">
                    <i class="fa-solid fa-user"></i> My Profile
                </a>
            </div>

            <!-- CONTENT -->
            <div class="card-panel">

                <div class="panel-header">
                    <h4>Billing Details</h4>
                    <div class="actions">
                        <a href="<%=request.getContextPath()%>/PatientBillingServlet?action=list" 
                           class="action-pill action-back" title="Back to billings">
                            <i class="fa-solid fa-arrow-left"></i> Back
                        </a>
                    </div>
                </div>
                
                <div class="billing-details-content">
                    <% 
                        Billing billing = (Billing) request.getAttribute("billing");
                        List<Installment> installments = (List<Installment>) request.getAttribute("installments");
                        String appointmentDate = (String) request.getAttribute("appointmentDate");
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                    %>
                    
                    <% if (billing == null) { %>
                        <div class="alert alert-warning">
                            <i class="fa-solid fa-triangle-exclamation"></i> Billing not found.
                        </div>
                    <% } else { %>
                    
                    <!-- Billing Information Card -->
                    <div class="details-card">
                        <div class="details-card-header">
                            <i class="fa-solid fa-receipt me-2"></i> Billing Information
                        </div>
                        <div class="details-card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <table class="info-table">
                                        <tr>
                                            <th>Billing ID:</th>
                                            <td>
                                                <span class="badge badge-dark">
                                                    <i class="fa-solid fa-hashtag me-1"></i>
                                                    <%= billing.getBillingId() %>
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Appointment ID:</th>
                                            <td>
                                                <span class="badge badge-secondary">
                                                    <i class="fa-solid fa-calendar-check me-1"></i>
                                                    <%= billing.getAppointmentId() %>
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Appointment Date:</th>
                                            <td>
                                                <i class="fa-solid fa-calendar-day me-1 text-muted"></i>
                                                <%= appointmentDate != null ? appointmentDate : "N/A" %>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="col-md-6">
                                    <table class="info-table">
                                        <tr>
                                            <th>Status:</th>
                                            <td>
                                                <%
                                                    String statusClass = "";
                                                    if ("Paid".equalsIgnoreCase(billing.getBillingStatus())) {
                                                        statusClass = "billing-status paid";
                                                    } else if ("Pending".equalsIgnoreCase(billing.getBillingStatus())) {
                                                        statusClass = "billing-status pending";
                                                    } else {
                                                        statusClass = "billing-status overdue";
                                                    }
                                                %>
                                                <span class="<%= statusClass %>">
                                                    <% if ("Paid".equalsIgnoreCase(billing.getBillingStatus())) { %>
                                                        <i class="fa-solid fa-check-circle me-1"></i>
                                                    <% } else if ("Pending".equalsIgnoreCase(billing.getBillingStatus())) { %>
                                                        <i class="fa-solid fa-clock me-1"></i>
                                                    <% } else { %>
                                                        <i class="fa-solid fa-exclamation-triangle me-1"></i>
                                                    <% } %>
                                                    <%= billing.getBillingStatus() %>
                                                </span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Total Amount:</th>
                                            <td class="amount-text">
                                                <i class="fa-solid fa-money-bill-wave me-1"></i>
                                                <%= currencyFormat.format(billing.getBillingAmount()) %>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Due Date:</th>
                                            <td>
                                                <i class="fa-solid fa-calendar-check me-1 text-muted"></i>
                                                <%= billing.getBillingDuedate() != null ? dateFormat.format(billing.getBillingDuedate()) : "Not Set" %>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            
                            <div class="row mt-4">
                                <div class="col-md-12">
                                    <table class="info-table">
                                        <tr>
                                            <th>Payment Method:</th>
                                            <td>
                                                <span class="status-pill <%= "Installment".equalsIgnoreCase(billing.getBillingMethod()) ? "installment" : "" %>">
                                                    <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) { %>
                                                        <i class="fa-solid fa-calendar-alt me-1"></i>
                                                    <% } else { %>
                                                        <i class="fa-solid fa-money-bill-wave me-1"></i>
                                                    <% } %>
                                                    <%= billing.getBillingMethod() %>
                                                </span>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod()) && installments != null && !installments.isEmpty()) { %>
                    <!-- Installment Details Card -->
                    <div class="details-card">
                        <div class="details-card-header" style="background: #264232;">
                            <i class="fa-solid fa-calendar-alt me-2"></i> Installment Schedule
                        </div>
                        <div class="details-card-body">
                            <div class="table-wrap">
                                <table class="table mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 60px;">#</th>
                                            <th style="width: 140px;">Payment Date</th>
                                            <th style="width: 150px;">Amount</th>
                                            <th style="width: 150px;">Paid Amount</th>
                                            <th style="width: 150px;">Remaining</th>
                                            <th style="width: 120px;">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            int installmentNum = 0;
                                            BigDecimal totalInstallmentAmount = BigDecimal.ZERO;
                                            BigDecimal totalPaidAmount = BigDecimal.ZERO;
                                            BigDecimal totalRemainingAmount = BigDecimal.ZERO;
                                            
                                            for (Installment installment : installments) { 
                                                installmentNum++;
                                                totalInstallmentAmount = totalInstallmentAmount.add(installment.getPaymentAmount());
                                                totalPaidAmount = totalPaidAmount.add(installment.getPaidAmount());
                                                totalRemainingAmount = totalRemainingAmount.add(installment.getRemainingAmount());
                                        %>
                                        <tr>
                                            <td><strong><%= installmentNum %></strong></td>
                                            <td><%= installment.getPaymentDate() %></td>
                                            <td class="fw-bold"><%= currencyFormat.format(installment.getPaymentAmount()) %></td>
                                            <td><%= currencyFormat.format(installment.getPaidAmount()) %></td>
                                            <td class="<%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-danger fw-bold" : "text-success fw-bold" %>">
                                                <%= currencyFormat.format(installment.getRemainingAmount()) %>
                                            </td>
                                            <td>
                                                <%
                                                    String installmentStatusClass = "";
                                                    String status = installment.getPaymentStatus();
                                                    if ("Paid".equalsIgnoreCase(status)) {
                                                        installmentStatusClass = "installment-status paid";
                                                    } else if ("Partial".equalsIgnoreCase(status)) {
                                                        installmentStatusClass = "installment-status partial";
                                                    } else if ("Overdue".equalsIgnoreCase(status)) {
                                                        installmentStatusClass = "installment-status overdue";
                                                    } else {
                                                        installmentStatusClass = "installment-status pending";
                                                    }
                                                %>
                                                <span class="<%= installmentStatusClass %>">
                                                    <% if ("Paid".equalsIgnoreCase(status)) { %>
                                                        <i class="fa-solid fa-check-circle me-1"></i>
                                                    <% } else if ("Partial".equalsIgnoreCase(status)) { %>
                                                        <i class="fa-solid fa-clock me-1"></i>
                                                    <% } else if ("Overdue".equalsIgnoreCase(status)) { %>
                                                        <i class="fa-solid fa-exclamation-triangle me-1"></i>
                                                    <% } else { %>
                                                        <i class="fa-solid fa-clock me-1"></i>
                                                    <% } %>
                                                    <%= status %>
                                                </span>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                    <tfoot style="background: #f8f9fa; font-weight: bold; border-top: 2px solid #e0e0e0;">
                                        <tr>
                                            <td colspan="2" class="text-end fw-bold">Totals:</td>
                                            <td class="fw-bold"><%= currencyFormat.format(totalInstallmentAmount) %></td>
                                            <td class="text-success fw-bold"><%= currencyFormat.format(totalPaidAmount) %></td>
                                            <td class="text-danger fw-bold"><%= currencyFormat.format(totalRemainingAmount) %></td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            
                            <div class="row mt-4">
                                <div class="col-md-12">
                                    <div class="alert alert-info mb-0">
                                        <i class="fa-solid fa-info-circle me-2"></i>
                                        <strong>Installment Summary:</strong> 
                                        Total of <%= installments.size() %> installment(s). 
                                        <%= totalPaidAmount.compareTo(BigDecimal.ZERO) > 0 ? 
                                            currencyFormat.format(totalPaidAmount) + " paid, " : "" %>
                                        <%= totalRemainingAmount.compareTo(BigDecimal.ZERO) > 0 ? 
                                            currencyFormat.format(totalRemainingAmount) + " remaining." : "Fully paid." %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    
                    <!-- Action Buttons -->
                    <div class="action-buttons-container">
                        <div class="actions">
                            
                            <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) { %>
                            
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