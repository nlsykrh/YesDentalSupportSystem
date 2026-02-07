package beans;

import java.util.Date;

public class DigitalConsent {
    private String consentId;
    private String patientIc;
    private String consentContext;
    private Date consentSigndate;
    private String appointmentId;
    
    public DigitalConsent() {}

    public DigitalConsent(String consentId, String patientIc, String consentContext, Date consentSigndate, String appointmentId) {
        this.consentId = consentId;
        this.patientIc = patientIc;
        this.consentContext = consentContext;
        this.consentSigndate = consentSigndate;
        this.appointmentId = appointmentId;
    }

    // Getters and Setters
    public String getConsentId() { return consentId; }
    public void setConsentId(String consentId) { this.consentId = consentId; }
    
    public String getPatientIc() { return patientIc; }
    public void setPatientIc(String patientIc) { this.patientIc = patientIc; }
    
    public String getConsentContext() { return consentContext; }
    public void setConsentContext(String consentContext) { this.consentContext = consentContext; }
    
    public Date getConsentSigndate() { return consentSigndate; }
    public void setConsentSigndate(Date consentSigndate) { this.consentSigndate = consentSigndate; }

    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }
}