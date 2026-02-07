package dao;

import beans.Staff;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO implements BaseDAO<Staff> {
    
    public boolean addStaff(Staff staff) {
        String sql = "INSERT INTO staff (staff_id, staff_name, staff_email, staff_phonenum, staff_role, staff_password) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staff.getStaffId());
            ps.setString(2, staff.getStaffName());
            ps.setString(3, staff.getStaffEmail());
            ps.setString(4, staff.getStaffPhonenum());
            ps.setString(5, staff.getStaffRole());
            ps.setString(6, staff.getStaffPassword());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("ERROR ADDING STAFF: " + e.getMessage());
            System.out.println("SQL: " + sql);
            System.out.println("Staff ID: " + staff.getStaffId());
            System.out.println("Name: " + staff.getStaffName());
        }
        return false;
    }
    
    public boolean updateStaff(Staff staff) {
        boolean hasPassword = staff.getStaffPassword() != null && !staff.getStaffPassword().trim().isEmpty();

        String sql;
        if (hasPassword) {
            sql = "UPDATE staff SET staff_name=?, staff_email=?, staff_phonenum=?, staff_role=?, staff_password=? WHERE staff_id=?";
        } else {
            sql = "UPDATE staff SET staff_name=?, staff_email=?, staff_phonenum=?, staff_role=? WHERE staff_id=?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int i = 1;
            ps.setString(i++, staff.getStaffName());
            ps.setString(i++, staff.getStaffEmail());
            ps.setString(i++, staff.getStaffPhonenum());
            ps.setString(i++, staff.getStaffRole());

            if (hasPassword) {
                ps.setString(i++, staff.getStaffPassword().trim());
            }

            ps.setString(i++, staff.getStaffId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public Staff getStaffById(String staffId) {
        Staff staff = null;
        String sql = "SELECT * FROM staff WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                staff = new Staff();
                
                staff.setStaffId(rs.getString("staff_id"));
                staff.setStaffName(rs.getString("staff_name"));
                staff.setStaffEmail(rs.getString("staff_email"));
                staff.setStaffPhonenum(rs.getString("staff_phonenum"));
                staff.setStaffRole(rs.getString("staff_role"));
                staff.setStaffPassword(rs.getString("staff_password"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return staff;
    }
    
    public boolean delete(String staffId) {
        String sql = "DELETE FROM staff WHERE staff_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, staffId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Staff> getAllStaff() {
        List<Staff> staffList = new ArrayList<>();

        String sql = "SELECT * FROM staff ORDER BY staff_id";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Staff staff = new Staff();
                
                staff.setStaffId(rs.getString("staff_id"));
                staff.setStaffName(rs.getString("staff_name"));
                staff.setStaffEmail(rs.getString("staff_email"));
                staff.setStaffPhonenum(rs.getString("staff_phonenum"));
                staff.setStaffRole(rs.getString("staff_role"));
                staff.setStaffPassword(rs.getString("staff_password"));

                staffList.add(staff);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return staffList;
    }
    
    public String getNextStaffId() {
        String sql = "SELECT MAX(staff_id) FROM staff";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next() && rs.getString(1) != null) {
                String lastId = rs.getString(1).trim();
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("STF%03d", num);
            }
            return "STF001";
        } catch (Exception e) {
            e.printStackTrace();
            return "STF001";
        }
    }

    @Override
    public boolean add(Staff obj) {
        return addStaff(obj);
    }

    @Override
    public boolean update(Staff obj) {
        return updateStaff(obj);
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public Staff getById(int id) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public List<Staff> getAllPatients() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}