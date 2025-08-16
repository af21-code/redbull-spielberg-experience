package model;

import java.math.BigDecimal;

public class CartItem {
    private int productId;
    private Integer slotId; // opzionale per le esperienze
    private String productName;
    private String imageUrl;
    private BigDecimal unitPrice;
    private int quantity;
    private String productType; // "EXPERIENCE" | "MERCHANDISE"

    public CartItem() {}

    public CartItem(int productId, Integer slotId, String productName, String imageUrl,
                    BigDecimal unitPrice, int quantity, String productType) {
        this.productId = productId;
        this.slotId = slotId;
        this.productName = productName;
        this.imageUrl = imageUrl;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
        this.productType = productType;
    }

    public int getProductId() { return productId; }
    public Integer getSlotId() { return slotId; }
    public String getProductName() { return productName; }
    public String getImageUrl() { return imageUrl; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public int getQuantity() { return quantity; }
    public String getProductType() { return productType; }

    public void setProductId(int productId) { this.productId = productId; }
    public void setSlotId(Integer slotId) { this.slotId = slotId; }
    public void setProductName(String productName) { this.productName = productName; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public void setProductType(String productType) { this.productType = productType; }

    public BigDecimal getTotal() {
        if (unitPrice == null) return BigDecimal.ZERO;
        return unitPrice.multiply(new BigDecimal(quantity));
    }
}
