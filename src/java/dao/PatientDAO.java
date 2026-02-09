package dao;

import beans.Patient;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO implements BaseDAO<Patient> {

    public boolean addPatient(Patient patient) {

        String sql = "INSERT INTO patient " +
                "(patient_ic, patient_name, patient_phone, patient_email, " +
                "patient_dob, patient_address, patient_guardian, patient_guardian_phone, " +
                "patient_password, patient_status, patient_crdate) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getPatientIc());
            ps.setString(2, patient.getPatientName());
            ps.setString(3, patient.getPatientPhone());
            ps.setString(4, patient.getPatientEmail());

            if (patient.getPatientDob() != null) {
                ps.setDate(5, new java.sql.Date(patient.getPatientDob().getTime()));
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setString(6, patient.getPatientAddress());
            ps.setString(7, patient.getPatientGuardian());
            ps.setString(8, patient.getPatientGuardianPhone());
            ps.setString(9, patient.getPatientPassword()); // phone number
            ps.setString(10, patient.getPatientStatus());

            if (patient.getPatientCrDate() != null) {
                ps.setTimestamp(11, new java.sql.Timestamp(patient.getPatientCrDate().getTime()));
            } else {
                ps.setTimestamp(11, new java.sql.Timestamp(System.currentTimeMillis()));
            }

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("ERROR ADDING PATIENT: " + e.getMessage());
            System.out.println("SQL: " + sql);
            System.out.println("IC: " + patient.getPatientIc());
            System.out.println("Name: " + patient.getPatientName());
        }
        return false;
    }

    // ✅ SAFE: updates all profile fields (including password if you pass it)
    public boolean updatePatient(Patient patient) {

        String sql = "UPDATE patient SET " +
                "patient_name = ?, patient_phone = ?, patient_email = ?, " +
                "patient_dob = ?, patient_address = ?, patient_guardian = ?, " +
                "patient_guardian_phone = ?, patient_status = ?, patient_password = ? " +
                "WHERE patient_ic = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getPatientName());
            ps.setString(2, patient.getPatientPhone());
            ps.setString(3, patient.getPatientEmail());

            if (patient.getPatientDob() != null) {
                ps.setDate(4, new java.sql.Date(patient.getPatientDob().getTime()));
            } else {
                ps.setNull(4, Types.DATE);
            }

            ps.setString(5, patient.getPatientAddress());
            ps.setString(6, patient.getPatientGuardian());
            ps.setString(7, patient.getPatientGuardianPhone());
            ps.setString(8, patient.getPatientStatus());
            ps.setString(9, patient.getPatientPassword());
            ps.setString(10, patient.getPatientIc());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ BEST for Change Password (updates ONLY password column)
    public boolean updatePatientPassword(String patientIc, String newPassword) {
        String sql = "UPDATE patient SET patient_password = ? WHERE patient_ic = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, patientIc);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Patient getPatientByIc(String patientIc) {
        Patient patient = null;
        String sql = "SELECT * FROM patient WHERE patient_ic = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patientIc);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                patient = new Patient();
                patient.setPatientIc(rs.getString("patient_ic"));
                patient.setPatientName(rs.getString("patient_name"));
                patient.setPatientPhone(rs.getString("patient_phone"));
                patient.setPatientEmail(rs.getString("patient_email"));
                patient.setPatientAddress(rs.getString("patient_address"));
                patient.setPatientDob(rs.getDate("patient_dob"));
                patient.setPatientGuardian(rs.getString("patient_guardian"));
                patient.setPatientGuardianPhone(rs.getString("patient_guardian_phone"));
                patient.setPatientStatus(rs.getString("patient_status"));
                patient.setPatientPassword(rs.getString("patient_password"));
                patient.setPatientCrDate(rs.getTimestamp("patient_crdate"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return patient;
    }

    public boolean delete(String patientIc) {
        String sql = "DELETE FROM patient WHERE patient_ic=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patientIc);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Patient> getAllPatients() {

        List<Patient> patients = new ArrayList<>();
        String sql = "SELECT * FROM patient ORDER BY patient_status ASC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {

                Patient patient = new Patient();
                patient.setPatientIc(rs.getString("patient_ic"));
                patient.setPatientName(rs.getString("patient_name"));
                patient.setPatientPhone(rs.getString("patient_phone"));
                patient.setPatientEmail(rs.getString("patient_email"));
                patient.setPatientAddress(rs.getString("patient_address"));
                patient.setPatientDob(rs.getDate("patient_dob"));
                patient.setPatientGuardian(rs.getString("patient_guardian"));
                patient.setPatientGuardianPhone(rs.getString("patient_guardian_phone"));
                patient.setPatientStatus(rs.getString("patient_status"));
                patient.setPatientCrDate(rs.getTimestamp("patient_crdate"));

                patients.add(patient);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return patients;
    }

    @Override
    public boolean add(Patient obj) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public boolean update(Patient obj) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public Patient getByIc(int patient_ic) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public Patient getById(int id) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}