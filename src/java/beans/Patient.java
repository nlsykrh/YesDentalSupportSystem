package beans;

import java.util.Date;
import java.io.Serializable;

public class Patient {
    
    private String patientIc;
    private String patientName;
    private String patientEmail;
    private String patientPhone;
    private String patientAddress;
    private Date patientDob;
    private String patientGuardian;
    private String patientGuardianPhone;
    private String patientPassword;
    private String patientStatus;
    private Date patientCrDate;
    
    public Patient() {}

    public Patient(String patientIc, String patientName, String patientEmail,
               String patientPhone, String patientAddress, Date patientDob,
               String patientGuardian, String patientGuardianPhone,
               String patientPassword, String patientStatus, Date patientCrDate) {

        this.patientIc = patientIc;
        this.patientName = patientName;
        this.patientEmail = patientEmail;
        this.patientPhone = patientPhone;
        this.patientAddress = patientAddress;
        this.patientDob = patientDob;
        this.patientGuardian = patientGuardian;
        this.patientGuardianPhone = patientGuardianPhone;
        this.patientPassword = patientPassword;
        this.patientStatus = patientStatus;
        this.patientCrDate = patientCrDate;
    }

    public String getPatientIc() {
        return patientIc;
    }

    public void setPatientIc(String patientIc) {
        this.patientIc = patientIc;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getPatientEmail() {
        return patientEmail;
    }

    public void setPatientEmail(String patientEmail) {
        this.patientEmail = patientEmail;
    }

    public String getPatientPhone() {
        return patientPhone;
    }

    public void setPatientPhone(String patientPhone) {
        this.patientPhone = patientPhone;
    }

    public String getPatientAddress() {
        return patientAddress;
    }

    public void setPatientAddress(String patientAddress) {
        this.patientAddress = patientAddress;
    }

    public Date getPatientDob() {
        return patientDob;
    }

    public void setPatientDob(Date patientDob) {
        this.patientDob = patientDob;
    }

    public String getPatientGuardian() {
        return patientGuardian;
    }

    public void setPatientGuardian(String patientGuardian) {
        this.patientGuardian = patientGuardian;
    }

    public String getPatientGuardianPhone() {
        return patientGuardianPhone;
    }

    public void setPatientGuardianPhone(String patientGuardianPhone) {
        this.patientGuardianPhone = patientGuardianPhone;
    }

    public String getPatientPassword() {
        return patientPassword;
    }

    public void setPatientPassword(String patientPassword) {
        this.patientPassword = patientPassword;
    }

    public String getPatientStatus() {
        return patientStatus;
    }

    public void setPatientStatus(String patientStatus) {
        this.patientStatus = patientStatus;
    }

    public Date getPatientCrDate() {
        return patientCrDate;
    }

    public void setPatientCrDate(Date patientCrDate) {
        this.patientCrDate = patientCrDate;
    }
}