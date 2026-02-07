package dao;

import beans.Treatment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TreatmentDAO implements BaseDAO<Treatment> {
    
    @Override
    public boolean add(Treatment treatment) {
        String sql = "INSERT INTO treatment (treatment_id, treatment_name, treatment_desc, treatment_price) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, treatment.getTreatmentId());
            ps.setString(2, treatment.getTreatmentName());
            ps.setString(3, treatment.getTreatmentDesc());
            ps.setDouble(4, treatment.getTreatmentPrice());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("ERROR ADDING TREATMENT: " + e.getMessage());
        }
        return false;
    }
    
    @Override
    public boolean update(Treatment treatment) {
        String sql = "UPDATE treatment SET treatment_name = ?, treatment_desc = ?, treatment_price = ? WHERE treatment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, treatment.getTreatmentName());
            ps.setString(2, treatment.getTreatmentDesc());
            ps.setDouble(3, treatment.getTreatmentPrice());
            ps.setString(4, treatment.getTreatmentId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Use delete(String treatmentId) instead");
    }
    
    public boolean delete(String treatmentId) {
        String sql = "DELETE FROM treatment WHERE treatment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, treatmentId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public Treatment getById(int id) {
        throw new UnsupportedOperationException("Use getTreatmentById(String treatmentId) instead");
    }
    
    public Treatment getTreatmentById(String treatmentId) {
        Treatment treatment = null;
        String sql = "SELECT * FROM treatment WHERE treatment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, treatmentId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                treatment = new Treatment();
                treatment.setTreatmentId(rs.getString("treatment_id"));
                treatment.setTreatmentName(rs.getString("treatment_name"));
                treatment.setTreatmentDesc(rs.getString("treatment_desc"));
                treatment.setTreatmentPrice(rs.getDouble("treatment_price"));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return treatment;
    }
    
    public List<Treatment> getAllTreatments() {
        List<Treatment> treatments = new ArrayList<>();
        String sql = "SELECT * FROM treatment ORDER BY treatment_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Treatment treatment = new Treatment();
                treatment.setTreatmentId(rs.getString("treatment_id"));
                treatment.setTreatmentName(rs.getString("treatment_name"));
                treatment.setTreatmentDesc(rs.getString("treatment_desc"));
                treatment.setTreatmentPrice(rs.getDouble("treatment_price"));
                
                treatments.add(treatment);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return treatments;
    }
    
    // Additional method for edit functionality
    public Treatment getTreatmentByIc(String treatmentId) {
        return getTreatmentById(treatmentId);
    }

    @Override
    public List<Treatment> getAllPatients() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}