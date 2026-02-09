<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Appointment" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Appointment - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 800px; }
        .form-label { font-weight: 500; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">✏️ Edit Appointment</h2>
        
        <% 
            Appointment appointment = (Appointment) request.getAttribute("appointment");
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            
            if (error != null) { 
        %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <% if (success != null) { %>
            <div class="alert alert-success">${success}</div>
        <% } %>
        
        <% if (appointment != null) { 
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String dateStr = appointment.getAppointmentDate() != null ? 
                sdf.format(appointment.getAppointmentDate()) : "";
        %>
        
        <form action="${pageContext.request.contextPath}/AppointmentServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">
            
            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">Appointment Details</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Appointment ID</label>
                            <input type="text" class="form-control" value="<%= appointment.getAppointmentId() %>" readonly>
                            <small class="text-muted">Cannot be changed</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Patient IC</label>
                            <input type="text" class="form-control" value="<%= appointment.getPatientIc() %>" readonly>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Appointment Date</label>
                            <input type="date" class="form-control" value="<%= dateStr %>" readonly>
                            <small class="text-muted">Date cannot be changed</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Appointment Time</label>
                            <input type="text" class="form-control" value="<%= appointment.getAppointmentTime() %>" readonly>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Appointment Status *</label>
                            <select class="form-control" name="appointment_status" required>
                            <option value="Pending" <%= "Pending".equals(appointment.getAppointmentStatus()) ? "selected" : "" %>>Pending</option>
                            <option value="Confirmed" <%= "Confirmed".equals(appointment.getAppointmentStatus()) ? "selected" : "" %>>Confirmed</option>
                            <option value="Cancelled" <%= "Cancelled".equals(appointment.getAppointmentStatus()) ? "selected" : "" %>>Cancelled</option>
                        </select>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Remarks</label>
                        <textarea class="form-control" name="remarks" rows="2"><%= appointment.getRemarks() != null ? appointment.getRemarks() : "" %></textarea>
                    </div>
                </div>
            </div>
            
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>Warning:</strong> Changing status from pending to confirmed will create billing and consent records automatically.
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewAppointments.jsp" class="btn btn-secondary">← Back to Appointments</a>
                <div>
                    <button type="submit" class="btn btn-primary">Update Appointment</button>
                    <a href="viewAppointments.jsp" class="btn btn-outline-secondary ms-2">Cancel</a>
                </div>
            </div>
        </form>
        
        <% } else { %>
            <div class="alert alert-warning">
                No appointment data found. Please select an appointment to edit.
            </div>
            <a href="viewAppointments.jsp" class="btn btn-primary">Back to Appointment List</a>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 
