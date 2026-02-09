<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
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
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .filter-pills {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .pill {
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            border-radius: 999px;
            padding: 7px 12px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            user-select: none;
            transition: all 0.2s ease;
        }
        .pill.active {
            background: rgba(215, 209, 166, 0.55);
            border-color: #e6dfb9;
            color: #3a382f;
        }
        .pill:hover:not(.active) {
            background: #f5f5f5;
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

        /* Status pills similar to appointment page */
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

        .actions {
            display: flex;
            gap: 8px;
            justify-content: center;
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
        .action-pay {
            border-color: #c9e5cf;
            color: #2a6b48;
        }

        .alert {
            border-radius: 10px;
            margin: 0 6% 12px;
        }

        .modal-content {
            border-radius: 16px;
            border: none;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        .modal-header {
            border-bottom: 2px solid #f0f0f0;
            padding: 20px 24px;
        }
        .modal-title {
            color: #9b2c2c;
            font-weight: 700;
        }
        .modal-body { padding: 24px; }
        .modal-footer {
            border-top: 2px solid #f0f0f0;
            padding: 20px 24px;
        }

        .total-summary {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 20px;
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

        @media (max-width: 992px) {
            body { overflow: auto; }
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; height: auto; overflow: visible; }
            .top-nav { padding: 18px 24px 8px; flex-wrap: wrap; gap: 10px; }
            .actions { justify-content: flex-start; }
            .search-input { width: 180px; }
            .card-panel { height: auto; overflow: visible; }
            .table-wrap { overflow: visible; }
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
                    <h4>My Billings</h4>
                    <div class="search-wrap">
                        <input id="billingSearch" type="text" class="search-input" placeholder="Search by ID / Status / Method...">
                        <!-- Future feature: Request Payment 
                        <a href="#" class="btn-add">
                            <i class="fa-solid fa-money-bill-wave"></i> Request Payment
                        </a>
                        -->
                    </div>
                </div>

                <!-- Billing Summary -->
                <%
                    List<Billing> billings = (List<Billing>) request.getAttribute("billings");
                    DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                    BigDecimal totalAmount = BigDecimal.ZERO;
                    BigDecimal totalPaid = BigDecimal.ZERO;
                    int pendingCount = 0;
                    int overdueCount = 0;
                    
                    if (billings != null && !billings.isEmpty()) {
                        for (Billing billing : billings) {
                            totalAmount = totalAmount.add(billing.getBillingAmount());
                            if ("Paid".equalsIgnoreCase(billing.getBillingStatus())) {
                                totalPaid = totalPaid.add(billing.getBillingAmount());
                            } else {
                                pendingCount++;
                                
                                // Check if overdue
                                if (billing.getBillingDuedate() != null && 
                                    billing.getBillingDuedate().before(new Date())) {
                                    overdueCount++;
                                }
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
                    <% if (overdueCount > 0) { %>
                    <div class="summary-item">
                        <span><i class="fas fa-exclamation-triangle text-danger"></i> Overdue:</span>
                        <strong class="text-danger"><%= overdueCount %></strong>
                    </div>
                    <% } %>
                </div>

                <!-- Filter pills - Similar to appointment page -->
                <div class="filter-pills mb-3">
                    <div class="pill active" data-status="all" onclick="setFilter('all', this)">All</div>
                    <div class="pill" data-status="Paid" onclick="setFilter('Paid', this)">Paid</div>
                    <div class="pill" data-status="Pending" onclick="setFilter('Pending', this)">Pending</div>
                    <div class="pill" data-status="Installment" onclick="setFilter('Installment', this)">Installment</div>
                </div>

                <div class="table-wrap">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th style="width:150px;">Billing ID</th>
                            <th style="width:150px;">Appointment ID</th>
                            <th style="width:150px;">Amount</th>
                            <th style="width:120px;">Status</th>
                            <th style="width:140px;">Method</th>
                            <th style="width:120px;">Due Date</th>
                            <th style="width:200px; text-align:center;">Actions</th>
                        </tr>
                        </thead>

                        <tbody id="billingBody">
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
                                    
                                    // Check if overdue
                                    boolean isOverdue = false;
                                    if (billing.getBillingDuedate() != null && 
                                        !"Paid".equalsIgnoreCase(status) &&
                                        billing.getBillingDuedate().before(new Date())) {
                                        isOverdue = true;
                                    }
                                    
                                    String statusClass = "status-pill";
                                    if ("Paid".equalsIgnoreCase(status)) {
                                        statusClass = "status-pill";
                                    } else if (isOverdue) {
                                        statusClass = "status-pill overdue";
                                    } else if ("Pending".equalsIgnoreCase(status)) {
                                        statusClass = "status-pill pending";
                                    }
                                    
                                    String methodClass = "";
                                    if ("Installment".equalsIgnoreCase(method)) {
                                        methodClass = "status-pill installment";
                                    } else {
                                        methodClass = "status-pill";
                                    }
                                    
                                    String searchText = (billingId + " " + appointmentId + " " + amount + " " + 
                                                        status + " " + method + " " + dueDate).toLowerCase();
                        %>
                        <tr class="billing-row" data-status="<%= status %>" data-method="<%= method %>" data-search="<%= searchText %>">
                            <td><strong><%= billingId %></strong></td>
                            <td><%= appointmentId %></td>
                            <td><strong><%= amount %></strong></td>
                            <td>
                                <span class="<%= statusClass %>">
                                    <% if ("Paid".equalsIgnoreCase(status)) { %>
                                        <i class="fa-solid fa-check-circle"></i>
                                    <% } else if (isOverdue) { %>
                                        <i class="fa-solid fa-exclamation-triangle"></i>
                                    <% } else { %>
                                        <i class="fa-solid fa-clock"></i>
                                    <% } %>
                                    <%= status %>
                                    <% if (isOverdue) { %> (Overdue) <% } %>
                                </span>
                            </td>
                            <td>
                                <span class="<%= methodClass %>">
                                    <% if ("Installment".equalsIgnoreCase(method)) { %>
                                        <i class="fa-solid fa-calendar-alt"></i>
                                    <% } else { %>
                                        <i class="fa-solid fa-money-bill-wave"></i>
                                    <% } %>
                                    <%= method %>
                                </span>
                            </td>
                            <td><%= dueDate %></td>
                            <td>
                                <div class="actions">
                                    <a href="<%=request.getContextPath()%>/PatientBillingServlet?action=view&billing_id=<%= billingId %>" 
                                       class="action-pill action-view" title="View billing details">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>
                                    
                                    <% if ("Installment".equals(billing.getBillingMethod())) { %>
                                    
                                    <% } %>
                                    
                                    <% if (!"Paid".equalsIgnoreCase(status)) { %>
                                    <!-- Future feature: Pay Now button
                                    <a href="#" class="action-pill action-pay" title="Pay now">
                                        <i class="fa-solid fa-credit-card"></i> Pay
                                    </a>
                                    -->
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr id="noDataRow">
                            <td colspan="7" class="text-center">No billing records found.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div id="noMatchRow" class="text-center py-4 text-muted" style="display:none;">
                    No billings match your filter/search.
                </div>

            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let activeFilter = "all";

    const searchInput = document.getElementById("billingSearch");
    const noMatchRow = document.getElementById("noMatchRow");
    const noDataRow = document.getElementById("noDataRow");

    function setFilter(status, el){
        activeFilter = status;
        document.querySelectorAll(".pill").forEach(p => p.classList.remove("active"));
        el.classList.add("active");
        applyFilterSearch();
    }

    function applyFilterSearch(){
        const q = (searchInput?.value || "").trim().toLowerCase();
        let shown = 0;

        const rows = document.querySelectorAll(".billing-row");
        rows.forEach(row => {
            const rowStatus = (row.getAttribute("data-status") || "").toLowerCase();
            const rowMethod = (row.getAttribute("data-method") || "").toLowerCase();
            
            let matchesFilter = true;
            if (activeFilter === "all") {
                matchesFilter = true;
            } else if (activeFilter.toLowerCase() === rowStatus) {
                matchesFilter = true;
            } else if (activeFilter.toLowerCase() === rowMethod) {
                matchesFilter = true;
            } else {
                matchesFilter = false;
            }

            const text = (row.getAttribute("data-search") || "");
            const matchesSearch = (!q) || text.includes(q);

            const show = matchesFilter && matchesSearch;
            row.style.display = show ? "" : "none";
            if (show) shown++;
        });

        const hasAnyRow = document.querySelectorAll(".billing-row").length > 0;
        if (noMatchRow) noMatchRow.style.display = (hasAnyRow && shown === 0) ? "block" : "none";
    }

    if (searchInput) {
        searchInput.addEventListener("input", applyFilterSearch);
    }
</script>

</body>
</html>