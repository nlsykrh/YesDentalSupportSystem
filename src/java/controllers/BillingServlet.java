package controllers;

import beans.*;
import dao.BillingDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.List;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/BillingServlet")
public class BillingServlet extends HttpServlet {
    private BillingDAO billingDAO;
    private SimpleDateFormat dateFormat;
    
    @Override
    public void init() {
        billingDAO = new BillingDAO();
        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if (action == null) {
            request.setAttribute("error", "No action specified");
            listBillings(request, response);
            return;
        }
        
        switch(action) {
            case "update_status":
                updateBillingStatus(request, response);
                break;
            case "update_method":
                updateBillingMethod(request, response);
                break;
            case "make_payment":
                makeInstallmentPayment(request, response);
                break;
            case "delete":
                deleteBilling(request, response);
                break;
            default:
                request.setAttribute("error", "Invalid action: " + action);
                listBillings(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if (action == null) {
            listBillings(request, response);
            return;
        }
        
        switch(action) {
            case "view":
                viewBilling(request, response);
                break;
            case "edit":
                editBilling(request, response);
                break;
            case "view_installments":
                viewInstallments(request, response);
                break;
            case "make_payment_form":
                showPaymentForm(request, response);
                break;
            default:
                listBillings(request, response);
        }
    }
    
    private void listBillings(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            List<Billing> billings = billingDAO.getAllBillings();
            request.setAttribute("billings", billings);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/viewBilling.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading billings: " + e.getMessage());
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/error.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private void viewBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String billingId = request.getParameter("billing_id");
        
        if (billingId == null || billingId.trim().isEmpty()) {
            request.setAttribute("error", "Billing ID is required.");
            listBillings(request, response);
            return;
        }
        
        try {
            Billing billing = billingDAO.getBillingById(billingId);
            
            if (billing == null) {
                request.setAttribute("error", "Billing not found.");
                listBillings(request, response);
                return;
            }
            
            // Get installments if billing method is Installment
            List<Installment> installments = null;
            if ("Installment".equalsIgnoreCase(billing.getBillingMethod())) {
                installments = billingDAO.getInstallmentsByBillingId(billingId);
            }
            
            request.setAttribute("billing", billing);
            request.setAttribute("installments", installments);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/viewBillingDetails.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading billing: " + e.getMessage());
            listBillings(request, response);
        }
    }
    
    private void editBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String billingId = request.getParameter("billing_id");
        
        if (billingId == null || billingId.trim().isEmpty()) {
            request.setAttribute("error", "Billing ID is required.");
            listBillings(request, response);
            return;
        }
        
        try {
            Billing billing = billingDAO.getBillingById(billingId);
            
            if (billing == null) {
                request.setAttribute("error", "Billing not found.");
                listBillings(request, response);
                return;
            }
            
            request.setAttribute("billing", billing);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/editBilling.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading billing: " + e.getMessage());
            listBillings(request, response);
        }
    }
    
    private void viewInstallments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String billingId = request.getParameter("billing_id");
        
        if (billingId == null || billingId.trim().isEmpty()) {
            request.setAttribute("error", "Billing ID is required.");
            listBillings(request, response);
            return;
        }
        
        try {
            Billing billing = billingDAO.getBillingById(billingId);
            List<Installment> installments = billingDAO.getInstallmentsByBillingId(billingId);
            
            request.setAttribute("billing", billing);
            request.setAttribute("installments", installments);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/viewInstallments.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading installments: " + e.getMessage());
            listBillings(request, response);
        }
    }
    
    private void showPaymentForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String installmentId = request.getParameter("installment_id");
        
        if (installmentId == null || installmentId.trim().isEmpty()) {
            request.setAttribute("error", "Installment ID is required.");
            listBillings(request, response);
            return;
        }
        
        try {
            // Get installment details
            // Note: You'll need to add a method to get installment by ID in BillingDAO
            // For now, we'll forward to the form with the ID
            request.setAttribute("installment_id", installmentId);
            
            RequestDispatcher dispatcher = 
                request.getRequestDispatcher("/billing/makePayment.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading payment form: " + e.getMessage());
            listBillings(request, response);
        }
    }
    
    private void updateBillingStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String billingId = request.getParameter("billing_id");
            String status = request.getParameter("billing_status");
            
            if (billingId == null || billingId.trim().isEmpty()) {
                throw new Exception("Billing ID is required");
            }
            
            if (status == null || status.trim().isEmpty()) {
                throw new Exception("Billing status is required");
            }
            
            boolean success = billingDAO.updateBillingStatus(billingId, status);
            
            if (success) {
                request.setAttribute("message", "Billing status updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update billing status.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        listBillings(request, response);
    }
    
    private void updateBillingMethod(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String billingId = request.getParameter("billing_id");
            String billingMethod = request.getParameter("billing_method");
            String installmentsStr = request.getParameter("num_installments");
            
            if (billingId == null || billingId.trim().isEmpty()) {
                throw new Exception("Billing ID is required");
            }
            
            if (billingMethod == null || billingMethod.trim().isEmpty()) {
                throw new Exception("Billing method is required");
            }
            
            int numInstallments = 1;
            if ("Installment".equalsIgnoreCase(billingMethod)) {
                if (installmentsStr == null || installmentsStr.trim().isEmpty()) {
                    throw new Exception("Number of installments is required for installment payment");
                }
                
                try {
                    numInstallments = Integer.parseInt(installmentsStr);
                    if (numInstallments < 1 || numInstallments > 5) {
                        throw new Exception("Number of installments must be between 1 and 5");
                    }
                } catch (NumberFormatException e) {
                    throw new Exception("Invalid number of installments");
                }
            }
            
            boolean success = billingDAO.updateBillingMethod(billingId, billingMethod, numInstallments);
            
            if (success) {
                request.setAttribute("message", "Billing method updated successfully!");
            } else {
                request.setAttribute("error", "Failed to update billing method.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        listBillings(request, response);
    }
    
    private void makeInstallmentPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String installmentId = request.getParameter("installment_id");
            String paymentAmountStr = request.getParameter("payment_amount");
            
            if (installmentId == null || installmentId.trim().isEmpty()) {
                throw new Exception("Installment ID is required");
            }
            
            if (paymentAmountStr == null || paymentAmountStr.trim().isEmpty()) {
                throw new Exception("Payment amount is required");
            }
            
            BigDecimal paymentAmount;
            try {
                paymentAmount = new BigDecimal(paymentAmountStr);
                if (paymentAmount.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new Exception("Payment amount must be greater than 0");
                }
            } catch (NumberFormatException e) {
                throw new Exception("Invalid payment amount format");
            }
            
            boolean success = billingDAO.makeInstallmentPayment(installmentId, paymentAmount);
            
            if (success) {
                request.setAttribute("message", "Payment processed successfully!");
            } else {
                request.setAttribute("error", "Failed to process payment.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        listBillings(request, response);
    }
    
    private void deleteBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            String billingId = request.getParameter("billing_id");
            
            if (billingId == null || billingId.trim().isEmpty()) {
                throw new Exception("Billing ID is required");
            }
            
            boolean success = billingDAO.deleteBilling(billingId);
            
            if (success) {
                request.setAttribute("message", "Billing deleted successfully!");
            } else {
                request.setAttribute("error", "Failed to delete billing.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        listBillings(request, response);
    }
}