<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="beans.Patient" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Yes Dental Clinic - Manage Patient</title>

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

        .top-right {
            display: flex;
            align-items: center;
            gap: 12px;
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

        /* soft logout pill (optional) */
        .logout-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 16px;
            border-radius: 999px;
            background: #c96a6a;
            color: white;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            box-shadow: 0 6px 14px rgba(0,0,0,0.18);
            transition: all 0.2s ease;
        }

        .logout-btn:hover {
            background: #b95a5a;
            transform: translateY(-1px);
        }

        .layout-wrap {
            width: 100%;
            padding: 30px 60px 40px;
            height: calc(100vh - 100px);
            overflow: hidden;
        }

        .layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 24px;
            width: 100%;
            max-width: 1400px;
            height: 100%;
            align-items: stretch;
        }

        .sidebar {
            background: var(--green-deep);
            color: #fff;
            border-radius: 14px;
            padding: 20px 16px;
            height: 100%;
            overflow: auto;
        }

        .sidebar h6 {
            font-size: 20px;
            margin-bottom: 12px;
            color: white;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255,255,255,0.25);
        }

        .side-link {
            display: flex;
            align-items: center;
            gap: 10px;

            color: white;
            padding: 9px 10px;
            border-radius: 10px;
            text-decoration: none;
            font-size: 14px;
            margin-bottom: 6px;
        }

        .side-link i {
            width: 18px;
            text-align: center;
            opacity: 0.95;
        }

        .side-link.active,
        .side-link:hover {
            background: rgba(255, 255, 255, 0.14);
            color: #ffe69b;
        }

        .card-panel {
            background: rgba(255, 255, 255, 0.92);
            border-radius: 16px;
            padding: 22px 24px 26px;
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.1);
            height: 100%;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 12px;
            align-items: center;
        }

        .panel-header h4 {
            margin: 0;
            font-weight: 700;
            color: #2f2f2f;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .search-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .search-input {
            border: 1px solid #d7ddd9;
            border-radius: 18px;
            padding: 6px 12px;
            font-size: 13px;
            width: 220px;
        }

        .btn-add {
            background: var(--gold-soft);
            color: #3a382f;
            border: none;
            border-radius: 18px;
            padding: 6px 14px;
            font-weight: 700;
            font-size: 13px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .table-wrap {
            border: 1px solid #d9d9d9;
            border-radius: 10px;
            background: #fff;
            flex: 1;
            min-height: 0;
            overflow: auto;
        }

        .table thead { background: #dcdcdc; }

        .table thead th {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .4px;
            color: #2b2b2b;
            position: sticky;
            top: 0;
            background: #dcdcdc;
            z-index: 5;
        }

        .table tbody td {
            font-size: 14px;
            vertical-align: middle;
        }

        .status-pill {
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            background: #e7f4ec;
            color: #2a6b48;
            display: inline-block;
            font-weight: 700;
        }

        .status-pill.inactive {
            background: #f6e6e6;
            color: #9b2c2c;
        }

        .actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        .action-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 12px;
            border-radius: 999px;
            border: 1px solid #d9d9d9;
            background: #fff;
            color: #2f2f2f;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
            white-space: nowrap;
        }

        .action-pill i { font-size: 14px; }

        .action-pill:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(0,0,0,0.08);
            background: #fafafa;
        }

        .action-view { border-color: #cfe0d5; color: #264232; }
        .action-edit { border-color: #e6dfb9; color: #5a4f1a; }

        .alert { border-radius: 10px; margin: 0 6% 12px; }

        @media (max-width: 992px) {
            .layout { grid-template-columns: 1fr; }
            .layout-wrap { padding: 20px; }
            .top-nav {
                padding: 18px 24px 8px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .actions { justify-content: flex-start; }
            .search-input { width: 180px; }
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

        <div class="top-right">
            <div class="user-chip">
                <i class="fa-solid fa-user"></i>
                <span><%= session.getAttribute("staffName") != null ? session.getAttribute("staffName") : "Staff" %></span>
            </div>

            <!-- OPTIONAL: remove if you don't want logout here -->
            <a href="<%=request.getContextPath()%>/LogoutServlet" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </a>
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
                
                <a class="side-link"href="/YesDentalSupportSystem/staff/staffDashboard.jsp">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/StaffServlet?action=list">
                    <i class="fa-solid fa-user-doctor"></i> Staff
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/AppointmentServlet?action=list">
                    <i class="fa-solid fa-calendar-check"></i> Appointments
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/BillingServlet?action=list">
                    <i class="fa-solid fa-file-invoice-dollar"></i> Billing
                </a>

                <a class="side-link active" href="/YesDentalSupportSystem/PatientServlet?action=list">
                    <i class="fa-solid fa-hospital-user"></i> Patients
                </a>

                <a class="side-link" href="/YesDentalSupportSystem/TreatmentServlet?action=list">
                    <i class="fa-solid fa-tooth"></i> Treatments
                </a>
            </div>

            <div class="card-panel">
                <div class="panel-header">
                    <h4>
                        <i class="fa-solid fa-hospital-user"></i>
                        Manage Patient
                    </h4>

                    <div class="search-wrap">
                        <input id="patientSearch" type="text" class="search-input" placeholder="Search by IC / Name / Status...">
                        <a href="/YesDentalSupportSystem/patient/addPatient.jsp" class="btn-add">
                            <i class="fa-solid fa-user-plus"></i>
                            Add Patient
                        </a>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th style="width: 220px;">IC Number</th>
                                <th>Name</th>
                                <th style="width: 140px;">Status</th>
                                <th style="width: 220px; text-align:center;">Actions</th>
                            </tr>
                        </thead>

                        <tbody id="patientTableBody">
                        <%
                            List<Patient> patients = (List<Patient>) request.getAttribute("patients");

                            if (patients != null && !patients.isEmpty()) {
                                for (Patient patient : patients) {
                                    String ic = patient.getPatientIc() != null ? patient.getPatientIc() : "";
                                    String name = patient.getPatientName() != null ? patient.getPatientName() : "";
                                    String status = patient.getPatientStatus() != null ? patient.getPatientStatus() : "";
                                    String statusText = "A".equalsIgnoreCase(status) ? "active" : "inactive";
                        %>
                            <tr data-search="<%= (ic + " " + name + " " + statusText).toLowerCase() %>">
                                <td><%= ic %></td>
                                <td><%= name %></td>
                                <td>
                                    <% if ("A".equalsIgnoreCase(status)) { %>
                                        <span class="status-pill">Active</span>
                                    <% } else { %>
                                        <span class="status-pill inactive">Inactive</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="actions">
                                        <a href="PatientServlet?action=view&patient_ic=<%= ic %>" class="action-pill action-view" title="View patient">
                                            <i class="fa-solid fa-eye"></i> View
                                        </a>

                                        <a href="PatientServlet?action=edit&patient_ic=<%= ic %>" class="action-pill action-edit" title="Edit patient">
                                            <i class="fa-solid fa-pen"></i> Edit
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="4" class="text-center">No patients found.</td>
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
    const searchInput = document.getElementById("patientSearch");
    const tableBody = document.getElementById("patientTableBody");

    if (searchInput && tableBody) {
        searchInput.addEventListener("input", function () {
            const keyword = this.value.trim().toLowerCase();
            const rows = tableBody.querySelectorAll("tr");

            rows.forEach(row => {
                const searchText = (row.getAttribute("data-search") || "").toLowerCase();
                row.style.display = (!keyword || searchText.includes(keyword)) ? "" : "none";
            });
        });
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
