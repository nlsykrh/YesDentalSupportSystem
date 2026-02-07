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
    <title>Installments - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .progress-container {
            background: #e9ecef;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .progress-bar {
            height: 20px;
            border-radius: 10px;
            background: linear-gradient(90deg, #20c997, #0d6efd);
            transition: width 0.5s ease;
        }
        .installment-card {
            border-left: 4px solid;
            transition: all 0.3s ease;
        }
        .installment-card.pending { border-left-color: #dc3545; }
        .installment-card.partial { border-left-color: #ffc107; }
        .installment-card.paid { border-left-color: #198754; }
        .installment-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">📊 Installment Details</h2>
        
        <% 
            Billing billing = (Billing) request.getAttribute("billing");
            List<Installment> installments = (List<Installment>) request.getAttribute("installments");
            DecimalFormat currencyFormat = new DecimalFormat("RM #,##0.00");
            
            // Calculate totals
            BigDecimal totalAmount = BigDecimal.ZERO;
            BigDecimal totalPaid = BigDecimal.ZERO;
            BigDecimal totalRemaining = BigDecimal.ZERO;
            int paidCount = 0;
            int totalCount = 0;
            
            if (installments != null && !installments.isEmpty()) {
                totalCount = installments.size();
                for (Installment inst : installments) {
                    totalAmount = totalAmount.add(inst.getPaymentAmount());
                    totalPaid = totalPaid.add(inst.getPaidAmount());
                    totalRemaining = totalRemaining.add(inst.getRemainingAmount());
                    if ("Paid".equals(inst.getPaymentStatus())) {
                        paidCount++;
                    }
                }
            }
            
            // Calculate percentages
            int paymentProgress = 0;
            if (totalCount > 0) {
                paymentProgress = (int) ((totalPaid.doubleValue() / totalAmount.doubleValue()) * 100);
            }
        %>
        
        <% if (billing == null) { %>
            <div class="alert alert-warning">
                Billing information not found.
            </div>
            <a href="viewBilling.jsp" class="btn btn-primary">Back to Billings</a>
        <% } else { %>
        
        <!-- Billing Summary Card -->
        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Billing Summary</h5>
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
                                <th>Total Amount:</th>
                                <td class="fw-bold text-primary fs-5"><%= currencyFormat.format(billing.getBillingAmount()) %></td>
                            </tr>
                            <tr>
                                <th>Installments:</th>
                                <td><%= totalCount %> installment(s)</td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <table class="table table-borderless">
                            <tr>
                                <th width="40%">Appointment ID:</th>
                                <td><%= billing.getAppointmentId() %></td>
                            </tr>
                            <tr>
                                <th>Status:</th>
                                <td>
                                    <span class="badge <%= "Paid".equals(billing.getBillingStatus()) ? "bg-success" : "bg-warning" %> fs-6">
                                        <%= billing.getBillingStatus() %>
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <th>Method:</th>
                                <td>
                                    <span class="badge bg-info">
                                        <%= billing.getBillingMethod() %>
                                    </span>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Payment Progress -->
        <div class="progress-container">
            <div class="d-flex justify-content-between mb-2">
                <div>
                    <h6 class="mb-0">Payment Progress</h6>
                    <small class="text-muted">
                        <%= paidCount %> of <%= totalCount %> installments paid
                    </small>
                </div>
                <div class="text-end">
                    <h6 class="mb-0"><%= currencyFormat.format(totalPaid) %> / <%= currencyFormat.format(totalAmount) %></h6>
                    <small class="text-muted"><%= paymentProgress %>% completed</small>
                </div>
            </div>
            <div class="progress" style="height: 10px;">
                <div class="progress-bar" role="progressbar" 
                     style="width: <%= paymentProgress %>%;" 
                     aria-valuenow="<%= paymentProgress %>" 
                     aria-valuemin="0" 
                     aria-valuemax="100">
                </div>
            </div>
            <div class="row mt-2 text-center">
                <div class="col-md-4">
                    <div class="text-success">
                        <i class="fas fa-check-circle fa-lg"></i>
                        <div class="fw-bold"><%= currencyFormat.format(totalPaid) %></div>
                        <small>Paid</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-warning">
                        <i class="fas fa-clock fa-lg"></i>
                        <div class="fw-bold"><%= currencyFormat.format(totalRemaining) %></div>
                        <small>Remaining</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-primary">
                        <i class="fas fa-money-bill-wave fa-lg"></i>
                        <div class="fw-bold"><%= currencyFormat.format(totalAmount) %></div>
                        <small>Total</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Installments List -->
        <div class="card">
            <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Installment Breakdown</h5>
                <span class="badge bg-light text-dark fs-6">
                    <%= totalCount %> Installments
                </span>
            </div>
            <div class="card-body">
                <% if (installments != null && !installments.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>#</th>
                                    <th>Installment ID</th>
                                    <th>Due Date</th>
                                    <th>Installment Amount</th>
                                    <th>Paid Amount</th>
                                    <th>Remaining</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    int installmentNumber = 1;
                                    for (Installment installment : installments) { 
                                        String statusClass = installment.getPaymentStatus().toLowerCase();
                                %>
                                <tr class="installment-card <%= statusClass %>">
                                    <td class="fw-bold"><%= installmentNumber++ %></td>
                                    <td>
                                        <span class="badge bg-dark"><%= installment.getInstallmentId() %></span>
                                    </td>
                                    <td>
                                        <i class="fas fa-calendar-alt me-2"></i>
                                        <%= installment.getPaymentDate() %>
                                    </td>
                                    <td class="fw-bold"><%= currencyFormat.format(installment.getPaymentAmount()) %></td>
                                    <td>
                                        <span class="<%= installment.getPaidAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-success fw-bold" : "" %>">
                                            <%= currencyFormat.format(installment.getPaidAmount()) %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="<%= installment.getRemainingAmount().compareTo(BigDecimal.ZERO) > 0 ? "text-danger fw-bold" : "text-success fw-bold" %>">
                                            <%= currencyFormat.format(installment.getRemainingAmount()) %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge <%= 
                                            "Paid".equals(installment.getPaymentStatus()) ? "bg-success" : 
                                            "Partial".equals(installment.getPaymentStatus()) ? "bg-warning" : "bg-danger" 
                                        %>">
                                            <i class="fas fa-<%= 
                                                "Paid".equals(installment.getPaymentStatus()) ? "check" : 
                                                "Partial".equals(installment.getPaymentStatus()) ? "clock" : "exclamation" 
                                            %> me-1"></i>
                                            <%= installment.getPaymentStatus() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (!"Paid".equals(installment.getPaymentStatus())) { %>
                                        <a href="BillingServlet?action=make_payment_form&installment_id=<%= installment.getInstallmentId() %>"
                                           class="btn btn-success btn-sm">
                                            <i class="fas fa-money-bill-wave"></i> Make Payment
                                        </a>
                                        <% } else { %>
                                        <span class="badge bg-success">
                                            <i class="fas fa-check"></i> Fully Paid
                                        </span>
                                        <% } %>
                                        
                                        <!-- View Payment History Button (if you implement payment history) -->
                                        <!--
                                        <a href="PaymentHistoryServlet?action=view&installment_id=<%= installment.getInstallmentId() %>"
                                           class="btn btn-info btn-sm ms-1">
                                            <i class="fas fa-history"></i> History
                                        </a>
                                        -->
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                            <tfoot class="table-secondary fw-bold">
                                <tr>
                                    <td colspan="3" class="text-end">Totals:</td>
                                    <td><%= currencyFormat.format(totalAmount) %></td>
                                    <td><%= currencyFormat.format(totalPaid) %></td>
                                    <td><%= currencyFormat.format(totalRemaining) %></td>
                                    <td colspan="2">
                                        <%= paidCount %> paid / <%= totalCount %> total
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    
                    <!-- Payment Statistics -->
                    <div class="row mt-4">
                        <div class="col-md-4">
                            <div class="card text-center border-success">
                                <div class="card-body">
                                    <h1 class="text-success"><i class="fas fa-check-circle"></i></h1>
                                    <h5 class="card-title"><%= paidCount %></h5>
                                    <p class="card-text">Installments Paid</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card text-center border-warning">
                                <div class="card-body">
                                    <h1 class="text-warning"><i class="fas fa-clock"></i></h1>
                                    <h5 class="card-title"><%= totalCount - paidCount %></h5>
                                    <p class="card-text">Pending/Partial</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card text-center border-primary">
                                <div class="card-body">
                                    <h1 class="text-primary"><i class="fas fa-percentage"></i></h1>
                                    <h5 class="card-title"><%= paymentProgress %>%</h5>
                                    <p class="card-text">Payment Completed</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                <% } else { %>
                    <div class="text-center py-5">
                        <i class="fas fa-file-invoice-dollar fa-4x text-muted mb-3"></i>
                        <h5>No Installments Found</h5>
                        <p class="text-muted">This billing does not have any installment records.</p>
                        <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>" 
                           class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add Installments
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="d-flex justify-content-between mt-4">
            <a href="viewBilling.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to Billings
            </a>
            
            <div>
                <a href="BillingServlet?action=view&billing_id=<%= billing.getBillingId() %>"
                   class="btn btn-info">
                    <i class="fas fa-eye"></i> View Billing Details
                </a>
                
                <% if ("Pending".equals(billing.getBillingStatus())) { %>
                <a href="BillingServlet?action=edit&billing_id=<%= billing.getBillingId() %>"
                   class="btn btn-warning ms-2">
                    <i class="fas fa-edit"></i> Edit Billing
                </a>
                <% } %>
                
                <!-- Quick Actions -->
                <div class="btn-group ms-2" role="group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-bs-toggle="dropdown">
                        <i class="fas fa-bolt"></i> Quick Actions
                    </button>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="dropdown-item" href="javascript:void(0)" 
                               onclick="markAllAsPaid('<%= billing.getBillingId() %>')">
                                <i class="fas fa-check-double text-success"></i> Mark All as Paid
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item" href="#" 
                               onclick="printInstallmentSchedule('<%= billing.getBillingId() %>')">
                                <i class="fas fa-print text-info"></i> Print Schedule
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a class="dropdown-item text-danger" 
                               href="BillingServlet?action=delete&billing_id=<%= billing.getBillingId() %>"
                               onclick="return confirm('Delete this billing and all installments?')">
                                <i class="fas fa-trash"></i> Delete Billing
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        
        <% } %>
    </div>
    
    <!-- JavaScript for Interactive Features -->
    <script>
        function markAllAsPaid(billingId) {
            if (confirm('Mark all installments as fully paid? This will update the billing status to Paid.')) {
                // You would implement this functionality
                // For now, redirect to an action that handles this
                window.location.href = 'BillingServlet?action=pay_all&billing_id=' + billingId;
            }
        }
        
        function printInstallmentSchedule(billingId) {
            // Open print-friendly version in new window
            window.open('PrintInstallmentServlet?billing_id=' + billingId, '_blank');
        }
        
        // Tooltip initialization
        document.addEventListener('DOMContentLoaded', function() {
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        });
        
        // Filter installments by status
        function filterInstallments(status) {
            const rows = document.querySelectorAll('.installment-card');
            rows.forEach(row => {
                if (status === 'all' || row.classList.contains(status)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>