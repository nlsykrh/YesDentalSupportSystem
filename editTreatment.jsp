<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Treatment" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Treatment - YesDental</title>
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
            background: url("YesDentalPic/Background.png") no-repeat center center fixed;
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

        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f5f7f5;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            color: #2f4a34;
            border: 1px solid #e1e8e1;
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
            background: #e9f0d5;
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

        .form-control[readonly] {
            background-color: #f0f2f0;
            color: #666;
            border-color: #d1d9d1;
            cursor: not-allowed;
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

        .save-btn, .cancel-btn {
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

        .cancel-btn {
            background: linear-gradient(135deg, #ff6b6b 0%, #ff3131 100%);
            color: white;
            border: 1px solid #d62828;
        }

        .cancel-btn:hover {
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
            font-size: 12px;
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

        .alert-warning {
            background-color: #fff8e1;
            color: #856404;
            border-color: #ffeaa7;
        }

        .alert-warning i {
            color: #ffc107;
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
            min-height: 100px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.5;
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
            
            .save-btn, .cancel-btn {
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
    <div class="overlay">
        <div class="top-nav">
            <div class="brand">
                <img src="<%=request.getContextPath()%>/YesDentalPic/Logo.png" alt="Logo">
                <div class="clinic-title">Yes Dental Clinic</div>
            </div>

            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Staff" %></span>
            </div>
        </div>

        <div class="layout-wrap">
            <div class="layout">

                <!-- Sidebar -->
                <div class="sidebar">
                    <h6>Staff Dashboard</h6>
                    <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                        Staff
                    </a>
                    <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                        Appointments
                    </a>
                    <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                         Billing
                    </a>
                    <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">
                         Patients
                    </a>
                    <a class="side-link active" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                        Treatments
                    </a>
                </div>

                <div class="card-panel">
                    <% 
                        Treatment treatment = (Treatment) request.getAttribute("treatment");
                        String error = (String) request.getAttribute("error");
                        
                        if (error != null) { 
                    %>
                        <div class="alert alert-danger">
                            <i class="fa-solid fa-exclamation-circle"></i> ${error}
                        </div>
                    <% } %>
                    
                    <div class="form-header">
                        <div class="form-header-icon">
                            <i class="fa-solid fa-pen-to-square"></i>
                        </div>
                        <h2>Edit Treatment</h2>
                    </div>
                    
                    <% if (treatment != null) { %>
                    
                    <form action="${pageContext.request.contextPath}/TreatmentServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        
                        <div class="form-card mb-4">
                            <div class="card-header">
                                Treatment Information
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label required">Treatment ID</label>
                                        <input type="text" class="form-control" name="treatment_id" 
                                               value="<%= treatment.getTreatmentId() %>" readonly>
                                        <small class="text-muted">Treatment ID cannot be changed</small>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label required">Treatment Name</label>
                                        <input type="text" class="form-control" name="treatment_name" 
                                               value="<%= treatment.getTreatmentName() %>" required>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label required">Treatment Price (RM)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">RM</span>
                                        <input type="number" class="form-control" name="treatment_price" 
                                               step="0.01" min="0" required 
                                               value="<%= String.format("%.2f", treatment.getTreatmentPrice()) %>">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label required">Description</label>
                                    <textarea class="form-control" name="treatment_desc" rows="5" required><%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "" %></textarea>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-buttons">
                            <button type="submit" class="save-btn">
                                <i class="fa-solid fa-floppy-disk"></i> Save Changes
                            </button>
                            <a href="/YesDentalSupportSystem/TreatmentServlet?action=list" class="cancel-btn">
                                <i class="fa-solid fa-times"></i> Cancel
                            </a>
                        </div>
                    </form>
                    
                    <% } else { %>
                    <div class="alert alert-warning">
                        <i class="fa-solid fa-exclamation-triangle"></i>
                        No treatment data found. Please select a treatment to edit.
                    </div>
                    <div class="form-buttons">
                        <a href="/YesDentalSupportSystem/TreatmentServlet?action=list" class="cancel-btn">
                            <i class="fa-solid fa-arrow-left"></i> Back to Treatment List
                        </a>
                    </div>
                    <% } %>
                </div>

            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
</body>
</html>