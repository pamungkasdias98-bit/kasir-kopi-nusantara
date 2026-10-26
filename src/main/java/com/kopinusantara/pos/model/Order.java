package com.kopinusantara.pos.model;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class Order {
    private static final DateTimeFormatter FULL = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter HOUR = DateTimeFormatter.ofPattern("HH:mm");

    private int id;
    private String orderNo;
    private String orderType;
    private String tableNo;
    private String customerName;
    private String note;
    private int subtotal;
    private int discount;
    private int tax;
    private int total;
    private String paymentMethod;
    private int cashReceived;
    private int changeAmount;
    private String status;
    private String cashierName;
    private LocalDateTime createdAt;
    private List<OrderItem> items = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public String getOrderType() { return orderType; }
    public void setOrderType(String orderType) { this.orderType = orderType; }
    public String getTableNo() { return tableNo; }
    public void setTableNo(String tableNo) { this.tableNo = tableNo; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public int getSubtotal() { return subtotal; }
    public void setSubtotal(int subtotal) { this.subtotal = subtotal; }
    public int getDiscount() { return discount; }
    public void setDiscount(int discount) { this.discount = discount; }
    public int getTax() { return tax; }
    public void setTax(int tax) { this.tax = tax; }
    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public int getCashReceived() { return cashReceived; }
    public void setCashReceived(int cashReceived) { this.cashReceived = cashReceived; }
    public int getChangeAmount() { return changeAmount; }
    public void setChangeAmount(int changeAmount) { this.changeAmount = changeAmount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCashierName() { return cashierName; }
    public void setCashierName(String cashierName) { this.cashierName = cashierName; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }

    public String getCreatedAtText() { return createdAt == null ? "" : createdAt.format(FULL); }
    public String getCreatedHour() { return createdAt == null ? "" : createdAt.format(HOUR); }

    /** Sudah berapa menit pesanan ini menunggu. */
    public long getElapsedMinutes() {
        return createdAt == null ? 0 : Math.max(0, Duration.between(createdAt, LocalDateTime.now()).toMinutes());
    }

    public String getTypeLabel() {
        switch (orderType == null ? "" : orderType) {
            case "TAKE_AWAY": return "Take Away";
            case "OJOL": return "Ojol";
            default: return "Dine In";
        }
    }

    public String getPaymentLabel() {
        switch (paymentMethod == null ? "" : paymentMethod) {
            case "QRIS": return "QRIS / GoPay";
            case "DEBIT": return "Debit / EDC";
            case "TRANSFER": return "Transfer Bank";
            default: return "Tunai";
        }
    }
}
