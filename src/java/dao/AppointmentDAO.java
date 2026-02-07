package dao;

import beans.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {
    
    // Get next appointment ID
    public String getNextAppointmentId() {
        String sql = "SELECT MAX(appointment_id) FROM appointment";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("APP%03d", num);
            } else {
                return "APP001";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "APP001";
        }
    }
    
    // Add appointment with all related records
    public boolean addAppointment(Appointment appointment, String treatmentId, 
                                  String billingMethod, int numInstallments) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Insert into appointment table
            String appSql = "INSERT INTO appointment (appointment_id, appointment_date, appointment_time, " +
                           "appointment_status, remarks, patient_ic) VALUES (?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(appSql)) {
                ps.setString(1, appointment.getAppointmentId());
                ps.setDate(2, new java.sql.Date(appointment.getAppointmentDate().getTime()));
                ps.setString(3, appointment.getAppointmentTime());
                ps.setString(4, appointment.getAppointmentStatus());
                ps.setString(5, appointment.getRemarks());
                ps.setString(6, appointment.getPatientIc());
                ps.executeUpdate();
            }
            
            // 2. Insert into appointmenttreatment table
            String atSql = "INSERT INTO appointmenttreatment (appointment_id, treatment_id, appointment_date) " +
                          "VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(atSql)) {
                ps.setString(1, appointment.getAppointmentId());
                ps.setString(2, treatmentId);
                ps.setDate(3, new java.sql.Date(appointment.getAppointmentDate().getTime()));
                ps.executeUpdate();
            }
            
            // 3. If status is "confirmed", create billing and consent
            if ("confirmed".equalsIgnoreCase(appointment.getAppointmentStatus())) {
                // Create billing
                Billing billing = createBilling(appointment, treatmentId, billingMethod);
                String billId = getNextBillingId(conn);
                billing.setBillingId(billId);
                
                String billSql = "INSERT INTO billing (billing_id, billing_amount, billing_duedate, " +
                                "billing_status, billing_method, appointment_id) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(billSql)) {
                    ps.setString(1, billing.getBillingId());
                    ps.setBigDecimal(2, billing.getBillingAmount());
                    ps.setDate(3, new java.sql.Date(billing.getBillingDuedate().getTime()));
                    ps.setString(4, billing.getBillingStatus());
                    ps.setString(5, billing.getBillingMethod());
                    ps.setString(6, billing.getAppointmentId());
                    ps.executeUpdate();
                }
                
                // Create digital consent
                DigitalConsent consent = createDigitalConsent(appointment, treatmentId);
                String consentId = getNextConsentId(conn);
                consent.setConsentId(consentId);
                
                String consentSql = "INSERT INTO digitalconsent (consent_id, patient_ic, consent_context, " +
                                   "consent_signdate) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(consentSql)) {
                    ps.setString(1, consent.getConsentId());
                    ps.setString(2, consent.getPatientIc());
                    ps.setString(3, consent.getConsentContext());
                    ps.setTimestamp(4, new java.sql.Timestamp(consent.getConsentSigndate().getTime()));
                    ps.executeUpdate();
                }
                
                // Create installments if billing method is installment
                if ("installment".equalsIgnoreCase(billingMethod) && numInstallments > 0) {
                    createInstallments(conn, billing, numInstallments);
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
    
    private Billing createBilling(Appointment appointment, String treatmentId, String billingMethod) {
        Billing billing = new Billing();
        billing.setAppointmentId(appointment.getAppointmentId());
        billing.setBillingMethod(billingMethod);
        billing.setBillingStatus("pending");
        
        // Get treatment price (you need to implement this based on your treatment table)
        BigDecimal amount = getTreatmentPrice(treatmentId);
        billing.setBillingAmount(amount);
        
        // Set due date as appointment date
        billing.setBillingDuedate(appointment.getAppointmentDate());
        
        return billing;
    }
    
    private DigitalConsent createDigitalConsent(Appointment appointment, String treatmentId) {
        DigitalConsent consent = new DigitalConsent();
        consent.setPatientIc(appointment.getPatientIc());
        consent.setConsentContext("Consent for treatment " + treatmentId + " on appointment " + 
                                 appointment.getAppointmentId());
        consent.setConsentSigndate(new java.util.Date());
        return consent;
    }
    
    private void createInstallments(Connection conn, Billing billing, int numInstallments) 
            throws SQLException {
        BigDecimal installmentAmount = billing.getBillingAmount()
                .divide(new BigDecimal(numInstallments), 2, java.math.RoundingMode.HALF_UP);
        
        String nextInstallmentId = getNextInstallmentId(conn);
        
        for (int i = 1; i <= numInstallments; i++) {
            Installment installment = new Installment();
            installment.setInstallmentId(generateInstallmentId(nextInstallmentId, i));
            installment.setNumofinstallment(numInstallments);
            
            // Calculate payment dates (example: 1 month apart starting from billing due date)
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(billing.getBillingDuedate());
            cal.add(java.util.Calendar.MONTH, i - 1);
            installment.setPaymentDate(new java.text.SimpleDateFormat("dd-MM-yyyy").format(cal.getTime()));
            
            installment.setPaymentStatus("pending");
            installment.setPaymentAmount(installmentAmount);
            
            String sql = "INSERT INTO installment (installment_id, numofinstallment, payment_date, " +
                        "payment_status, payment_amount) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, installment.getInstallmentId());
                ps.setInt(2, installment.getNumofinstallment());
                ps.setString(3, installment.getPaymentDate());
                ps.setString(4, installment.getPaymentStatus());
                ps.setBigDecimal(5, installment.getPaymentAmount());
                ps.executeUpdate();
            }
        }
    }
    
    private String generateInstallmentId(String baseId, int sequence) {
        int num = Integer.parseInt(baseId.substring(1)) + sequence - 1;
        return String.format("I%03d", num);
    }
    
    private String getNextBillingId(Connection conn) throws SQLException {
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
    
    private String getNextConsentId(Connection conn) throws SQLException {
        String sql = "SELECT MAX(consent_id) FROM digitalconsent";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("CID%03d", num);
            } else {
                return "CID001";
            }
        }
    }
    
    private String getNextInstallmentId(Connection conn) throws SQLException {
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
    
    private BigDecimal getTreatmentPrice(String treatmentId) {
        // You need to implement this based on your treatment table
        // This is a placeholder - replace with actual database query
        return new BigDecimal("500.00");
    }
    
    // Get all appointments
    public List<Appointment> getAllAppointments() {
        List<Appointment> appointments = new ArrayList<>();
        String sql = "SELECT * FROM appointment ORDER BY appointment_date DESC, appointment_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Appointment appointment = new Appointment();
                appointment.setAppointmentId(rs.getString("appointment_id"));
                appointment.setAppointmentDate(rs.getDate("appointment_date"));
                appointment.setAppointmentTime(rs.getString("appointment_time"));
                appointment.setAppointmentStatus(rs.getString("appointment_status"));
                appointment.setRemarks(rs.getString("remarks"));
                appointment.setPatientIc(rs.getString("patient_ic"));
                appointments.add(appointment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return appointments;
    }
    
    // Get appointment by ID
    public Appointment getAppointmentById(String appointmentId) {
        Appointment appointment = null;
        String sql = "SELECT * FROM appointment WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                appointment = new Appointment();
                appointment.setAppointmentId(rs.getString("appointment_id"));
                appointment.setAppointmentDate(rs.getDate("appointment_date"));
                appointment.setAppointmentTime(rs.getString("appointment_time"));
                appointment.setAppointmentStatus(rs.getString("appointment_status"));
                appointment.setRemarks(rs.getString("remarks"));
                appointment.setPatientIc(rs.getString("patient_ic"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return appointment;
    }
    
    // Update appointment status
    public boolean updateAppointmentStatus(String appointmentId, String status) {
        String sql = "UPDATE appointment SET appointment_status = ? WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setString(2, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete appointment
    public boolean deleteAppointment(String appointmentId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Delete from related tables first
            String[] sqls = {
                "DELETE FROM appointmenttreatment WHERE appointment_id = ?",
                "DELETE FROM billing WHERE appointment_id = ?",
                "DELETE FROM appointment WHERE appointment_id = ?"
            };
            
            for (String sql : sqls) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, appointmentId);
                    ps.executeUpdate();
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
    
    // Get treatments for an appointment
    public List<AppointmentTreatment> getAppointmentTreatments(String appointmentId) {
        List<AppointmentTreatment> treatments = new ArrayList<>();
        String sql = "SELECT * FROM appointmenttreatment WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                AppointmentTreatment treatment = new AppointmentTreatment();
                treatment.setAppointmentId(rs.getString("appointment_id"));
                treatment.setTreatmentId(rs.getString("treatment_id"));
                treatment.setAppointmentDate(rs.getDate("appointment_date"));
                treatments.add(treatment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return treatments;
    }
    
    // ===== AppointmentDAO.java (ADD / REPLACE THESE METHODS ONLY) =====

// 1) REPLACE your getBookedTimesConfirmed with this (fixes 14:00:00 vs 14:00)
public List<String> getBookedTimesConfirmed(String dateStr) {
    List<String> times = new ArrayList<>();

    String sql = "SELECT appointment_time FROM appointment " +
                 "WHERE appointment_date = ? " +
                 "AND LOWER(appointment_status) = 'confirmed'";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setDate(1, java.sql.Date.valueOf(dateStr));
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String t = rs.getString("appointment_time"); // e.g. 14:00:00
            if (t != null && t.length() >= 5) t = t.substring(0, 5); // -> 14:00
            times.add(t);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return times;
}

// 2) ADD this new method (returns FULLY booked dates in that month)
public List<String> getFullyBookedDates(String monthStr) {
    List<String> dates = new ArrayList<>();

    String sql =
        "SELECT appointment_date " +
        "FROM appointment " +
        "WHERE LOWER(appointment_status) = 'confirmed' " +
        "AND appointment_date >= ? AND appointment_date < ? " +
        "GROUP BY appointment_date " +
        "HAVING COUNT(DISTINCT appointment_time) >= 6";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        java.time.LocalDate firstDay = java.time.LocalDate.parse(monthStr + "-01");
        java.time.LocalDate nextMonth = firstDay.plusMonths(1);

        ps.setDate(1, java.sql.Date.valueOf(firstDay));
        ps.setDate(2, java.sql.Date.valueOf(nextMonth));

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            dates.add(rs.getDate("appointment_date").toString()); // yyyy-MM-dd
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return dates;
}



public boolean isConfirmedSlotTaken(java.util.Date date, String time) {
    String sql = "SELECT COUNT(*) FROM appointment " +
                 "WHERE appointment_date = ? " +
                 "AND appointment_time = ? " +
                 "AND LOWER(appointment_status) = 'confirmed'";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setDate(1, new java.sql.Date(date.getTime()));
        ps.setString(2, time);

        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;

    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}


}