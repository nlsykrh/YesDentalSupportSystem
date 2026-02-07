package controllers;

import beans.Staff;
import dao.StaffDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/StaffServlet")
public class StaffServlet extends HttpServlet {

    private StaffDAO staffDAO;

    @Override
    public void init() {
        staffDAO = new StaffDAO();
    }

    private boolean isStaffLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("staffId") != null;
    }

    private void deny(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isStaffLoggedIn(request)) {
            deny(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            listStaff(request, response);
            return;
        }

        switch (action) {
            case "add":
                addStaff(request, response);
                break;
            case "update":
                updateStaff(request, response);
                break;
            case "delete":
                deleteStaff(request, response);
                break;
            default:
                listStaff(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!isStaffLoggedIn(request)) {
            deny(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null || "list".equalsIgnoreCase(action)) {
            listStaff(request, response);
            return;
        }

        switch (action) {
            case "edit":
                editStaff(request, response);
                break;
            case "view":
                viewStaff(request, response);
                break;
            case "add":
                request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
                break;
            default:
                listStaff(request, response);
        }
    }

    private void listStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Staff> staffList = staffDAO.getAllStaff();
        request.setAttribute("staffList", staffList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/staff/viewStaff.jsp");
        dispatcher.forward(request, response);
    }

    private void editStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String staffId = request.getParameter("staff_id");

        if (staffId == null || staffId.trim().isEmpty()) {
            request.setAttribute("error", "Staff ID is required.");
            listStaff(request, response);
            return;
        }

        Staff staff = staffDAO.getStaffById(staffId);

        if (staff == null) {
            request.setAttribute("error", "Staff not found.");
            listStaff(request, response);
            return;
        }

        request.setAttribute("staff", staff);
        request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
    }

    private void addStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String staffName = request.getParameter("staff_name");
            String staffEmail = request.getParameter("staff_email");
            String staffPhone = request.getParameter("staff_phonenum");
            String staffRole = request.getParameter("staff_role");
            String otherRole = request.getParameter("staff_role_other");
            String password = request.getParameter("staff_password");
            String confirmPassword = request.getParameter("confirm_password");

            if (staffName == null || staffName.trim().isEmpty()
                    || staffEmail == null || staffEmail.trim().isEmpty()
                    || staffPhone == null || staffPhone.trim().isEmpty()
                    || staffRole == null || staffRole.trim().isEmpty()
                    || password == null || password.trim().isEmpty()
                    || confirmPassword == null || confirmPassword.trim().isEmpty()) {
                throw new Exception("Please fill in all required fields.");
            }

            staffEmail = staffEmail.trim();
            if (!staffEmail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                request.setAttribute("error", "Invalid email format. Example: name@gmail.com");
                request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
                return;
            }

            if ("Other".equalsIgnoreCase(staffRole)) {
                if (otherRole == null || otherRole.trim().isEmpty()) {
                    request.setAttribute("error", "Please specify the staff role.");
                    request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
                    return;
                }
                staffRole = otherRole.trim();
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Password and Confirm Password do not match.");
                request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
                return;
            }

            String generatedId = staffDAO.getNextStaffId();

            Staff staff = new Staff();
            staff.setStaffId(generatedId);
            staff.setStaffName(staffName.trim());
            staff.setStaffEmail(staffEmail);
            staff.setStaffPhonenum(staffPhone.trim());
            staff.setStaffRole(staffRole);
            staff.setStaffPassword(password);

            boolean success = staffDAO.addStaff(staff);

            if (success) {
                request.setAttribute("message", "Staff ID for " + staffName.trim() + " is " + generatedId);
                request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to add staff.");
                request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/staff/addStaff.jsp").forward(request, response);
        }
    }
    private void viewStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String staffId = request.getParameter("staff_id");

        if (staffId == null || staffId.trim().isEmpty()) {
            request.setAttribute("error", "Staff ID is required.");
            listStaff(request, response);
            return;
        }

        Staff staff = staffDAO.getStaffById(staffId);

        if (staff == null) {
            request.setAttribute("error", "Staff not found.");
            listStaff(request, response);
            return;
        }

        request.setAttribute("staff", staff);
        request.getRequestDispatcher("/staff/viewStaffDetails.jsp").forward(request, response);
    }

    private void updateStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String staffId = request.getParameter("staff_id");
        String staffName = request.getParameter("staff_name");
        String staffEmail = request.getParameter("staff_email");
        String staffPhone = request.getParameter("staff_phonenum");
        String staffRole = request.getParameter("staff_role");
        String otherRole = request.getParameter("staff_role_other");
        String newPassword = request.getParameter("staff_password");
        String confirmPassword = request.getParameter("confirm_password");

        try {
            // ===== Basic validation =====
            if (staffId == null || staffId.trim().isEmpty()) {
                throw new Exception("Staff ID is required.");
            }

            if (staffName == null || staffName.trim().isEmpty()
                    || staffEmail == null || staffEmail.trim().isEmpty()
                    || staffPhone == null || staffPhone.trim().isEmpty()
                    || staffRole == null || staffRole.trim().isEmpty()) {
                throw new Exception("Please fill in all required fields.");
            }

            staffId = staffId.trim();
            staffName = staffName.trim();
            staffEmail = staffEmail.trim();
            staffPhone = staffPhone.trim();
            staffRole = staffRole.trim();

            // Email format check
            if (!staffEmail.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                request.setAttribute("error", "Invalid email format. Example: name@gmail.com");
                request.setAttribute("staff", staffDAO.getStaffById(staffId));
                request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
                return;
            }

            // Role = Other
            if ("Other".equalsIgnoreCase(staffRole)) {
                if (otherRole == null || otherRole.trim().isEmpty()) {
                    request.setAttribute("error", "Please specify the staff role.");
                    request.setAttribute("staff", staffDAO.getStaffById(staffId));
                    request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
                    return;
                }
                staffRole = otherRole.trim();
            }

            // ===== Create staff object EARLY (fix your error) =====
            Staff staff = new Staff();
            staff.setStaffId(staffId);
            staff.setStaffName(staffName);
            staff.setStaffEmail(staffEmail);
            staff.setStaffPhonenum(staffPhone);
            staff.setStaffRole(staffRole);

            // ===== Password logic (ONLY if user typed password) =====
            if (newPassword != null) newPassword = newPassword.trim();

            if (newPassword != null && !newPassword.isEmpty()) {

                if (newPassword.length() < 6) {
                    request.setAttribute("error", "Password must be at least 6 characters.");
                    request.setAttribute("staff", staffDAO.getStaffById(staffId));
                    request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
                    return;
                }

                if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
                    request.setAttribute("error", "Please confirm the new password.");
                    request.setAttribute("staff", staffDAO.getStaffById(staffId));
                    request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
                    return;
                }

                if (!newPassword.equals(confirmPassword.trim())) {
                    request.setAttribute("error", "Password and Confirm Password do not match.");
                    request.setAttribute("staff", staffDAO.getStaffById(staffId));
                    request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
                    return;
                }

                // ✅ only set password when typed
                staff.setStaffPassword(newPassword);
            }
            // else: do NOT set password at all (keep null) → DAO must not update password

            boolean success = staffDAO.updateStaff(staff);

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/StaffServlet?action=list&msg="
                        + java.net.URLEncoder.encode("Staff updated successfully!", "UTF-8"));
            } else {
                request.setAttribute("error", "Update failed. Please try again.");
                request.setAttribute("staff", staffDAO.getStaffById(staffId));
                request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Invalid data: " + e.getMessage());
            request.setAttribute("staff", staffDAO.getStaffById(staffId));
            request.getRequestDispatcher("/staff/editStaff.jsp").forward(request, response);
        }
    }

    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String staffId = request.getParameter("staff_id");

        if (staffId == null || staffId.trim().isEmpty()) {
            request.setAttribute("error", "Staff ID is required.");
            listStaff(request, response);
            return;
        }

        boolean success = staffDAO.delete(staffId);

        if (success) request.setAttribute("message", "Staff deleted successfully!");
        else request.setAttribute("error", "Failed to delete staff.");

        listStaff(request, response);
    }
}
