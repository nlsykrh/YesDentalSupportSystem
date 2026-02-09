package controllers;

import beans.*;
import dao.AppointmentDAO;
import dao.BillingDAO;
import dao.DigitalConsentDAO;
import dao.PatientDAO;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.net.URLEncoder;

@WebServlet("/AppointmentServlet")
public class AppointmentServlet extends HttpServlet {

    private AppointmentDAO appointmentDAO;
    private BillingDAO billingDAO;
    private DigitalConsentDAO consentDAO;
    private PatientDAO patientDAO;
    private SimpleDateFormat dateFormat;

    @Override
    public void init() {
        appointmentDAO = new AppointmentDAO();
        billingDAO = new BillingDAO();
        consentDAO = new DigitalConsentDAO();
        patientDAO = new PatientDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }

    private boolean isPatient(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("patientId") != null;
    }

    private boolean isStaff(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("staffId") != null;
    }

    private String getSessionPatientIc(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session == null) ? null : (String) session.getAttribute("patientId");
    }

    private String getSessionStaffId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session == null) ? null : (String) session.getAttribute("staffId");
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        return isPatient(request) || isStaff(request);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=true");
            return;
        }

        String action = request.getParameter("action");

        if (action == null || "list".equalsIgnoreCase(action) || "list_patient".equalsIgnoreCase(action)) {
            listAppointments(request, response);
            return;
        }

        switch (action) {
            case "edit":
                editAppointment(request, response);
                break;

            case "view":
                viewAppointment(request, response);
                break;

            case "add":
                request.getRequestDispatcher("/appointment/scheduleAppointment.jsp").forward(request, response);
                break;

            case "consent":
                showDigitalConsent(request, response);
                break;

            default:
                listAppointments(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=true");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            request.setAttribute("error", "No action specified");
            listAppointments(request, response);
            return;
        }

        switch (action) {
            case "add":
                addAppointment(request, response);
                break;

            case "update":
                updateAppointment(request, response);
                break;

            case "delete":
                deleteAppointment(request, response);
                break;

            case "confirm":
                confirmAppointment(request, response);
                break;

            case "cancel":
                cancelAppointment(request, response);
                break;

            case "sign_consent":
                processDigitalConsent(request, response);
                break;

            case "decline_consent":
                declineDigitalConsent(request, response);
                break;

            default:
                request.setAttribute("error", "Invalid action: " + action);
                listAppointments(request, response);
        }
    }

    private void listAppointments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            List<Appointment> mine = appointmentDAO.getAppointmentsByPatientIc(patientIc);
            request.setAttribute("appointments", mine);
        } else {
            List<Appointment> all = appointmentDAO.getAllAppointments();
            request.setAttribute("appointments", all);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/appointment/viewAppointment.jsp");
        dispatcher.forward(request, response);
    }

    // ✅ supports multiple treatments
    private void addAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String patientIc;

            if (isPatient(request) && !isStaff(request)) {
                patientIc = getSessionPatientIc(request);
            } else {
                patientIc = request.getParameter("patient_ic");
            }

            String appointmentDateStr = request.getParameter("appointment_date");
            String appointmentTime = request.getParameter("appointment_time");
            String[] treatmentIds = request.getParameterValues("treatment_ids");
            String billingMethod = request.getParameter("billing_method");

            if (patientIc == null || patientIc.trim().isEmpty()
                    || appointmentDateStr == null || appointmentDateStr.trim().isEmpty()
                    || appointmentTime == null || appointmentTime.trim().isEmpty()) {
                throw new Exception("Please fill in all required fields");
            }

            if (treatmentIds == null || treatmentIds.length == 0) {
                throw new Exception("Please select at least one treatment");
            }

            if (appointmentTime.length() >= 5) appointmentTime = appointmentTime.substring(0, 5);

            Appointment appointment = new Appointment();
            appointment.setAppointmentId(appointmentDAO.getNextAppointmentId());
            appointment.setPatientIc(patientIc);

            Date appointmentDate = dateFormat.parse(appointmentDateStr);
            Date today = new Date();
            if (appointmentDate.before(today)
                    && !dateFormat.format(appointmentDate).equals(dateFormat.format(today))) {
                throw new Exception("Appointment date cannot be in the past");
            }

            appointment.setAppointmentDate(appointmentDate);
            appointment.setAppointmentTime(appointmentTime);
            appointment.setAppointmentStatus("Pending");
            appointment.setRemarks(request.getParameter("remarks"));

            if (appointmentDAO.isConfirmedSlotTaken(appointmentDate, appointmentTime)) {
                request.setAttribute("error", "This slot is already CONFIRMED. Please choose another date/time.");
                request.getRequestDispatcher("/appointment/scheduleAppointment.jsp").forward(request, response);
                return;
            }

            int numInstallments = 0;
            if (billingMethod != null && "installment".equalsIgnoreCase(billingMethod)) {
                String installmentsStr = request.getParameter("num_installments");
                if (installmentsStr == null || installmentsStr.trim().isEmpty())
                    throw new Exception("Number of installments is required");

                numInstallments = Integer.parseInt(installmentsStr);
                if (numInstallments < 1 || numInstallments > 5)
                    throw new Exception("Installments must be 1 to 5");
            }

            boolean success = appointmentDAO.addAppointment(appointment, treatmentIds, billingMethod, numInstallments);

            if (success) {
                request.setAttribute("messageType", "book");
                request.setAttribute("message", "Appointment scheduled successfully!");
            } else {
                request.setAttribute("error", "Failed to schedule appointment.");
            }

            listAppointments(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/appointment/scheduleAppointment.jsp").forward(request, response);
        }
    }

    private void editAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentId = request.getParameter("appointment_id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            request.setAttribute("error", "Appointment ID is required.");
            listAppointments(request, response);
            return;
        }

        appointmentId = appointmentId.trim();

        Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);
        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            listAppointments(request, response);
            return;
        }

        String status = appointment.getAppointmentStatus() != null ? appointment.getAppointmentStatus() : "";

        // ===== PATIENT RULES =====
        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);

            if (patientIc == null || !patientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }

            if (!"Confirmed".equalsIgnoreCase(status)) {
                request.setAttribute("error", "You can only edit your appointment when status is CONFIRMED.");
                listAppointments(request, response);
                return;
            }
        }

        // ===== STAFF RULES =====
        if (isStaff(request)) {
            if (!"Confirmed".equalsIgnoreCase(status) && !"Pending".equalsIgnoreCase(status)) {
                request.setAttribute("error", "Staff can only edit appointments with status CONFIRMED or PENDING.");
                listAppointments(request, response);
                return;
            }
        }

        List<AppointmentTreatment> currentTreatments = appointmentDAO.getAppointmentTreatments(appointmentId);

        request.setAttribute("appointment", appointment);
        request.setAttribute("currentTreatments", currentTreatments);

        request.getRequestDispatcher("/appointment/editAppointment.jsp").forward(request, response);
    }

    private void viewAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentId = request.getParameter("appointment_id");
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            appointmentId = request.getParameter("appointmentId");
        }

        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            request.setAttribute("error", "Appointment ID is required.");
            listAppointments(request, response);
            return;
        }

        appointmentId = appointmentId.trim();

        Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);
        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            listAppointments(request, response);
            return;
        }

        List<AppointmentTreatment> treatments = appointmentDAO.getAppointmentTreatments(appointmentId);

        request.setAttribute("appointment", appointment);
        request.setAttribute("treatments", treatments);

        request.getRequestDispatcher("/appointment/viewAppointmentDetails.jsp").forward(request, response);
    }

    // ✅ FIXED: if staff updates status -> Confirmed, store STAFF_ID
    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String appointmentId = request.getParameter("appointment_id");
            String dateStr = request.getParameter("appointment_date");
            String timeStr = request.getParameter("appointment_time");
            String remarks = request.getParameter("remarks");
            String[] treatmentIds = request.getParameterValues("treatment_ids");

            if (appointmentId == null || appointmentId.trim().isEmpty()) throw new Exception("Appointment ID is required");
            if (dateStr == null || dateStr.trim().isEmpty()) throw new Exception("Appointment date is required");
            if (timeStr == null || timeStr.trim().isEmpty()) throw new Exception("Appointment time is required");
            if (treatmentIds == null || treatmentIds.length == 0) throw new Exception("Please select at least one treatment");

            appointmentId = appointmentId.trim();
            if (timeStr.length() >= 5) timeStr = timeStr.substring(0, 5);

            Appointment old = appointmentDAO.getAppointmentById(appointmentId);
            if (old == null) throw new Exception("Appointment not found");

            String oldStatus = old.getAppointmentStatus() != null ? old.getAppointmentStatus() : "";

            // PATIENT RULES
            if (isPatient(request) && !isStaff(request)) {
                String patientIc = getSessionPatientIc(request);
                if (patientIc == null || !patientIc.equals(old.getPatientIc())) throw new Exception("Not allowed.");
                if (!"Confirmed".equalsIgnoreCase(oldStatus)) throw new Exception("You can only edit your appointment when status is CONFIRMED.");
            }

            // STAFF RULES
            if (isStaff(request)) {
                if (!"Confirmed".equalsIgnoreCase(oldStatus) && !"Pending".equalsIgnoreCase(oldStatus)) {
                    throw new Exception("Staff can only edit appointments with status CONFIRMED or PENDING.");
                }
            }

            Date newDate = dateFormat.parse(dateStr);

            boolean changingSlot =
                    (old.getAppointmentDate() == null || !dateFormat.format(old.getAppointmentDate()).equals(dateStr))
                            || !(old.getAppointmentTime() != null && old.getAppointmentTime().length() >= 5
                            ? old.getAppointmentTime().substring(0, 5).equals(timeStr)
                            : timeStr.equals(old.getAppointmentTime()));

            if (changingSlot && appointmentDAO.isConfirmedSlotTaken(newDate, timeStr)) {
                throw new Exception("This time slot is already CONFIRMED. Choose another time.");
            }

            // new status
            String newStatus = oldStatus;
            if (isStaff(request)) {
                String statusParam = request.getParameter("appointment_status");
                if (statusParam == null || statusParam.trim().isEmpty()) throw new Exception("Appointment status is required");
                newStatus = statusParam.trim();
            }

            // 1) update appointment
            boolean ok = appointmentDAO.updateAppointment(appointmentId, newDate, timeStr, newStatus, remarks);
            if (!ok) throw new Exception("Failed to update appointment.");

            // 2) update treatments
            boolean tOk = appointmentDAO.updateAppointmentTreatments(appointmentId, treatmentIds);
            if (!tOk) throw new Exception("Appointment updated, but failed to update treatments.");

            // ✅ IMPORTANT: if staff changed status to Confirmed -> set STAFF_ID
            if (isStaff(request) && "Confirmed".equalsIgnoreCase(newStatus)) {
                String staffId = getSessionStaffId(request);

                // DEBUG (optional)
                System.out.println(">>> UPDATE -> CONFIRMED staffId = " + staffId);

                boolean sOk = appointmentDAO.updateAppointmentStatus(appointmentId, "Confirmed", staffId);
                if (!sOk) throw new Exception("Appointment updated but failed to store STAFF_ID.");
            }

            request.setAttribute("messageType", "edit");
            request.setAttribute("message", "Appointment updated successfully!");

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    private void deleteAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isStaff(request)) throw new Exception("Only staff can delete appointment");

            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty()) throw new Exception("Appointment ID is required");

            boolean success = appointmentDAO.deleteAppointment(appointmentId);

            if (success) {
                request.setAttribute("messageType", "book");
                request.setAttribute("message", "Appointment deleted successfully!");
            } else request.setAttribute("error", "Failed to delete appointment.");

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    private void confirmAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isStaff(request)) throw new Exception("Only staff can confirm appointment");

            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty()) throw new Exception("Appointment ID is required");

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found");

            String t = appt.getAppointmentTime();
            if (t != null && t.length() >= 5) t = t.substring(0, 5);

            if (appointmentDAO.isConfirmedSlotTaken(appt.getAppointmentDate(), t)) {
                request.setAttribute("error", "Another appointment is already confirmed for this slot.");
                listAppointments(request, response);
                return;
            }

            String staffId = getSessionStaffId(request);
            System.out.println(">>> CONFIRM staffId = " + staffId);

            boolean success = appointmentDAO.updateAppointmentStatus(appointmentId, "Confirmed", staffId);

            if (success) {
                boolean billingCreated = billingDAO.createBillingForAppointment(appointmentId, "Pay at Counter", 1);
                if (billingCreated) {
                    request.setAttribute("messageType", "book");
                    request.setAttribute("message", "Appointment confirmed and billing created.");
                } else {
                    request.setAttribute("error", "Appointment confirmed but billing failed.");
                }
            } else {
                request.setAttribute("error", "Failed to confirm appointment.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    // =======================
    // ✅ SHOW DIGITAL CONSENT
    // =======================
    private void showDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isPatient(request) || isStaff(request)) {
                throw new Exception("Only patient can sign digital consent.");
            }

            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty()) {
                throw new Exception("Appointment ID is required.");
            }
            appointmentId = appointmentId.trim();

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found.");

            String sessionIc = getSessionPatientIc(request);
            if (sessionIc == null || !sessionIc.equals(appt.getPatientIc())) {
                throw new Exception("Not allowed.");
            }

            DigitalConsent consent = consentDAO.getConsentByAppointmentId(appointmentId);
            if (consent == null) throw new Exception("Digital consent record not found.");

            Patient patient = patientDAO.getPatientByIc(sessionIc);
            if (patient == null) throw new Exception("Patient record not found.");

            request.setAttribute("appointment", appt);
            request.setAttribute("patient", patient);
            request.setAttribute("consent", consent);

            request.getRequestDispatcher("/appointment/digitalConsent.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            listAppointments(request, response);
        }
    }

    private void processDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isPatient(request) || isStaff(request)) {
                throw new Exception("Only patient can sign consent.");
            }

            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty()) {
                throw new Exception("Appointment ID is required.");
            }
            appointmentId = appointmentId.trim();

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found.");

            String sessionIc = getSessionPatientIc(request);
            if (sessionIc == null || !sessionIc.equals(appt.getPatientIc())) {
                throw new Exception("Not allowed.");
            }

            if (!"Confirmed".equalsIgnoreCase(appt.getAppointmentStatus())) {
                throw new Exception("You can only sign consent when appointment is Confirmed.");
            }

            DigitalConsent consent = consentDAO.getConsentByAppointmentId(appointmentId);
            if (consent == null) throw new Exception("Consent record not found.");

            if (consent.getConsentSigndate() != null) {
                throw new Exception("Consent already signed.");
            }

            boolean ok = consentDAO.signConsent(appointmentId);

            if (ok) {
                response.sendRedirect(request.getContextPath()
                        + "/AppointmentServlet?action=list&msg="
                        + URLEncoder.encode("Digital consent signed successfully!", "UTF-8"));
                return;
            } else {
                throw new Exception("Failed to sign digital consent.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            listAppointments(request, response);
        }
    }

    private void declineDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isPatient(request) || isStaff(request)) {
                throw new Exception("Only patient can reject consent.");
            }

            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty()) {
                throw new Exception("Appointment ID is required.");
            }
            appointmentId = appointmentId.trim();

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found.");

            String sessionIc = getSessionPatientIc(request);
            if (sessionIc == null || !sessionIc.equals(appt.getPatientIc())) {
                throw new Exception("Not allowed.");
            }

            if ("Cancelled".equalsIgnoreCase(appt.getAppointmentStatus())) {
                request.setAttribute("messageType", "cancel");
                request.setAttribute("message", "Appointment already cancelled.");
                listAppointments(request, response);
                return;
            }

            boolean ok = appointmentDAO.updateAppointmentStatus(appointmentId, "Cancelled", null);

            if (ok) {
                request.setAttribute("messageType", "cancel");
                request.setAttribute("message", "Consent rejected. Your appointment has been cancelled.");
            } else {
                throw new Exception("Failed to cancel appointment.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String appointmentId = request.getParameter("appointment_id");
            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

            boolean ok = appointmentDAO.updateAppointmentStatus(appointmentId.trim(), "Cancelled", null);

            if (ok) {
                request.setAttribute("messageType", "cancel");
                request.setAttribute("message", "Your appointment has been cancelled.");
            } else {
                request.setAttribute("error", "Failed to cancel appointment.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }
}
