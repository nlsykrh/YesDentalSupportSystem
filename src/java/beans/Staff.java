package beans;

import java.util.Date;
import java.io.Serializable;

public class Staff implements Serializable {
    
    private String staffId;
    private String staffName;
    private String staffEmail;
    private String staffPhonenum;
    private String staffRole;
    private String staffPassword;
    
    public Staff() {}

    public Staff(String staffId, String staffName, String staffEmail,
               String staffPhonenum, String staffRole, String staffPassword) {
        this.staffId = staffId;
        this.staffName = staffName;
        this.staffEmail = staffEmail;
        this.staffPhonenum = staffPhonenum;
        this.staffRole = staffRole;
        this.staffPassword = staffPassword;
    }

    public String getStaffId() {
        return staffId;
    }

    public void setStaffId(String staffId) {
        this.staffId = staffId;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public String getStaffEmail() {
        return staffEmail;
    }

    public void setStaffEmail(String staffEmail) {
        this.staffEmail = staffEmail;
    }

    public String getStaffPhonenum() {
        return staffPhonenum;
    }

    public void setStaffPhonenum(String staffPhonenum) {
        this.staffPhonenum = staffPhonenum;
    }

    public String getStaffRole() {
        return staffRole;
    }

    public void setStaffRole(String staffRole) {
        this.staffRole = staffRole;
    }

    public String getStaffPassword() {
        return staffPassword;
    }

    public void setStaffPassword(String staffPassword) {
        this.staffPassword = staffPassword;
    }
}