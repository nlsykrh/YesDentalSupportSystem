<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Patient - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 800px; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">➕ Add New Patient</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <!--<form action="PatientServlet" method="post">-->
        <form action="${pageContext.request.contextPath}/PatientServlet" method="post">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="patient_crdate" value="<%= new java.sql.Timestamp(System.currentTimeMillis()) %>">
            <input type="hidden" name="patient_status" value="A">
            <input type="hidden" name="patient_password">
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Full Name</label>
                    <input type="text" class="form-control" name="patient_name" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">IC Number</label>
                    <input type="text" class="form-control" name="patient_ic" required>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Phone</label>
                    <input type="tel" class="form-control" name="patient_phone" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-control" name="patient_email" required>
                </div>
            </div>
            
            <div class="row mb-3">
                <div class="col-md-6">
                    <label class="form-label">Date of Birth</label>
                    <input type="date" class="form-control" name="patient_dob" required>
                </div>
                <div class="mb-3">
                <label class="form-label">Address</label>
                <textarea class="form-control" name="patient_address" rows="2" required></textarea>
                </div>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Guardian's Name</label>
                <textarea class="form-control" name="patient_guardian" rows="3"></textarea>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Guardian's Phone</label>
                <textarea class="form-control" name="patient_guardian_phone" rows="3"></textarea>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewPatients.jsp" class="btn btn-secondary">← Back to Patients</a>
                <button type="submit" class="btn btn-primary">Add Patient</button>
            </div>
        </form>
    </div>
</body>
</html>