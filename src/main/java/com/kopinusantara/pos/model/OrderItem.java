package com.kopinusantara.pos.model;

public class OrderItem {
    private int id;
    private int menuItemId;
    private String itemName;
    private int unitPrice;
    private int qty;
    private String note;
    private int lineTotal;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getMenuItemId() { return menuItemId; }
    public void setMenuItemId(int menuItemId) { this.menuItemId = menuItemId; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public int getUnitPrice() { return unitPrice; }
    public void setUnitPrice(int unitPrice) { this.unitPrice = unitPrice; }
    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public int getLineTotal() { return lineTotal; }
    public void setLineTotal(int lineTotal) { this.lineTotal = lineTotal; }
}
