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
    <title>Yes Dental Clinic - Manage Billing</title>

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
        
        /* USER AREA - Updated to match first code */
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

        /* Updated sidebar links to match first code */
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
        .side-link i{
            width:18px;
            text-align:center;
        }
        .side-link:hover,
        .side-link.active{
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
        }
        
        /* Billing specific styles */
        .badge {
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: bold;
            display: inline-block;
        }
        
        .badge-success {
            background-color: #d4edda;
            color: #155724;
            border-radius: 999px;
            padding: 4px 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
            border-radius: 999px;
            padding: 4px 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border-radius: 999px;
            padding: 4px 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-secondary {
            background-color: #e2e3e5;
            color: #383d41;
            border-radius: 999px;
            padding: 4px 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .emoji-btn {
            padding: 6px 10px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
        }
        
        .emoji-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
    </style>
</head>

<body>
<div class="overlay">
    <!-- HEADER - Updated to match first code -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-area">
            <div class="user-chip">
                <i class="fa fa-user"></i>
                <%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Staff" %>
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
                    <h4>Manage Billing</h4>
<!--                    <div class="search-wrap">
                        <input id="billingSearch" type="text" class="search-input" placeholder="Search by ID / Status / Method...">
                        <a href="/YesDentalSupportSystem/billing/addBilling.jsp" class="btn-add">Add Billing</a>
                    </div>-->
                </div>

                <div class="table-wrap">
                    <table class="table mb-0">
                        <thead>
                        <tr>
                            <th style="width: 330px;">Patient Name</th>
                            <th>Amount</th>
                            <th style="width: 120px;">Status</th>
                            <th style="width: 140px;">Method</th>
                            <th style="width: 220px; text-align:center;">Actions</th>
                        </tr>
                        </thead>

                        <tbody id="billingTableBody">
                        <%
                            List<Billing> billings = (List<Billing>) request.getAttribute("billings");
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");

                            if (billings != null && !billings.isEmpty()) {
                                for (Billing billing : billings) {
                                    String appointmentId = String.valueOf(billing.getAppointmentId());
                                    String amount = currencyFormat.format(billing.getBillingAmount());
                                    String status = billing.getBillingStatus() != null ? billing.getBillingStatus() : "";
                                    String method = billing.getBillingMethod() != null ? billing.getBillingMethod() : "";
                        %>
                        <tr data-search="<%= (appointmentId + " " + status + " " + method).toLowerCase() %>">
                            <td><%= billing.getPatientName() != null ? billing.getPatientName() : appointmentId %></td>
                            <td><%= amount %></td>
                            <td>
                                <% if ("Paid".equalsIgnoreCase(status)) { %>
                                    <span class="badge-success"><%= status %></span>
                                <% } else if ("Pending".equalsIgnoreCase(status)) { %>
                                    <span class="badge-warning"><%= status %></span>
                                <% } else { %>
                                    <span class="badge-secondary"><%= status %></span>
                                <% } %>
                            </td>
                            <td>
                                <% if ("Installment".equalsIgnoreCase(method)) { %>
                                    <span class="badge-info"><%= method %></span>
                                <% } else { %>
                                    <span class="badge-secondary"><%= method %></span>
                                <% } %>
                            </td>
                            <td>
                                <div class="actions">
                                    <a href="BillingServlet?action=view&billing_id=<%= billing.getBillingId() %>" 
                                       class="action-pill action-view" title="View billing">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>
                                    
                                    <% if ("Pending".equals(billing.getBillingStatus())) { %>
                                    <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>" 
                                       class="action-pill action-edit" title="Edit billing">
                                        <i class="fa-solid fa-pen"></i> Edit
                                    </a>
                                    <% } %>
                                    
                                    <% if ("Installment".equals(billing.getBillingMethod()) && !"Paid".equals(billing.getBillingStatus())) { %>
                                    <a href="BillingServlet?action=view_installments&billing_id=<%= billing.getBillingId() %>" 
                                       class="action-pill action-view" title="View installments">
                                        <i class="fa-solid fa-money-bill-wave"></i> Installments
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
                            <td colspan="5" class="text-center">No billings found.</td>
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