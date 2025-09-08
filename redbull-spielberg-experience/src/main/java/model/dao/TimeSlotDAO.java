package model.dao;

import model.TimeSlot;

import java.time.LocalDate;
import java.util.List;

public interface TimeSlotDAO {
    /**
     * Tutti gli slot futuri disponibili per un prodotto.
     */
    List<TimeSlot> findAvailableByProduct(int productId) throws Exception;

    /**
     * Slot disponibili per un prodotto in una data specifica (yyyy-MM-dd).
     */
    List<TimeSlot> findAvailableByProductAndDate(int productId, LocalDate date) throws Exception;

    /**
     * Recupera un singolo slot.
     */
    TimeSlot findById(int slotId) throws Exception;
}