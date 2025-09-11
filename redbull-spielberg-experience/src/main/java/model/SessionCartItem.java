package model;

import java.util.Objects;

public class SessionCartItem {
    private int productId;
    private Integer slotId; // può essere null per i prodotti normali
    private int quantity;

    public SessionCartItem(int productId, Integer slotId, int quantity) {
        this.productId = productId;
        this.slotId = slotId;
        this.quantity = Math.max(1, quantity);
    }

    public int getProductId() { return productId; }
    public Integer getSlotId() { return slotId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int q) { this.quantity = Math.max(1, q); }
    public void inc(int delta) { this.quantity = Math.max(1, this.quantity + delta); }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof SessionCartItem)) return false;
        SessionCartItem that = (SessionCartItem) o;
        return productId == that.productId && Objects.equals(slotId, that.slotId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(productId, slotId);
    }
}