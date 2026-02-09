package beans;

import java.util.Date;

public class AppointmentTreatment {
    private String appointmentId;
    private String treatmentId;
    private Date appointmentDate;

    // ✅ add these 3 (from TREATMENT table)
    private String treatmentName;
    private String treatmentDesc;
    private double treatmentPrice;

    public AppointmentTreatment() {}

    public AppointmentTreatment(String appointmentId, String treatmentId, Date appointmentDate) {
        this.appointmentId = appointmentId;
        this.treatmentId = treatmentId;
        this.appointmentDate = appointmentDate;
    }

    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }

    public String getTreatmentId() { return treatmentId; }
    public void setTreatmentId(String treatmentId) { this.treatmentId = treatmentId; }

    public Date getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(Date appointmentDate) { this.appointmentDate = appointmentDate; }

    // ✅ new getters/setters
    public String getTreatmentName() { return treatmentName; }
    public void setTreatmentName(String treatmentName) { this.treatmentName = treatmentName; }

    public String getTreatmentDesc() { return treatmentDesc; }
    public void setTreatmentDesc(String treatmentDesc) { this.treatmentDesc = treatmentDesc; }

    public double getTreatmentPrice() { return treatmentPrice; }
    public void setTreatmentPrice(double treatmentPrice) { this.treatmentPrice = treatmentPrice; }
}