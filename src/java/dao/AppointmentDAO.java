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

    // ======================================================
    // ✅ ADD APPOINTMENT (MULTI TREATMENT) - TRANSACTION
    // ======================================================
    public boolean addAppointment(Appointment appointment, String[] treatmentIds,
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

            // 2) Insert APPOINTMENTTREATMENT (MULTI)
            String atSql =
                    "INSERT INTO APPOINTMENTTREATMENT (APPOINTMENT_ID, TREATMENT_ID, APPOINTMENT_DATE) " +
                            "VALUES (?, ?, ?)";

            if (treatmentIds == null || treatmentIds.length == 0) {
                throw new SQLException("No treatment selected");
            }

            for (String treatmentId : treatmentIds) {
                if (treatmentId == null) continue;
                treatmentId = treatmentId.trim();
                if (treatmentId.isEmpty()) continue;

                try (PreparedStatement ps = conn.prepareStatement(atSql)) {
                    ps.setString(1, appointment.getAppointmentId().trim());
                    ps.setString(2, treatmentId);
                    ps.setDate(3, new java.sql.Date(appointment.getAppointmentDate().getTime()));
                    ps.executeUpdate();
                }
            }

            // 3) If CONFIRMED at creation -> create billing/consent/installments
            if ("Confirmed".equalsIgnoreCase(appointment.getAppointmentStatus())) {
                createBillingAndConsentIfMissing(conn, appointment.getAppointmentId().trim());
                // installments only if installment billing method + numInstallments > 0
                if (billingMethod != null && "installment".equalsIgnoreCase(billingMethod) && numInstallments > 0) {
                    // create installments requires a Billing object; easiest: create billing first then read amount
                    Billing billing = getBillingByAppointmentId(conn, appointment.getAppointmentId().trim());
                    if (billing != null) createInstallments(conn, billing, numInstallments);
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

    // ======================================================
    // ✅ KEEP: OLD ADD APPOINTMENT (SINGLE TREATMENT)
    // ======================================================
    public boolean addAppointment(Appointment appointment, String treatmentId,
                                  String billingMethod, int numInstallments) {
        String[] ids = new String[]{treatmentId};
        return addAppointment(appointment, ids, billingMethod, numInstallments);
    }

    // =========================
    // INSTALLMENTS
    // =========================
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

    private BigDecimal getTreatmentPriceFromDB(Connection conn, String treatmentId) throws SQLException {
        String sql = "SELECT TREATMENT_PRICE FROM TREATMENT WHERE TRIM(TREATMENT_ID) = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, treatmentId.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1) != null ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
        return BigDecimal.ZERO;
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
                        "FROM APPOINTMENT WHERE TRIM(APPOINTMENT_ID) = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, appointmentId == null ? "" : appointmentId.trim());
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
    // ✅ UPDATE STATUS + STAFF + CREATE BILLING + CREATE CONSENT (DERBY SAFE)
    // =========================
    public boolean updateAppointmentStatus(String appointmentId, String status, String staffId) {

        if (appointmentId == null || appointmentId.trim().isEmpty()) return false;
        appointmentId = appointmentId.trim();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean isConfirmed = "Confirmed".equalsIgnoreCase(status);

            // 1) Update status (+ staffId if confirmed)
            String sql;
            if (isConfirmed) {
                sql = "UPDATE APPOINTMENT SET APPOINTMENT_STATUS = ?, STAFF_ID = ? WHERE TRIM(APPOINTMENT_ID) = ?";
            } else {
                sql = "UPDATE APPOINTMENT SET APPOINTMENT_STATUS = ? WHERE TRIM(APPOINTMENT_ID) = ?";
            }

            int updated;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);

                if (isConfirmed) {
                    if (staffId == null || staffId.trim().isEmpty()) {
                        ps.setNull(2, Types.VARCHAR);
                    } else {
                        ps.setString(2, staffId.trim());
                    }
                    ps.setString(3, appointmentId);
                } else {
                    ps.setString(2, appointmentId);
                }

                updated = ps.executeUpdate();
            }

            if (updated <= 0) {
                conn.rollback();
                return false;
            }

            // 2) If Confirmed -> create billing + consent if missing
            if (isConfirmed) {
                createBillingAndConsentIfMissing(conn, appointmentId);
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

    // ✅ UPDATE FULL (date/time/status/remarks)
    public boolean updateAppointment(String appointmentId, java.util.Date date, String time, String status, String remarks) {
        String sql =
                "UPDATE APPOINTMENT " +
                        "SET APPOINTMENT_DATE=?, APPOINTMENT_TIME=?, APPOINTMENT_STATUS=?, REMARKS=? " +
                        "WHERE TRIM(APPOINTMENT_ID)=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, new java.sql.Date(date.getTime()));
            ps.setString(2, time);
            ps.setString(3, status);
            ps.setString(4, remarks);
            ps.setString(5, appointmentId == null ? "" : appointmentId.trim());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ======================================================
    // ✅ UPDATE APPOINTMENTTREATMENT (MULTI) - REPLACE ALL
    // ======================================================
    public boolean updateAppointmentTreatments(String appointmentId, String[] treatmentIds) {

        if (appointmentId == null || appointmentId.trim().isEmpty()) return false;
        appointmentId = appointmentId.trim();

        if (treatmentIds == null || treatmentIds.length == 0) return false;

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // get current appointment date
            java.sql.Date apptDate = null;
            String dateSql = "SELECT APPOINTMENT_DATE FROM APPOINTMENT WHERE TRIM(APPOINTMENT_ID)=?";
            try (PreparedStatement ps = conn.prepareStatement(dateSql)) {
                ps.setString(1, appointmentId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) apptDate = rs.getDate(1);
            }
            if (apptDate == null) throw new SQLException("Appointment date not found.");

            // 1) delete old treatments
            String delSql = "DELETE FROM APPOINTMENTTREATMENT WHERE TRIM(APPOINTMENT_ID)=?";
            try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                ps.setString(1, appointmentId);
                ps.executeUpdate();
            }

            // 2) insert new treatments
            String insSql =
                    "INSERT INTO APPOINTMENTTREATMENT (APPOINTMENT_ID, TREATMENT_ID, APPOINTMENT_DATE) " +
                            "VALUES (?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(insSql)) {
                for (String tid : treatmentIds) {
                    if (tid == null) continue;
                    tid = tid.trim();
                    if (tid.isEmpty()) continue;

                    ps.setString(1, appointmentId);
                    ps.setString(2, tid);
                    ps.setDate(3, apptDate);
                    ps.addBatch();
                }
                ps.executeBatch();
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
    // DELETE
    // =========================
    public boolean deleteAppointment(String appointmentId) {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String[] sqls = {
                    "DELETE FROM APPOINTMENTTREATMENT WHERE TRIM(APPOINTMENT_ID) = ?",
                    "DELETE FROM BILLING WHERE TRIM(APPOINTMENT_ID) = ?",
                    "DELETE FROM APPOINTMENT WHERE TRIM(APPOINTMENT_ID) = ?"
            };

            for (String sql : sqls) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, appointmentId == null ? "" : appointmentId.trim());
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
    // ✅ APPOINTMENT TREATMENTS (WITH DETAILS)
    // =========================
    public List<AppointmentTreatment> getAppointmentTreatments(String appointmentId) {
        List<AppointmentTreatment> treatments = new ArrayList<>();
        String apptTrim = (appointmentId == null) ? "" : appointmentId.trim();

        String sql =
                "SELECT TRIM(appt_t.APPOINTMENT_ID) APPOINTMENT_ID, " +
                        "       TRIM(appt_t.TREATMENT_ID)   TREATMENT_ID, " +
                        "       appt_t.APPOINTMENT_DATE, " +
                        "       t.TREATMENT_NAME, t.TREATMENT_DESC, t.TREATMENT_PRICE " +
                        "FROM APPOINTMENTTREATMENT appt_t " +
                        "LEFT JOIN TREATMENT t ON TRIM(t.TREATMENT_ID) = TRIM(appt_t.TREATMENT_ID) " +
                        "WHERE TRIM(appt_t.APPOINTMENT_ID) = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, apptTrim);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AppointmentTreatment at = new AppointmentTreatment();
                at.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                at.setTreatmentId(rs.getString("TREATMENT_ID"));
                at.setAppointmentDate(rs.getDate("APPOINTMENT_DATE"));

                at.setTreatmentName(rs.getString("TREATMENT_NAME"));
                at.setTreatmentDesc(rs.getString("TREATMENT_DESC"));

                double price = rs.getDouble("TREATMENT_PRICE");
                if (rs.wasNull()) price = 0.0;
                at.setTreatmentPrice(price);

                treatments.add(at);
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
                String t = rs.getString("APPOINTMENT_TIME");
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

    // ======================================================
    // ✅ HELPERS: Create billing & consent if missing
    // ======================================================
    private void createBillingAndConsentIfMissing(Connection conn, String appointmentId) throws SQLException {

        // get patient_ic, appointment_date, remarks
        String patientIc = null;
        java.sql.Date apptDate = null;
        String remarks = null;

        String getSql =
                "SELECT PATIENT_IC, APPOINTMENT_DATE, REMARKS " +
                "FROM APPOINTMENT WHERE TRIM(APPOINTMENT_ID)=?";

        try (PreparedStatement ps = conn.prepareStatement(getSql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                patientIc = rs.getString("PATIENT_IC");
                apptDate  = rs.getDate("APPOINTMENT_DATE");
                remarks   = rs.getString("REMARKS");
            }
        }

        if (patientIc == null || apptDate == null) {
            throw new SQLException("Appointment data not found to create billing/consent.");
        }

        // ---------- BILLING (exists?) ----------
        boolean billingExists;
        String checkBillSql =
                "SELECT 1 FROM BILLING WHERE TRIM(APPOINTMENT_ID)=? FETCH FIRST 1 ROWS ONLY";

        try (PreparedStatement ps = conn.prepareStatement(checkBillSql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            billingExists = rs.next();
        }

        if (!billingExists) {
            BigDecimal totalAmount = BigDecimal.ZERO;

            // ✅ IMPORTANT: alias "at" is reserved in Derby -> use "apt"
            String totalSql =
                    "SELECT COALESCE(SUM(COALESCE(t.TREATMENT_PRICE,0)),0) AS TOTAL " +
                    "FROM APPOINTMENTTREATMENT apt " +
                    "LEFT JOIN TREATMENT t ON TRIM(t.TREATMENT_ID)=TRIM(apt.TREATMENT_ID) " +
                    "WHERE TRIM(apt.APPOINTMENT_ID)=?";

            try (PreparedStatement ps = conn.prepareStatement(totalSql)) {
                ps.setString(1, appointmentId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    BigDecimal v = rs.getBigDecimal("TOTAL");
                    totalAmount = (v != null) ? v : BigDecimal.ZERO;
                }
            }

            String billId = getNextBillingId(conn);

            String billSql =
                    "INSERT INTO BILLING (BILLING_ID, BILLING_AMOUNT, BILLING_DUEDATE, BILLING_STATUS, BILLING_METHOD, APPOINTMENT_ID) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(billSql)) {
                ps.setString(1, billId);
                ps.setBigDecimal(2, totalAmount);
                ps.setDate(3, apptDate);
                ps.setString(4, "Pending");
                ps.setString(5, "Pay at Counter");
                ps.setString(6, appointmentId);
                ps.executeUpdate();
            }
        }

        // ---------- CONSENT (exists?) ----------
        boolean consentExists;
        String checkConsentSql =
                "SELECT 1 FROM DIGITALCONSENT WHERE TRIM(APPOINTMENT_ID)=? FETCH FIRST 1 ROWS ONLY";

        try (PreparedStatement ps = conn.prepareStatement(checkConsentSql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            consentExists = rs.next();
        }

        if (!consentExists) {
            String consentId = getNextConsentId(conn);

            String consentContext =
                    "Patient has given consent for " + ((remarks != null) ? remarks.trim() : "");

            String consentSql =
                    "INSERT INTO DIGITALCONSENT (CONSENT_ID, PATIENT_IC, CONSENT_CONTEXT, CONSENT_SIGNDATE, APPOINTMENT_ID) " +
                    "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement ps = conn.prepareStatement(consentSql)) {
                ps.setString(1, consentId);
                ps.setString(2, patientIc);
                ps.setString(3, consentContext);
                ps.setNull(4, Types.TIMESTAMP);  // ✅ NULL until patient signs
                ps.setString(5, appointmentId);
                ps.executeUpdate();
            }
        }
    }

    // small helper (only used if you ever want installments in addAppointment confirmed)
    private Billing getBillingByAppointmentId(Connection conn, String appointmentId) {
        String sql =
                "SELECT BILLING_ID, BILLING_AMOUNT, BILLING_DUEDATE, BILLING_STATUS, BILLING_METHOD, APPOINTMENT_ID " +
                "FROM BILLING WHERE TRIM(APPOINTMENT_ID)=? FETCH FIRST 1 ROWS ONLY";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Billing b = new Billing();
                b.setBillingId(rs.getString("BILLING_ID"));
                b.setBillingAmount(rs.getBigDecimal("BILLING_AMOUNT"));
                b.setBillingDuedate(rs.getDate("BILLING_DUEDATE"));
                b.setBillingStatus(rs.getString("BILLING_STATUS"));
                b.setBillingMethod(rs.getString("BILLING_METHOD"));
                b.setAppointmentId(rs.getString("APPOINTMENT_ID"));
                return b;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
