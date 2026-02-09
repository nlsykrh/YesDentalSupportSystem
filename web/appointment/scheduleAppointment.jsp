<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.TreatmentDAO" %>
<%@ page import="beans.Treatment" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Schedule Appointment - YesDental</title>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

    <!-- Flatpickr (inline calendar) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    <style>
        body { background-color: #f8f9fa; }
        .container { max-width: 900px; }
        .form-label { font-weight: 500; }

        /* Calendar look */
        .calendar-card { border-radius: 12px; overflow: hidden; }
        .flatpickr-calendar.inline {
            width: 100%;
            box-shadow: none;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
        }
        .flatpickr-months { background: #556b2f; border-radius: 12px 12px 0 0; }
        .flatpickr-current-month,
        .flatpickr-prev-month,
        .flatpickr-next-month {
            color: #fff !important;
            fill: #fff !important;
        }

        /* grey disabled dates */
        .flatpickr-day.flatpickr-disabled {
            color: #cbd5e1 !important;
            background: #f1f5f9 !important;
            cursor: not-allowed !important;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">📅 Schedule New Appointment</h2>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
    <% } %>

    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("message") %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/AppointmentServlet" method="post">
        <input type="hidden" name="action" value="add">

        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Patient Information</h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-12">
                        <label class="form-label">Patient IC Number *</label>
                        <input type="text" class="form-control" name="patient_ic"
                               pattern="\d{12}" title="12 digit IC number"
                               value="<%= request.getParameter("patient_ic") != null ? request.getParameter("patient_ic") : "" %>"
                               required>
                        <small class="text-muted">12 digits only</small>
                    </div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">Appointment Details</h5>
            </div>

            <div class="card-body">
                <div class="row g-4">
                    <!-- LEFT: inline calendar -->
                    <div class="col-md-7">
                        <label class="form-label">Appointment Date *</label>

                        <!-- This is the real input that will be submitted -->
                        <input type="text" class="form-control mb-3" name="appointment_date" id="appointmentDate"
                               placeholder="Select date"
                               value="<%= request.getParameter("appointment_date") != null ? request.getParameter("appointment_date") : "" %>"
                               required>

                        <div class="calendar-card p-2 bg-white" id="calendarWrap"></div>

                        <small class="text-muted d-block mt-2">
                            Grey dates = fully booked (all slots confirmed).
                        </small>
                    </div>

                    <!-- RIGHT: time dropdown -->
                    <div class="col-md-5">
                        <label class="form-label">Appointment Time *</label>
                        <select class="form-control" name="appointment_time" id="appointmentTime" required>
                            <option value="">Select Time</option>
                            <option value="09:00">09:00 AM</option>
                            <option value="10:00">10:00 AM</option>
                            <option value="11:00">11:00 AM</option>
                            <option value="14:00">02:00 PM</option>
                            <option value="15:00">03:00 PM</option>
                            <option value="16:00">04:00 PM</option>
                        </select>

                        <small class="text-muted">
                            Confirmed times will be removed after you choose a date.
                        </small>
                    </div>
                </div>

                <div class="row mb-3 mt-4">
                    <div class="col-md-12">
                        <label class="form-label">Treatment Required *</label>
                        <select class="form-control" name="treatment_id" required>
                            <option value="">Select Treatment</option>
                            <%
                                TreatmentDAO treatmentDAO = new TreatmentDAO();
                                List<Treatment> treatments = treatmentDAO.getAllTreatments();
                                if (treatments != null && !treatments.isEmpty()) {
                                    for (Treatment t : treatments) {
                            %>
                            <option value="<%= t.getTreatmentId() %>">
                                <%= t.getTreatmentId() %> - <%= t.getTreatmentName() %>
                            </option>
                            <%
                                    }
                                } else {
                            %>
                            <option value="none">No treatment added</option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Remarks</label>
                    <textarea class="form-control" name="remarks" rows="2"
                              placeholder="Any special notes or requirements"><%= request.getParameter("remarks") != null ? request.getParameter("remarks") : "" %></textarea>
                </div>
            </div>
        </div>

        <div class="alert alert-info">
            <strong>Note:</strong> Fully booked dates are disabled. Confirmed slots cannot be booked again.
        </div>

        <div class="d-flex justify-content-between">
            <a href="viewAppointment.jsp" class="btn btn-secondary">← Back to Appointments</a>
            <div>
                <button type="submit" class="btn btn-success">Schedule Appointment</button>
                <a href="viewAppointment.jsp" class="btn btn-outline-secondary ms-2">Cancel</a>
            </div>
        </div>
    </form>
</div>

<script>
    const ALL_SLOTS = [
        { value: "09:00", label: "09:00 AM" },
        { value: "10:00", label: "10:00 AM" },
        { value: "11:00", label: "11:00 AM" },
        { value: "14:00", label: "02:00 PM" },
        { value: "15:00", label: "03:00 PM" },
        { value: "16:00", label: "04:00 PM" }
    ];

    function rebuildTimeDropdown(bookedSet) {
        const select = document.getElementById("appointmentTime");
        select.innerHTML = '<option value="">Select Time</option>';

        let count = 0;
        for (const s of ALL_SLOTS) {
            if (!bookedSet.has(s.value)) {
                const opt = document.createElement("option");
                opt.value = s.value;
                opt.textContent = s.label;
                select.appendChild(opt);
                count++;
            }
        }

        if (count === 0) {
            const opt = document.createElement("option");
            opt.value = "";
            opt.disabled = true;
            opt.textContent = "No available time";
            select.appendChild(opt);
        }
    }

    async function fetchFullyBooked(monthStr) {
        const url = "<%= request.getContextPath() %>/AvailabilityServlet?action=fullyBooked&month=" + encodeURIComponent(monthStr);
        const res = await fetch(url);
        const arr = await res.json(); // ["YYYY-MM-DD",...]
        return new Set(arr);
    }

    async function fetchBookedTimes(dateYmd) {
        const url = "<%= request.getContextPath() %>/AvailabilityServlet?date=" + encodeURIComponent(dateYmd);
        const res = await fetch(url);
        const booked = await res.json(); // ["14:00", ...]
        return new Set(booked);
    }

    (async function init(){
        let disabledDates = new Set();

        const now = new Date();
        const curMonth = now.getFullYear() + "-" + String(now.getMonth() + 1).padStart(2,"0");
        disabledDates = await fetchFullyBooked(curMonth);

        flatpickr("#appointmentDate", {
            dateFormat: "Y-m-d",
            minDate: "today",
            inline: true,
            appendTo: document.getElementById("calendarWrap"),

            disable: [
                function(date) {
                    const ymd = date.toISOString().slice(0,10);
                    return disabledDates.has(ymd);
                }
            ],

            onMonthChange: async function(selectedDates, dateStr, instance) {
                const y = instance.currentYear;
                const m = String(instance.currentMonth + 1).padStart(2,"0");
                disabledDates = await fetchFullyBooked(`${y}-${m}`);
                instance.redraw();
            },

            onChange: async function(selectedDates, dateStr, instance) {
                if (!dateStr) return;
                const bookedSet = await fetchBookedTimes(dateStr);
                rebuildTimeDropdown(bookedSet);
            }
        });
    })();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
 
