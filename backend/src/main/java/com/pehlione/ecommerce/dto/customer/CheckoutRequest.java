package com.pehlione.ecommerce.dto.customer;

public class CheckoutRequest {
    private ShippingAddressRequest shippingAddress;
    private PaymentRequest payment;

    public ShippingAddressRequest getShippingAddress() { return shippingAddress; }
    public PaymentRequest getPayment() { return payment; }
    public void setShippingAddress(ShippingAddressRequest shippingAddress) { this.shippingAddress = shippingAddress; }
    public void setPayment(PaymentRequest payment) { this.payment = payment; }
}
