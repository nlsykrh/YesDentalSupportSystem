package dao;

import beans.*;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    // =========================
    // ID GENERATION
    // =========================
    public String getNextAppointmentId() {
        String sql = "SELECT MAX(APPOINTMENT_ID) FROM APPOINTMENT";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1);   // e.g. APP005
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

    // =========================
    // ADD APPOINTMENT (TRANSACTION)
    // =========================
    public boolean addAppointment(Appointment appointment, String treatmentId,
                                  String billingMethod, int numInstallments) {

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1) Insert APPOINTMENT
            String appSql =
                    "INSERT INTO APPOINTMENT (APPOINTMENT_ID, APPOINTMENT_DATE, APPOINTMENT_TIME, " +
                            "APPOINTMENT_STATUS, REMARKS, PATIENT_IC) VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(appSql)) {
                ps.setString(1, appointment.getAppointmentId());
                ps.setDate(2, new java.sql.Date(appointment.getAppointmentDate().getTime()));
                ps.setString(3, appointment.getAppointmentTime());
                ps.setString(4, appointment.getAppointmentStatus());
                ps.setString(5, appointment.getRemarks());
                ps.setString(6, appointment.getPatientIc());
                ps.executeUpdate();
            }

            // 2) Insert APPOINTMENTTREATMENT
            String atSql =
                    "INSERT INTO APPOINTMENTTREATMENT (APPOINTMENT_ID, TREATMENT_ID, APPOINTMENT_DATE) " +
                            "VALUES (?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(atSql)) {
                ps.setString(1, appointment.getAppointmentId());
                ps.setString(2, treatmentId);
                ps.setDate(3, new java.sql.Date(appointment.getAppointmentDate().getTime()));
                ps.executeUpdate();
            }

            // 3) If CONFIRMED -> create billing & consent & installments
            if ("Confirmed".equalsIgnoreCase(appointment.getAppointmentStatus())) {

                Billing billing = createBilling(appointment, treatmentId, billingMethod);
                String billId = getNextBillingId(conn);
                billing.setBillingId(billId);

                String billSql =
                        "INSERT INTO BILLING (BILLING_ID, BILLING_AMOUNT, BILLING_DUEDATE, " +
                                "BILLING_STATUS, BILLING_METHOD, APPOINTMENT_ID) VALUES (?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(billSql)) {
                    ps.setString(1, billing.getBillingId());
                    ps.setBigDecimal(2, billing.getBillingAmount());
                    ps.setDate(3, new java.sql.Date(billing.getBillingDuedate().getTime()));
                    ps.setString(4, billing.getBillingStatus());
                    ps.setString(5, billing.getBillingMethod());
                    ps.setString(6, billing.getAppointmentId());
                    ps.executeUpdate();
                }

                // ⚠️ NOTE:
                // If your DIGITALCONSENT table has APPOINTMENT_ID column, you must include it here.
                // Your current insert does NOT include APPOINTMENT_ID.
                DigitalConsent consent = createDigitalConsent(appointment, treatmentId);
                String consentId = getNextConsentId(conn);
                consent.setConsentId(consentId);

                String consentSql =
                        "INSERT INTO DIGITALCONSENT (CONSENT_ID, PATIENT_IC, CONSENT_CONTEXT, CONSENT_SIGNDATE) " +
                                "VALUES (?, ?, ?, ?)";

                try (PreparedStatement ps = conn.prepareStatement(consentSql)) {
                    ps.setString(1, consent.getConsentId());
                    ps.setString(2, consent.getPatientIc());
                    ps.setString(3, consent.getConsentContext());
                    ps.setTimestamp(4, new Timestamp(consent.getConsentSigndate().getTime()));
                    ps.executeUpdate();
                }

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
        billing.setBillingStatus("Pending");

        BigDecimal amount = getTreatmentPrice(treatmentId);
        billing.setBillingAmount(amount);

        billing.setBillingDuedate(appointment.getAppointmentDate());
        return billing;
    }

    private DigitalConsent createDigitalConsent(Appointment appointment, String treatmentId) {
        DigitalConsent consent = new DigitalConsent();
        consent.setPatientIc(appointment.getPatientIc());
        consent.setConsentContext("Consent for treatment " + treatmentId + " (Appointment " + appointment.getAppointmentId() + ")");
        consent.setConsentSigndate(new java.util.Date());
        return consent;
    }

    private void createInstallments(Connection conn, Billing billing, int numInstallments) throws SQLException {
        BigDecimal installmentAmount = billing.getBillingAmount()
                .divide(new BigDecimal(numInstallments), 2, java.math.RoundingMode.HALF_UP);

        String baseId = getNextInstallmentId(conn);

        for (int i = 1; i <= numInstallments; i++) {
            Installment installment = new Installment();
            installment.setInstallmentId(generateInstallmentId(baseId, i));
            installment.setNumofinstallment(numInstallments);

            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(billing.getBillingDuedate());
            cal.add(java.util.Calendar.MONTH, i - 1);
            installment.setPaymentDate(new java.text.SimpleDateFormat("dd-MM-yyyy").format(cal.getTime()));

            installment.setPaymentStatus("Pending");
            installment.setPaymentAmount(installmentAmount);

            String sql =
                    "INSERT INTO INSTALLMENT (INSTALLMENT_ID, NUMOFINSTALLMENT, PAYMENT_DATE, PAYMENT_STATUS, PAYMENT_AMOUNT) " +
                            "VALUES (?, ?, ?, ?, ?)";

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
        String sql = "SELECT MAX(BILLING_ID) FROM BILLING";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1); // B001
                int num = Integer.parseInt(lastId.substring(1)) + 1;
                return String.format("B%03d", num);
            } else {
                return "B001";
            }
        }
    }

    private String getNextConsentId(Connection conn) throws SQLException {
        String sql = "SELECT MAX(CONSENT_ID) FROM DIGITALCONSENT";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1); // CID001
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("CID%03d", num);
            } else {
                return "CID001";
            }
        }
    }

    private String getNextInstallmentId(Connection conn) throws SQLException {
        String sql = "SELECT MAX(INSTALLMENT_ID) FROM INSTALLMENT";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1); // I001
                int num = Integer.parseInt(lastId.substring(1)) + 1;
                return String.format("I%03d", num);
            } else {
                return "I001";
            }
        }
    }

    private BigDecimal getTreatmentPrice(String treatmentId) {
        // TODO: Replace with actual query from TREATMENT table if you have it
        return new BigDecimal("500.00");
    }

    // =========================
    // LIST
    // =========================
    public List<Appointment> getAppointmentsByPatientIc(String patientIc) {
        List<Appointment> appointments = new ArrayList<>();

        String sql =
                "SELECT APPOINTMENT_ID, APPOINTMENT_DATE, APPOINTMENT_TIME, APPOINTMENT_STATUS, REMARKS, PATIENT_IC " +
                        "FROM APPOINTMENT " +
                        "WHERE PATIENT_IC = ? " +
                        "ORDER BY APPOINTMENT_DATE DESC, APPOINTMENT_TIME DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patientIc);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                a.setAppointmentDate(rs.getDate("APPOINTMENT_DATE"));
                a.setAppointmentTime(rs.getString("APPOINTMENT_TIME"));
                a.setAppointmentStatus(rs.getString("APPOINTMENT_STATUS"));
                a.setRemarks(rs.getString("REMARKS"));
                a.setPatientIc(rs.getString("PATIENT_IC"));
                appointments.add(a);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return appointments;
    }

    public List<Appointment> getAllAppointments() {
        List<Appointment> appointments = new ArrayList<>();

        String sql =
                "SELECT APPOINTMENT_ID, APPOINTMENT_DATE, APPOINTMENT_TIME, APPOINTMENT_STATUS, REMARKS, PATIENT_IC " +
                        "FROM APPOINTMENT " +
                        "ORDER BY APPOINTMENT_DATE DESC, APPOINTMENT_TIME DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            ResultSet rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Appointment a = new Appointment();
                a.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                a.setAppointmentDate(rs.getDate("APPOINTMENT_DATE"));
                a.setAppointmentTime(rs.getString("APPOINTMENT_TIME"));
                a.setAppointmentStatus(rs.getString("APPOINTMENT_STATUS"));
                a.setRemarks(rs.getString("REMARKS"));
                a.setPatientIc(rs.getString("PATIENT_IC"));
                appointments.add(a);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return appointments;
    }

    // =========================
    // GET BY ID
    // =========================
    public Appointment getAppointmentById(String appointmentId) {
        Appointment appointment = null;

        String sql =
                "SELECT APPOINTMENT_ID, APPOINTMENT_DATE, APPOINTMENT_TIME, APPOINTMENT_STATUS, REMARKS, PATIENT_IC " +
                        "FROM APPOINTMENT WHERE APPOINTMENT_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                appointment = new Appointment();
                appointment.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                appointment.setAppointmentDate(rs.getDate("APPOINTMENT_DATE"));
                appointment.setAppointmentTime(rs.getString("APPOINTMENT_TIME"));
                appointment.setAppointmentStatus(rs.getString("APPOINTMENT_STATUS"));
                appointment.setRemarks(rs.getString("REMARKS"));
                appointment.setPatientIc(rs.getString("PATIENT_IC"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return appointment;
    }

    // =========================
    // UPDATE STATUS
    // =========================
    public boolean updateAppointmentStatus(String appointmentId, String status) {
        String sql = "UPDATE APPOINTMENT SET APPOINTMENT_STATUS = ? WHERE APPOINTMENT_ID = ?";

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

    // ✅ UPDATE FULL
    public boolean updateAppointment(String appointmentId, java.util.Date date, String time, String status, String remarks) {
        String sql =
                "UPDATE APPOINTMENT " +
                        "SET APPOINTMENT_DATE=?, APPOINTMENT_TIME=?, APPOINTMENT_STATUS=?, REMARKS=? " +
                        "WHERE APPOINTMENT_ID=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, new java.sql.Date(date.getTime()));
            ps.setString(2, time);
            ps.setString(3, status);
            ps.setString(4, remarks);
            ps.setString(5, appointmentId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // =========================
    // DELETE
    // =========================
    public boolean deleteAppointment(String appointmentId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String[] sqls = {
                    "DELETE FROM APPOINTMENTTREATMENT WHERE APPOINTMENT_ID = ?",
                    "DELETE FROM BILLING WHERE APPOINTMENT_ID = ?",
                    "DELETE FROM APPOINTMENT WHERE APPOINTMENT_ID = ?"
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

    // =========================
    // APPOINTMENT TREATMENTS
    // =========================
    public List<AppointmentTreatment> getAppointmentTreatments(String appointmentId) {
        List<AppointmentTreatment> treatments = new ArrayList<>();

        String sql =
                "SELECT APPOINTMENT_ID, TREATMENT_ID, APPOINTMENT_DATE " +
                        "FROM APPOINTMENTTREATMENT WHERE APPOINTMENT_ID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AppointmentTreatment t = new AppointmentTreatment();
                t.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                t.setTreatmentId(rs.getString("TREATMENT_ID"));
                t.setAppointmentDate(rs.getDate("APPOINTMENT_DATE"));
                treatments.add(t);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return treatments;
    }

    // =========================
    // SLOT CHECKS / CALENDAR HELPERS
    // =========================
    public List<String> getBookedTimesConfirmed(String dateStr) {
        List<String> times = new ArrayList<>();

        String sql =
                "SELECT APPOINTMENT_TIME FROM APPOINTMENT " +
                        "WHERE APPOINTMENT_DATE = ? " +
                        "AND LOWER(APPOINTMENT_STATUS) = 'confirmed'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(dateStr));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String t = rs.getString("APPOINTMENT_TIME"); // e.g. 14:00:00
                if (t != null && t.length() >= 5) t = t.substring(0, 5);
                times.add(t);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return times;
    }

    public List<String> getFullyBookedDates(String monthStr) {
        List<String> dates = new ArrayList<>();

        String sql =
                "SELECT APPOINTMENT_DATE " +
                        "FROM APPOINTMENT " +
                        "WHERE LOWER(APPOINTMENT_STATUS) = 'confirmed' " +
                        "AND APPOINTMENT_DATE >= ? AND APPOINTMENT_DATE < ? " +
                        "GROUP BY APPOINTMENT_DATE " +
                        "HAVING COUNT(DISTINCT APPOINTMENT_TIME) >= 6";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            java.time.LocalDate firstDay = java.time.LocalDate.parse(monthStr + "-01");
            java.time.LocalDate nextMonth = firstDay.plusMonths(1);

            ps.setDate(1, java.sql.Date.valueOf(firstDay));
            ps.setDate(2, java.sql.Date.valueOf(nextMonth));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                dates.add(rs.getDate("APPOINTMENT_DATE").toString());
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return dates;
    }

    public boolean isConfirmedSlotTaken(java.util.Date date, String time) {
        String sql =
                "SELECT COUNT(*) FROM APPOINTMENT " +
                        "WHERE APPOINTMENT_DATE = ? " +
                        "AND APPOINTMENT_TIME = ? " +
                        "AND LOWER(APPOINTMENT_STATUS) = 'confirmed'";

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