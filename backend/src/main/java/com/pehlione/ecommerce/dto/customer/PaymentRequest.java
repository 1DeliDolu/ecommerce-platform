package com.pehlione.ecommerce.dto.customer;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class PaymentRequest {
    @NotBlank
    @Size(max = 200)
    private String cardHolder;

    @NotBlank
    @Size(min = 12, max = 23)
    private String cardNumber;

    @NotBlank
    @Pattern(regexp = "^(0[1-9]|1[0-2])/\\d{2}$", message = "must be in MM/YY format")
    private String expiry;

    @NotBlank
    @Pattern(regexp = "^\\d{3,4}$", message = "must be 3 or 4 digits")
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
