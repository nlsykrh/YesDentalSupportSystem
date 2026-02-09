<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Make Payment</title>

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
            background: url("<%=request.getContextPath()%>/YesDentalPic/Background.png") no-repeat center center fixed;
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
            overflow-y: auto;
        }
        .layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            min-height: 100%;
            align-items: stretch;
        }
        
        /* ===== SIDEBAR ===== */
        .sidebar {
            background: var(--green-deep);
            color: white;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
        }
        .sidebar h6 {
            font-size: 20px;
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.25);
            color: white;
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
            background: rgba(255, 255, 255, 0.14);
            color: #ffe69b;
        }
        
        .card-panel {
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
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

        /* Form specific styles */
        .form-content {
            flex: 1;
            overflow-y: auto;
            padding: 0;
        }

        h2 {
            text-align: left;
            color: #2f2f2f;
            margin-bottom: 30px;
            font-size: 28px;
            font-weight: 700;
        }

        .form-card {
            background: white;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            overflow: hidden;
        }

        .card-header {
            background: linear-gradient(135deg, #2f4f2f 0%, #3a5c3a 100%);
            color: white;
            padding: 16px 20px;
            font-weight: 600;
            font-size: 18px;
        }

        .card-body {
            padding: 30px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2f4f2f;
        }

        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.2s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #2f4f2f;
            box-shadow: 0 0 0 2px rgba(47, 79, 47, 0.1);
        }

        .form-control[readonly] {
            background-color: #f5f5f5;
            cursor: not-allowed;
        }

        .text-muted {
            color: #666;
            font-size: 12px;
            margin-top: 4px;
            display: block;
        }

        .button-container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eaeaea;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
            text-align: center;
        }

        .btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
            color: white;
        }

        .btn-success {
            background-color: #28a745;
            color: white;
        }

        .btn-success:hover {
            background-color: #218838;
            color: white;
        }

        .alert {
            padding: 12px 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .mb-3 {
            margin-bottom: 20px;
        }

        .mb-4 {
            margin-bottom: 25px;
        }

        .mb-0 {
            margin-bottom: 0;
        }

        .mt-4 {
            margin-top: 25px;
        }

        .mt-5 {
            margin-top: 30px;
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
            .search-input { 
                width: 180px; 
            }
        }
    </style>
</head>

<body>
<div class="overlay">
    <!-- HEADER -->
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/YesDentalPic/Logo.png" alt="Logo">
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

    <div class="layout-wrap">
        <div class="layout">

            <!-- SIDEBAR -->
            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                
                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-users"></i> Staff
                </a>
                
                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>
                
                <a class="side-link active" href="/YesDentalSupportSystem/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>
                
                <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                    <i class="fa-solid fa-user-injured"></i> Patients
                </a>
                
                <a class="side-link" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                    <i class="fa-solid fa-stethoscope"></i> Treatments
                </a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>Make Payment</h4>
                </div>

                <div class="form-content">
                    <% 
                        String installmentId = (String) request.getAttribute("installment_id");
                        String error = (String) request.getAttribute("error");
                    %>
                    
                    <% if (error != null) { %>
                        <div class="alert alert-danger"><%= error %></div>
                    <% } %>
                    
                    <form action="${pageContext.request.contextPath}/BillingServlet" method="post">
                        <input type="hidden" name="action" value="make_payment">
                        <input type="hidden" name="installment_id" value="<%= installmentId %>">
                        
                        <div class="form-card">
                            <div class="card-header">
                                <h5 class="mb-0">Payment Details</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <label class="form-label">Installment ID</label>
                                    <input type="text" class="form-control" value="<%= installmentId %>" readonly>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Payment Amount (RM) *</label>
                                    <input type="number" class="form-control" name="payment_amount" 
                                           step="0.01" min="0.01" required>
                                    <small class="text-muted">Enter the payment amount</small>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Payment Method</label>
                                    <select class="form-control" name="payment_method">
                                        <option value="Credit Card">Credit Card</option>
                                        <option value="Debit Card">Debit Card</option>
                                        <option value="Cash">Cash</option>
                                        <!--<option value="Online Banking">Online Banking</option>-->
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="button-container">
                            <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-success">Process Payment</button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>