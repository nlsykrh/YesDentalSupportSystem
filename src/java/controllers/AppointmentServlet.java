package controllers;

import beans.*;
import dao.AppointmentDAO;
import dao.BillingDAO;
import dao.DigitalConsentDAO;
import dao.PatientDAO;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
        return session != null && session.getAttribute("patientIc") != null;
    }

    private boolean isStaff(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("staffId") != null;
    }

    private String getSessionPatientIc(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (String) session.getAttribute("patientIc");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
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
            case "sign_consent":
                processDigitalConsent(request, response);
                break;
            case "decline_consent":
                declineDigitalConsent(request, response);
                break;
            case "cancel":
                cancelAppointment(request, response);
                break;
            default:
                request.setAttribute("error", "Invalid action: " + action);
                listAppointments(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
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

    private void listAppointments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Appointment> all = appointmentDAO.getAllAppointments();

        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            List<Appointment> mine = new ArrayList<>();
            if (all != null) {
                for (Appointment a : all) {
                    if (a != null && patientIc != null && patientIc.equals(a.getPatientIc())) {
                        mine.add(a);
                    }
                }
            }
            request.setAttribute("appointments", mine);
        } else {
            request.setAttribute("appointments", all);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/appointment/viewAppointment.jsp");
        dispatcher.forward(request, response);
    }

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
            String treatmentId = request.getParameter("treatment_id");
            String billingMethod = request.getParameter("billing_method");

            if (patientIc == null || patientIc.trim().isEmpty()
                    || appointmentDateStr == null || appointmentDateStr.trim().isEmpty()
                    || appointmentTime == null || appointmentTime.trim().isEmpty()
                    || treatmentId == null || treatmentId.trim().isEmpty()) {
                throw new Exception("Please fill in all required fields");
            }

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

        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            if (patientIc == null || !patientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }
        }

        List<AppointmentTreatment> treatments = appointmentDAO.getAppointmentTreatments(appointmentId);
        request.setAttribute("appointment", appointment);
        request.setAttribute("treatments", treatments);

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

        if (isPatient(request) && !isStaff(request)) {
            String patientIc = getSessionPatientIc(request);
            if (patientIc == null || !patientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }
        }

        List<AppointmentTreatment> treatments = appointmentDAO.getAppointmentTreatments(appointmentId);
        request.setAttribute("appointment", appointment);
        request.setAttribute("treatments", treatments);

        request.getRequestDispatcher("/appointment/viewAppointmentDetails.jsp").forward(request, response);
    }

    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isStaff(request)) {
                throw new Exception("Only staff can update appointment status");
            }

            String appointmentId = request.getParameter("appointment_id");
            String status = request.getParameter("appointment_status");

            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

            if (status == null || status.trim().isEmpty())
                throw new Exception("Appointment status is required");

            boolean success = appointmentDAO.updateAppointmentStatus(appointmentId, status);

            if (success) request.setAttribute("message", "Appointment updated successfully!");
            else request.setAttribute("error", "Failed to update appointment.");

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    private void deleteAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!isStaff(request)) {
                throw new Exception("Only staff can delete appointment");
            }

            String appointmentId = request.getParameter("appointment_id");

            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

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
            if (!isStaff(request)) {
                throw new Exception("Only staff can confirm appointment");
            }

            String appointmentId = request.getParameter("appointment_id");

            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found");

            if (appointmentDAO.isConfirmedSlotTaken(appt.getAppointmentDate(), appt.getAppointmentTime())) {
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

    private void showDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isPatient(request) || isStaff(request)) {
            request.setAttribute("error", "Only patient can access digital consent.");
            listAppointments(request, response);
            return;
        }

        String appointmentId = request.getParameter("appointment_id");

        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            request.setAttribute("error", "Appointment ID is required.");
            listAppointments(request, response);
            return;
        }

        try {
            String sessionPatientIc = getSessionPatientIc(request);

            Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);
            if (appointment == null) {
                request.setAttribute("error", "Appointment not found.");
                listAppointments(request, response);
                return;
            }

            if (sessionPatientIc == null || !sessionPatientIc.equals(appointment.getPatientIc())) {
                request.setAttribute("error", "Not allowed.");
                listAppointments(request, response);
                return;
            }

            if (!"Confirmed".equalsIgnoreCase(appointment.getAppointmentStatus())) {
                request.setAttribute("error", "Only confirmed appointments require digital consent.");
                listAppointments(request, response);
                return;
            }

            if (consentDAO.hasConsentForAppointment(appointmentId)) {
                request.setAttribute("message", "Consent already signed.");
                listAppointments(request, response);
                return;
            }

            Patient patient = patientDAO.getPatientByIc(sessionPatientIc);
            List<AppointmentTreatment> treatments = appointmentDAO.getAppointmentTreatments(appointmentId);

            StringBuilder treatmentText = new StringBuilder();
            if (treatments != null) {
                for (AppointmentTreatment t : treatments) {
                    if (t != null && t.getTreatmentId() != null) {
                        treatmentText.append(t.getTreatmentId()).append(", ");
                    }
                }
            }
            if (treatmentText.length() > 2) treatmentText.setLength(treatmentText.length() - 2);

            Date now = new Date();
            String signedDate = new SimpleDateFormat("dd/MM/yyyy").format(now);

            String consentContext =
                    "DIGITAL CONSENT FORM\n" +
                    "Patient Name: " + (patient != null && patient.getPatientName() != null ? patient.getPatientName() : "") + "\n" +
                    "Patient IC: " + sessionPatientIc + "\n" +
                    "Appointment ID: " + appointmentId + "\n" +
                    "Treatment(s): " + treatmentText + "\n" +
                    "I hereby give my consent to receive dental treatment at Yes Dental Clinic.\n" +
                    "I understand the risks (pain, bleeding, swelling, infection) and I may decline.\n" +
                    "Signed Date: " + signedDate;

            request.setAttribute("appointment", appointment);
            request.setAttribute("patient", patient);
            request.setAttribute("treatmentText", treatmentText.toString());
            request.setAttribute("consentContext", consentContext);
            request.setAttribute("today", now);

            request.getRequestDispatcher("/appointment/digitalConsent.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            listAppointments(request, response);
        }
    }

    private void processDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isPatient(request) || isStaff(request)) {
            request.setAttribute("error", "Only patient can sign digital consent.");
            listAppointments(request, response);
            return;
        }

        try {
            String appointmentId = request.getParameter("appointment_id");
            String consentText = request.getParameter("consent_text");
            String sessionPatientIc = getSessionPatientIc(request);

            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found");

            if (sessionPatientIc == null || !sessionPatientIc.equals(appt.getPatientIc()))
                throw new Exception("Not allowed");

            if (!"Confirmed".equalsIgnoreCase(appt.getAppointmentStatus()))
                throw new Exception("Consent allowed only when appointment is Confirmed");

            if (consentDAO.hasConsentForAppointment(appointmentId))
                throw new Exception("Consent already signed");

            DigitalConsent consent = new DigitalConsent();
            consent.setConsentId(consentDAO.getNextConsentId());
            consent.setPatientIc(sessionPatientIc);
            consent.setAppointmentId(appointmentId);
            consent.setConsentContext(consentText != null ? consentText : "General dental treatment consent");
            consent.setConsentSigndate(new Date());

            boolean success = consentDAO.addDigitalConsent(consent);

            if (success) request.setAttribute("message", "Digital consent signed successfully!");
            else request.setAttribute("error", "Failed to sign consent");

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }

    private void declineDigitalConsent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isPatient(request) || isStaff(request)) {
            request.setAttribute("error", "Only patient can decline digital consent.");
            listAppointments(request, response);
            return;
        }

        try {
            String appointmentId = request.getParameter("appointment_id");
            String sessionPatientIc = getSessionPatientIc(request);

            if (appointmentId == null || appointmentId.trim().isEmpty())
                throw new Exception("Appointment ID is required");

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found");

            if (sessionPatientIc == null || !sessionPatientIc.equals(appt.getPatientIc()))
                throw new Exception("Not allowed");

            if (!"Confirmed".equalsIgnoreCase(appt.getAppointmentStatus()))
                throw new Exception("Only confirmed appointments can decline consent");

            boolean success = appointmentDAO.updateAppointmentStatus(appointmentId, "Cancelled");

            if (success) request.setAttribute("message", "Consent declined. Appointment cancelled.");
            else request.setAttribute("error", "Failed to cancel appointment");

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

            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt == null) throw new Exception("Appointment not found");

            if (isPatient(request) && !isStaff(request)) {
                String patientIc = getSessionPatientIc(request);
                if (patientIc == null || !patientIc.equals(appt.getPatientIc())) {
                    throw new Exception("Not allowed");
                }
            } else if (!isStaff(request)) {
                throw new Exception("Not allowed");
            }

            boolean success = appointmentDAO.updateAppointmentStatus(appointmentId, "Cancelled");

            if (success) request.setAttribute("message", "Appointment cancelled successfully!");
            else request.setAttribute("error", "Failed to cancel appointment");

        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }

        listAppointments(request, response);
    }
}
