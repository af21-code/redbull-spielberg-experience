package model;

import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class SessionCart {

    private final Map<String, SessionCartItem> items = new LinkedHashMap<>();

    private String keyOf(int productId, Integer slotId) {
        return productId + "|" + (slotId == null ? "null" : slotId);
    }

    public Collection<SessionCartItem> getItems() {
        return items.values();
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }

    public void clear() {
        items.clear();
    }

    public void add(int productId, Integer slotId, int qty) {
        String k = keyOf(productId, slotId);
        SessionCartItem it = items.get(k);
        if (it == null) {
            items.put(k, new SessionCartItem(productId, slotId, Math.max(1, qty)));
        } else {
            it.inc(qty);
        }
    }

    public void setQuantity(int productId, Integer slotId, int qty) {
        String k = keyOf(productId, slotId);
        if (qty <= 0) {
            items.remove(k);
        } else {
            SessionCartItem it = items.get(k);
            if (it == null) items.put(k, new SessionCartItem(productId, slotId, qty));
            else it.setQuantity(qty);
        }
    }

    public void remove(int productId, Integer slotId) {
        items.remove(keyOf(productId, slotId));
    }
}