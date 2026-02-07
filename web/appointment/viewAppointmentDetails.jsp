<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="beans.AppointmentTreatment" %>
<%@ page import="dao.DigitalConsentDAO" %>
<%@ page import="beans.DigitalConsent" %>
<!DOCTYPE html>
<html>
<head>
    <title>Appointment Details - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">📋 Appointment Details</h2>
        
        <% 
            Appointment appointment = (Appointment) request.getAttribute("appointment");
            List<AppointmentTreatment> treatments = (List<AppointmentTreatment>) request.getAttribute("treatments");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        %>
        
        <% if (appointment == null) { %>
            <div class="alert alert-warning">
                Appointment not found.
            </div>
            <a href="viewAppointments.jsp" class="btn btn-primary">Back to Appointments</a>
        <% } else { %>
        
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Appointment Information</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3">
                        <strong>Appointment ID:</strong><br>
                        <span class="badge bg-dark fs-6"><%= appointment.getAppointmentId() %></span>
                    </div>
                    <div class="col-md-3">
                        <strong>Date:</strong><br>
                        <%= dateFormat.format(appointment.getAppointmentDate()) %>
                    </div>
                    <div class="col-md-3">
                        <strong>Time:</strong><br>
                        <%= appointment.getAppointmentTime() %>
                    </div>
                    <div class="col-md-3">
                        <strong>Status:</strong><br>
                        <span class="badge 
                            <%= "Confirmed".equals(appointment.getAppointmentStatus()) ? "bg-success" : 
                                "Cancelled".equals(appointment.getAppointmentStatus()) ? "bg-danger" : 
                               "Pending".equals(appointment.getAppointmentStatus()) ? "bg-warning" : "bg-danger" %>">
                            <%= appointment.getAppointmentStatus().toUpperCase() %>
                        </span>
                    </div>
                </div>
                
                <hr>
                
                <div class="row">
                    <div class="col-md-6">
                        <strong>Patient IC:</strong><br>
                        <%= appointment.getPatientIc() %>
                    </div>
                    <div class="col-md-6">
                        <strong>Remarks:</strong><br>
                        <%= appointment.getRemarks() != null ? appointment.getRemarks() : "No remarks" %>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="card mb-4">
            <div class="card-header bg-info text-white">
                <h5 class="mb-0">Treatment Information</h5>
            </div>
            <div class="card-body">
                <% if (treatments != null && !treatments.isEmpty()) { %>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Treatment ID</th>
                                <th>Treatment Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (AppointmentTreatment treatment : treatments) { %>
                            <tr>
                                <td><%= treatment.getTreatmentId() %></td>
                                <td><%= dateFormat.format(treatment.getAppointmentDate()) %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <p class="text-muted">No treatments recorded for this appointment.</p>
                <% } %>
            </div>
        </div>
            
            <% 
    DigitalConsentDAO consentDAO = new DigitalConsentDAO();
    DigitalConsent consent = consentDAO.getConsentByAppointmentId(appointment.getAppointmentId());
%>

<div class="card mb-4">
    <div class="card-header bg-success text-white">
        <h5 class="mb-0"><i class="fas fa-file-contract"></i> Digital Consent Status</h5>
    </div>
    <div class="card-body">
        <% if (consent != null) { 
            SimpleDateFormat timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        %>
            <div class="row">
                <div class="col-md-4">
                    <strong>Consent ID:</strong><br>
                    <span class="badge bg-dark"><%= consent.getConsentId() %></span>
                </div>
                <div class="col-md-4">
                    <strong>Signed Date:</strong><br>
                    <%= timestampFormat.format(consent.getConsentSigndate()) %>
                </div>
                <div class="col-md-4">
                    <strong>Status:</strong><br>
                    <span class="badge bg-success">SIGNED</span>
                </div>
            </div>
            <div class="mt-3">
                <strong>Consent Context:</strong><br>
                <%= consent.getConsentContext() %>
            </div>
        <% } else if ("Confirmed".equals(appointment.getAppointmentStatus())) { %>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>Digital consent pending!</strong> This confirmed appointment requires digital consent.
            </div>
            <a href="AppointmentServlet?action=consent&appointment_id=<%= appointment.getAppointmentId() %>"
               class="btn btn-primary">
               <i class="fas fa-file-signature"></i> Sign Digital Consent Now
            </a>
        <% } else { %>
            <p class="text-muted">Digital consent will be available once appointment is confirmed.</p>
        <% } %>
    </div>
</div>
        
        <%
    // Reuse consentDAO or create new one
    DigitalConsentDAO consentDAO = new DigitalConsentDAO();
    boolean hasConsent = consentDAO.hasConsentForAppointment(appointment.getAppointmentId());
    String status = appointment.getAppointmentStatus();
    boolean isCancelled = "Cancelled".equals(status) || "Canceled".equals(status);
%>

<div class="d-flex justify-content-between">
    <a href="/YesDentalSupportSystem/AppointmentServlet?action=list" class="btn btn-secondary">
        <i class="fas fa-arrow-left"></i> Back to Appointments
    </a>
    <div>
        <a href="AppointmentServlet?action=edit&appointment_id=<%= appointment.getAppointmentId() %>"
           class="btn btn-warning">
            <i class="fas fa-edit"></i> Edit Appointment
        </a>
        
        <% if (!isCancelled && !hasConsent) { %>
            <form action="AppointmentServlet" method="post" style="display:inline;" 
                  onsubmit="return confirmCancel()">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">
                <button type="submit" class="btn btn-danger">
                    <i class="fas fa-ban"></i> Cancel Appointment
                </button>
            </form>
        <% } else if (isCancelled) { %>
            <span class="badge bg-secondary">
                <i class="fas fa-times"></i> Already Cancelled
            </span>
        <% } else if (hasConsent) { %>
            <span class="badge bg-info" title="Cannot cancel after consent is signed">
                <i class="fas fa-lock"></i> Appointment Locked
            </span>
        <% } %>
        
        <!-- Optional: Keep delete for cancelled appointments only -->
        <% if (isCancelled) { %>
            <form action="AppointmentServlet" method="post" style="display:inline;" 
                  onsubmit="return confirmDelete()">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">
                <button type="submit" class="btn btn-outline-danger">
                    <i class="fas fa-trash"></i> Delete
                </button>
            </form>
        <% } %>
    </div>
</div>
        
        <% } %>
    </div>
    
    <script>
        function confirmCancel() {
            return confirm('Are you sure you want to cancel this appointment? This will change the status to "Cancelled".');
        }
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>