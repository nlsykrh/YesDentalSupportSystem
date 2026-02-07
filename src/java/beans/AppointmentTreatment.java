package beans;

import java.util.Date;

public class AppointmentTreatment {
    private String appointmentId;
    private String treatmentId;
    private Date appointmentDate;
    
    public AppointmentTreatment() {}

    public AppointmentTreatment(String appointmentId, String treatmentId, Date appointmentDate) {
        this.appointmentId = appointmentId;
        this.treatmentId = treatmentId;
        this.appointmentDate = appointmentDate;
    }

    // Getters and Setters
    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }
    
    public String getTreatmentId() { return treatmentId; }
    public void setTreatmentId(String treatmentId) { this.treatmentId = treatmentId; }
    
    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }
}