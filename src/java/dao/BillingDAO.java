package dao;

import beans.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class BillingDAO {
    
    // Get next billing ID
    public String getNextBillingId() {
        String sql = "SELECT MAX(billing_id) FROM billing";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(1)) + 1;
                return String.format("B%03d", num);
            } else {
                return "B001";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "B001";
        }
    }
    
    // Create billing when appointment is confirmed
    public boolean createBillingForAppointment(String appointmentId, String billingMethod, int numInstallments) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get appointment details
            Appointment appointment = getAppointmentDetails(conn, appointmentId);
            if (appointment == null) {
                throw new SQLException("Appointment not found: " + appointmentId);
            }
            
            // Get treatment price
            BigDecimal treatmentPrice = getTreatmentPriceForAppointment(conn, appointmentId);
            
            // Create billing record
            String billingId = getNextBillingIdFromDB(conn);
            Billing billing = new Billing();
            billing.setBillingId(billingId);
            billing.setBillingAmount(treatmentPrice);
            billing.setBillingStatus("Pending");
            billing.setBillingMethod(billingMethod);
            billing.setAppointmentId(appointmentId);
            
            // Set due date - if installment, set to first installment date, else set to appointment date
            if ("Installment".equalsIgnoreCase(billingMethod)) {
                // Set due date to 30 days from now for installment
                Calendar cal = Calendar.getInstance();
                cal.setTime(new java.util.Date());
                cal.add(Calendar.DAY_OF_MONTH, 30);
                billing.setBillingDuedate(cal.getTime());
            } else {
                // Set due date to appointment date
                billing.setBillingDuedate(appointment.getAppointmentDate());
            }
            
            // Insert billing record
            String billingSql = "INSERT INTO billing (billing_id, billing_amount, billing_duedate, " +
                               "billing_status, billing_method, appointment_id) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(billingSql)) {
                ps.setString(1, billing.getBillingId());
                ps.setBigDecimal(2, billing.getBillingAmount());
                ps.setDate(3, new java.sql.Date(billing.getBillingDuedate().getTime()));
                ps.setString(4, billing.getBillingStatus());
                ps.setString(5, billing.getBillingMethod());
                ps.setString(6, billing.getAppointmentId());
                ps.executeUpdate();
            }
            
            // Create installments if billing method is Installment
            if ("Installment".equalsIgnoreCase(billingMethod) && numInstallments > 0) {
                createInstallments(conn, billing, numInstallments);
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private Appointment getAppointmentDetails(Connection conn, String appointmentId) throws SQLException {
        String sql = "SELECT * FROM appointment WHERE appointment_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Appointment appointment = new Appointment();
                appointment.setAppointmentId(rs.getString("appointment_id"));
                appointment.setAppointmentDate(rs.getDate("appointment_date"));
                appointment.setAppointmentTime(rs.getString("appointment_time"));
                appointment.setAppointmentStatus(rs.getString("appointment_status"));
                appointment.setPatientIc(rs.getString("patient_ic"));
                return appointment;
            }
        }
        return null;
    }
    
    private BigDecimal getTreatmentPriceForAppointment(Connection conn, String appointmentId) throws SQLException {
        // Get treatment ID from appointmenttreatment table
        String treatmentSql = "SELECT t.treatment_price " +
                             "FROM appointmenttreatment at " +
                             "JOIN treatment t ON at.treatment_id = t.treatment_id " +
                             "WHERE at.appointment_id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(treatmentSql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getBigDecimal("treatment_price");
            } else {
                // Default price if treatment not found
                return new BigDecimal("500.00");
            }
        }
    }
    
    private String getNextBillingIdFromDB(Connection conn) throws SQLException {
        String sql = "SELECT MAX(billing_id) FROM billing";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(1)) + 1;
                return String.format("B%03d", num);
            } else {
                return "B001";
            }
        }
    }
    
    private void createInstallments(Connection conn, Billing billing, int numInstallments) throws SQLException {
    BigDecimal installmentAmount = billing.getBillingAmount()
            .divide(new BigDecimal(numInstallments), 2, java.math.RoundingMode.HALF_UP);
    
    String nextInstallmentId = getNextInstallmentIdFromDB(conn);
    
    java.util.Calendar cal = java.util.Calendar.getInstance();
    if (billing.getBillingDuedate() != null) {
        cal.setTime(billing.getBillingDuedate());
    } else {
        // If no due date, start from today
        cal.setTime(new java.util.Date());
    }
    
    // For installment, start from the billing due date
    // First installment due on billing due date
    for (int i = 1; i <= numInstallments; i++) {
        Installment installment = new Installment();
        installment.setInstallmentId(generateInstallmentId(nextInstallmentId, i));
        installment.setNumofinstallment(numInstallments);
        installment.setPaymentAmount(installmentAmount);
        installment.setPaidAmount(BigDecimal.ZERO);
        installment.setRemainingAmount(installmentAmount);
        installment.setPaymentStatus("Pending");
        
        // Set payment dates
        // First installment due on billing due date, subsequent ones monthly
        if (i == 1) {
            // Keep the current date (billing due date)
        } else {
            cal.add(java.util.Calendar.MONTH, 1);
        }
        
        installment.setPaymentDate(new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime()));
        installment.setBillingId(billing.getBillingId());
        
        String sql = "INSERT INTO installment (installment_id, numofinstallment, payment_amount, " +
                    "paid_amount, remaining_amount, payment_status, payment_date, billing_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, installment.getInstallmentId());
            ps.setInt(2, installment.getNumofinstallment());
            ps.setBigDecimal(3, installment.getPaymentAmount());
            ps.setBigDecimal(4, installment.getPaidAmount());
            ps.setBigDecimal(5, installment.getRemainingAmount());
            ps.setString(6, installment.getPaymentStatus());
            ps.setString(7, installment.getPaymentDate());
            ps.setString(8, installment.getBillingId());
            ps.executeUpdate();
        }
    }
}
    
    private String generateInstallmentId(String baseId, int sequence) {
        int num = Integer.parseInt(baseId.substring(1)) + sequence - 1;
        return String.format("I%03d", num);
    }
    
    private String getNextInstallmentIdFromDB(Connection conn) throws SQLException {
        String sql = "SELECT MAX(installment_id) FROM installment";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(1)) + 1;
                return String.format("I%03d", num);
            } else {
                return "I001";
            }
        }
    }
    
    // Get all billings
    public List<Billing> getAllBillings() {
        List<Billing> billings = new ArrayList<>();
        String sql = "SELECT b.*, a.appointment_date, a.patient_ic, a.appointment_status \n" +
                    "FROM billing b \n" +
                    "JOIN appointment a ON b.appointment_id = a.appointment_id \n" +
                    "WHERE a.appointment_status = 'Confirmed'\n" +
                    "ORDER BY b.billing_duedate DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Billing billing = new Billing();
                billing.setBillingId(rs.getString("billing_id"));
                billing.setBillingAmount(rs.getBigDecimal("billing_amount"));
                billing.setBillingDuedate(rs.getDate("billing_duedate"));
                billing.setBillingStatus(rs.getString("billing_status"));
                billing.setBillingMethod(rs.getString("billing_method"));
                billing.setAppointmentId(rs.getString("appointment_id"));
                billings.add(billing);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return billings;
    }
    
    // Get billing by ID
    public Billing getBillingById(String billingId) {
        Billing billing = null;
        String sql = "SELECT b.*, a.appointment_date, a.patient_ic " +
                    "FROM billing b " +
                    "JOIN appointment a ON b.appointment_id = a.appointment_id " +
                    "WHERE b.billing_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, billingId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                billing = new Billing();
                billing.setBillingId(rs.getString("billing_id"));
                billing.setBillingAmount(rs.getBigDecimal("billing_amount"));
                billing.setBillingDuedate(rs.getDate("billing_duedate"));
                billing.setBillingStatus(rs.getString("billing_status"));
                billing.setBillingMethod(rs.getString("billing_method"));
                billing.setAppointmentId(rs.getString("appointment_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return billing;
    }
    
    // Get billings by appointment ID
    public Billing getBillingByAppointmentId(String appointmentId) {
        Billing billing = null;
        String sql = "SELECT * FROM billing WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                billing = new Billing();
                billing.setBillingId(rs.getString("billing_id"));
                billing.setBillingAmount(rs.getBigDecimal("billing_amount"));
                billing.setBillingDuedate(rs.getDate("billing_duedate"));
                billing.setBillingStatus(rs.getString("billing_status"));
                billing.setBillingMethod(rs.getString("billing_method"));
                billing.setAppointmentId(rs.getString("appointment_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return billing;
    }
    
    // Update billing status
    public boolean updateBillingStatus(String billingId, String status) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Update billing status
            String sql = "UPDATE billing SET billing_status = ? WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setString(2, billingId);
                ps.executeUpdate();
            }
            
            // If status is "Paid" and billing method is "Pay at Counter", update due date
            if ("Paid".equalsIgnoreCase(status)) {
                Billing billing = getBillingById(billingId);
                if ("Pay at Counter".equalsIgnoreCase(billing.getBillingMethod())) {
                    String updateDateSql = "UPDATE billing SET billing_duedate = ? WHERE billing_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateDateSql)) {
                        ps.setDate(1, new java.sql.Date(new java.util.Date().getTime()));
                        ps.setString(2, billingId);
                        ps.executeUpdate();
                    }
                }
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // Update billing method
    // Update billing method
public boolean updateBillingMethod(String billingId, String billingMethod, int numInstallments) {
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);
        
        // Get billing details within the same transaction
        Billing billing = getBillingByIdWithinTransaction(conn, billingId);
        if (billing == null) {
            throw new SQLException("Billing not found: " + billingId);
        }
        
        // Update billing method
        String sql = "UPDATE billing SET billing_method = ? WHERE billing_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, billingMethod);
            ps.setString(2, billingId);
            ps.executeUpdate();
        }
        
        // Update billing object with new method
        billing.setBillingMethod(billingMethod);
        
        // If changing to Installment, create installments
        if ("Installment".equalsIgnoreCase(billingMethod)) {
            // Delete existing installments if any
            String deleteSql = "DELETE FROM installment WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setString(1, billingId);
                ps.executeUpdate();
            }
            
            // Update due date to 30 days from now for installment billing
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(new java.util.Date());
            cal.add(java.util.Calendar.DAY_OF_MONTH, 30);
            billing.setBillingDuedate(cal.getTime());
            
            // Update billing due date in database
            String updateDateSql = "UPDATE billing SET billing_duedate = ? WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateDateSql)) {
                ps.setDate(1, new java.sql.Date(billing.getBillingDuedate().getTime()));
                ps.setString(2, billingId);
                ps.executeUpdate();
            }
            
            // Create new installments with correct due date
            createInstallments(conn, billing, numInstallments);
        }
        
        conn.commit();
        return true;
        
    } catch (SQLException e) {
        e.printStackTrace();
        if (conn != null) {
            try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        }
        return false;
    } finally {
        if (conn != null) {
            try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}

// Helper method to get billing within transaction
private Billing getBillingByIdWithinTransaction(Connection conn, String billingId) throws SQLException {
    String sql = "SELECT * FROM billing WHERE billing_id = ?";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, billingId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            Billing billing = new Billing();
            billing.setBillingId(rs.getString("billing_id"));
            billing.setBillingAmount(rs.getBigDecimal("billing_amount"));
            billing.setBillingDuedate(rs.getDate("billing_duedate"));
            billing.setBillingStatus(rs.getString("billing_status"));
            billing.setBillingMethod(rs.getString("billing_method"));
            billing.setAppointmentId(rs.getString("appointment_id"));
            return billing;
        }
    }
    return null;
}
    
    // Get installments by billing ID
    public List<Installment> getInstallmentsByBillingId(String billingId) {
        List<Installment> installments = new ArrayList<>();
        String sql = "SELECT * FROM installment WHERE billing_id = ? ORDER BY payment_date";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, billingId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Installment installment = new Installment();
                installment.setInstallmentId(rs.getString("installment_id"));
                installment.setNumofinstallment(rs.getInt("numofinstallment"));
                installment.setPaymentAmount(rs.getBigDecimal("payment_amount"));
                installment.setPaidAmount(rs.getBigDecimal("paid_amount"));
                installment.setRemainingAmount(rs.getBigDecimal("remaining_amount"));
                installment.setPaymentStatus(rs.getString("payment_status"));
                installment.setPaymentDate(rs.getString("payment_date"));
                installment.setBillingId(rs.getString("billing_id"));
                installments.add(installment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return installments;
    }
    
    // Make installment payment
    public boolean makeInstallmentPayment(String installmentId, BigDecimal paymentAmount) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Get current installment
            String selectSql = "SELECT * FROM installment WHERE installment_id = ?";
            Installment installment = null;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setString(1, installmentId);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    installment = new Installment();
                    installment.setInstallmentId(rs.getString("installment_id"));
                    installment.setPaymentAmount(rs.getBigDecimal("payment_amount"));
                    installment.setPaidAmount(rs.getBigDecimal("paid_amount"));
                    installment.setRemainingAmount(rs.getBigDecimal("remaining_amount"));
                    installment.setPaymentStatus(rs.getString("payment_status"));
                    installment.setBillingId(rs.getString("billing_id"));
                }
            }
            
            if (installment == null) {
                throw new SQLException("Installment not found: " + installmentId);
            }
            
            // Calculate new paid amount and remaining amount
            BigDecimal newPaidAmount = installment.getPaidAmount().add(paymentAmount);
            BigDecimal newRemainingAmount = installment.getPaymentAmount().subtract(newPaidAmount);
            
            // Update installment
            String updateSql = "UPDATE installment SET paid_amount = ?, remaining_amount = ?, " +
                              "payment_status = ? WHERE installment_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setBigDecimal(1, newPaidAmount);
                ps.setBigDecimal(2, newRemainingAmount);
                
                // Update payment status
                String newStatus = newRemainingAmount.compareTo(BigDecimal.ZERO) <= 0 ? "Paid" : "Partial";
                ps.setString(3, newStatus);
                ps.setString(4, installmentId);
                ps.executeUpdate();
            }
            
            // Check if all installments for this billing are paid
            checkAndUpdateBillingStatus(conn, installment.getBillingId());
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void checkAndUpdateBillingStatus(Connection conn, String billingId) throws SQLException {
        // Check if all installments are paid
        String sql = "SELECT COUNT(*) as total, " +
                    "SUM(CASE WHEN payment_status = 'Paid' THEN 1 ELSE 0 END) as paid " +
                    "FROM installment WHERE billing_id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, billingId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                int paid = rs.getInt("paid");
                
                // If all installments are paid, update billing status to Paid
                if (total > 0 && total == paid) {
                    String updateSql = "UPDATE billing SET billing_status = 'Paid' WHERE billing_id = ?";
                    try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setString(1, billingId);
                        updatePs.executeUpdate();
                    }
                }
            }
        }
    }
    
    // Delete billing
    public boolean deleteBilling(String billingId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Delete related installments first
            String deleteInstallmentsSql = "DELETE FROM installment WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteInstallmentsSql)) {
                ps.setString(1, billingId);
                ps.executeUpdate();
            }
            
            // Delete billing
            String deleteBillingSql = "DELETE FROM billing WHERE billing_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteBillingSql)) {
                ps.setString(1, billingId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}