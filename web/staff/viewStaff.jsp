<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Staff" %>

<%
    if (session == null || session.getAttribute("staffId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Manage Staff</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        :root{
            --green-dark:#2f4a34;
            --green-deep:#264232;
            --gold-soft:#d7d1a6;
        }
        body{
            overflow:hidden;
            margin:0;
            min-height:100vh;
            background:url("<%=request.getContextPath()%>/images/Background.png") no-repeat center center fixed;
            background-size:cover;
            font-family:"Segoe UI",sans-serif;
        }
        .overlay{
            min-height:100vh;
            background:rgba(255,255,255,.38);
            backdrop-filter:blur(1.5px);
        }
        .top-nav{
            display:flex;
            align-items:center;
            justify-content:space-between;
            padding:22px 60px 8px;
        }
        .brand{
            display:flex;
            align-items:center;
            gap:12px;
        }
        .brand img{height:48px;}
        .clinic-title{
            font-size:26px;
            font-weight:700;
            color:var(--green-dark);
            font-family:"Times New Roman",serif;
        }
        .user-chip{
            display:inline-flex;
            align-items:center;
            gap:8px;
            background:#f3f3f3;
            padding:6px 12px;
            border-radius:18px;
            font-size:13px;
            color:#2f3a34;
        }

        .layout-wrap{
            width:100%;
            padding:30px 60px 40px;
            height:calc(100vh - 100px);
            overflow:hidden;
        }
        .layout{
            display:grid;
            grid-template-columns:280px 1fr;
            gap:24px;
            width:100%;
            max-width:1400px;
            height:100%;
            align-items:stretch;
        }
        .sidebar{
            background:var(--green-deep);
            color:#fff;
            border-radius:14px;
            padding:20px 16px;
            height:100%;
            overflow:auto;
        }
        .sidebar h6{
            font-size:20px;
            margin-bottom:12px;
            color:#fff;
            padding-bottom:10px;
            border-bottom:1px solid rgba(255,255,255,.25);
        }
        .side-link{
            display:block;
            color:#fff;
            padding:7px 10px;
            border-radius:8px;
            text-decoration:none;
            font-size:14px;
            margin-bottom:6px;
        }
        .side-link.active,.side-link:hover{
            background:rgba(255,255,255,.14);
            color:#ffe69b;
        }

        .card-panel{
            background:rgba(255,255,255,.92);
            border-radius:16px;
            padding:22px 24px 26px;
            box-shadow:0 14px 30px rgba(0,0,0,.1);
            height:100%;
            display:flex;
            flex-direction:column;
            overflow:hidden;
        }
        .panel-header{
            display:flex;
            justify-content:space-between;
            gap:14px;
            align-items:center;
            margin-bottom:12px;
        }
        .panel-header h4{
            margin:0;
            font-weight:800;
            color:#2f2f2f;
        }
        .search-wrap{
            display:flex;
            align-items:center;
            gap:10px;
        }
        .search-input{
            border:1px solid #d7ddd9;
            border-radius:18px;
            padding:7px 12px;
            font-size:13px;
            width:240px;
        }
        .btn-add{
            background:var(--gold-soft);
            color:#3a382f;
            border:none;
            border-radius:18px;
            padding:8px 14px;
            font-weight:800;
            font-size:13px;
            text-decoration:none;
            display:inline-flex;
            align-items:center;
            gap:8px;
            white-space:nowrap;
        }

        .table-wrap{
            border:1px solid #d9d9d9;
            border-radius:10px;
            background:#fff;
            flex:1;
            min-height:0;
            overflow:auto;
        }
        .table{margin:0;}
        .table thead{background:#dcdcdc;}
        .table thead th{
            font-size:12px;
            text-transform:uppercase;
            letter-spacing:.4px;
            color:#2b2b2b;
            position:sticky;
            top:0;
            background:#dcdcdc;
            z-index:5;
            padding:12px 14px;
        }
        .table tbody td{
            font-size:14px;
            vertical-align:middle;
            padding:12px 14px;
        }

        .role-pill{
            padding:5px 12px;
            border-radius:999px;
            font-size:12px;
            background:#e7f4ec;
            color:#2a6b48;
            display:inline-block;
            font-weight:700;
        }

        .actions{
            display:flex;
            gap:10px;
            justify-content:center;
        }
        .action-pill{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:7px 12px;
            border-radius:999px;
            border:1px solid #d9d9d9;
            background:#fff;
            color:#2f2f2f;
            text-decoration:none;
            font-size:13px;
            font-weight:700;
            white-space:nowrap;
            transition:transform .08s ease, box-shadow .12s ease, background .12s ease;
        }
        .action-pill i{font-size:14px;}
        .action-pill:hover{
            transform:translateY(-1px);
            box-shadow:0 10px 18px rgba(0,0,0,.08);
            background:#fafafa;
        }
        .action-view{border-color:#cfe0d5;color:#264232;}
        .action-edit{border-color:#e6dfb9;color:#5a4f1a;}
        .action-del{border-color:#f0c7c7;color:#9b2c2c;}

        .alert{border-radius:10px;margin:0 60px 12px;}

        @media(max-width:992px){
            .layout{grid-template-columns:1fr;}
            .layout-wrap{padding:20px;}
            .top-nav{padding:18px 24px 8px;flex-wrap:wrap;gap:10px;}
            .search-input{width:180px;}
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

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success">${message}</div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">${error}</div>
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
                    <h4>Manage Staff</h4>

                    <div class="search-wrap">
                        <input id="staffSearch" type="text" class="search-input" placeholder="Search by ID / Name / Role...">
                        <a href="<%=request.getContextPath()%>/StaffServlet?action=add" class="btn-add">
                            <i class="fa-solid fa-plus"></i> Add Staff
                        </a>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table table-hover mb-0">
                        <thead>
                        <tr>
                            <th style="width:220px;">Staff ID</th>
                            <th>Name</th>
                            <th style="width:220px;">Role</th>
                            <th style="width:260px; text-align:center;">Actions</th>
                        </tr>
                        </thead>
                        <tbody id="staffTableBody">
                        <%
                            List<Staff> staffList = (List<Staff>) request.getAttribute("staffList");
                            if (staffList != null && !staffList.isEmpty()) {
                                for (Staff s : staffList) {
                                    String id = s.getStaffId() != null ? s.getStaffId() : "";
                                    String name = s.getStaffName() != null ? s.getStaffName() : "";
                                    String role = s.getStaffRole() != null ? s.getStaffRole() : "";
                        %>
                        <tr data-search="<%= (id + " " + name + " " + role).toLowerCase() %>">
                            <td><strong><%= id %></strong></td>
                            <td><%= name %></td>
                            <td><span class="role-pill"><%= role %></span></td>
                            <td>
                                <div class="actions">
                                    <a href="<%=request.getContextPath()%>/StaffServlet?action=view&staff_id=<%= id %>"
                                        class="action-pill action-view">
                                        <i class="fa-solid fa-eye"></i> View
                                    </a>
                                    
                                    <a href="<%=request.getContextPath()%>/StaffServlet?action=edit&staff_id=<%= id %>"
                                       class="action-pill action-edit">
                                        <i class="fa-solid fa-pen"></i> Edit
                                    </a>

                                    <form action="<%=request.getContextPath()%>/StaffServlet" method="post" style="display:inline;"
                                          onsubmit="return confirmDelete()">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="staff_id" value="<%= id %>">
                                        <button type="submit" class="action-pill action-del">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4" class="text-center py-4">No staff found.</td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

            </div>

        </div>
    </div>
</div>

<script>
    const staffSearch = document.getElementById("staffSearch");
    const staffBody = document.getElementById("staffTableBody");

    if (staffSearch && staffBody) {
        staffSearch.addEventListener("input", function () {
            const keyword = this.value.trim().toLowerCase();
            const rows = staffBody.querySelectorAll("tr");

            rows.forEach(row => {
                const searchText = (row.getAttribute("data-search") || "").toLowerCase();
                row.style.display = (!keyword || searchText.includes(keyword)) ? "" : "none";
            });
        });
    }

    function confirmDelete() {
        return confirm("Are you sure you want to delete this staff?");
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
