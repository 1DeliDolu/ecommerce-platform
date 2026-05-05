package com.pehlione.ecommerce.dto.customer;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

public class CheckoutRequest {
    @Valid
    @NotNull
    private ShippingAddressRequest shippingAddress;

    @Valid
    @NotNull
    private PaymentRequest payment;

    public ShippingAddressRequest getShippingAddress() { return shippingAddress; }
    public PaymentRequest getPayment() { return payment; }
    public void setShippingAddress(ShippingAddressRequest shippingAddress) { this.shippingAddress = shippingAddress; }
    public void setPayment(PaymentRequest payment) { this.payment = payment; }
}
