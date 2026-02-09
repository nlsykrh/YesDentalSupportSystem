package controllers;

import beans.Patient;
import dao.PatientDAO;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private PatientDAO patientDAO;

    @Override
    public void init() {
        patientDAO = new PatientDAO();
    }

    // ✅ For IC checking (AJAX)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("checkIc".equalsIgnoreCase(action)) {
            checkIc(request, response);
            return;
        }

        // Default: open register page
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }

    // ✅ For patient register submit
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        // Your register.jsp uses action="add"
        if (action == null || !"add".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/register.jsp");
            return;
        }

        registerPatient(request, response);
    }

    private void checkIc(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String ic = request.getParameter("patient_ic");
        boolean exists = false;

        if (ic != null) {
            ic = ic.trim();
            if (!ic.isEmpty()) {
                exists = (patientDAO.getPatientByIc(ic) != null);
            }
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"exists\":" + exists + "}");
    }

    private void registerPatient(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        try {
            String patientIc = request.getParameter("patient_ic");
            if (patientIc == null) patientIc = "";
            patientIc = patientIc.trim();

            // ✅ Validate IC format (server side)
            if (!patientIc.matches("\\d{12}")) {
                response.sendRedirect(request.getContextPath() + "/register.jsp?err=invalid");
                return;
            }

            // ✅ Server-side check IC already exists
            if (patientDAO.getPatientByIc(patientIc) != null) {
                response.sendRedirect(request.getContextPath() + "/register.jsp?err=exists");
                return;
            }

            Patient patient = new Patient();

            patient.setPatientName(request.getParameter("patient_name"));
            patient.setPatientIc(patientIc);
            patient.setPatientPhone(request.getParameter("patient_phone"));
            patient.setPatientEmail(request.getParameter("patient_email"));
            patient.setPatientAddress(request.getParameter("patient_address"));
            patient.setPatientGuardian(request.getParameter("patient_guardian"));
            patient.setPatientGuardianPhone(request.getParameter("patient_guardian_phone"));

            // DOB
            String dob = request.getParameter("patient_dob");
            Date dobDate = new SimpleDateFormat("yyyy-MM-dd").parse(dob);
            patient.setPatientDob(dobDate);

            // ✅ password = phone
            patient.setPatientPassword(patient.getPatientPhone());

            // status + created date
            String status = request.getParameter("patient_status");
            if (status == null || status.trim().isEmpty()) status = "A";
            patient.setPatientStatus(status);

            patient.setPatientCrDate(new Date());

            boolean success = patientDAO.addPatient(patient);

            if (success) {
                // ✅ show popup on register.jsp then JS redirect to login.jsp
                response.sendRedirect(request.getContextPath() + "/register.jsp?popup=success");
            } else {
                response.sendRedirect(request.getContextPath() + "/register.jsp?err=fail");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register.jsp?err=invalid");
        }
    }
}