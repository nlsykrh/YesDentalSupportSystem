<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="beans.Staff" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .profile-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            border-radius: 10px;
            margin-bottom: 2rem;
        }
        .profile-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        .card {
            border: none;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 1.5rem;
        }
        .card-header {
            background-color: #f8f9fa;
            border-bottom: 2px solid #e9ecef;
            font-weight: 600;
        }
        .info-row {
            padding: 0.75rem 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .readonly-field {
            background-color: #f8f9fa;
        }
        .password-form {
            max-width: 400px;
            margin: 0 auto;
        }
        .welcome-user {
            background-color: #e8f4fc;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <!-- Welcome Message -->
        <div class="welcome-user">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-1">Welcome, 
                        <% if ("patient".equals(request.getAttribute("userType"))) { 
                            Patient p = (Patient) request.getAttribute("patient"); %>
                            <%= p.getPatientName() %>
                        <% } else if ("staff".equals(request.getAttribute("userType"))) { 
                            Staff s = (Staff) request.getAttribute("staff"); %>
                            <%= s.getStaffName() %>
                        <% } %>
                    </h5>
                    <span class="badge bg-primary">
                        <% if ("patient".equals(request.getAttribute("userType"))) { %>
                            Patient
                        <% } else { %>
                            <%= request.getAttribute("staffRole") %>
                        <% } %>
                    </span>
                </div>
                <a href="LogoutServlet" class="btn btn-outline-danger btn-sm">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
        
        <!-- Success/Error Messages -->
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <%
            String userType = (String) request.getAttribute("userType");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            boolean isEditMode = "true".equals(request.getParameter("edit"));
            boolean isChangePassword = "true".equals(request.getParameter("changepassword"));
        %>
        
        <!-- Profile Header -->
        <div class="profile-header text-center">
            <div class="profile-icon">
                <% if ("patient".equals(userType)) { %>
                    <i class="fas fa-user-injured"></i>
                <% } else { %>
                    <i class="fas fa-user-md"></i>
                <% } %>
            </div>
            <h1>My Profile</h1>
            <p class="lead">
                <% if ("patient".equals(userType)) { %>
                    Manage your personal information
                <% } else { %>
                    Manage your staff profile
                <% } %>
            </p>
        </div>
        
        <!-- Navigation -->
        <div class="d-flex justify-content-between mb-4">
            <div>
                <% if ("patient".equals(userType)) { %>
                    <a href="/YesDentalSupportSystem/patient/index.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-home"></i>Dashboard
                    </a>
                <% } else { %>
                    <a href="/YesDentalSupportSystem/staff/index.jsp" class="btn btn-outline-secondary">
                        <i class="fas fa-home"></i> Dashboard
                    </a>
                <% } %>
            </div>
            <div>
                <% if (!isEditMode && !isChangePassword) { %>
                    <a href="ProfileServlet?edit=true" class="btn btn-primary">
                        <i class="fas fa-edit"></i> Edit Profile
                    </a>
                <% } else if (isEditMode) { %>
                    <a href="ProfileServlet" class="btn btn-outline-secondary">
                        <i class="fas fa-times"></i> Cancel Edit
                    </a>
                <% } else if (isChangePassword) { %>
                    <a href="ProfileServlet" class="btn btn-outline-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                <% } %>
            </div>
        </div>
        
        <!-- Change Password Form -->
        <% if (isChangePassword) { %>
        <div class="card">
            <div class="card-header">
                <i class="fas fa-key"></i> Change Password
            </div>
            <div class="card-body">
                <form action="ProfileServlet" method="post" class="password-form">
                    <input type="hidden" name="action" value="changePassword">
                    
                    <div class="mb-3">
                        <label class="form-label">Current Password</label>
                        <input type="password" name="current_password" class="form-control" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <input type="password" name="new_password" class="form-control" required
                               minlength="6" placeholder="Minimum 6 characters">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" name="confirm_password" class="form-control" required>
                    </div>
                    
                    <div class="text-center">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Change Password
                        </button>
                        <a href="ProfileServlet" class="btn btn-outline-secondary ms-2">
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
        <% } else if (isEditMode) { %>
        <!-- Edit Profile Form -->
        <form action="ProfileServlet" method="post" id="profileForm">
            <input type="hidden" name="action" value="update">
            
            <% if ("patient".equals(userType)) { 
                Patient patient = (Patient) request.getAttribute("patient");
            %>
                <!-- Personal Information -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-id-card"></i> Personal Information
                    </div>
                    <div class="card-body">
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">IC Number:</div>
                            <div class="col-md-9">
                                <input type="text" class="form-control readonly-field" 
                                       value="<%= patient.getPatientIc() %>" readonly>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Full Name:</div>
                            <div class="col-md-9">
                                <input type="text" name="patient_name" class="form-control" 
                                       value="<%= patient.getPatientName() != null ? patient.getPatientName() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Email:</div>
                            <div class="col-md-9">
                                <input type="email" name="patient_email" class="form-control" 
                                       value="<%= patient.getPatientEmail() != null ? patient.getPatientEmail() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Phone:</div>
                            <div class="col-md-9">
                                <input type="tel" name="patient_phone" class="form-control" 
                                       value="<%= patient.getPatientPhone() != null ? patient.getPatientPhone() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Date of Birth:</div>
                            <div class="col-md-9">
                                <input type="date" name="patient_dob" class="form-control" 
                                       value="<%= patient.getPatientDob() != null ? sdf.format(patient.getPatientDob()) : "" %>">
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-address-book"></i> Contact Information
                    </div>
                    <div class="card-body">
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Address:</div>
                            <div class="col-md-9">
                                <textarea name="patient_address" class="form-control" rows="3"><%= patient.getPatientAddress() != null ? patient.getPatientAddress() : "" %></textarea>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Guardian Name:</div>
                            <div class="col-md-9">
                                <input type="text" name="patient_guardian" class="form-control" 
                                       value="<%= patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "" %>">
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Guardian Phone:</div>
                            <div class="col-md-9">
                                <input type="tel" name="patient_guardian_phone" class="form-control" 
                                       value="<%= patient.getPatientGuardianPhone() != null ? patient.getPatientGuardianPhone() : "" %>">
                            </div>
                        </div>
                    </div>
                </div>
                
            <% } else if ("staff".equals(userType)) { 
                Staff staff = (Staff) request.getAttribute("staff");
            %>
                <!-- Staff Information -->
                <div class="card">
                    <div class="card-header">
                        <i class="fas fa-id-badge"></i> Staff Information
                    </div>
                    <div class="card-body">
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Staff ID:</div>
                            <div class="col-md-9">
                                <input type="text" class="form-control readonly-field" 
                                       value="<%= staff.getStaffId() %>" readonly>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Full Name:</div>
                            <div class="col-md-9">
                                <input type="text" name="staff_name" class="form-control" 
                                       value="<%= staff.getStaffName() != null ? staff.getStaffName() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Email:</div>
                            <div class="col-md-9">
                                <input type="email" name="staff_email" class="form-control" 
                                       value="<%= staff.getStaffEmail() != null ? staff.getStaffEmail() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Phone Number:</div>
                            <div class="col-md-9">
                                <input type="tel" name="staff_phonenum" class="form-control" 
                                       value="<%= staff.getStaffPhonenum() != null ? staff.getStaffPhonenum() : "" %>" required>
                            </div>
                        </div>
                        <div class="row info-row">
                            <div class="col-md-3 fw-bold">Role:</div>
                            <div class="col-md-9">
                                <span class="badge bg-info">
                                    <%= staff.getStaffRole() != null ? staff.getStaffRole() : "Not assigned" %>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>
            
            <!-- Save Button -->
            <div class="card mt-4 border-primary">
                <div class="card-body text-center">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <i class="fas fa-save"></i> Save
                    </button>
                    <a href="ProfileServlet" class="btn btn-outline-secondary btn-lg ms-2">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </div>
        </form>
        <% } else { %>
        <!-- View Mode -->
        <% if ("patient".equals(userType)) { 
            Patient patient = (Patient) request.getAttribute("patient");
        %>
            <!-- Personal Information -->
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-id-card"></i> Personal Information
                </div>
                <div class="card-body">
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">IC Number:</div>
                        <div class="col-md-9"><%= patient.getPatientIc() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Full Name:</div>
                        <div class="col-md-9"><%= patient.getPatientName() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Email:</div>
                        <div class="col-md-9"><%= patient.getPatientEmail() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Phone:</div>
                        <div class="col-md-9"><%= patient.getPatientPhone() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Date of Birth:</div>
                        <div class="col-md-9"><%= patient.getPatientDob() != null ? sdf.format(patient.getPatientDob()) : "Not set" %></div>
                    </div>
                </div>
            </div>
            
            <!-- Contact Information -->
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-address-book"></i> Contact Information
                </div>
                <div class="card-body">
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Address:</div>
                        <div class="col-md-9"><%= patient.getPatientAddress() != null ? patient.getPatientAddress().replace("\n", "<br>") : "Not set" %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Guardian Name:</div>
                        <div class="col-md-9"><%= patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "Not set" %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Guardian Phone:</div>
                        <div class="col-md-9"><%= patient.getPatientGuardianPhone() != null ? patient.getPatientGuardianPhone() : "Not set" %></div>
                    </div>
                </div>
            </div>
            
            <!-- Account Information -->
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-user-shield"></i> Account Information
                </div>
                <div class="card-body">
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Status:</div>
                        <div class="col-md-9">
                            <span class="badge <%= "A".equals(patient.getPatientStatus()) ? "bg-success" : "bg-secondary" %>">
                                <%= "A".equals(patient.getPatientStatus()) ? "Active" : "Inactive" %>
                            </span>
                        </div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Registration Date:</div>
                        <div class="col-md-9">
                            <%= patient.getPatientCrDate() != null ? sdf.format(patient.getPatientCrDate()) : "N/A" %>
                        </div>
                    </div>
                </div>
            </div>
            
        <% } else if ("staff".equals(userType)) { 
            Staff staff = (Staff) request.getAttribute("staff");
        %>
            <!-- Staff Information -->
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-id-badge"></i> Staff Information
                </div>
                <div class="card-body">
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Staff ID:</div>
                        <div class="col-md-9"><%= staff.getStaffId() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Full Name:</div>
                        <div class="col-md-9"><%= staff.getStaffName() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Email:</div>
                        <div class="col-md-9"><%= staff.getStaffEmail() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Phone Number:</div>
                        <div class="col-md-9"><%= staff.getStaffPhonenum() %></div>
                    </div>
                    <div class="row info-row">
                        <div class="col-md-3 fw-bold">Role:</div>
                        <div class="col-md-9">
                            <span class="badge bg-info">
                                <%= staff.getStaffRole() != null ? staff.getStaffRole() : "Not assigned" %>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        document.getElementById('profileForm')?.addEventListener('submit', function(e) {
            const emailInput = this.querySelector('input[type="email"]');
            const phoneInput = this.querySelector('input[type="tel"]');
            
            if (emailInput && !isValidEmail(emailInput.value)) {
                e.preventDefault();
                alert('Please enter a valid email address.');
                emailInput.focus();
                return false;
            }
            
            if (phoneInput && !isValidPhone(phoneInput.value)) {
                e.preventDefault();
                alert('Please enter a valid phone number.');
                phoneInput.focus();
                return false;
            }
            
            return true;
        });
        
        function isValidEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }
        
        function isValidPhone(phone) {
            const re = /^[\+]?[0-9\s\-\(\)]{10,}$/;
            return re.test(phone);
        }
    </script>
</body>
</html>