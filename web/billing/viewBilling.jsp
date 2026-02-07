<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html>
<head>
    <title>Billing Management - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .status-badge {
            font-size: 0.8em;
            padding: 5px 10px;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">💰 Billing Management</h2>
        
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
        </div>
        
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Billing List</h5>
            </div>
            <div class="card-body">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>Billing ID</th>
                            <th>Amount</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Method</th>
                            <th>Appointment ID</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Billing> billings = (List<Billing>) request.getAttribute("billings");
                            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");

                            if (billings != null && !billings.isEmpty()) {
                                for (Billing billing : billings) {
                                    String dateStr = billing.getBillingDuedate() != null ? 
                                        dateFormat.format(billing.getBillingDuedate()) : "N/A";
                        %>
                        <tr>
                            <td><%= billing.getBillingId() %></td>
                            <td><%= currencyFormat.format(billing.getBillingAmount()) %></td>
                            <td><%= dateStr %></td>
                            <td>
                                <span class="badge <%= "Paid".equals(billing.getBillingStatus()) ? "bg-success" : "bg-warning" %> status-badge">
                                    <%= billing.getBillingStatus() %>
                                </span>
                            </td>
                            <td>
                                <span class="badge <%= "Installment".equals(billing.getBillingMethod()) ? "bg-info" : "bg-secondary" %> status-badge">
                                    <%= billing.getBillingMethod() %>
                                </span>
                            </td>
                            <td><%= billing.getAppointmentId() %></td>
                            <td>
                                <a href="BillingServlet?action=view&billing_id=<%= billing.getBillingId() %>"
                                   class="btn btn-info btn-sm">
                                   <i class="fas fa-eye"></i> View
                                </a>
                                
                                <% if ("Pending".equals(billing.getBillingStatus())) { %>
                                <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>"
                                   class="btn btn-warning btn-sm">
                                   <i class="fas fa-edit"></i> Edit
                                </a>
                                <% } %>
                                
                                <% if ("Installment".equals(billing.getBillingMethod()) && !"Paid".equals(billing.getBillingStatus())) { %>
                                <a href="BillingServlet?action=view_installments&billing_id=<%= billing.getBillingId() %>"
                                   class="btn btn-primary btn-sm">
                                   <i class="fas fa-list"></i> Installments
                                </a>
                                <% } %>
                                
<!--                                <form action="BillingServlet" method="post" style="display:inline;" 
                                      onsubmit="return confirmDelete()">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="billing_id" value="<%= billing.getBillingId() %>">
                                    <button type="submit" class="btn btn-sm btn-danger">
                                        <i class="fas fa-trash"></i> Delete
                                    </button>
                                </form>-->
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center">No billings found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>//
//        function confirmDelete() {
//            return confirm('Are you sure you want to delete this billing? All related installments will also be deleted.');
//        }
//    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>