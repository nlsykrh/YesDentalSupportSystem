package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import dao.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // IMPORTANT: login.jsp must send name="userId"
        String userId = request.getParameter("userId");   // Patient IC or Staff ID
        String password = request.getParameter("password");
        String userType = request.getParameter("userType");

        if (userId != null) userId = userId.trim();
        if (password != null) password = password.trim();
        if (userType != null) userType = userType.trim();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            if ("patient".equalsIgnoreCase(userType)) {

                String sql = "SELECT PATIENT_IC, PATIENT_NAME FROM PATIENT " +
                             "WHERE PATIENT_IC = ? AND PATIENT_PASSWORD = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userId);
                pstmt.setString(2, password);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("patientId", rs.getString("PATIENT_IC"));
                    session.setAttribute("patientName", rs.getString("PATIENT_NAME"));
                    session.setAttribute("userType", "patient");
                    response.sendRedirect("patient/patientDashboard.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=true");
                }

            } else if ("staff".equalsIgnoreCase(userType)) {

                String sql = "SELECT STAFF_ID, STAFF_NAME, STAFF_ROLE FROM STAFF " +
                             "WHERE STAFF_ID = ? AND STAFF_PASSWORD = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userId);
                pstmt.setString(2, password);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("staffId", rs.getString("STAFF_ID"));
                    session.setAttribute("staffName", rs.getString("STAFF_NAME"));
                    session.setAttribute("staffRole", rs.getString("STAFF_ROLE"));
                    session.setAttribute("userType", "staff");
                    response.sendRedirect("staff/staffDashboard.jsp");
                } else {
                    response.sendRedirect("login.jsp?error=true");
                }

            } else {
                // userType missing/invalid
                response.sendRedirect("login.jsp?error=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Database error");

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}