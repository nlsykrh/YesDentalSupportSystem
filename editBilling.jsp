<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Billing" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Edit Billing</title>

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
            box-shadow: 0 6px 14px rgba(0, 0, 0, 0.2);
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
       
        /* ===== SIDEBAR ===== */
        .sidebar{
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
            border-bottom: 1px solid rgba(255, 255, 255, 0.25);
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

        /* ===== MAIN PANEL ===== */
        .card-panel{
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: auto;
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
        
        /* Form Styling */
        .form-label {
            font-weight: 600;
            color: #2f4a34;
            margin-bottom: 8px;
            display: block;
            font-size: 14px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.2s ease;
            background: #fff;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--green-dark);
            box-shadow: 0 0 0 2px rgba(47, 79, 47, 0.1);
        }
        
        .form-control[readonly] {
            background-color: #f8f9fa;
            cursor: not-allowed;
        }
        
        select.form-control {
            cursor: pointer;
        }
        
        .row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -10px;
        }
        
        .col-md-6 {
            flex: 0 0 50%;
            max-width: 50%;
            padding: 0 10px;
            margin-bottom: 20px;
        }
        
        .col-md-12 {
            flex: 0 0 100%;
            max-width: 100%;
            padding: 0 10px;
            margin-bottom: 20px;
        }
        
        /* Card styling */
        .card {
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            margin-bottom: 25px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        
        .card-header {
            background: linear-gradient(135deg, var(--green-dark) 0%, var(--green-deep) 100%);
            color: white;
            padding: 16px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            font-weight: 600;
            font-size: 18px;
        }
        
        .card-body {
            padding: 25px;
        }
        
        /* Alert Styling */
        .alert {
            border-radius: 10px;
            margin: 0 0 20px 0;
            border: none;
            padding: 14px 18px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .alert-warning {
            background-color: #fff3cd;
            color: #856404;
            border-left: 4px solid #ffc107;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }
        
        /* Badge Styling */
        .badge {
            padding: 5px 10px;
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
        
        /* Button Styling */
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s ease;
        }
        
        .btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--green-dark) 0%, var(--green-deep) 100%);
            color: white;
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-outline-secondary {
            background-color: transparent;
            border: 1px solid #6c757d;
            color: #6c757d;
        }
        
        .btn-outline-secondary:hover {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-sm {
            padding: 5px 10px;
            font-size: 12px;
        }
        
        /* Button Group */
        .d-flex {
            display: flex;
        }
        
        .justify-content-between {
            justify-content: space-between;
        }
        
        .justify-content-end {
            justify-content: flex-end;
        }
        
        .ms-2 {
            margin-left: 10px;
        }
        
        /* Installment Section */
        .bg-light {
            background-color: #f8f9fa !important;
        }
        
        .border {
            border: 1px solid #dee2e6 !important;
        }
        
        .rounded {
            border-radius: 8px !important;
        }
        
        .p-3 {
            padding: 20px !important;
        }
        
        .input-group {
            display: flex;
            margin-bottom: 15px;
        }
        
        .input-group-text {
            padding: 10px 14px;
            background-color: #e9ecef;
            border: 1px solid #ced4da;
            border-right: none;
            border-radius: 8px 0 0 8px;
            font-size: 14px;
        }
        
        .input-group .form-control {
            border-radius: 0 8px 8px 0;
            border-left: none;
        }
        
        .text-muted {
            color: #6c757d !important;
            font-size: 12px;
        }
        
        strong {
            font-weight: bold;
        }
        
        small {
            font-size: 12px;
        }
        
        i {
            margin-right: 8px;
        }
        
        /* Page Title */
        h2 {
            color: var(--green-dark);
            margin-bottom: 25px;
            font-size: 28px;
            font-weight: 700;
        }
        
        /* Status Pill */
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
        
        /* Responsive */
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
        }
    </style>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
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

            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user"></i> Staff
                </a>
                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>
                <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>
                <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                    <i class="fa-solid fa-user-injured"></i> Patients
                </a>
                <a class="side-link active" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                    <i class="fa-solid fa-stethoscope"></i> Treatments
                </a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>Edit Billing</h4>
                </div>
                
                <% 
                    Billing billing = (Billing) request.getAttribute("billing");
                    String error = (String) request.getAttribute("error");
                    String success = (String) request.getAttribute("success");
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
                    
                    if (error != null) { 
                %>
                    <div class="alert alert-danger">${error}</div>
                <% } %>
                
                <% if (success != null) { %>
                    <div class="alert alert-success">${success}</div>
                <% } %>
                
                <% if (billing != null) { 
                    String dateStr = billing.getBillingDuedate() != null ? 
                        sdf.format(billing.getBillingDuedate()) : "";
                %>
                
                <form action="${pageContext.request.contextPath}/BillingServlet" method="post" id="billingForm">
                    <input type="hidden" name="action" value="update_billing">
                    <input type="hidden" name="billing_id" value="<%= billing.getBillingId() %>">
                    
                    <div class="card">
                        <div class="card-header">
                            Billing Details
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <label class="form-label">Billing ID</label>
                                    <input type="text" class="form-control" value="<%= billing.getBillingId() %>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Amount</label>
                                    <input type="text" class="form-control" value="<%= currencyFormat.format(billing.getBillingAmount()) %>" readonly>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <label class="form-label">Due Date</label>
                                    <input type="text" class="form-control" value="<%= dateStr %>" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Appointment ID</label>
                                    <input type="text" class="form-control" value="<%= billing.getAppointmentId() %>" readonly>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <label class="form-label">Billing Status *</label>
                                    <select class="form-control" name="billing_status" required>
                                        <option value="Pending" <%= "Pending".equals(billing.getBillingStatus()) ? "selected" : "" %>>Pending</option>
                                        <option value="Paid" <%= "Paid".equals(billing.getBillingStatus()) ? "selected" : "" %>>Paid</option>
                                        <option value="Overdue" <%= "Overdue".equals(billing.getBillingStatus()) ? "selected" : "" %>>Overdue</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Payment Method *</label>
                                    <select class="form-control" name="billing_method" id="billingMethod" required>
                                        <option value="Pay in Whole" <%= "Pay in Whole".equals(billing.getBillingMethod()) ? "selected" : "" %>>Pay in Whole</option>
                                        <option value="Pay at Counter" <%= "Pay at Counter".equals(billing.getBillingMethod()) ? "selected" : "" %>>Pay at Counter</option>
                                        <option value="Installment" <%= "Installment".equals(billing.getBillingMethod()) ? "selected" : "" %>>Installment</option>
                                    </select>
                                </div>
                            </div>
                            
                            <!-- Installment Section -->
                            <div class="row" id="installmentSection" style="display: <%= "Installment".equals(billing.getBillingMethod()) ? "block" : "none" %>;">
                                <div class="col-md-12">
                                    <div class="border rounded p-3 bg-light">
                                        <h6 style="margin-bottom: 15px; color: var(--green-dark); font-weight: bold;">Installment Configuration</h6>
                                        
                                        <div class="row">
                                            <div class="col-md-6">
                                                <label class="form-label">Number of Installments *</label>
                                                <select class="form-control" name="num_installments" id="numInstallments">
                                                    <option value="1" <%= getInstallmentCount(billing) == 1 ? "selected" : "" %>>1 Installment</option>
                                                    <option value="2" <%= getInstallmentCount(billing) == 2 ? "selected" : "" %>>2 Installments</option>
                                                    <option value="3" <%= getInstallmentCount(billing) == 3 ? "selected" : "" %>>3 Installments</option>
                                                    <option value="4" <%= getInstallmentCount(billing) == 4 ? "selected" : "" %>>4 Installments</option>
                                                    <option value="5" <%= getInstallmentCount(billing) == 5 ? "selected" : "" %>>5 Installments</option>
                                                </select>
                                                <small class="text-muted">Maximum 5 installments allowed</small>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Installment Amount</label>
                                                <input type="text" class="form-control" id="installmentAmount" readonly>
                                            </div>
                                        </div>
                                        
                                        <div style="margin-top: 15px;">
                                            <label class="form-label">Installment Due Dates *</label>
                                            <div id="dateInputsContainer">
                                                <!-- Dynamic date inputs will be inserted here -->
                                            </div>
                                            <input type="hidden" name="installment_dates" id="installmentDates">
                                            <small class="text-muted">Select due date for each installment</small>
                                        </div>
                                        
                                        <div class="alert alert-info" style="margin-top: 15px;">
                                            <strong>ℹ️</strong>
                                            <small>Total Amount: <strong><%= currencyFormat.format(billing.getBillingAmount()) %></strong> | 
                                            Installment dates must be in YYYY-MM-DD format and comma-separated.</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="alert alert-warning">
                        <strong>⚠️ Note:</strong> Changing payment method to "Installment" will create new installment records.
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <div>
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-save"></i> Update Billing
                            </button>
                            <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="btn btn-outline-secondary ms-2">
                                <i class="fa-solid fa-times"></i> Cancel
                            </a>
                        </div>
                    </div>
                </form>
                
                <% } else { %>
                    <div class="alert alert-warning">
                        No billing data found. Please select a billing to edit.
                    </div>
                    <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="btn btn-primary">
                        <i class="fa-solid fa-arrow-left"></i> Back to Billing List
                    </a>
                <% } %>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script>
    // Calculate installment amount
    function calculateInstallmentAmount() {
        const totalAmount = <%= billing != null ? billing.getBillingAmount() : 0 %>;
        const numInstallments = parseInt(document.getElementById('numInstallments').value);
        if (numInstallments > 0 && totalAmount > 0) {
            const installmentAmount = totalAmount / numInstallments;
            document.getElementById('installmentAmount').value = 'RM ' + installmentAmount.toFixed(2);
        }
    }
    
    // Generate date inputs based on number of installments
    function generateDateInputs() {
        const numInstallments = parseInt(document.getElementById('numInstallments').value);
        const container = document.getElementById('dateInputsContainer');
        container.innerHTML = '';
        
        for (let i = 1; i <= numInstallments; i++) {
            const div = document.createElement('div');
            div.className = 'date-input-group';
            div.innerHTML = `
                <div class="input-group">
                    <span class="input-group-text">Installment ${i}</span>
                    <input type="text" class="form-control installment-date" 
                           placeholder="YYYY-MM-DD" data-index="${i}"
                           required>
                    <button type="button" class="btn btn-outline-secondary btn-sm" onclick="setDateToToday(${i})">
                        Today
                    </button>
                </div>
            `;
            container.appendChild(div);
            
            // Initialize flatpickr for date input
            flatpickr(div.querySelector('.installment-date'), {
                dateFormat: "Y-m-d",
                minDate: "today"
            });
        }
        
        calculateInstallmentAmount();
    }
    
    // Set date to today for specific installment
    function setDateToToday(index) {
        const today = new Date();
        const dateStr = today.toISOString().split('T')[0];
        document.querySelector(`.installment-date[data-index="${index}"]`).value = dateStr;
        updateInstallmentDates();
    }
    
    // Update hidden field with comma-separated dates
    function updateInstallmentDates() {
        const dateInputs = document.querySelectorAll('.installment-date');
        const dates = Array.from(dateInputs).map(input => input.value).filter(date => date.trim() !== '');
        document.getElementById('installmentDates').value = dates.join(',');
    }
    
    // Initialize when page loads
    document.addEventListener('DOMContentLoaded', function() {
        calculateInstallmentAmount();
        
        // Generate date inputs if installment method is selected
        if (document.getElementById('billingMethod').value === 'Installment') {
            generateDateInputs();
        }
        
        // Add event listeners for date inputs
        document.addEventListener('change', function(e) {
            if (e.target.classList.contains('installment-date')) {
                updateInstallmentDates();
            }
        });
    });
    
    // Toggle installment section based on payment method
    document.getElementById('billingMethod').addEventListener('change', function() {
        const installmentSection = document.getElementById('installmentSection');
        if (this.value === 'Installment') {
            installmentSection.style.display = 'block';
            generateDateInputs();
        } else {
            installmentSection.style.display = 'none';
        }
    });
    
    // Regenerate date inputs when number of installments changes
    document.getElementById('numInstallments').addEventListener('change', function() {
        if (document.getElementById('billingMethod').value === 'Installment') {
            generateDateInputs();
        }
        calculateInstallmentAmount();
    });
    
    // Form validation
    document.getElementById('billingForm').addEventListener('submit', function(e) {
        const method = document.getElementById('billingMethod').value;
        
        if (method === 'Installment') {
            const dateInputs = document.querySelectorAll('.installment-date');
            const dates = Array.from(dateInputs).map(input => input.value);
            
            // Check if all dates are filled
            if (dates.some(date => date.trim() === '')) {
                e.preventDefault();
                alert('Please select dates for all installments.');
                return false;
            }
            
            // Check for duplicate dates
            const uniqueDates = new Set(dates);
            if (uniqueDates.size !== dates.length) {
                e.preventDefault();
                alert('Installment dates must be unique.');
                return false;
            }
        }
    });
</script>
</body>
</html>

<%!
    // Helper method to get installment count from billing
    private int getInstallmentCount(Billing billing) {
        // You might want to fetch actual installment count from database
        return 1; // Default value
    }
%>