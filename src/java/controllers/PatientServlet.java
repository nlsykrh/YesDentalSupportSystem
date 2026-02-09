package controllers;

import beans.Patient;
import dao.PatientDAO;

import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("addForm".equals(action)) {
            RequestDispatcher rd = request.getRequestDispatcher("/patient/addPatient.jsp");
            rd.forward(request, response);
            return;
        }

        if ("checkIc".equals(action)) {
            checkIc(request, response);
            return;
        }

        if ("edit".equals(action)) {
            editPatient(request, response);
            return;
        }

        if ("view".equals(action)) {
            viewPatient(request, response);
            return;
        }

        listPatients(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addPatient(request, response);
            return;
        }

        if ("update".equals(action)) {
            updatePatient(request, response);
            return;
        }

        if ("delete".equals(action)) {
            deletePatient(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/PatientServlet?action=list");
    }

    private void checkIc(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");
        boolean exists = false;

        if (patientIc != null && !patientIc.trim().isEmpty()) {
            Patient patient = patientDAO.getPatientByIc(patientIc.trim());
            exists = (patient != null);
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"exists\":" + exists + "}");
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
        patient.setPatientStatus("A");
        patient.setPatientCrDate(new Date());

        boolean success = patientDAO.addPatient(patient);

        if (success) {
            // ✅ redirect back to add form with popup param
            response.sendRedirect(request.getContextPath() + "/PatientServlet?action=addForm&popup=added");
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


private void updatePatient(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    try {
        String patientIc = request.getParameter("patient_ic");
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

        patient.setPatientDob(new SimpleDateFormat("yyyy-MM-dd")
                .parse(request.getParameter("patient_dob")));

        String newPassword = request.getParameter("patient_password");
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            patient.setPatientPassword(newPassword.trim());
        } else {
            patient.setPatientPassword(existing.getPatientPassword());
        }

        boolean success = patientDAO.updatePatient(patient);

        if (success) {
            // ✅ redirect back to edit page with popup param
            response.sendRedirect(request.getContextPath()
                    + "/PatientServlet?action=edit&patient_ic="
                    + java.net.URLEncoder.encode(patientIc, "UTF-8")
                    + "&popup=updated");
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

    // Your existing methods (edit/view/list) — keep as you already have:
    private void editPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");
        Patient patient = patientDAO.getPatientByIc(patientIc);

        request.setAttribute("patient", patient);
        request.getRequestDispatcher("/patient/editPatient.jsp").forward(request, response);
    }

    private void viewPatient(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIc = request.getParameter("patient_ic");
        Patient patient = patientDAO.getPatientByIc(patientIc);

        request.setAttribute("patient", patient);
        request.getRequestDispatcher("/patient/viewPatientDetails.jsp").forward(request, response);
    }

    private void listPatients(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("patients", patientDAO.getAllPatients());
        request.getRequestDispatcher("/patient/viewPatients.jsp").forward(request, response);
    }

    private void deletePatient(HttpServletRequest request, HttpServletResponse response) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}
