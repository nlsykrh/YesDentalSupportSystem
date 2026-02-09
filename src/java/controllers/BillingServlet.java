package controllers;

import beans.*;
import dao.BillingDAO;
import dao.DBConnection;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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
            case "update_billing":
                updateBilling(request, response);
                break;
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
    
    private void updateBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Connection conn = null;
        try {
            String billingId = request.getParameter("billing_id");
            String billingStatus = request.getParameter("billing_status");
            String billingMethod = request.getParameter("billing_method");
            String installmentsStr = request.getParameter("num_installments");
            String installmentDatesStr = request.getParameter("installment_dates");
            
            if (billingId == null || billingId.trim().isEmpty())
                throw new Exception("Billing ID is required");
            
            if (billingStatus == null || billingStatus.trim().isEmpty())
                throw new Exception("Billing status is required");
            
            if (billingMethod == null || billingMethod.trim().isEmpty())
                throw new Exception("Billing method is required");
            
            int numInstallments = 1;
            List<String> installmentDates = new ArrayList<>();
            
            if ("Installment".equalsIgnoreCase(billingMethod)) {
                if (installmentsStr == null || installmentsStr.trim().isEmpty())
                    throw new Exception("Number of installments required");
                
                numInstallments = Integer.parseInt(installmentsStr);
                
                if (numInstallments < 1 || numInstallments > 5)
                    throw new Exception("Installments must be between 1–5");
                
                // Parse installment dates
                if (installmentDatesStr != null && !installmentDatesStr.trim().isEmpty()) {
                    String[] dates = installmentDatesStr.split(",");
                    if (dates.length != numInstallments) {
                        throw new Exception("Number of dates must match number of installments");
                    }
                    
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    sdf.setLenient(false);
                    
                    for (String date : dates) {
                        try {
                            sdf.parse(date.trim()); // Validate date format
                            installmentDates.add(date.trim());
                        } catch (Exception e) {
                            throw new Exception("Invalid date format for installment: " + date);
                        }
                    }
                } else {
                    throw new Exception("Installment dates are required");
                }
            }
            
            // Get database connection
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // First, get the billing amount
            BigDecimal billingAmount = getBillingAmount(conn, billingId);
            
            // Update billing status and method
            String updateSql = "UPDATE billing SET billing_status = ?, billing_method = ? WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, billingStatus);
                ps.setString(2, billingMethod);
                ps.setString(3, billingId);
                ps.executeUpdate();
            }
            
            // Handle installment creation/deletion based on payment method
            if ("Installment".equalsIgnoreCase(billingMethod)) {
                // Delete existing installments
                String deleteSql = "DELETE FROM installment WHERE billing_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setString(1, billingId);
                    ps.executeUpdate();
                }
                
                // Calculate installment amount
                BigDecimal installmentAmount = billingAmount.divide(
                    new BigDecimal(numInstallments), 2, java.math.RoundingMode.HALF_UP);
                
                // Get next installment ID
                String nextInstallmentId = getNextInstallmentId(conn);
                
                // Create new installments with specified dates
                for (int i = 0; i < numInstallments; i++) {
                    String installmentId = generateInstallmentId(nextInstallmentId, i);
                    
                    String insertSql = "INSERT INTO installment " +
                                      "(installment_id, numofinstallment, payment_amount, " +
                                      "paid_amount, remaining_amount, payment_status, payment_date, billing_id) " +
                                      "VALUES (?, ?, ?, 0, ?, 'Pending', ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        ps.setString(1, installmentId);
                        ps.setInt(2, numInstallments);
                        ps.setBigDecimal(3, installmentAmount);
                        ps.setBigDecimal(4, installmentAmount); // remaining_amount initially equals payment_amount
                        ps.setString(5, installmentDates.get(i));
                        ps.setString(6, billingId);
                        ps.executeUpdate();
                    }
                }
            } else {
                // If NOT Installment, delete any existing installments
                String deleteSql = "DELETE FROM installment WHERE billing_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setString(1, billingId);
                    ps.executeUpdate();
                }
            }
            
            conn.commit();
            request.setAttribute("success", "Billing updated successfully!");
            
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            request.setAttribute("error", "Error: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true); 
                    conn.close(); 
                } catch (SQLException e) { 
                    e.printStackTrace(); 
                }
            }
        }
        
        // Redirect back to edit page to show updated data
        editBilling(request, response);
    }
    
    private BigDecimal getBillingAmount(Connection conn, String billingId) throws SQLException {
        String sql = "SELECT billing_amount FROM billing WHERE billing_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, billingId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal("billing_amount");
            }
        }
        throw new SQLException("Billing not found with ID: " + billingId);
    }
    
    private String getNextInstallmentId(Connection conn) throws SQLException {
        String sql = "SELECT MAX(installment_id) FROM installment";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                // Extract numeric part and increment
                String numericPart = lastId.substring(1); // Remove 'I' prefix
                int num = Integer.parseInt(numericPart) + 1;
                return String.format("I%03d", num);
            } else {
                return "I001";
            }
        }
    }
    
    private String generateInstallmentId(String baseId, int sequence) {
        // Parse base ID (e.g., "I001") to get the starting number
        String numericPart = baseId.substring(1); // Remove 'I' prefix
        int startNum = Integer.parseInt(numericPart);
        
        // Generate sequential ID
        int newNum = startNum + sequence;
        return String.format("I%03d", newNum);
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
            // Get installment details from DAO
            List<Installment> installments = billingDAO.getInstallmentsByInstallmentId(installmentId);
            if (installments == null || installments.isEmpty()) {
                request.setAttribute("error", "Installment not found.");
                listBillings(request, response);
                return;
            }
            
            Installment installment = installments.get(0);
            request.setAttribute("installment", installment);
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
                request.setAttribute("success", "Billing status updated successfully!");
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
                request.setAttribute("success", "Billing method updated successfully!");
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
                request.setAttribute("success", "Payment processed successfully!");
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
                request.setAttribute("success", "Billing deleted successfully!");
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