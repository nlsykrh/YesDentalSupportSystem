package beans;

import java.math.BigDecimal;
import java.util.Date;

public class Billing {
    private String billingId;
    private BigDecimal billingAmount;
    private Date billingDuedate;
    private String billingStatus; // Pending, Paid
    private String billingMethod; // Pay at Counter, Installment
    private String appointmentId;
    private String patientName;
    private int numInstallments;
private String installmentDates;
    
    public Billing() {}

     public Billing(String billingId, BigDecimal billingAmount, Date billingDuedate,
                   String billingStatus, String billingMethod, String appointmentId, 
                   String patientName, int numInstallments, String installmentDates) {
        this.billingId = billingId;
        this.billingAmount = billingAmount;
        this.billingDuedate = billingDuedate;
        this.billingStatus = billingStatus;
        this.billingMethod = billingMethod;
        this.appointmentId = appointmentId;
        this.patientName = patientName;
        this.numInstallments = numInstallments;
        this.installmentDates = installmentDates;
    }

    // Getters and Setters
    public String getBillingId() { return billingId; }
    public void setBillingId(String billingId) { this.billingId = billingId; }
    
    public BigDecimal getBillingAmount() { return billingAmount; }
    public void setBillingAmount(BigDecimal billingAmount) { this.billingAmount = billingAmount; }
    
    public Date getBillingDuedate() { return billingDuedate; }
    public void setBillingDuedate(Date billingDuedate) { this.billingDuedate = billingDuedate; }
    
    public String getBillingStatus() { return billingStatus; }
    public void setBillingStatus(String billingStatus) { this.billingStatus = billingStatus; }
    
    public String getBillingMethod() { return billingMethod; }
    public void setBillingMethod(String billingMethod) { this.billingMethod = billingMethod; }
    
    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }
    
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

public int getNumInstallments() {
    return numInstallments;
}

public void setNumInstallments(int numInstallments) {
    this.numInstallments = numInstallments;
}

public String getInstallmentDates() {
    return installmentDates;
}

public void setInstallmentDates(String installmentDates) {
    this.installmentDates = installmentDates;
}
}