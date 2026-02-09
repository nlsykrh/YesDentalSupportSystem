<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - My Billings</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root {
            --green-dark: #2f4a34;
            --green-deep: #264232;
            --gold-soft: #d7d1a6;
        }
        body {
            margin: 0;
            min-height: 100vh;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
            font-family: "Segoe UI", sans-serif;
            overflow-y: auto; /* Changed from hidden to auto for scrolling */
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
        .top-links a {
            color: #5f6a63;
            text-decoration: none;
            margin: 0 10px;
            font-size: 14px;
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
            min-height: calc(100vh - 100px);
        }
        .layout{
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            min-height: 100%;
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
            display: flex;
            flex-direction: column;
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 20px;
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
        .status-pill.info{
            background: #d1ecf1;
            color: #0c5460;
        }
        .status-pill.secondary{
            background: #e2e3e5;
            color: #383d41;
        }
        .status-pill.warning{
            background: #fff3cd;
            color: #856404;
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
        .action-installment { border-color: #d1ecf1; color: #0c5460; }

        .alert { 
            border-radius: 10px; 
            margin: 0 6% 12px; 
        }
        
        /* Custom styles for billing list page */
        .welcome-header {
            background: var(--green-deep);
            color: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 24px;
        }
        
        .welcome-header h4 {
            color: white;
            margin: 0 0 8px 0;
            font-size: 20px;
        }
        
        .welcome-header p {
            margin: 0;
            opacity: 0.9;
            font-size: 14px;
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
        
        .text-danger {
            color: #dc3545 !important;
        }
        
        .text-success {
            color: #28a745 !important;
        }
        
        .text-warning {
            color: #ffc107 !important;
        }
        
        .fw-bold {
            font-weight: bold;
        }
        
        .total-summary {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 24px;
            border-left: 4px solid var(--green-dark);
            border: 1px solid #e0e0e0;
        }
        
        .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            align-items: center;
        }
        
        .summary-item span {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #555;
        }
        
        .summary-item strong {
            font-size: 16px;
        }

        @media (max-width: 992px) {
            .layout { 
                grid-template-columns: 1fr; 
                gap: 20px;
            }
            .layout-wrap { 
                padding: 20px; 
            }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .panel-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            .search-wrap {
                width: 100%;
                justify-content: space-between;
            }
            .search-input {
                flex: 1;
                max-width: 300px;
            }
            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }
            .actions {
                justify-content: flex-start;
                flex-wrap: wrap;
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
        <div class="alert alert-success">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">${error}</div>
    <% } %>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Patient Dashboard</h6>
                <a class="side-link" href="<%=request.getContextPath()%>/patient/patientDashboard.jsp">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>

                    <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">
                        <i class="fa-solid fa-calendar-check"></i> View Appointment
                    </a>

                    <a class="side-link active" href="<%=request.getContextPath()%>/PatientBillingServlet?action=list"">
                        <i class="fa-solid fa-file-invoice-dollar"></i> My Billings
                    </a>

                    <a class="side-link" href="<%=request.getContextPath()%>/ProfileServlet">
                        <i class="fa-solid fa-user"></i> My Profile
                    </a>
            </div>

            <div class="card-panel">
                <div class="welcome-header">
                    <h4><i class="fas fa-file-invoice-dollar"></i> My Billings</h4>
                    <p class="mb-0">View and manage your billing records</p>
                </div>
                
                <div class="panel-header">
                    <div>
                        <h4>Billing Records</h4>
                        <small class="text-muted">Total: <%= request.getAttribute("billings") != null ? ((List<?>) request.getAttribute("billings")).size() : 0 %> records</small>
                    </div>
                    <div class="search-wrap">
                        <input id="billingSearch" type="text" class="search-input" placeholder="Search by ID / Status / Method...">
                        <!--<a href="/YesDentalSupportSystem/patient/patientDashboard.jsp" class="btn-add">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </a>-->
                    </div>
                </div>

                <!-- Billing Summary -->
                <%
                    List<Billing> billings = (List<Billing>) request.getAttribute("billings");
                    DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                    BigDecimal totalAmount = BigDecimal.ZERO;
                    BigDecimal totalPaid = BigDecimal.ZERO;
                    int pendingCount = 0;
                    
                    if (billings != null && !billings.isEmpty()) {
                        for (Billing billing : billings) {
                            totalAmount = totalAmount.add(billing.getBillingAmount());
                            if ("Paid".equalsIgnoreCase(billing.getBillingStatus())) {
                                totalPaid = totalPaid.add(billing.getBillingAmount());
                            } else {
                                pendingCount++;
                            }
                        }
                    }
                %>
                
                <div class="total-summary">
                    <div class="summary-item">
                        <span><i class="fas fa-receipt" style="color: var(--green-dark);"></i> Total Billings:</span>
                        <strong><%= currencyFormat.format(totalAmount) %></strong>
                    </div>
                    <div class="summary-item">
                        <span><i class="fas fa-check-circle text-success"></i> Paid Amount:</span>
                        <strong class="text-success"><%= currencyFormat.format(totalPaid) %></strong>
                    </div>
                    <div class="summary-item">
                        <span><i class="fas fa-clock text-warning"></i> Pending Payments:</span>
                        <strong class="text-warning"><%= pendingCount %></strong>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th style="width: 120px;">Billing ID</th>
                            <th style="width: 150px;">Appointment ID</th>
                            <th>Amount</th>
                            <th style="width: 120px;">Status</th>
                            <th style="width: 140px;">Method</th>
                            <th style="width: 120px;">Due Date</th>
                            <th style="width: 180px; text-align:center;">Actions</th>
                        </tr>
                        </thead>

                        <tbody id="billingTableBody">
                        <%
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

                            if (billings != null && !billings.isEmpty()) {
                                for (Billing billing : billings) {
                                    String billingId = billing.getBillingId();
                                    String appointmentId = String.valueOf(billing.getAppointmentId());
                                    String amount = currencyFormat.format(billing.getBillingAmount());
                                    String status = billing.getBillingStatus() != null ? billing.getBillingStatus() : "";
                                    String method = billing.getBillingMethod() != null ? billing.getBillingMethod() : "";
                                    String dueDate = billing.getBillingDuedate() != null ? dateFormat.format(billing.getBillingDuedate()) : "N/A";
                        %>
                        <tr data-search="<%= (billingId + " " + appointmentId + " " + status + " " + method).toLowerCase() %>">
                            <td><span class="badge badge-dark"><%= billingId %></span></td>
                            <td><%= appointmentId %></td>
                            <td><strong><%= amount %></strong></td>
                            <td>
                                <% if ("Paid".equalsIgnoreCase(status)) { %>
                                    <span class="status-pill"><i class="fas fa-check-circle"></i> <%= status %></span>
                                <% } else if ("Pending".equalsIgnoreCase(status)) { %>
                                    <span class="status-pill warning"><i class="fas fa-clock"></i> <%= status %></span>
                                <% } else { %>
                                    <span class="status-pill secondary"><%= status %></span>
                                <% } %>
                            </td>
                            <td>
                                <% if ("Installment".equalsIgnoreCase(method)) { %>
                                    <span class="status-pill info"><i class="fas fa-calendar-check"></i> <%= method %></span>
                                <% } else { %>
                                    <span class="status-pill secondary"><i class="fas fa-money-bill-wave"></i> <%= method %></span>
                                <% } %>
                            </td>
                            <td><%= dueDate %></td>
                            <td>
                                <div class="actions">
                                    <a href="/YesDentalSupportSystem/PatientBillingServlet?action=view&billing_id=<%= billingId %>" 
                                       class="action-pill action-view" title="View details">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>
                                    
                                    <% if ("Installment".equals(billing.getBillingMethod())) { %>
                                    <a href="/YesDentalSupportSystem/PatientBillingServlet?action=view_installments&billing_id=<%= billingId %>" 
                                       class="action-pill action-installment" title="View installments">
                                        <i class="fa-solid fa-calendar-alt"></i> Schedule
                                    </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center py-4">
                                <i class="fas fa-receipt fa-3x text-muted mb-3"></i>
                                <h5>No billing records found</h5>
                                <p class="text-muted">You don't have any billing records yet.</p>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
    const searchInput = document.getElementById("billingSearch");
    const tableBody = document.getElementById("billingTableBody");

    if (searchInput && tableBody) {
        searchInput.addEventListener("input", function () {
            const keyword = this.value.trim().toLowerCase();
            const rows = tableBody.querySelectorAll("tr");

            rows.forEach(row => {
                const searchText = (row.getAttribute("data-search") || "").toLowerCase();
                row.style.display = (!keyword || searchText.includes(keyword)) ? "" : "none";
            });
        });
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>