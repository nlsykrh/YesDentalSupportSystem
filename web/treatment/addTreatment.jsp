<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Treatment - YesDental</title>
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
        <h2 class="mb-4">➕ Add New Treatment</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <form action="${pageContext.request.contextPath}/TreatmentServlet" method="post">
            <input type="hidden" name="action" value="add">
            
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">Treatment Information</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label required">Treatment ID</label>
                            <input type="text" class="form-control" name="treatment_id" required
                                   placeholder="e.g., TX001">
                            <small class="text-muted">Unique identifier for the treatment</small>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label required">Treatment Name</label>
                            <input type="text" class="form-control" name="treatment_name" required
                                   placeholder="e.g., Dental Cleaning">
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label required">Treatment Price (RM)</label>
                        <div class="input-group">
                            <span class="input-group-text">RM</span>
                            <input type="number" class="form-control" name="treatment_price" 
                                   step="0.01" min="0" required placeholder="0.00">
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label required">Description</label>
                        <textarea class="form-control" name="treatment_desc" rows="4" required
                                  placeholder="Describe the treatment procedure, duration, and benefits..."></textarea>
                    </div>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="viewTreatments.jsp" class="btn btn-outline-secondary">
                    ← Back to Treatments
                </a>
                <div>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-save"></i> Add Treatment
                    </button>
                    <button type="reset" class="btn btn-secondary ms-2">Reset</button>
                </div>
            </div>
        </form>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
</body>
</html>