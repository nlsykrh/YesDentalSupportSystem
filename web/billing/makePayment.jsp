<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Make Payment - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 600px; }
        .form-label { font-weight: 500; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">💳 Make Payment</h2>
        
        <% 
            String installmentId = (String) request.getAttribute("installment_id");
            String error = (String) request.getAttribute("error");
            String success = (String) request.getAttribute("success");
            
            if (error != null) { 
        %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <% if (success != null) { %>
            <div class="alert alert-success">${success}</div>
        <% } %>
        
        <% if (installmentId != null) { %>
        
        <form action="${pageContext.request.contextPath}/BillingServlet" method="post">
            <input type="hidden" name="action" value="make_payment">
            <input type="hidden" name="installment_id" value="<%= installmentId %>">
            
            <div class="card mb-4">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0">Payment Details</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Installment ID</label>
                            <input type="text" class="form-control" value="<%= installmentId %>" readonly>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Payment Amount (RM) *</label>
                            <input type="number" class="form-control" name="payment_amount" 
                                   step="0.01" min="0.01" max="100000" required
                                   placeholder="Enter payment amount">
                            <small class="text-muted">Enter the amount you wish to pay for this installment</small>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Payment Method</label>
                            <select class="form-control" name="payment_method" required>
                                <option value="Cash">Cash</option>
                                <option value="Credit Card">Credit Card</option>
                                <option value="Debit Card">Debit Card</option>
                                <option value="Online Banking">Online Banking</option>
                                <option value="E-Wallet">E-Wallet</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Payment Date</label>
                            <input type="date" class="form-control" name="payment_date" 
                                   value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                   required>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Reference Number</label>
                            <input type="text" class="form-control" name="reference_no" 
                                   placeholder="Optional reference number">
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="alert alert-info">
                <i class="fas fa-info-circle"></i>
                <strong>Note:</strong> Partial payments are allowed. The remaining amount will be carried forward to the next payment.
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewBilling.jsp" class="btn btn-secondary">← Back to Billings</a>
                <div>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-check"></i> Process Payment
                    </button>
                    <a href="viewBilling.jsp" class="btn btn-outline-secondary ms-2">Cancel</a>
                </div>
            </div>
        </form>
        
        <% } else { %>
            <div class="alert alert-warning">
                No installment selected for payment.
            </div>
            <a href="viewBilling.jsp" class="btn btn-primary">Back to Billing List</a>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>