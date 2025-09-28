package model.dao;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface AdminStatsDAO {

    // KPI base
    int countOrdersToday() throws Exception;
    BigDecimal sumRevenueToday() throws Exception;

    int countOrdersInLastDays(int days) throws Exception;
    BigDecimal sumRevenueInLastDays(int days) throws Exception;

    int countNewUsersInLastDays(int days) throws Exception;

    // Conteggi per stato (PENDING / CONFIRMED / PROCESSING / COMPLETED / CANCELLED)
    Map<String, Integer> countByStatuses(String... statuses) throws Exception;

    // Liste
    List<Map<String, Object>> latestOrders(int limit) throws Exception;           // ultimi N ordini
    List<Map<String, Object>> topProductsLastDays(int days, int limit) throws Exception; // top prodotti per ricavi/qty
}