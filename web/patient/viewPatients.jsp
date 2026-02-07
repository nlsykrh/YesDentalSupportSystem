<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@page import="java.util.ArrayList"%>
<%@ page import="beans.Patient" %>

<!DOCTYPE html>
<html>
<head>
    <title>View Patients - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">👨‍⚕️ Patient Management</h2>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success">${message}</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <div class="d-flex justify-content-between mb-3">
            <a href="/YesDentalSupportSystem/staff/index.jsp" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="/YesDentalSupportSystem/patient/addPatient.jsp" class="btn btn-success">
                <i class="fas fa-plus"></i> Add New Patient
            </a>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Patient List</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>IC Number</th>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Date of Birth</th>
                            <th>Status</th>
                            <th>Registration Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Patient> patients = (List<Patient>) request.getAttribute("patients");
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

                            if (patients != null && !patients.isEmpty()) {
                                for (Patient patient : patients) {
                                    String dobStr = patient.getPatientDob() != null ? 
                                        sdf.format(patient.getPatientDob()) : "N/A";
                                    String crDateStr = patient.getPatientCrDate() != null ? 
                                        sdf.format(patient.getPatientCrDate()) : "N/A";
                        %>
                        <tr>
                            <td><%= patient.getPatientIc() %></td>
                            <td><%= patient.getPatientName() %></td>
                            <td><%= patient.getPatientEmail() %></td>
                            <td><%= patient.getPatientPhone() %></td>
                            <td><%= dobStr %></td>
                            <td>
                                <span class="badge <%= "A".equals(patient.getPatientStatus()) ? "bg-success" : "bg-secondary" %>">
                                    <%= "A".equals(patient.getPatientStatus()) ? "Active" : "Inactive" %>
                                </span>
                            </td>
                            <td><%= crDateStr %></td>
                            <td>
                                 <a href="PatientServlet?action=view&patient_ic=<%= patient.getPatientIc() %>"
                                   class="btn btn-info btn-sm">
                                   <i class="fas fa-eye"></i> View
                                </a>
                                <a href="PatientServlet?action=edit&patient_ic=<%= patient.getPatientIc() %>"
                                   class="btn btn-warning btn-sm">
                                   <i class="fas fa-edit"></i> Edit
                                </a>
                                
<!--                                <form action="PatientServlet" method="post" style="display:inline;" 
                                      onsubmit="return confirmDelete()">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="patient_ic" value="<%= patient.getPatientIc() %>">
                                    <button type="submit" class="btn btn-sm btn-danger">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </form>-->
                                
<!--                                <a href="../appointment/scheduleAppointment.jsp?patient_ic=<%= patient.getPatientIc() %>" 
                                   class="btn btn-sm btn-info">
                                    <i class="fas fa-calendar-plus"></i> Appointment
                                </a>-->
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="8" class="text-center">No patients found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>//
//        function confirmDelete() {
//            return confirm('Are you sure you want to delete this patient? This action cannot be undone.');
//        }
//    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
