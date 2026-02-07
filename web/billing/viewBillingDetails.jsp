<%@page import="java.text.SimpleDateFormat"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Billing" %>
<%@ page import="beans.Installment" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html>
<head>
    <title>Billing Details - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">📋 Billing Details</h2>
        
        <% 
            Billing billing = (Billing) request.getAttribute("billing");
            List<Installment> installments = (List<Installment>) request.getAttribute("installments");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
        %>
        
        <% if (billing == null) { %>
            <div class="alert alert-warning">
                Billing not found.
            </div>
            <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="btn btn-primary">Back to Billings</a>
        <% } else { %>
        
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Billing Information</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <table class="table table-borderless">
                            <tr>
                                <th width="40%">Billing ID:</th>
                                <td><span class="badge bg-dark fs-6"><%= billing.getBillingId() %></span></td>
                            </tr>
                            <tr>
                                <th>Amount:</th>
                                <td class="fw-bold text-primary fs-5"><%= currencyFormat.format(billing.getBillingAmount()) %></td>
                            </tr>
                            <tr>
                                <th>Due Date:</th>
                                <td><%= dateFormat.format(billing.getBillingDuedate()) %></td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <table class="table table-borderless">
                            <tr>
                                <th width="40%">Status:</th>
                                <td>
                                    <span class="badge <%= "Paid".equals(billing.getBillingStatus()) ? "bg-success" : "bg-warning" %> fs-6">
                                        <%= billing.getBillingStatus() %>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Payment Method:</th>
                                <td>
                                    <span class="badge <%= "Installment".equals(billing.getBillingMethod()) ? "bg-info" : "bg-secondary" %>">
                                        <%= billing.getBillingMethod() %>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Appointment ID:</th>
                                <td><%= billing.getAppointmentId() %></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod()) && installments != null && !installments.isEmpty()) { %>
        <div class="card mb-4">
            <div class="card-header bg-info text-white">
                <h5 class="mb-0">Installment Details</h5>
            </div>
            <div class="card-body">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Installment ID</th>
                            <th>Installment #</th>
                            <th>Payment Date</th>
                            <th>Amount</th>
                            <th>Paid Amount</th>
                            <th>Remaining</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Installment installment : installments) { 
                            int installmentNum = installments.indexOf(installment) + 1;
                        %>
                        <tr>
                            <td><%= installment.getInstallmentId() %></td>
                            <td><%= installmentNum %>/<%= installment.getNumofinstallment() %></td>
                            <td><%= installment.getPaymentDate() %></td>
                            <td class="fw-bold"><%= currencyFormat.format(installment.getPaymentAmount()) %></td>
                            <td><%= currencyFormat.format(installment.getPaidAmount()) %></td>
                            <td class="<%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-danger fw-bold" : "text-success fw-bold" %>">
                                <%= currencyFormat.format(installment.getRemainingAmount()) %>
                            </td>
                            <td>
                                <span class="badge <%= "Paid".equals(installment.getPaymentStatus()) ? "bg-success" : 
                                                    "Partial".equals(installment.getPaymentStatus()) ? "bg-warning" : "bg-danger" %>">
                                    <%= installment.getPaymentStatus() %>
                                </span>
                            </td>
                            <td>
                                <% if (!"Paid".equals(installment.getPaymentStatus())) { %>
                                <a href="BillingServlet?action=make_payment_form&installment_id=<%= installment.getInstallmentId() %>"
                                   class="btn btn-success btn-sm">
                                    <i class="fas fa-money-bill-wave"></i> Pay
                                </a>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>
        
        <div class="d-flex justify-content-between">
            <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Billings
            </a>
            <div>
                <% if ("Pending".equals(billing.getBillingStatus())) { %>
                <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>"
                   class="btn btn-warning">
                    <i class="fas fa-edit"></i> Edit Billing
                </a>
                <% } %>
                
                <% if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) { %>
                <a href="BillingServlet?action=view_installments&billing_id=<%= billing.getBillingId() %>"
                   class="btn btn-info">
                    <i class="fas fa-list"></i> View Installments
                </a>
                <% } %>
                
<!--                <form action="BillingServlet" method="post" style="display:inline;" 
                      onsubmit="return confirmDelete()">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="billing_id" value="<%= billing.getBillingId() %>">
                    <button type="submit" class="btn btn-danger">
                        <i class="fas fa-trash"></i> Delete Billing
                    </button>
                </form>-->
            </div>
        </div>
        
        <% } %>
    </div>
    
    <script>//
//        function confirmDelete() {
//            return confirm('Are you sure you want to delete this billing? All related installments will also be deleted.');
//        }
//    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>