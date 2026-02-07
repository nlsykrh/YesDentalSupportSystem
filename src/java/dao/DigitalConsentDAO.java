package dao;

import beans.DigitalConsent;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DigitalConsentDAO {
    
    // Get next consent ID
    public String getNextConsentId() {
        String sql = "SELECT MAX(consent_id) FROM digitalconsent";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("CID%03d", num);
            } else {
                return "CID001";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "CID001";
        }
    }
    
    public boolean addDigitalConsent(DigitalConsent consent) {
        String sql = "INSERT INTO digitalconsent (consent_id, patient_ic, consent_context, consent_signdate, appointment_id) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, consent.getConsentId());
            ps.setString(2, consent.getPatientIc());
            ps.setString(3, consent.getConsentContext());
            ps.setTimestamp(4, new Timestamp(consent.getConsentSigndate().getTime()));
            ps.setString(5, consent.getAppointmentId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    
    // Get consent by patient IC
    public List<DigitalConsent> getConsentsByPatientIc(String patientIc) {
        List<DigitalConsent> consents = new ArrayList<>();
        String sql = "SELECT * FROM digitalconsent WHERE patient_ic = ? ORDER BY consent_signdate DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, patientIc);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                DigitalConsent consent = new DigitalConsent();
                consent.setConsentId(rs.getString("consent_id"));
                consent.setPatientIc(rs.getString("patient_ic"));
                consent.setConsentContext(rs.getString("consent_context"));
                consent.setConsentSigndate(rs.getTimestamp("consent_signdate"));
                consents.add(consent);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return consents;
    }
    
    // Get consent by appointment ID (through patient)
    public DigitalConsent getConsentByAppointmentId(String appointmentId) {
        String sql = "SELECT * FROM digitalconsent WHERE appointment_id = ? ORDER BY consent_signdate DESC FETCH FIRST 1 ROWS ONLY";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                DigitalConsent consent = new DigitalConsent();
                consent.setConsentId(rs.getString("consent_id"));
                consent.setPatientIc(rs.getString("patient_ic"));
                consent.setConsentContext(rs.getString("consent_context"));
                consent.setConsentSigndate(rs.getTimestamp("consent_signdate"));
                return consent;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Check if consent exists for appointment
    public boolean hasConsentForAppointment(String appointmentId) {
        String sql = "SELECT COUNT(*) FROM digitalconsent WHERE appointment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}