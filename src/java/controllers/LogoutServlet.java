package controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String redirectPage = "login.jsp";
        
        if (session != null) {
            // Get user info for logging (optional)
            String userType = (String) session.getAttribute("userType");
            String userName = null;
            
            if ("patient".equals(userType)) {
                userName = (String) session.getAttribute("patientName");
            } else if ("staff".equals(userType)) {
                userName = (String) session.getAttribute("staffName");
            }
            
            // Log logout activity (optional - you can add your logging mechanism here)
            System.out.println("User logged out: " + userName + " (Type: " + userType + ")");
            
            // Invalidate session
            session.invalidate();
            
            // Optionally add a message
            request.setAttribute("logoutMessage", "You have been successfully logged out.");
        }
        
        // Redirect to login page with optional parameter
        response.sendRedirect(redirectPage + "?logout=true");
        
        // Alternatively, if you want to forward to JSP with message:
        // request.setAttribute("message", "You have been successfully logged out.");
        // request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}