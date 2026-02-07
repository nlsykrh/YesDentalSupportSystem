<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Appointment" %>
<%@ page import="dao.DigitalConsentDAO" %>
<!DOCTYPE html>
<html>
<head>
    <title>Appointments - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .filter-tabs .nav-link {
            cursor: pointer;
        }
        .filter-tabs .nav-link.active {
            font-weight: bold;
        }
        .appointment-row {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">📅 Appointment Management</h2>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success">${message}</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <div class="d-flex justify-content-between mb-3">
            <a href="patient/patientDashboard.jsp" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="scheduleAppointment.jsp" class="btn btn-success">
                <i class="fas fa-plus"></i> Add Appointment
            </a>
        </div>
        
        <!-- Status Filter Tabs -->
        <div class="card mb-3">
            <div class="card-body">
                <h5 class="card-title mb-3">Filter by Status</h5>
                <div class="filter-tabs">
                    <ul class="nav nav-pills">
                        <li class="nav-item">
                            <a class="nav-link active" data-status="all" onclick="filterAppointments('all')">
                                <i class="fas fa-list me-1"></i> All Appointments
                                <span class="badge bg-secondary" id="count-all">0</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-status="Confirmed" onclick="filterAppointments('Confirmed')">
                                <i class="fas fa-check-circle me-1"></i> Confirmed
                                <span class="badge bg-success" id="count-confirmed">0</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-status="Pending" onclick="filterAppointments('Pending')">
                                <i class="fas fa-clock me-1"></i> Pending
                                <span class="badge bg-warning" id="count-pending">0</span>
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-status="Cancelled" onclick="filterAppointments('Cancelled')">
                                <i class="fas fa-times-circle me-1"></i> Cancelled
                                <span class="badge bg-danger" id="count-cancelled">0</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        
        <!-- Appointments Table -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Appointment List</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped table-hover" id="appointmentsTable">
                    <thead>
                        <tr>
                            <th>Appointment ID</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Patient IC</th>
                            <th>Status</th>
                            <th>Remarks</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="appointmentsBody">
                        <%
                            List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                            
                            // Count statuses
                            int countAll = 0;
                            int countConfirmed = 0;
                            int countPending = 0;
                            int countCancelled = 0;

                            if (appointments != null && !appointments.isEmpty()) {
                                for (Appointment appointment : appointments) {
                                    String dateStr = appointment.getAppointmentDate() != null ? 
                                        dateFormat.format(appointment.getAppointmentDate()) : "N/A";
                                    String status = appointment.getAppointmentStatus();
                                    
                                    // Update counters
                                    countAll++;
                                    if ("Confirmed".equals(status)) {
                                        countConfirmed++;
                                    } else if ("Pending".equals(status)) {
                                        countPending++;
                                    } else if ("Cancelled".equals(status) || "Canceled".equals(status)) {
                                        countCancelled++;
                                    }
                        %>
                        <tr class="appointment-row" data-status="<%= status %>">
                            <td><%= appointment.getAppointmentId() %></td>
                            <td><%= dateStr %></td>
                            <td><%= appointment.getAppointmentTime() %></td>
                            <td><%= appointment.getPatientIc() %></td>
                            <td>
                                <span class="badge 
                                <%= "Confirmed".equals(status) ? "bg-success" : 
                                   "Pending".equals(status) ? "bg-warning" : 
                                   "Cancelled".equals(status) || "Canceled".equals(status) ? "bg-danger" : "bg-info" %>">
                                <%= status %>
                                </span>
                            </td>
                            <td><%= appointment.getRemarks() != null ? appointment.getRemarks() : "" %></td>
                            <td>
                                <a href="AppointmentServlet?action=view&appointment_id=<%= appointment.getAppointmentId() %>"
                                   class="btn btn-info btn-sm">
                                   <i class="fas fa-eye"></i> View
                                </a>
                                
                                <a href="AppointmentServlet?action=edit&appointment_id=<%= appointment.getAppointmentId() %>"
                                   class="btn btn-warning btn-sm">
                                   <i class="fas fa-edit"></i> Edit
                                </a>
                                
                                
                                <% if ("Confirmed".equals(appointment.getAppointmentStatus())) { 
                                    // Check if consent already exists
                                    DigitalConsentDAO consentDAO = new DigitalConsentDAO();
                                    boolean hasConsent = consentDAO.hasConsentForAppointment(appointment.getAppointmentId());
                                %>
                                    <% if (!hasConsent) { %>
                                    <a href="AppointmentServlet?action=consent&appointment_id=<%= appointment.getAppointmentId() %>"
                                       class="btn btn-primary btn-sm">
                                       <i class="fas fa-file-signature"></i> Digital Consent
                                    </a>
                                    <% } else { %>
                                    <span class="badge bg-success">
                                        <i class="fas fa-check-circle"></i> Consent Signed
                                    </span>
                                    <% } %>
                                <% } %>
                                
                                <% 
    // Check if consent exists
                                DigitalConsentDAO consentDAO = new DigitalConsentDAO();
                                boolean hasConsent = consentDAO.hasConsentForAppointment(appointment.getAppointmentId());

                                // Show cancel button only if:
                                // 1. Status is NOT "Cancelled" or "Canceled"
                                // 2. Digital consent has NOT been signed
                                if ((!"Cancelled".equals(appointment.getAppointmentStatus()) && !"Canceled".equals(appointment.getAppointmentStatus())) && !hasConsent) { 
                            %>
                                <form action="AppointmentServlet" method="post" style="display:inline;" 
                                      onsubmit="return confirmCancel()">
                                    <input type="hidden" name="action" value="cancel">
                                    <input type="hidden" name="appointment_id" value="<%= appointment.getAppointmentId() %>">
                                    <button type="submit" class="btn btn-sm btn-danger">
                                        <i class="fas fa-ban"></i> Cancel
                                    </button>
                                </form>
                            <% } else if ("Cancelled".equals(appointment.getAppointmentStatus()) || "Canceled".equals(appointment.getAppointmentStatus())) { %>
                                <span class="badge bg-secondary">
                                    <i class="fas fa-times"></i> Cancelled
                                </span>
                            <% } else if (hasConsent) { %>
                                <span class="badge bg-info" title="Cannot cancel after consent is signed">
                                    <i class="fas fa-lock"></i> Locked
                                </span>
                            <% } %>
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr id="noAppointmentsRow">
                            <td colspan="7" class="text-center">No appointments found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <!-- Display when no appointments match filter -->
                <div id="noFilterMatch" class="text-center py-3" style="display: none;">
                    <i class="fas fa-filter fa-2x text-muted mb-3"></i>
                    <p class="text-muted mb-0">No appointments match the selected filter.</p>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Set initial counts
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('count-all').textContent = <%= countAll %>;
            document.getElementById('count-confirmed').textContent = <%= countConfirmed %>;
            document.getElementById('count-pending').textContent = <%= countPending %>;
            document.getElementById('count-cancelled').textContent = <%= countCancelled %>;
            
            // Store all rows in a variable for easy filtering
            window.appointmentRows = document.querySelectorAll('.appointment-row');
            window.noAppointmentsRow = document.getElementById('noAppointmentsRow');
        });
        
        function filterAppointments(status) {
            // Update active tab
            document.querySelectorAll('.filter-tabs .nav-link').forEach(tab => {
                tab.classList.remove('active');
            });
            event.target.classList.add('active');
            
            let rowsToShow = 0;
            
            // Show/hide rows based on status
            window.appointmentRows.forEach(row => {
                const rowStatus = row.getAttribute('data-status');
                const shouldShow = status === 'all' || rowStatus === status;
                
                if (shouldShow) {
                    row.style.display = '';
                    rowsToShow++;
                } else {
                    row.style.display = 'none';
                }
            });
            
            // Handle empty states
            const noFilterMatch = document.getElementById('noFilterMatch');
            
            if (rowsToShow === 0) {
                // Hide the original "no appointments" row if it exists
                if (window.noAppointmentsRow) {
                    window.noAppointmentsRow.style.display = 'none';
                }
                // Show the "no filter match" message
                noFilterMatch.style.display = 'block';
            } else {
                // Hide both empty state messages
                if (window.noAppointmentsRow) {
                    window.noAppointmentsRow.style.display = 'none';
                }
                noFilterMatch.style.display = 'none';
            }
        }
        
        function confirmCancel() {
            return confirm('Are you sure you want to cancel this appointment? This will change the status to "Cancelled".');
        }
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>