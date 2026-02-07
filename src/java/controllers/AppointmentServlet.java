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

    // ✅ patient session key = "patientId" (contains PATIENT_IC)
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

    private boolean isLoggedIn(HttpServletRequest request) {
        return isPatient(request) || isStaff(request);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ✅ Block if not logged in
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
                // patient/staff both can see schedule page
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

        // ✅ Block if not logged in
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

        // ✅ PATIENT sees only own appointments
        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);

            // ✅ BEST: query only mine (recommended)
            // If you don't have getAppointmentsByPatientIc, add it (code below in DAO section)
            List<Appointment> mine = appointmentDAO.getAppointmentsByPatientIc(patientIc);
            request.setAttribute("appointments", mine);

        } else {
            // ✅ STAFF sees all
            List<Appointment> all = appointmentDAO.getAllAppointments();
            request.setAttribute("appointments", all);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/appointment/viewAppointment.jsp");
        dispatcher.forward(request, response);
    }

    private void addAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String patientIc;

            // ✅ patient uses session patientId (PATIENT_IC)
            if (isPatient(request) && !isStaff(request)) {
                patientIc = getSessionPatientIc(request);
            } else {
                patientIc = request.getParameter("patient_ic");
            }

            String appointmentDateStr = request.getParameter("appointment_date");
            String appointmentTime = request.getParameter("appointment_time");
            String treatmentId = request.getParameter("treatment_id");
            String billingMethod = request.getParameter("billing_method");

            if (patientIc == null || patientIc.trim().isEmpty()
                    || appointmentDateStr == null || appointmentDateStr.trim().isEmpty()
                    || appointmentTime == null || appointmentTime.trim().isEmpty()
                    || treatmentId == null || treatmentId.trim().isEmpty()) {
                throw new Exception("Please fill in all required fields");
            }

            // normalize time (avoid 14:00:00)
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

            // slot block (confirmed only)
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

            boolean success = appointmentDAO.addAppointment(appointment, treatmentId, billingMethod, numInstallments);

            if (success) request.setAttribute("message", "Appointment scheduled successfully!");
            else request.setAttribute("error", "Failed to schedule appointment.");

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

        Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);

        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            listAppointments(request, response);
            return;
        }

        // ✅ patient cannot edit others
        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            if (patientIc == null || !patientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }
        }

        // ✅ BOTH staff & patient can edit ONLY when status = Confirmed
        if (!"Confirmed".equalsIgnoreCase(appointment.getAppointmentStatus())) {
            request.setAttribute("error", "Edit is allowed only for CONFIRMED appointments.");
            listAppointments(request, response);
            return;
        }

        request.setAttribute("appointment", appointment);
        request.getRequestDispatcher("/appointment/editAppointment.jsp").forward(request, response);
    }

    private void viewAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentId = request.getParameter("appointment_id");

        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            request.setAttribute("error", "Appointment ID is required.");
            listAppointments(request, response);
            return;
        }

        Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);

        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            listAppointments(request, response);
            return;
        }

        // ✅ patient cannot view others
        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            if (patientIc == null || !patientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }
        }

        request.setAttribute("appointment", appointment);
        request.getRequestDispatcher("/appointment/viewAppointmentDetails.jsp").forward(request, response);
    }

    // Staff only
    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isStaff(request)) throw new Exception("Only staff can update appointment");

            String appointmentId = request.getParameter("appointment_id");
            String dateStr = request.getParameter("appointment_date");
            String timeStr = request.getParameter("appointment_time");
            String status = request.getParameter("appointment_status");
            String remarks = request.getParameter("remarks");

            if (appointmentId == null || appointmentId.trim().isEmpty()) throw new Exception("Appointment ID is required");
            if (dateStr == null || dateStr.trim().isEmpty()) throw new Exception("Appointment date is required");
            if (timeStr == null || timeStr.trim().isEmpty()) throw new Exception("Appointment time is required");
            if (status == null || status.trim().isEmpty()) throw new Exception("Appointment status is required");

            if (timeStr.length() >= 5) timeStr = timeStr.substring(0, 5);

            Date newDate = dateFormat.parse(dateStr);

            Appointment old = appointmentDAO.getAppointmentById(appointmentId);
            if (old == null) throw new Exception("Appointment not found");

            boolean changingSlot =
                    !dateFormat.format(old.getAppointmentDate()).equals(dateStr)
                            || !(old.getAppointmentTime() != null && old.getAppointmentTime().length() >= 5
                            ? old.getAppointmentTime().substring(0, 5).equals(timeStr)
                            : timeStr.equals(old.getAppointmentTime()));

            if (changingSlot && appointmentDAO.isConfirmedSlotTaken(newDate, timeStr)) {
                throw new Exception("This time slot is already CONFIRMED. Choose another time.");
            }

            boolean ok = appointmentDAO.updateAppointment(appointmentId, newDate, timeStr, status, remarks);

            if (ok) request.setAttribute("message", "Appointment updated successfully!");
            else request.setAttribute("error", "Failed to update appointment.");

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

            if (success) request.setAttribute("message", "Appointment deleted successfully!");
            else request.setAttribute("error", "Failed to delete appointment.");

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

            boolean success = appointmentDAO.updateAppointmentStatus(appointmentId, "Confirmed");

            if (success) {
                boolean billingCreated = billingDAO.createBillingForAppointment(appointmentId, "Pay at Counter", 1);
                if (billingCreated) request.setAttribute("message", "Appointment confirmed and billing created.");
                else request.setAttribute("error", "Appointment confirmed but billing failed.");
            } else {
                request.setAttribute("error", "Failed to confirm appointment.");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    // ===== Keep your existing versions for these 4 methods =====
    private void showDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("error", "showDigitalConsent: keep your existing code here");
        listAppointments(request, response);
    }

    private void processDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("error", "processDigitalConsent: keep your existing code here");
        listAppointments(request, response);
    }

    private void declineDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("error", "declineDigitalConsent: keep your existing code here");
        listAppointments(request, response);
    }

    private void cancelAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("error", "cancelAppointment: keep your existing code here");
        listAppointments(request, response);
    }
}