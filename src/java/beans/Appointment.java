package beans;

import java.util.Date;

public class Appointment {
    private String appointmentId;
    private Date appointmentDate;
    private String appointmentTime;
    private String appointmentStatus; // pending, confirmed, cancelled
    private String remarks;
    private String patientIc;
    private String staffId;
    
    public Appointment() {}

    public Appointment(String appointmentId, Date appointmentDate, String appointmentTime,
                      String appointmentStatus, String remarks, String patientIc, String staffId) {
        this.appointmentId = appointmentId;
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;
        this.appointmentStatus = appointmentStatus;
        this.remarks = remarks;
        this.patientIc = patientIc;
        this.staffId = staffId;
    }

    // Getters and Setters
    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }
    
    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }
    
    public String getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(String appointmentTime) { this.appointmentTime = appointmentTime; }
    
    public String getAppointmentStatus() { return appointmentStatus; }
    public void setAppointmentStatus(String appointmentStatus) { this.appointmentStatus = appointmentStatus; }
    
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    
    public String getPatientIc() { return patientIc; }
    public void setPatientIc(String patientIc) { this.patientIc = patientIc; }
    
    public String getStaffId() { return staffId; }
    public void setStaffId(String staffId) { this.staffId = staffId; }
}