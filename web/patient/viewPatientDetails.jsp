<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Patient" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Patient - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 800px; }
        .form-label { font-weight: 500; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">✏️ View Patient Details</h2>
        
        <% 
            Patient patient = (Patient) request.getAttribute("patient");
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            
            if (error != null) { 
        %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <% if (success != null) { %>
            <div class="alert alert-success">${success}</div>
        <% } %>
        
        <% if (patient != null) { 
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String dobStr = patient.getPatientDob() != null ? 
                sdf.format(patient.getPatientDob()) : "";
        %>
        
        <form action="${pageContext.request.contextPath}/PatientServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="patient_ic" value="<%= patient.getPatientIc() %>">
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">IC Number</label>
                    <input type="text" class="form-control" value="<%= patient.getPatientIc() %>" readonly>
                    <small class="text-muted">IC Number cannot be changed</small>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Full Name *</label>
                    <input type="text" class="form-control" name="patient_name" 
                           value="<%= patient.getPatientName() != null ? patient.getPatientName() : "" %>" readonly>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Phone *</label>
                    <input type="tel" class="form-control" name="patient_phone" 
                           value="<%= patient.getPatientPhone() != null ? patient.getPatientPhone() : "" %>" readonly>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email *</label>
                    <input type="email" class="form-control" name="patient_email" 
                           value="<%= patient.getPatientEmail() != null ? patient.getPatientEmail() : "" %>" readonly>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Date of Birth *</label>
                    <input type="date" class="form-control" name="patient_dob" 
                           value="<%= dobStr %>" readonly>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Status</label>
                    <select class="form-control" name="patient_status" disabled>
                        <option value="A" <%= "A".equals(patient.getPatientStatus()) ? "selected" : "" %>>Active</option>
                        <option value="I" <%= "I".equals(patient.getPatientStatus()) ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Address *</label>
                <textarea class="form-control" name="patient_address" rows="2" readonly required><%= patient.getPatientAddress() != null ? patient.getPatientAddress() : "" %></textarea>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Guardian's Name</label>
                    <input type="text" class="form-control" name="patient_guardian"  readonly
                           value="<%= patient.getPatientGuardian() != null ? patient.getPatientGuardian() : "" %>">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Guardian's Phone</label>
                    <input type="tel" class="form-control" name="patient_guardian_phone" readonly 
                           value="<%= patient.getPatientGuardianPhone() != null ? patient.getPatientGuardianPhone() : "" %>">
                </div>
            </div>
            
            <div class="mb-4">
                <h5>System Information</h5>
                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label">Registration Date</label>
                        <input type="text" class="form-control" 
                               value="<%= patient.getPatientCrDate() != null ? 
                                   new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(patient.getPatientCrDate()) : "N/A" %>" 
                               readonly>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Password</label>
                        <input type="text" class="form-control" 
                               value="<%= patient.getPatientPassword() != null ? patient.getPatientPassword() : "N/A" %>" 
                               readonly>
                        <small class="text-muted">Auto-generated from phone number</small>
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="/YesDentalSupportSystem/PatientServlet?action=list" class="btn btn-secondary">← Back to Patients</a>
<!--                <div>
                    <button type="submit" class="btn btn-primary">Update Patient</button>
                    <a href="viewPatients.jsp" class="btn btn-outline-secondary ms-2">Cancel</a>
                </div>-->
            </div>
        </form>
        
        <% } else { %>
            <div class="alert alert-warning">
                No patient data found.
            </div>
            <a href="/YesDentalSupportSystem/patient/viewPatients.jsp" class="btn btn-primary">Back to Patient List</a>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>