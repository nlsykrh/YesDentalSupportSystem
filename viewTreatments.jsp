<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Treatment" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Treatments - YesDental</title>
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
            font-family: Arial, sans-serif;
            background: url("YesDentalPic/Background.png") no-repeat center center fixed;
            background-size: cover;
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

        .brand img { 
            height: 48px; 
        }

        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: #2f4a34;
            font-family: "Times New Roman", serif;
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

        /* Notification Styles */
        .notification-container {
            position: fixed;
            top: 100px;
            left: 50%;
            transform: translateX(-50%);
            z-index: 1000;
            width: 500px;
            max-width: 90%;
        }

        .notification {
            padding: 16px 20px;
            border-radius: 8px;
            margin-bottom: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            justify-content: space-between;
            animation: slideIn 0.3s ease-out;
            border-left: 4px solid;
        }

        .notification-success {
            background-color: #d4edda;
            color: #155724;
            border-color: #28a745;
        }

        .notification-error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #dc3545;
        }

        .notification-warning {
            background-color: #fff3cd;
            color: #856404;
            border-color: #ffc107;
        }

        .notification-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border-color: #17a2b8;
        }

        .notification-content {
            flex: 1;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .notification-icon {
            font-size: 18px;
        }

        .notification-close {
            background: none;
            border: none;
            color: inherit;
            cursor: pointer;
            font-size: 16px;
            opacity: 0.7;
            transition: opacity 0.2s;
        }

        .notification-close:hover {
            opacity: 1;
        }

        @keyframes slideIn {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .layout-wrap {
            width: 100%;
            padding: 30px 60px 40px;
            height: calc(100vh - 100px);
            overflow: hidden;
        }

        .layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            height: 100%;
            align-items: stretch;
        }

        .sidebar {
            background: #264232;
            color: #fff;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }

        .sidebar h6 {
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

        .card-panel {
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .page-title {
            color: #000;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 15px;
            text-align: left;
        }

        .controls-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }

        .search-wrapper {
            position: relative;
            flex-grow: 0;
            width: 300px;
        }

        .search-input {
            width: 100%;
            padding: 10px 15px 10px 15px;
            border: 1px solid #e0e0e0;
            border-radius: 30px;
            font-size: 14px;
            outline: none;
            color: #555;
            background-color: #fff;
        }
        
        .search-input::placeholder {
            color: #aaa;
        }

        .btn-add-custom {
            background-color: #e9f0d5;
            color: #2f4f2f;
            border: 1px solid #dce8c0;
            padding: 10px 25px;
            border-radius: 30px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
            white-space: nowrap;
        }

        .btn-add-custom:hover {
            background-color: #dbe6b9;
            text-decoration: none;
            color: #1a331a;
        }

        .price-cell { 
            font-weight: 600; 
            color: #198754; 
        }
        
        .btn-edit {
            background: #ffd54f;
            color: #856404;
            border: none;
            padding: 8px 12px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 36px;
            text-decoration: none;
        }
        
        .btn-edit:hover {
            background: #ffca28;
            transform: scale(1.05);
        }
        
        .btn-delete {
            background: #ff8a80;
            color: #c62828;
            border: none;
            padding: 8px 12px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 36px;
        }
        
        .btn-delete:hover {
            background: #ff5252;
            transform: scale(1.05);
        }

        .table-container {
            overflow-x: auto;
            border-radius: 8px;
            border: 1px solid #e0e0e0;
            margin-top: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            flex: 1;
            min-height: 0;
        }
        
        .treatment-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 800px;
        }
        
        .treatment-table thead {
            background-color: #e0e0e0;
            color: #333;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: bold;
        }
        
        .treatment-table th {
            padding: 16px 12px;
            text-align: center;
            font-weight: 700;
            font-size: 14px;
            border-bottom: 1px solid #ccc;
            position: sticky;
            top: 0;
            background: #e0e0e0;
            z-index: 5;
        }
        
        .treatment-table tbody tr {
            border-bottom: 1px solid #eaeaea;
            transition: background-color 0.2s ease;
        }
        
        .treatment-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .treatment-table td {
            padding: 14px 12px;
            font-size: 14px;
            color: #333;
            vertical-align: middle;
            text-align: center;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
            justify-content: center;
        }
        
        .no-treatments {
            text-align: center;
            padding: 60px 20px;
            background: #f9f9f9;
            border-radius: 8px;
            margin-top: 20px;
            border: 2px dashed #ddd;
        }
        
        .form-inline {
            display: inline-block;
            margin: 0;
        }

        .records-count {
            padding: 15px;
            text-align: center;
            color: #888;
            font-size: 12px;
            background: #fafafa;
        }

        /* Description column styles */
        .description-cell {
            text-align: left !important;
            max-width: 400px;
            word-wrap: break-word;
            line-height: 1.4;
        }
        
        .description-preview {
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            max-height: 2.8em;
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
            
            .search-wrapper { 
                width: 250px; 
            }
            
            .btn-add-custom {
                padding: 8px 20px;
            }
            
            .notification-container {
                width: 90%;
                top: 80px;
            }
        }

        @media (max-width: 768px) {
            .controls-row {
                flex-wrap: wrap;
            }
            
            .search-wrapper {
                width: 100%;
            }
            
            .treatment-table {
                min-width: 600px;
            }
            
            .description-cell {
                max-width: 250px;
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

        <!-- Notification Container -->
        <div class="notification-container">
            <% if (request.getAttribute("message") != null) { %>
                <div class="notification notification-success">
                    <div class="notification-content">
                        <i class="fas fa-check-circle notification-icon"></i>
                        <span>${message}</span>
                    </div>
                    <button class="notification-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="notification notification-error">
                    <div class="notification-content">
                        <i class="fas fa-exclamation-circle notification-icon"></i>
                        <span>${error}</span>
                    </div>
                    <button class="notification-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
            
            <% if (request.getAttribute("warning") != null) { %>
                <div class="notification notification-warning">
                    <div class="notification-content">
                        <i class="fas fa-exclamation-triangle notification-icon"></i>
                        <span>${warning}</span>
                    </div>
                    <button class="notification-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
            
            <% if (request.getAttribute("info") != null) { %>
                <div class="notification notification-info">
                    <div class="notification-content">
                        <i class="fas fa-info-circle notification-icon"></i>
                        <span>${info}</span>
                    </div>
                    <button class="notification-close" onclick="this.parentElement.style.display='none'">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            <% } %>
        </div>

        <div class="layout-wrap">
            <div class="layout">

                <!-- Sidebar -->
                <div class="sidebar">
                    <h6>Staff Dashboard</h6>
                    <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">Staff</a>
                    <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">Appointments</a>
                    <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">Billing</a>
                    <a class="side-link" href="/YesDentalSupportSystem/PatientServlet?action=list">Patients</a>
                    <a class="side-link active" href="/YesDentalSupportSystem/TreatmentServlet?action=list">Treatments</a>
                </div>

                <div class="card-panel">
                    <div class="page-header">
                        <h2 class="page-title">Manage Treatments</h2>
                        
                        <div class="controls-row">
                            <div class="search-wrapper">
                                <input type="text" id="searchInput" class="search-input" placeholder="Search treatments..." onkeyup="filterTable()">
                            </div>
                            
                            <a href="/YesDentalSupportSystem/treatment/addTreatment.jsp" class="btn-add-custom">
                                Add Treatment
                            </a>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <% 
                            List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
                            
                            if (treatments != null && !treatments.isEmpty()) { 
                        %>
                            <table class="treatment-table" id="treatmentTable">
                                <thead>
                                    <tr>
                                        <th width="15%">TREATMENT ID</th>
                                        <th width="20%">TREATMENT NAME</th>
                                        <th width="40%">DESCRIPTION</th>
                                        <th width="10%">PRICE (RM)</th>
                                        <th width="15%">ACTIONS</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Treatment treatment : treatments) { %>
                                    <tr>
                                        <td><%= treatment.getTreatmentId() %></td>
                                        <td><%= treatment.getTreatmentName() %></td>
                                        <td class="description-cell">
                                            <div class="description-preview" title="<%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "No description" %>">
                                                <%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "-" %>
                                            </div>
                                        </td>
                                        <td class="price-cell"><%= String.format("%.2f", treatment.getTreatmentPrice()) %></td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="TreatmentServlet?action=edit&treatment_id=<%= treatment.getTreatmentId() %>"
                                                   class="btn-edit" title="Edit Treatment" style="background:transparent; color:#d4a017; box-shadow:none;">
                                                    <i class="fas fa-pencil-alt"></i>
                                                </a>
                                                
                                                <form action="TreatmentServlet" method="post" class="form-inline" 
                                                      onsubmit="return confirmDelete()">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="treatment_id" value="<%= treatment.getTreatmentId() %>">
                                                    <button type="submit" class="btn-delete" title="Delete Treatment" style="background:transparent; color:#666; box-shadow:none;">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            
                            <div class="records-count">
                                Total Records: <%= treatments.size() %>
                            </div>
                        <% } else { %>
                            <div class="no-treatments">
                                <i class="fas fa-tooth" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                                <h5 style="color: #666; margin-bottom: 10px;">No treatments found</h5>
                                <a href="/YesDentalSupportSystem/treatment/addTreatment.jsp" class="btn-add-custom">
                                    Add Your First Treatment
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script>
        function confirmDelete() {
            return confirm('Are you sure you want to delete this treatment?');
        }
        
        // Search Functionality
        function filterTable() {
            var input, filter, table, tr, td, i, txtValue;
            input = document.getElementById("searchInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("treatmentTable");
            tr = table.getElementsByTagName("tr");

            // Loop through all table rows, and hide those who don't match the search query
            for (i = 0; i < tr.length; i++) {
                // Look at all columns for search: ID, Name, Description
                tdId = tr[i].getElementsByTagName("td")[0];
                tdName = tr[i].getElementsByTagName("td")[1];
                tdDesc = tr[i].getElementsByTagName("td")[2];
                
                if (tdId || tdName || tdDesc) {
                    txtValueId = tdId.textContent || tdId.innerText;
                    txtValueName = tdName.textContent || tdName.innerText;
                    txtValueDesc = tdDesc.textContent || tdDesc.innerText;
                    
                    if (txtValueId.toUpperCase().indexOf(filter) > -1 || 
                        txtValueName.toUpperCase().indexOf(filter) > -1 ||
                        txtValueDesc.toUpperCase().indexOf(filter) > -1) {
                        tr[i].style.display = "";
                    } else {
                        tr[i].style.display = "none";
                    }
                }
            }
        }
        
        // Auto-hide notifications after 5 seconds
        document.addEventListener('DOMContentLoaded', function() {
            var notifications = document.querySelectorAll('.notification');
            notifications.forEach(function(notification) {
                setTimeout(function() {
                    notification.style.transition = 'opacity 0.5s ease';
                    notification.style.opacity = '0';
                    setTimeout(function() {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 500);
                }, 5000); // 5 seconds
            });
        });
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>