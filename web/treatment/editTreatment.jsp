<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Treatment" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Treatment - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 800px; }
        .form-label { font-weight: 500; }
        .required:after { content:" *"; color:red; }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h2 class="mb-4">✏️ Edit Treatment</h2>
        
        <% 
            Treatment treatment = (Treatment) request.getAttribute("treatment");
            String error = (String) request.getAttribute("error");
            
            if (error != null) { 
        %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <% if (treatment != null) { %>
        
        <form action="${pageContext.request.contextPath}/TreatmentServlet" method="post">
            <input type="hidden" name="action" value="update">
            
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Treatment Information</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label required">Treatment ID</label>
                            <input type="text" class="form-control" name="treatment_id" 
                                   value="<%= treatment.getTreatmentId() %>" readonly>
                            <small class="text-muted">Treatment ID cannot be changed</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label required">Treatment Name</label>
                            <input type="text" class="form-control" name="treatment_name" 
                                   value="<%= treatment.getTreatmentName() %>" required>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label required">Treatment Price (RM)</label>
                        <div class="input-group">
                            <span class="input-group-text">RM</span>
                            <input type="number" class="form-control" name="treatment_price" 
                                   step="0.01" min="0" required 
                                   value="<%= String.format("%.2f", treatment.getTreatmentPrice()) %>">
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label required">Description</label>
                        <textarea class="form-control" name="treatment_desc" rows="4" required><%= treatment.getTreatmentDesc() != null ? treatment.getTreatmentDesc() : "" %></textarea>
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewTreatments.jsp" class="btn btn-outline-secondary">
                    ← Back to Treatments
                </a>
                <div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Update Treatment
                    </button>
                    <a href="viewTreatments.jsp" class="btn btn-secondary ms-2">Cancel</a>
                </div>
            </div>
        </form>
        
        <% } else { %>
        <div class="alert alert-warning">
            <i class="fas fa-exclamation-triangle"></i> No treatment data found. Please select a treatment to edit.
        </div>
        <a href="viewTreatments.jsp" class="btn btn-primary">
            <i class="fas fa-arrow-left"></i> Back to Treatment List
        </a>
        <% } %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
</body>
</html>