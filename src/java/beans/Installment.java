package beans;

import java.math.BigDecimal;

public class Installment {
    private String installmentId;
    private int numofinstallment;
    private String paymentStatus; // Pending, Paid
    private BigDecimal paymentAmount;
    private BigDecimal paidAmount;
    private BigDecimal remainingAmount;
    private String paymentDate;
    private String billingId;
    
    public Installment() {}

    public Installment(String installmentId, int numofinstallment, String paymentStatus,
                      BigDecimal paymentAmount, BigDecimal paidAmount, BigDecimal remainingAmount,
                      String paymentDate, String billingId) {
        this.installmentId = installmentId;
        this.numofinstallment = numofinstallment;
        this.paymentStatus = paymentStatus;
        this.paymentAmount = paymentAmount;
        this.paidAmount = paidAmount;
        this.remainingAmount = remainingAmount;
        this.paymentDate = paymentDate;
        this.billingId = billingId;
    }

    // Getters and Setters
    public String getInstallmentId() { return installmentId; }
    public void setInstallmentId(String installmentId) { this.installmentId = installmentId; }
    
    public int getNumofinstallment() { return numofinstallment; }
    public void setNumofinstallment(int numofinstallment) { this.numofinstallment = numofinstallment; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public BigDecimal getPaymentAmount() { return paymentAmount; }
    public void setPaymentAmount(BigDecimal paymentAmount) { this.paymentAmount = paymentAmount; }
    
    public BigDecimal getPaidAmount() { return paidAmount; }
    public void setPaidAmount(BigDecimal paidAmount) { this.paidAmount = paidAmount; }
    
    public BigDecimal getRemainingAmount() { return remainingAmount; }
    public void setRemainingAmount(BigDecimal remainingAmount) { this.remainingAmount = remainingAmount; }
    
    public String getPaymentDate() { return paymentDate; }
    public void setPaymentDate(String paymentDate) { this.paymentDate = paymentDate; }
    
    public String getBillingId() { return billingId; }
    public void setBillingId(String billingId) { this.billingId = billingId; }
}