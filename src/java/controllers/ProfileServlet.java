package controllers;

import beans.Patient;
import beans.Staff;
import dao.PatientDAO;
import dao.StaffDAO;
import java.io.IOException;
import java.text.SimpleDateFormat;
import javax.servlet.*;
import javax.servlet.http.*;

public class ProfileServlet extends HttpServlet {

    private PatientDAO patientDAO;
    private StaffDAO staffDAO;
    private SimpleDateFormat dateFormat;

    @Override
    public void init() {
        patientDAO = new PatientDAO();
        staffDAO = new StaffDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");

        if (userType == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if ("patient".equals(userType)) {
            String patientIc = (String) session.getAttribute("patientId");
            if (patientIc != null) {
                Patient patient = patientDAO.getPatientByIc(patientIc);
                if (patient != null) {
                    request.setAttribute("patient", patient);
                    request.setAttribute("userType", "patient");
                    RequestDispatcher dispatcher =
                            request.getRequestDispatcher("/profile/viewProfile.jsp");
                    dispatcher.forward(request, response);
                } else {
                    session.invalidate();
                    response.sendRedirect("login.jsp?error=Patient not found");
                }
            } else {
                response.sendRedirect("login.jsp");
            }

        } else if ("staff".equals(userType)) {
            String staffId = (String) session.getAttribute("staffId");
            if (staffId != null) {
                Staff staff = staffDAO.getStaffById(staffId);
                if (staff != null) {
                    request.setAttribute("staff", staff);
                    request.setAttribute("userType", "staff");
                    request.setAttribute("staffRole", session.getAttribute("staffRole"));
                    RequestDispatcher dispatcher =
                            request.getRequestDispatcher("/profile/viewProfile.jsp");
                    dispatcher.forward(request, response);
                } else {
                    session.invalidate();
                    response.sendRedirect("login.jsp?error=Staff not found");
                }
            } else {
                response.sendRedirect("login.jsp");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        String userType = (String) session.getAttribute("userType");
        String action = request.getParameter("action");

        if (userType == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        if ("update".equals(action)) {
            if ("patient".equals(userType)) {
                String patientIc = (String) session.getAttribute("patientId");
                updatePatientProfile(request, response, patientIc);
            } else if ("staff".equals(userType)) {
                String staffId = (String) session.getAttribute("staffId");
                updateStaffProfile(request, response, staffId);
            }
            return;
        }

        if ("changePassword".equals(action)) {
            // ✅ patient only
            if (!"patient".equals(userType)) {
                request.setAttribute("error", "Only patients can change password.");
                doGet(request, response);
                return;
            }

            String patientIc = (String) session.getAttribute("patientId");
            changePatientPassword(request, response, patientIc);
        }
    }

    private void updatePatientProfile(HttpServletRequest request, HttpServletResponse response, String patientIc)
            throws ServletException, IOException {

        try {
            Patient existingPatient = patientDAO.getPatientByIc(patientIc);
            if (existingPatient == null) {
                request.setAttribute("error", "Patient not found.");
                doGet(request, response);
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

            String dobStr = request.getParameter("patient_dob");
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                patient.setPatientDob(dateFormat.parse(dobStr));
            } else {
                patient.setPatientDob(existingPatient.getPatientDob());
            }

            // ✅ keep current password (DO NOT overwrite here)
            patient.setPatientPassword(existingPatient.getPatientPassword());

            patient.setPatientStatus(existingPatient.getPatientStatus());
            patient.setPatientCrDate(existingPatient.getPatientCrDate());

            boolean success = patientDAO.updatePatient(patient);

            if (success) {
                request.getSession().setAttribute("patientName", patient.getPatientName());
                request.setAttribute("message", "Profile updated successfully!");
                request.setAttribute("patient", patient);
                request.setAttribute("userType", "patient");
            } else {
                request.setAttribute("error", "Failed to update profile.");
                request.setAttribute("patient", existingPatient);
                request.setAttribute("userType", "patient");
            }

            RequestDispatcher dispatcher = request.getRequestDispatcher("/profile/viewProfile.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error updating profile: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void updateStaffProfile(HttpServletRequest request, HttpServletResponse response, String staffId)
            throws ServletException, IOException {

        try {
            Staff existingStaff = staffDAO.getStaffById(staffId);
            if (existingStaff == null) {
                request.setAttribute("error", "Staff not found.");
                doGet(request, response);
                return;
            }

            Staff staff = new Staff();
            staff.setStaffId(staffId);
            staff.setStaffName(request.getParameter("staff_name"));
            staff.setStaffEmail(request.getParameter("staff_email"));
            staff.setStaffPhonenum(request.getParameter("staff_phonenum"));
            staff.setStaffRole(existingStaff.getStaffRole());
            staff.setStaffPassword(existingStaff.getStaffPassword());

            boolean success = staffDAO.updateStaff(staff);

            if (success) {
                request.getSession().setAttribute("staffName", staff.getStaffName());
                request.setAttribute("message", "Profile updated successfully!");
                request.setAttribute("staff", staff);
                request.setAttribute("userType", "staff");
            } else {
                request.setAttribute("error", "Failed to update profile.");
                request.setAttribute("staff", existingStaff);
                request.setAttribute("userType", "staff");
            }

            RequestDispatcher dispatcher = request.getRequestDispatcher("/profile/viewProfile.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error updating profile: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void changePatientPassword(HttpServletRequest request, HttpServletResponse response, String patientIc)
            throws ServletException, IOException {

        try {
            String currentPassword = request.getParameter("current_password");
            String newPassword = request.getParameter("new_password");
            String confirmPassword = request.getParameter("confirm_password");

            if (newPassword == null || newPassword.trim().isEmpty()) {
                request.setAttribute("error", "New password is required.");
                doGet(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "New passwords do not match.");
                doGet(request, response);
                return;
            }

            Patient patient = patientDAO.getPatientByIc(patientIc);
            if (patient == null || !patient.getPatientPassword().equals(currentPassword)) {
                request.setAttribute("error", "Current password is incorrect.");
                doGet(request, response);
                return;
            }

            // ✅ update ONLY password column
            boolean success = patientDAO.updatePatientPassword(patientIc, newPassword);

            if (success) {
                request.setAttribute("message", "Password changed successfully!");
            } else {
                request.setAttribute("error", "Failed to change password.");
            }

            doGet(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error changing password: " + e.getMessage());
            doGet(request, response);
        }
    }
}