package model.dao;

import model.CartItem;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface OrderDAO {

   
    String createOrder(int userId,
                       List<CartItem> cart,
                       String shippingAddress,
                       String billingAddress,
                       String notes,
                       String paymentMethod) throws Exception;

    
    List<Map<String, Object>> adminList(LocalDate from, LocalDate to, Integer userId) throws Exception;
}