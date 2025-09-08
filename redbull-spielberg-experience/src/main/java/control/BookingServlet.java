package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

import model.Product;
import model.TimeSlot;
import model.dao.ProductDAO;
import model.dao.TimeSlotDAO;
import model.dao.impl.ProductDAOImpl;
import model.dao.impl.TimeSlotDAOImpl;

@WebServlet("/booking")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAOImpl();
    private final ProductDAO  productDAO  = new ProductDAOImpl();

    // Semplice DTO interno per veicoli
    public static class VehicleOption {
        private final String code;   // es. RB21
        private final String label;  // es. F1 RB-21
        private final String specs;  // es. "V6 Turbo Hybrid · 1000+ CV"
        public VehicleOption(String code, String label, String specs) {
            this.code = code;
            this.label = label;
            this.specs = specs;
        }
        public String getCode()  { return code; }
        public String getLabel() { return label; }
        public String getSpecs() { return specs; }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ctx = req.getContextPath();
        String pid = req.getParameter("productId");
        if (pid == null || pid.isBlank()) {
            resp.sendRedirect(ctx + "/shop");
            return;
        }

        final int productId;
        try {
            productId = Integer.parseInt(pid);
        } catch (NumberFormatException nfe) {
            resp.sendRedirect(ctx + "/shop");
            return;
        }

        try {
            // 1) Carico prodotto e verifico sia un’ESPERIENZA
            Product product = productDAO.findById(productId);
            if (product == null || product.getProductType() != Product.ProductType.EXPERIENCE) {
                // prodotto non valido per la prenotazione
                resp.sendRedirect(ctx + "/shop");
                return;
            }

            // 2) Eventuale filtro data
            String dateParam = req.getParameter("date"); // atteso yyyy-MM-dd
            List<TimeSlot> slots;
            LocalDate selectedDate = null;

            if (dateParam != null && !dateParam.isBlank()) {
                try {
                    selectedDate = LocalDate.parse(dateParam);
                    slots = timeSlotDAO.findAvailableByProductAndDate(productId, selectedDate);
                } catch (DateTimeParseException dtpe) {
                    // formato data non valido: fallback a tutti gli slot futuri
                    slots = timeSlotDAO.findAvailableByProduct(productId);
                }
            } else {
                // senza filtro: tutti gli slot futuri disponibili
                slots = timeSlotDAO.findAvailableByProduct(productId);
            }

            // 3) Preparo lista veicoli da mostrare nella JSP (puoi spostarla a DB in futuro)
            List<VehicleOption> vehicles = new ArrayList<>();
            vehicles.add(new VehicleOption("RB21", "F1 RB-21",        "V6 Turbo Hybrid · ~1000 CV · Slicks"));
            vehicles.add(new VehicleOption("F2RB", "F2 Red Bull",     "V6 aspirato · ~620 CV · Monoposto scuola"));
            vehicles.add(new VehicleOption("NASC", "NASCAR Red Bull", "V8 ~750 CV · Cambio manuale · Stock car"));

            // 4) Attributi per la JSP
            req.setAttribute("product", product);
            req.setAttribute("productId", productId);
            req.setAttribute("selectedDate", selectedDate);
            req.setAttribute("slots", slots);
            req.setAttribute("vehicles", vehicles);

            // 5) Forward alla pagina
            req.getRequestDispatcher("/views/booking.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Errore nel caricamento degli slot", e);
        }
    }

    // doPost lo useremo per confermare la prenotazione (aggiunta al carrello / pagamento)
}