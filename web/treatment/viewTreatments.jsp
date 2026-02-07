<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Treatment" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Treatments - YesDental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .price-cell { font-weight: 600; color: #198754; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">🦷 Treatment Management</h2>
        
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success">${message}</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">${error}</div>
        <% } %>
        
        <div class="d-flex justify-content-between mb-3">
            <a href="staff/index.jsp" class="btn btn-outline-secondary">
                <i class="fas fa-home"></i> Home
            </a>
            <a href="treatment/addTreatment.jsp" class="btn btn-success">
                <i class="fas fa-plus"></i> Add New Treatment
            </a>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">Treatment List</h5>
            </div>
            <div class="card-body">
                <% 
                    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
                    
                    if (treatments != null && !treatments.isEmpty()) { 
                %>
                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Treatment ID</th>
                                <th>Treatment Name</th>
                                <th>Description</th>
                                <th>Price (RM)</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Treatment treatment : treatments) { %>
                            <tr>
                                <td><strong><%= treatment.getTreatmentId() %></strong></td>
                                <td><%= treatment.getTreatmentName() %></td>
                                <td>
                                    <% 
                                        String desc = treatment.getTreatmentDesc();
                                        if (desc != null && desc.length() > 100) {
                                            desc = desc.substring(0, 100) + "...";
                                        }
                                    %>
                                    <%= desc != null ? desc : "No description" %>
                                </td>
                                <td class="price-cell">RM <%= String.format("%.2f", treatment.getTreatmentPrice()) %></td>
                                <td>
                                    <a href="TreatmentServlet?action=edit&treatment_id=<%= treatment.getTreatmentId() %>"
                                       class="btn btn-warning btn-sm">
                                       <i class="fas fa-edit"></i> Edit
                                    </a>
                                    
                                    <form action="TreatmentServlet" method="post" style="display:inline;" 
                                          onsubmit="return confirmDelete()">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="treatment_id" value="<%= treatment.getTreatmentId() %>">
                                        <button type="submit" class="btn btn-sm btn-danger">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4">
                    <i class="fas fa-tooth fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">No treatments found</h5>
                    <p class="text-muted">Add your first treatment to get started.</p>
                    <a href="treatment/addTreatment.jsp" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add Treatment
                    </a>
                </div>
                <% } %>
            </div>
            <% if (treatments != null && !treatments.isEmpty()) { %>
            <div class="card-footer text-muted">
                Total Treatments: <%= treatments.size() %>
            </div>
            <% } %>
        </div>
    </div>
    
    <script>
        function confirmDelete() {
            return confirm('Are you sure you want to delete this treatment? This action cannot be undone.');
        }
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>