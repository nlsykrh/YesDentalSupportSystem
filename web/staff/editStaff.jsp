<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Staff staff = (Staff) request.getAttribute("staff");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Edit Staff</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root {
            --green-dark: #2f4a34;
            --green-deep: #264232;
            --gold-soft: #d7d1a6;
        }
        body {
            overflow: hidden;
            margin: 0;
            min-height: 100vh;
            background: url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size: cover;
            font-family: "Segoe UI", sans-serif;
        }
        .overlay {
            min-height: 100vh;
            background: rgba(255, 255, 255, 0.38);
            backdrop-filter: blur(1.5px);
        }
        .top-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 22px 60px 8px;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .brand img { height: 48px; }
        .clinic-title {
            font-size: 26px;
            font-weight: 700;
            color: var(--green-dark);
            font-family: "Times New Roman", serif;
        }
        .user-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f3f3f3;
            padding: 6px 12px;
            border-radius: 18px;
            font-size: 13px;
            color: #2f3a34;
        }

        .layout-wrap {
            width: 100%;
            padding: 30px 60px 40px;
            height: calc(100vh - 100px);
            overflow: hidden;
        }
        .layout{
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            height: 100%;
            align-items: stretch;
        }
        .sidebar{
            background: var(--green-deep);
            color: #fff;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }
        .sidebar h6{
            font-size: 20px;
            margin-bottom: 12px;
            color: white;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.25);
        }
        .side-link {
            display: block;
            color: white;
            padding: 7px 10px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }
        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, 0.14);
            color: #ffe69b;
        }

        .card-panel{
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .panel-header h4 {
            margin: 0 0 12px;
            font-weight: 700;
            color: #2f2f2f;
        }

        .form-wrap{
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
            overflow: auto;
            padding: 18px;
        }

        .btn-save{
            background: var(--gold-soft);
            color: #3a382f;
            border: none;
            border-radius: 18px;
            padding: 10px 14px;
            font-weight: 800;
            font-size: 13px;
        }
        .btn-back{
            border-radius: 18px;
            padding: 10px 14px;
            font-weight: 700;
            font-size: 13px;
        }

        .alert { border-radius: 10px; }
        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav { padding: 18px 24px 8px; flex-wrap: wrap; gap: 10px; }
        }
    </style>
</head>

<body>
<div class="overlay">
    <div class="top-nav">
        <div class="brand">
            <img src="<%=request.getContextPath()%>/images/Logo.png" alt="Logo">
            <div class="clinic-title">Yes Dental Clinic</div>
        </div>

        <div class="user-chip">
            <i class="fa-solid fa-user"></i>
            <span><%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Staff" %></span>
        </div>
    </div>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger mx-5">${error}</div>
    <% } %>

    <div class="layout-wrap">
        <div class="layout">

            <div class="sidebar">
                <h6>Staff Dashboard</h6>
                <a class="side-link active" href="<%=request.getContextPath()%>/StaffServlet?action=list">Staff</a>
                <a class="side-link" href="<%=request.getContextPath()%>/AppointmentServlet?action=list">Appointments</a>
                <a class="side-link" href="<%=request.getContextPath()%>/BillingServlet?action=list">Billing</a>
                <a class="side-link" href="<%=request.getContextPath()%>/PatientServlet?action=list">Patients</a>
                <a class="side-link" href="<%=request.getContextPath()%>/TreatmentServlet?action=list">Treatments</a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>Edit Staff</h4>
                </div>

                <div class="form-wrap">
                    <% if (staff != null) { %>
                    <form action="<%=request.getContextPath()%>/StaffServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="staff_id" value="<%= staff.getStaffId() %>">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Staff ID</label>
                                <input type="text" class="form-control" value="<%= staff.getStaffId() %>" readonly>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Full Name *</label>
                                <input type="text" class="form-control" name="staff_name"
                                       value="<%= staff.getStaffName() != null ? staff.getStaffName() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Phone Number *</label>
                                <input type="text" class="form-control" name="staff_phonenum"
                                       value="<%= staff.getStaffPhonenum() != null ? staff.getStaffPhonenum() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Email *</label>
                                <input type="email" class="form-control" name="staff_email"
                                       value="<%= staff.getStaffEmail() != null ? staff.getStaffEmail() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Role *</label>
                                <select class="form-select" name="staff_role" required>
                                    <option value="">Select Role</option>
                                    <option value="Dentist" <%= "Dentist".equals(staff.getStaffRole()) ? "selected" : "" %>>Dentist</option>
                                    <option value="Assistant" <%= "Assistant".equals(staff.getStaffRole()) ? "selected" : "" %>>Assistant</option>
                                    <option value="Receptionist" <%= "Receptionist".equals(staff.getStaffRole()) ? "selected" : "" %>>Receptionist</option>
                                    <option value="Other" <%= "Other".equals(staff.getStaffRole()) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">New Password (Optional)</label>
                                <input type="password" class="form-control" name="staff_password" placeholder="Leave empty to keep current password">
                            </div>
                        </div>

                        <div class="d-flex justify-content-between mt-4">
                            <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">Back</a>
                            <button type="submit" class="btn-save">Update Staff</button>
                        </div>
                    </form>
                    <% } else { %>
                        <div class="alert alert-warning">No staff found.</div>
                        <a class="btn btn-secondary btn-back" href="<%=request.getContextPath()%>/StaffServlet?action=list">Back</a>
                    <% } %>
                </div>

            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
