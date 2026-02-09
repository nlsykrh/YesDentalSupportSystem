package controllers;

import beans.*;
import dao.BillingDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PatientBillingServlet")
public class PatientBillingServlet extends HttpServlet {
    private BillingDAO billingDAO;
    
    @Override
    public void init() throws ServletException {
        billingDAO = new BillingDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        // Check if user is logged in - using patientId (which contains the IC)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("patientId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        if (action == null) {
            listPatientBillings(request, response);
            return;
        }
        
        switch(action) {
            case "view":
                viewPatientBilling(request, response);
                break;
            case "view_installments":
                viewPatientInstallments(request, response);
                break;
            case "list":
            default:
                listPatientBillings(request, response);
        }
    }
    
    private void listPatientBillings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get patient IC from session - it's stored as "patientId" in LoginServlet
            HttpSession session = request.getSession();
            String patientIc = (String) session.getAttribute("patientId");
            
            if (patientIc == null) {
                // Redirect to login if no patient ID in session
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            // Debug: Print patientIc to console
            System.out.println("Patient IC retrieved from session (as patientId): " + patientIc);
            
            // Get patient's billings using patientIc
            List<Billing> billings = billingDAO.getBillingsByPatientIc(patientIc);
            request.setAttribute("billings", billings);
            
            // Also get patient name for display
            String patientName = (String) session.getAttribute("patientName");
            request.setAttribute("patientName", patientName);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/patientViewBilling.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading your billings: " + e.getMessage());
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/error.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private void viewPatientBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String billingId = request.getParameter("billing_id");
        
        if (billingId == null || billingId.trim().isEmpty()) {
            request.setAttribute("error", "Billing ID is required.");
            listPatientBillings(request, response);
            return;
        }
        
        try {
            // Get patient IC from session - stored as "patientId"
            HttpSession session = request.getSession();
            String patientIc = (String) session.getAttribute("patientId");
            
            if (patientIc == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            // Debug
            System.out.println("Checking billing " + billingId + " for patient IC: " + patientIc);
            
            // Verify this billing belongs to the patient
            Billing billing = billingDAO.getBillingById(billingId);
            if (billing == null) {
                request.setAttribute("error", "Billing not found.");
                listPatientBillings(request, response);
                return;
            }
            
            // Check if billing belongs to patient
            boolean isPatientBilling = billingDAO.isBillingBelongsToPatient(billingId, patientIc);
            if (!isPatientBilling) {
                request.setAttribute("error", "You are not authorized to view this billing.");
                listPatientBillings(request, response);
                return;
            }
            
            // Get installments if billing method is Installment
            List<Installment> installments = null;
            if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) {
                installments = billingDAO.getInstallmentsByBillingId(billingId);
            }
            
            // Get appointment date for display
            String appointmentDate = billingDAO.getAppointmentDateByBillingId(billingId);
            request.setAttribute("appointmentDate", appointmentDate);
            
            request.setAttribute("billing", billing);
            request.setAttribute("installments", installments);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/patientViewBillingDetails.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading billing: " + e.getMessage());
            listPatientBillings(request, response);
        }
    }
    
    private void viewPatientInstallments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String billingId = request.getParameter("billing_id");
        
        if (billingId == null || billingId.trim().isEmpty()) {
            request.setAttribute("error", "Billing ID is required.");
            listPatientBillings(request, response);
            return;
        }
        
        try {
            // Get patient IC from session - stored as "patientId"
            HttpSession session = request.getSession();
            String patientIc = (String) session.getAttribute("patientId");
            
            if (patientIc == null) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            
            // Verify this billing belongs to the patient
            boolean isPatientBilling = billingDAO.isBillingBelongsToPatient(billingId, patientIc);
            if (!isPatientBilling) {
                request.setAttribute("error", "You are not authorized to view this billing.");
                listPatientBillings(request, response);
                return;
            }
            
            Billing billing = billingDAO.getBillingById(billingId);
            List<Installment> installments = billingDAO.getInstallmentsByBillingId(billingId);
            
            request.setAttribute("billing", billing);
            request.setAttribute("installments", installments);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/viewPatientInstallments.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading installments: " + e.getMessage());
            listPatientBillings(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}