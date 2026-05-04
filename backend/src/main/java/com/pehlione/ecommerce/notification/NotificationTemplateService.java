package com.pehlione.ecommerce.notification;

import com.pehlione.ecommerce.domain.CustomerOrder;
import com.pehlione.ecommerce.domain.CustomerOrderItem;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
public class NotificationTemplateService {

    private final NotificationMailService mailService;

    public NotificationTemplateService(NotificationMailService mailService) {
        this.mailService = mailService;
    }

    public String orderConfirmationHtml(CustomerOrder order) {
        String html = mailService.loadTemplate("email-templates/order-confirmation.html");

        String itemSummary = order.getItems()
                .stream()
                .map(this::formatItem)
                .collect(Collectors.joining(", "));

        html = mailService.replace(html, "customerName", order.getShippingFullName());
        html = mailService.replace(html, "orderNumber", order.getOrderNumber());
        html = mailService.replace(html, "status", order.getStatus().name());
        html = mailService.replace(html, "totalAmount", order.getTotalAmount().toString());
        html = mailService.replace(html, "itemSummary", itemSummary);
        html = mailService.replace(html, "subtotal", order.getSubtotal().toString());

        return html;
    }

    private String formatItem(CustomerOrderItem item) {
        return item.getProductName()
                + " x "
                + item.getQuantity()
                + " = €"
                + item.getLineTotal();
    }
}
