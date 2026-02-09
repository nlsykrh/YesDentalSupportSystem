package controllers;

import beans.Patient;
import dao.PatientDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class PatientServlet extends HttpServlet {

    private PatientDAO patientDAO;
    private SimpleDateFormat dateFormat;

    @Override
    public void init() {
        patientDAO = new PatientDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addPatient(request, response);
        } else if ("update".equals(action)) {
            updatePatient(request, response);
        } else if ("delete".equals(action)) {
            deletePatient(request, response);
        } else if ("register".equals(action)) {
            registerPatient(request, response);
        } else {
            // fallback
            response.sendRedirect(request.getContextPath() + "/PatientServlet?action=list");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty() || "list".equalsIgnoreCase(action)) {
            listPatients(request, response);
            return;
        }

        switch (action) {
            case "addForm":
                showAddForm(request, response);
                break;

            case "checkIc":
                checkIc(request, response);
                break;

            case "edit":
                editPatient(request, response);
                break;

            case "view":
                viewPatient(request, response);
                break;

            default:
                listPatients(request, response);
                break;
        }
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/patient/addPatient.jsp");
        dispatcher.forward(request, response);
    }

    private void checkIc(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");
        boolean exists = false;

        if (patientIc != null) {
            patientIc = patientIc.trim();
            if (!patientIc.isEmpty()) {
                Patient patient = patientDAO.getPatientByIc(patientIc);
                exists = (patient != null);
            }
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"exists\":" + exists + "}");
    }

    private void viewPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");

        if (patientIc == null || patientIc.trim().isEmpty()) {
            request.setAttribute("error", "Patient IC is required.");
            listPatients(request, response);
            return;
        }

        Patient patient = patientDAO.getPatientByIc(patientIc.trim());

        if (patient == null) {
            request.setAttribute("error", "Patient not found with IC: " + patientIc);
            listPatients(request, response);
            return;
        }

        request.setAttribute("patient", patient);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/patient/viewPatientDetails.jsp");
        dispatcher.forward(request, response);
    }

    private void editPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");

        if (patientIc == null || patientIc.trim().isEmpty()) {
            request.setAttribute("error", "Patient IC is required.");
            listPatients(request, response);
            return;
        }

        Patient patient = patientDAO.getPatientByIc(patientIc.trim());

        if (patient == null) {
            request.setAttribute("error", "Patient not found with IC: " + patientIc);
            listPatients(request, response);
            return;
        }

        request.setAttribute("patient", patient);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/patient/editPatient.jsp");
        dispatcher.forward(request, response);
    }

    private void listPatients(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Patient> patients = patientDAO.getAllPatients();
        request.setAttribute("patients", patients);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/patient/viewPatients.jsp");
        dispatcher.forward(request, response);
    }

    private void registerPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Patient patient = new Patient();

            patient.setPatientName(request.getParameter("patient_name"));
            patient.setPatientIc(request.getParameter("patient_ic"));
            patient.setPatientPhone(request.getParameter("patient_phone"));
            patient.setPatientEmail(request.getParameter("patient_email"));
            patient.setPatientAddress(request.getParameter("patient_address"));
            patient.setPatientGuardian(request.getParameter("patient_guardian"));
            patient.setPatientGuardianPhone(request.getParameter("patient_guardian_phone"));

            patient.setPatientDob(new SimpleDateFormat("yyyy-MM-dd")
                    .parse(request.getParameter("patient_dob")));

            patient.setPatientPassword(patient.getPatientPhone());
            patient.setPatientStatus(request.getParameter("patient_status"));
            patient.setPatientCrDate(new Date());

            boolean success = patientDAO.addPatient(patient);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            } else {
                request.setAttribute("error", "Failed to register patient.");
                request.getRequestDispatcher("/patient/addPatient.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/patient/addPatient.jsp").forward(request, response);
        }
    }

    private void addPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Patient patient = new Patient();

            patient.setPatientName(request.getParameter("patient_name"));
            patient.setPatientIc(request.getParameter("patient_ic"));
            patient.setPatientPhone(request.getParameter("patient_phone"));
            patient.setPatientEmail(request.getParameter("patient_email"));
            patient.setPatientAddress(request.getParameter("patient_address"));
            patient.setPatientGuardian(request.getParameter("patient_guardian"));
            patient.setPatientGuardianPhone(request.getParameter("patient_guardian_phone"));

            patient.setPatientDob(new SimpleDateFormat("yyyy-MM-dd")
                    .parse(request.getParameter("patient_dob")));

            patient.setPatientPassword(patient.getPatientPhone());
            patient.setPatientStatus(request.getParameter("patient_status"));
            patient.setPatientCrDate(new Date());

            boolean success = patientDAO.addPatient(patient);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/PatientServlet?action=list");
            } else {
                request.setAttribute("error", "Failed to add patient.");
                request.getRequestDispatcher("/patient/addPatient.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/patient/addPatient.jsp").forward(request, response);
        }
    }

    private void deletePatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");

        boolean success = patientDAO.delete(patientIc);

        if (success) {
            request.setAttribute("message", "Patient deleted successfully!");
        } else {
            request.setAttribute("error", "Failed to delete patient.");
        }

        listPatients(request, response);
    }

private void updatePatient(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    try {
        request.setCharacterEncoding("UTF-8");

        String patientIc = request.getParameter("patient_ic");
        if (patientIc == null || patientIc.trim().isEmpty()) {
            request.setAttribute("error", "Patient IC is required.");
            listPatients(request, response);
            return;
        }

        Patient existing = patientDAO.getPatientByIc(patientIc);
        if (existing == null) {
            request.setAttribute("error", "Patient not found.");
            listPatients(request, response);
            return;
        }

        Patient patient = new Patient();
        patient.setPatientIc(patientIc);

        patient.setPatientName(request.getParameter("patient_name"));
        patient.setPatientPhone(request.getParameter("patient_phone"));
        patient.setPatientEmail(request.getParameter("patient_email"));
        patient.setPatientAddress(request.getParameter("patient_address"));
        patient.setPatientGuardian(request.getParameter("patient_guardian"));
        patient.setPatientGuardianPhone(request.getParameter("patient_guardian_phone"));
        patient.setPatientStatus(request.getParameter("patient_status"));

        // DOB
        String dobStr = request.getParameter("patient_dob");
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            patient.setPatientDob(new SimpleDateFormat("yyyy-MM-dd").parse(dobStr));
        } else {
            patient.setPatientDob(existing.getPatientDob());
        }

        // ✅ Password (optional)
        String newPass = request.getParameter("patient_password");
        if (newPass != null && !newPass.trim().isEmpty()) {
            patient.setPatientPassword(newPass.trim());
        } else {
            patient.setPatientPassword(existing.getPatientPassword()); // keep old
        }

        boolean success = patientDAO.updatePatient(patient);

        if (success) {
            // after update go back list
            response.sendRedirect(request.getContextPath() + "/PatientServlet?action=list");
        } else {
            request.setAttribute("error", "Update failed. Please try again.");
            request.setAttribute("patient", existing);
            request.getRequestDispatcher("/patient/editPatient.jsp").forward(request, response);
        }

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Invalid data: " + e.getMessage());
        request.getRequestDispatcher("/patient/editPatient.jsp").forward(request, response);
    }
}
}