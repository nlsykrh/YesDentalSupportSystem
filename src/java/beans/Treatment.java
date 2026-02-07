package beans;

import java.io.Serializable;

public class Treatment implements Serializable {
    
    private String treatmentId;
    private String treatmentName;
    private String treatmentDesc;
    private double treatmentPrice;
    
    public Treatment() {}

    public Treatment(String treatmentId, String treatmentName, String treatmentDesc, double treatmentPrice) {
        this.treatmentId = treatmentId;
        this.treatmentName = treatmentName;
        this.treatmentDesc = treatmentDesc;
        this.treatmentPrice = treatmentPrice;
    }

    // Getters and Setters
    public String getTreatmentId() {
        return treatmentId;
    }

    public void setTreatmentId(String treatmentId) {
        this.treatmentId = treatmentId;
    }

    public String getTreatmentName() {
        return treatmentName;
    }

    public void setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
    }

    public String getTreatmentDesc() {
        return treatmentDesc;
    }

    public void setTreatmentDesc(String treatmentDesc) {
        this.treatmentDesc = treatmentDesc;
    }

    public double getTreatmentPrice() {
        return treatmentPrice;
    }

    public void setTreatmentPrice(double treatmentPrice) {
        this.treatmentPrice = treatmentPrice;
    }
}