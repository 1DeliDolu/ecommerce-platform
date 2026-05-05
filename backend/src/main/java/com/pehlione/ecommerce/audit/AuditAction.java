package com.pehlione.ecommerce.audit;

public final class AuditAction {
    public static final String USER_REGISTERED = "USER_REGISTERED";
    public static final String LOGIN_SUCCESS = "LOGIN_SUCCESS";
    public static final String LOGIN_FAILED = "LOGIN_FAILED";
    public static final String ACCOUNT_LOCKED_OUT = "ACCOUNT_LOCKED_OUT";
    public static final String TOKEN_REFRESHED = "TOKEN_REFRESHED";
    public static final String PRODUCT_CREATED = "PRODUCT_CREATED";
    public static final String ORDER_CREATED = "ORDER_CREATED";
    public static final String PAYMENT_FAILED = "PAYMENT_FAILED";
    public static final String ROLE_CHANGED = "ROLE_CHANGED";
    public static final String PERMISSION_DENIED = "PERMISSION_DENIED";

    private AuditAction() {
    }
}
