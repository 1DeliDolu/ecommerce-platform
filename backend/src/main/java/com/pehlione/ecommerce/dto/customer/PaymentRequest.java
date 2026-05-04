package com.pehlione.ecommerce.dto.customer;

public class PaymentRequest {
    private String cardHolder;
    private String cardNumber;
    private String expiry;
    private String cvv;

    public String getCardHolder() { return cardHolder; }
    public String getCardNumber() { return cardNumber; }
    public String getExpiry() { return expiry; }
    public String getCvv() { return cvv; }

    public void setCardHolder(String cardHolder) { this.cardHolder = cardHolder; }
    public void setCardNumber(String cardNumber) { this.cardNumber = cardNumber; }
    public void setExpiry(String expiry) { this.expiry = expiry; }
    public void setCvv(String cvv) { this.cvv = cvv; }
}
