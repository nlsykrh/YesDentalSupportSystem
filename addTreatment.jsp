<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Treatment - YesDental</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body, html {
            height: 100vh;
            overflow: hidden;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            /* FIXED: Added <%=request.getContextPath()%> and removed typo 's' at the end */
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
        }

        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.38);
            backdrop-filter: blur(1.5px);
        }

        /* Top Navigation */
        .top-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 60px 8px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .brand img { 
            height: 42px;
            border-radius: 8px;
        }

        .clinic-title {
            font-size: 22px;
            font-weight: 700;
            color: #2f4a34;
            letter-spacing: 0.5px;
        }

        .top-right {
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
        }

        .logout-btn:hover {
            background: #b95a5a;
            transform: translateY(-1px);
        }

        /* Main Layout */
        .layout-wrap {
            width: 100%;
            padding: 30px 50px;
            height: calc(100vh - 80px);
            overflow: hidden;
        }

        .layout {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 25px;
            width: 100%;
            max-width: 1300px;
            margin: 0 auto;
            height: 100%;
            align-items: stretch;
        }

        /* Sidebar */
        .sidebar {
            background: linear-gradient(180deg, #2f4a34 0%, #264232 100%);
            border-radius: 12px;
            padding: 25px 18px;
            height: 100%;
            overflow: auto;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .sidebar h6 {
            font-size: 18px;
            margin-bottom: 20px;
            color: white;
            padding-bottom: 15px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            font-weight: 600;
        }

        .side-link {
            display: flex;
            align-items: center;
            gap: 10px;
            color: rgba(255, 255, 255, 0.85);
            padding: 10px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
            transition: all 0.2s ease;
        }

        .side-link i {
            font-size: 16px;
            width: 20px;
            text-align: center;
        }

        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, 0.15);
            color: #ffce38;
            font-weight: 500;
        }

        /* Main Content Panel */
        .card-panel {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: auto;
        }

        /* Form Header */
        .form-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #eaeaea;
        }

        .form-header h2 {
            margin: 0;
            color: #2f4a34;
            font-size: 24px;
            font-weight: 700;
        }

        .form-header-icon {
            background: linear-gradient(135deg, #e9f0d5 0%, #d4e1b5 100%);
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #2f4a34;
            font-size: 20px;
        }

        /* Form Elements */
        .form-label { 
            font-weight: 600; 
            color: #333;
            margin-bottom: 8px;
            display: block;
            font-size: 14px;
        }

        .required:after { 
            content:" *"; 
            color: #e74c3c; 
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #dce1d6;
            border-radius: 8px;
            background-color: #f8f9f8;
            font-size: 14px;
            transition: all 0.3s ease;
            color: #333;
        }

        .form-control:focus {
            background-color: white;
            border-color: #3f9042;
            outline: none;
            box-shadow: 0 0 0 3px rgba(63, 144, 66, 0.1);
        }

        .form-control::placeholder {
            color: #8a8f8a;
            font-size: 13.5px;
        }

        /* Card Styling */
        .form-card {
            border: 1px solid #e5e9e5;
            border-radius: 10px;
            background-color: white;
            margin-bottom: 25px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }

        .card-header {
            background: linear-gradient(135deg, #f8f9fa 0%, #eef1ee 100%);
            border-bottom: 1px solid #e5e9e5;
            padding: 18px 25px;
            font-weight: 600;
            color: #2f4a34;
            font-size: 16px;
        }

        .card-body {
            padding: 25px;
        }

        /* Form Buttons */
        .form-buttons {
            margin-top: 30px;
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            padding-top: 20px;
            border-top: 1px solid #eaeaea;
        }

        .save-btn, .reset-btn {
            padding: 12px 28px;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            min-width: 140px;
        }

        .save-btn {
            background: linear-gradient(135deg, #3f9042 0%, #2e6c31 100%);
            color: white;
            border: 1px solid #2e6c31;
        }

        .save-btn:hover {
            background: linear-gradient(135deg, #2e6c31 0%, #255a28 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(63, 144, 66, 0.2);
        }

        .reset-btn {
            background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
            color: white;
            border: 1px solid #495057;
        }

        .reset-btn:hover {
            background: linear-gradient(135deg, #495057 0%, #343a40 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108, 117, 125, 0.2);
        }

        .back-btn {
            background: linear-gradient(135deg, #ff6b6b 0%, #ff3131 100%);
            color: white;
            border: 1px solid #d62828;
            padding: 12px 28px;
            border-radius: 8px;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
            min-width: 140px;
        }

        .back-btn:hover {
            background: linear-gradient(135deg, #ff5252 0%, #d62828 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 49, 49, 0.2);
        }

        /* Input Group */
        .input-group {
            width: 100%;
            border-radius: 8px;
            overflow: hidden;
        }

        .input-group-text {
            background-color: #f0f2f0;
            border: 1px solid #dce1d6;
            color: #555;
            font-weight: 500;
            padding: 12px 15px;
        }

        /* Text Helpers */
        .text-muted {
            font-size: 12.5px;
            color: #6c757d;
            margin-top: 6px;
            display: block;
            font-style: italic;
        }

        /* Alerts */
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            border: 1px solid transparent;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
        }

        .alert-danger {
            background-color: #ffeaea;
            color: #721c24;
            border-color: #f5c6cb;
        }

        .alert-danger i {
            color: #dc3545;
        }

        /* Grid Layout */
        .row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .row .col-md-6 {
            flex: 1;
        }

        /* Spacing Utilities */
        .mb-3 {
            margin-bottom: 20px;
        }

        .mb-4 {
            margin-bottom: 30px;
        }

        .mb-0 {
            margin-bottom: 0 !important;
        }

        /* Textarea Specific */
        textarea.form-control {
            resize: vertical;
            min-height: 120px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.5;
        }

        /* Info Section */
        .form-info {
            background: #f8f9fa;
            border-left: 4px solid #3f9042;
            padding: 15px 20px;
            border-radius: 6px;
            margin-bottom: 25px;
            font-size: 13.5px;
            color: #555;
        }

        .form-info i {
            color: #3f9042;
            margin-right: 8px;
        }

        /* Responsive Design */
        @media (max-width: 1100px) {
            .layout { 
                grid-template-columns: 1fr; 
                gap: 20px;
            }
            
            .sidebar {
                height: auto;
                max-height: 300px;
            }
            
            .layout-wrap { 
                padding: 20px; 
            }
        }

        @media (max-width: 768px) {
            .top-nav {
                padding: 15px 20px;
            }
            
            .layout-wrap {
                padding: 15px;
            }
            
            .card-panel {
                padding: 20px;
            }
            
            .row {
                flex-wrap: wrap;
                gap: 15px;
            }
            
            .row .col-md-6 {
                flex: 0 0 100%;
            }
            
            .form-buttons {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .save-btn, .reset-btn, .back-btn {
                min-width: 120px;
                padding: 10px 20px;
            }
            
            .form-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
        }

        @media (max-width: 480px) {
            .brand img {
                height: 36px;
            }
            
            .clinic-title {
                font-size: 18px;
            }
            
            .user-chip {
                padding: 6px 12px;
                font-size: 12px;
            }
            
            .form-header h2 {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>
<%
    String staffName = (String) session.getAttribute("staffName");
    String staffId = (String) session.getAttribute("staffId");
    String staffRole = (String) session.getAttribute("staffRole");

    if (staffName == null || staffName.trim().isEmpty()) staffName = "Staff";
    if (staffId == null || staffId.trim().isEmpty()) staffId = "-";
    if (staffRole == null || staffRole.trim().isEmpty()) staffRole = "Staff";
%>
    
    <div class="overlay">
        <div class="top-nav">
            <div class="brand">
                <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
                <div class="clinic-title">Yes Dental Clinic</div>
            </div>

            <div class="top-right">
                <div class="user-chip">
                    <i class="fa-solid fa-user"></i>
                    <span><%= staffName %></span>
                </div>

                <form action="<%=request.getContextPath()%>/LogoutServlet" method="post" style="margin:0;">
                    <button type="submit" class="logout-btn">
                        <i class="fa-solid fa-right-from-bracket"></i> Logout
                    </button>
                </form>
            </div>
        </div>

        <div class="layout-wrap">
            <div class="layout">

                <!-- UPDATED SIDEBAR -->
                <div class="sidebar">
                    <h6>Staff Dashboard</h6>

                    <a class="side-link" href="<%=request.getContextPath()%>/staff/staffDashboard.jsp">
                        <i class="fa-solid fa-chart-line"></i> Dashboard
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                        <i class="fa-solid fa-user-doctor"></i> Staff
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                        <i class="fa-solid fa-calendar-check"></i> Appointments
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                        <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                    </a>

                    <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                        <i class="fa-solid fa-hospital-user"></i> Patients
                    </a>

                    <a class="side-link active" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                        <i class="fa-solid fa-tooth"></i> Treatments
                    </a>
                </div>

                <div class="card-panel">
                    <div class="form-header">
                        <div class="form-header-icon">
                            <i class="fa-solid fa-plus"></i>
                        </div>
                        <h2>Add New Treatment</h2>
                    </div>
                    
                    <% if (request.getAttribute("error") != null) { %>
                        <div class="alert alert-danger">
                            <i class="fa-solid fa-exclamation-circle"></i> ${error}
                        </div>
                    <% } %>
                    
                    <div class="form-info">
                        <i class="fa-solid fa-info-circle"></i>
                        Fill in the details below to add a new treatment to the system. All fields marked with * are required.
                    </div>
                    
                    <form action="${pageContext.request.contextPath}/TreatmentServlet" method="post" id="addTreatmentForm">
                        <input type="hidden" name="action" value="add">
                        
                        <div class="form-card mb-4">
                            <div class="card-header">
                                Treatment Information
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label required">Treatment ID</label>
                                        <input type="text" class="form-control" name="treatment_id" required
                                               placeholder="e.g., TX001 or 2024001">
                                        <small class="text-muted">Enter a unique identifier for the treatment</small>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label required">Treatment Name</label>
                                        <input type="text" class="form-control" name="treatment_name" required
                                               placeholder="e.g., Dental Cleaning, Root Canal, Teeth Whitening">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label required">Treatment Price (RM)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">RM</span>
                                        <input type="number" class="form-control" name="treatment_price" 
                                               step="0.01" min="0" required placeholder="0.00">
                                    </div>
                                    <small class="text-muted">Enter the price in Malaysian Ringgit (RM)</small>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label required">Description</label>
                                    <textarea class="form-control" name="treatment_desc" rows="5" required
                                              placeholder="Describe the treatment procedure, duration, benefits, and any special instructions..."></textarea>
                                    <small class="text-muted">Provide a clear description for patients and staff reference</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-buttons">
                            <button type="submit" class="save-btn">
                                <i class="fa-solid fa-floppy-disk"></i> Save Treatment
                            </button>
                            <button type="button" class="reset-btn" onclick="resetForm(event)">
                                <i class="fa-solid fa-rotate-left"></i> Reset Form
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
    <script>
    function resetForm(event) {
        event.preventDefault();
        if (confirm('Are you sure you want to reset the form? All entered data will be lost.')) {
            document.getElementById("addTreatmentForm").reset();
        }
    }
    </script>
</body>
</html>
