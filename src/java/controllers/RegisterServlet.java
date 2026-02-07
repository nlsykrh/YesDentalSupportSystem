package controllers;

import beans.Patient;
import dao.PatientDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")   // ✅ Option 1 mapping
public class RegisterServlet extends HttpServlet {

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
            // If action is missing/unknown, go back safely
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            editPatient(request, response);
        } else if ("delete".equals(action)) {
            deletePatient(request, response);
        } else {
            // Default action: list patients (your existing behavior)
            listPatients(request, response);
        }
    }

    private void editPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");

        if (patientIc == null || patientIc.trim().isEmpty()) {
            request.setAttribute("error", "Patient IC is required for editing.");
            listPatients(request, response);
            return;
        }

        Patient patient = patientDAO.getPatientByIc(patientIc);

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

        System.out.println("DEBUG: Number of patients fetched: "
                + (patients != null ? patients.size() : "null"));

        request.setAttribute("patients", patients);

        // your existing forward
        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
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

            // DOB
            patient.setPatientDob(
                    new SimpleDateFormat("yyyy-MM-dd")
                            .parse(request.getParameter("patient_dob"))
            );

            // ✅ PASSWORD = PHONE (AUTOMATIC)
            patient.setPatientPassword(patient.getPatientPhone());

            // Hidden fields
            patient.setPatientStatus(request.getParameter("patient_status"));
            patient.setPatientCrDate(new Date());

            boolean success = patientDAO.addPatient(patient);

            if (success) {
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("error", "Failed to add patient.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
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

            // DOB
            patient.setPatientDob(
                    new SimpleDateFormat("yyyy-MM-dd")
                            .parse(request.getParameter("patient_dob"))
            );

            // ✅ PASSWORD = PHONE (AUTOMATIC)
            patient.setPatientPassword(patient.getPatientPhone());

            // Hidden fields
            patient.setPatientStatus(request.getParameter("patient_status"));
            patient.setPatientCrDate(new Date());

            boolean success = patientDAO.addPatient(patient);

            if (success) {
                response.sendRedirect("login.jsp");
            } else {
                request.setAttribute("error", "Failed to add patient.");
                request.getRequestDispatcher("addPatient.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("addPatient.jsp").forward(request, response);
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
            Patient patient = new Patient();

            patient.setPatientIc(request.getParameter("patient_ic"));
            patient.setPatientName(request.getParameter("patient_name"));
            patient.setPatientPhone(request.getParameter("patient_phone"));
            patient.setPatientEmail(request.getParameter("patient_email"));
            patient.setPatientAddress(request.getParameter("patient_address"));
            patient.setPatientGuardian(request.getParameter("patient_guardian"));
            patient.setPatientGuardianPhone(request.getParameter("patient_guardian_phone"));
            patient.setPatientStatus(request.getParameter("patient_status"));

            patient.setPatientDob(
                    new SimpleDateFormat("yyyy-MM-dd")
                            .parse(request.getParameter("patient_dob"))
            );

            boolean success = patientDAO.updatePatient(patient);

            if (success) {
                request.setAttribute("message", "Patient updated successfully!");
            } else {
                request.setAttribute("error", "Update failed. Please try again.");
            }

            // Redirect after update
            response.sendRedirect("PatientServlet");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid data: " + e.getMessage());
            request.getRequestDispatcher("/patient/editPatient.jsp").forward(request, response);
        }
    }
}
