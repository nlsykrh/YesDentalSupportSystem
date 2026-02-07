<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Yes Dental Support System</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="row">
            <div class="col-md-12 text-center">
                <h1 class="mb-4">🏥 YesDental Support System</h1>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Main Menu</h5>
                        <div class="list-group">
                            <a href="/YesDentalSupportSystem/PatientServlet?action=list" class="list-group-item list-group-item-action">
                                👨‍⚕️ Manage Patient
                            </a>
                            <a href="/YesDentalSupportSystem/StaffServlet?action=list" class="list-group-item list-group-item-action">
                                👥 Manage Staff
                            </a>
                            <a href="/YesDentalSupportSystem/AppointmentServlet?action=list" class="list-group-item list-group-item-action">
                                📅 Manage Appointment
                            </a>
                            <a href="/YesDentalSupportSystem/TreatmentServlet?action=list" class="list-group-item list-group-item-action">
                                🦷 Manage Treatment
                            </a>
                            <a href="/YesDentalSupportSystem/BillingServlet?action=list" class="list-group-item list-group-item-action">
                                💰 Manage Billing
                            </a>
<!--                            <a href="/YesDentalSupportSystem/ProfileServlet" class="btn btn-outline-primary">
                            <i class="fas fa-user"></i> My Profile-->
                            <a href="/YesDentalSupportSystem/ProfileServlet" class="list-group-item list-group-item-action">
                                My Profile
                            </a>
<!--                            <a href="patient/addPatient.jsp" class="list-group-item list-group-item-action">
                                ➕ Add New Patient
                            </a>
                            <a href="staff/addStaff.jsp" class="list-group-item list-group-item-action">
                                ➕ Add New Staff
                            </a>
                            <a href="appointment/scheduleAppointment.jsp" class="list-group-item list-group-item-action">
                                ➕ Schedule Appointment
                            </a>-->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>