package model;

import java.time.LocalDate;
import java.time.LocalTime;

public class TimeSlot {
    private int slotId;
    private int productId;
    private LocalDate slotDate;
    private LocalTime slotTime;
    private int maxCapacity;
    private int bookedCapacity;
    private boolean available;

    public int getRemainingCapacity() {
        return Math.max(0, maxCapacity - bookedCapacity);
    }

    // Getters & setters
    public int getSlotId() { return slotId; }
    public void setSlotId(int slotId) { this.slotId = slotId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public LocalDate getSlotDate() { return slotDate; }
    public void setSlotDate(LocalDate slotDate) { this.slotDate = slotDate; }

    public LocalTime getSlotTime() { return slotTime; }
    public void setSlotTime(LocalTime slotTime) { this.slotTime = slotTime; }

    public int getMaxCapacity() { return maxCapacity; }
    public void setMaxCapacity(int maxCapacity) { this.maxCapacity = maxCapacity; }

    public int getBookedCapacity() { return bookedCapacity; }
    public void setBookedCapacity(int bookedCapacity) { this.bookedCapacity = bookedCapacity; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
}