<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Billing" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Billing - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 800px; }
        .form-label { font-weight: 500; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">✏️ Edit Billing</h2>
        
        <% 
            Billing billing = (Billing) request.getAttribute("billing");
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
            
            if (error != null) { 
        %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <% if (success != null) { %>
            <div class="alert alert-success">${success}</div>
        <% } %>
        
        <% if (billing != null) { 
            String dateStr = billing.getBillingDuedate() != null ? 
                sdf.format(billing.getBillingDuedate()) : "";
        %>
        
        <form action="${pageContext.request.contextPath}/BillingServlet" method="post">
            <input type="hidden" name="action" value="update_method">
            <input type="hidden" name="billing_id" value="<%= billing.getBillingId() %>">
            
            <div class="card mb-4">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">Billing Details</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Billing ID</label>
                            <input type="text" class="form-control" value="<%= billing.getBillingId() %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Amount</label>
                            <input type="text" class="form-control" value="<%= currencyFormat.format(billing.getBillingAmount()) %>" readonly>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Due Date</label>
                            <input type="text" class="form-control" value="<%= dateStr %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Appointment ID</label>
                            <input type="text" class="form-control" value="<%= billing.getAppointmentId() %>" readonly>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Current Status</label>
                            <input type="text" class="form-control" value="<%= billing.getBillingStatus() %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Update Status</label>
                            <select class="form-control" name="billing_status">
                                <option value="Pending" <%= "Pending".equals(billing.getBillingStatus()) ? "selected" : "" %>>Pending</option>
                                <option value="Paid" <%= "Paid".equals(billing.getBillingStatus()) ? "selected" : "" %>>Paid</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Current Payment Method</label>
                            <input type="text" class="form-control" value="<%= billing.getBillingMethod() %>" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Update Payment Method *</label>
                            <select class="form-control" name="billing_method" id="billingMethod" required>
                                <option value="Pay in Whole" <%= "Pay in Whole".equals(billing.getBillingMethod()) ? "selected" : "" %>>Pay in Whole</option>
                                <option value="Installment" <%= "Installment".equals(billing.getBillingMethod()) ? "selected" : "" %>>Installment</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row mb-3" id="installmentSection" style="display: <%= "Installment".equals(billing.getBillingMethod()) ? "block" : "none" %>;">
                        <div class="col-md-12">
                            <label class="form-label">Number of Installments *</label>
                            <select class="form-control" name="num_installments" id="numInstallments">
                                <option value="1">1 Installment</option>
                                <option value="2">2 Installments</option>
                                <option value="3">3 Installments</option>
                                <option value="4">4 Installments</option>
                                <option value="5">5 Installments</option>
                            </select>
                            <small class="text-muted">Maximum 5 installments allowed</small>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle"></i>
                <strong>Note:</strong> Changing payment method to "Installment" will create installment records automatically.
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewBilling.jsp" class="btn btn-secondary">← Back to Billings</a>
                <div>
                    <button type="submit" class="btn btn-primary">Update Billing</button>
                    <a href="viewBilling.jsp" class="btn btn-outline-secondary ms-2">Cancel</a>
                </div>
            </div>
        </form>
        
        <% } else { %>
            <div class="alert alert-warning">
                No billing data found. Please select a billing to edit.
            </div>
            <a href="viewBilling.jsp" class="btn btn-primary">Back to Billing List</a>
        <% } %>
    </div>
    
    <script>
        document.getElementById('billingMethod').addEventListener('change', function() {
            var installmentSection = document.getElementById('installmentSection');
            if (this.value === 'Installment') {
                installmentSection.style.display = 'block';
                document.getElementById('numInstallments').required = true;
            } else {
                installmentSection.style.display = 'none';
                document.getElementById('numInstallments').required = false;
            }
        });
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>