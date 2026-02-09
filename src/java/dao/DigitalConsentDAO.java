package dao;

import beans.DigitalConsent;
import java.sql.*;

public class DigitalConsentDAO {

    // ✅ Get next consent ID
    public String getNextConsentId() {
        String sql = "SELECT MAX(consent_id) FROM digitalconsent";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1).trim(); // CID001
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("CID%03d", num);
            }
            return "CID001";

        } catch (SQLException e) {
            e.printStackTrace();
            return "CID001";
        }
    }

    // ✅ Insert consent (unsigned allowed)
    public boolean addDigitalConsent(DigitalConsent consent) {
        String sql = "INSERT INTO digitalconsent (consent_id, patient_ic, consent_context, consent_signdate, appointment_id) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, consent.getConsentId());
            ps.setString(2, consent.getPatientIc());
            ps.setString(3, consent.getConsentContext());

            if (consent.getConsentSigndate() == null) {
                ps.setNull(4, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(4, new Timestamp(consent.getConsentSigndate().getTime()));
            }

            ps.setString(5, consent.getAppointmentId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Get consent by appointment id
    public DigitalConsent getConsentByAppointmentId(String appointmentId) {
        String sql =
            "SELECT consent_id, patient_ic, consent_context, consent_signdate, appointment_id " +
            "FROM digitalconsent WHERE TRIM(appointment_id) = ? " +
            "FETCH FIRST 1 ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId == null ? "" : appointmentId.trim());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                DigitalConsent dc = new DigitalConsent();
                dc.setConsentId(rs.getString("consent_id"));
                dc.setPatientIc(rs.getString("patient_ic"));
                dc.setConsentContext(rs.getString("consent_context"));

                Timestamp ts = rs.getTimestamp("consent_signdate");
                dc.setConsentSigndate(ts != null ? new java.util.Date(ts.getTime()) : null);

                dc.setAppointmentId(rs.getString("appointment_id"));
                return dc;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // ✅ Sign consent (set timestamp)
    public boolean signConsent(String appointmentId) {
        String sql =
            "UPDATE digitalconsent SET consent_signdate = CURRENT_TIMESTAMP " +
            "WHERE TRIM(appointment_id) = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId == null ? "" : appointmentId.trim());
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
