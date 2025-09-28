package dto;

import java.math.BigDecimal;

public class DashboardStats {
    private int ordersToday;
    private BigDecimal revenueToday = BigDecimal.ZERO;
    private int pendingCount;
    private int lowStockCount;

    public int getOrdersToday() { return ordersToday; }
    public void setOrdersToday(int ordersToday) { this.ordersToday = ordersToday; }

    public BigDecimal getRevenueToday() { return revenueToday; }
    public void setRevenueToday(BigDecimal revenueToday) { this.revenueToday = revenueToday; }

    public int getPendingCount() { return pendingCount; }
    public void setPendingCount(int pendingCount) { this.pendingCount = pendingCount; }

    public int getLowStockCount() { return lowStockCount; }
    public void setLowStockCount(int lowStockCount) { this.lowStockCount = lowStockCount; }
}