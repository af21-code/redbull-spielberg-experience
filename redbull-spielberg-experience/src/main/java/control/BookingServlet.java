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

    /** ViewModel per gli slot (JSP-friendly) */
    public static final class SlotVM {
        private final int slotId;
        private final String label;
        private final boolean soldOut;
        private final boolean checked;

        public SlotVM(int slotId, String label, boolean soldOut, boolean checked) {
            this.slotId = slotId;
            this.label = label;
            this.soldOut = soldOut;
            this.checked = checked;
        }
        public int getSlotId()      { return slotId; }
        public String getLabel()    { return label; }
        public boolean isSoldOut()  { return soldOut; }
        public boolean isChecked()  { return checked; }
    }

    /** ViewModel per i veicoli (JSP-friendly) */
    public static final class VehicleVM {
        private final String code, label, specs, img;
        private final boolean featured, checked;

        public VehicleVM(String code, String label, String specs, String img, boolean featured, boolean checked) {
            this.code = code; this.label = label; this.specs = specs; this.img = img;
            this.featured = featured; this.checked = checked;
        }
        public String getCode()     { return code; }
        public String getLabel()    { return label; }
        public String getSpecs()    { return specs; }
        public String getImg()      { return img; }
        public boolean isFeatured() { return featured; }
        public boolean isChecked()  { return checked; }
    }

    /** Opzioni “di catalogo”; tienile qui o spostale a DB in futuro */
    public static final class VehicleOption {
        private final String code, label, specs;
        public VehicleOption(String code, String label, String specs) {
            this.code = code; this.label = label; this.specs = specs;
        }
        public String getCode()  { return code; }
        public String getLabel() { return label; }
        public String getSpecs() { return specs; }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        final String ctx = req.getContextPath();
        final String pid = req.getParameter("productId");
        if (pid == null || pid.isBlank()) { resp.sendRedirect(ctx + "/shop"); return; }

        final int productId;
        try { productId = Integer.parseInt(pid); }
        catch (NumberFormatException nfe) { resp.sendRedirect(ctx + "/shop"); return; }

        try {
            // 1) Prodotto
            Product product = productDAO.findById(productId);
            if (product == null || product.getProductType() != Product.ProductType.EXPERIENCE) {
                resp.sendRedirect(ctx + "/shop");
                return;
            }
            req.setAttribute("product", product);
            req.setAttribute("productId", productId);

            // 2) Data selezionata + slot
            String dateParam = req.getParameter("date"); // yyyy-MM-dd
            LocalDate selectedDate = null;
            List<TimeSlot> slots;
            if (dateParam != null && !dateParam.isBlank()) {
                try {
                    selectedDate = LocalDate.parse(dateParam);
                    slots = timeSlotDAO.findAvailableByProductAndDate(productId, selectedDate);
                } catch (DateTimeParseException dtpe) {
                    slots = timeSlotDAO.findAvailableByProduct(productId);
                }
            } else {
                slots = timeSlotDAO.findAvailableByProduct(productId);
            }
            req.setAttribute("selectedDate", selectedDate);

            // 3) Calcolo disponibilità totale + preparo SlotVM (niente logica in JSP)
            int totalRemaining = 0;
            List<SlotVM> slotsVm = new ArrayList<>();
            boolean firstCheckedAssigned = false;
            if (selectedDate != null && slots != null) {
                for (TimeSlot t : slots) {
                    int remaining = t.getMaxCapacity() - t.getBookedCapacity();
                    boolean soldOut = remaining <= 0;
                    if (remaining > 0) totalRemaining += remaining;

                    boolean checked = false;
                    if (!soldOut && !firstCheckedAssigned) {
                        checked = true;
                        firstCheckedAssigned = true;
                    }
                    String label = t.getSlotTime().toString() + " · posti " + Math.max(remaining, 0);
                    slotsVm.add(new SlotVM(t.getSlotId(), label, soldOut, checked));
                }
            }
            req.setAttribute("totalRemaining", totalRemaining);
            req.setAttribute("slotsVm", slotsVm);

            // 4) Veicoli -> VM
            List<VehicleOption> catalog = new ArrayList<>();
            catalog.add(new VehicleOption("RB21", "F1 RB-21",        "V6 Turbo Hybrid · ~1000 CV · Slicks"));
            catalog.add(new VehicleOption("F2RB", "F2 Red Bull",     "V6 aspirato · ~620 CV · Monoposto scuola"));
            catalog.add(new VehicleOption("NASC", "NASCAR Red Bull", "V8 ~750 CV · Cambio manuale · Stock car"));

            String selectedVehicleCode = req.getParameter("vehicleCode");
            List<VehicleVM> vehiclesVm = new ArrayList<>();
            boolean anyVehicleChecked = false;
            for (VehicleOption v : catalog) {
                String code = v.getCode() == null ? "" : v.getCode().toUpperCase();
                String img;
                boolean featured = code.contains("RB21");
                if (featured)                       img = ctx + "/images/vehicles/rb21.jpg";
                else if (code.contains("F2"))       img = ctx + "/images/vehicles/f2.jpg";
                else if (code.contains("NASCAR"))   img = ctx + "/images/vehicles/nascar.jpg";
                else                                img = ctx + "/images/vehicles/placeholder-vehicle.jpg";

                boolean checked;
                if (selectedVehicleCode != null && !selectedVehicleCode.isBlank()) {
                    checked = code.equalsIgnoreCase(selectedVehicleCode);
                } else {
                    checked = !anyVehicleChecked && featured; // default sulla RB21
                }
                if (checked) anyVehicleChecked = true;

                vehiclesVm.add(new VehicleVM(v.getCode(), v.getLabel(), v.getSpecs(), img, featured, checked));
            }
            // se nessuno è checked (es. non c'è RB21), check il primo
            if (!anyVehicleChecked && !vehiclesVm.isEmpty()) {
                VehicleVM first = vehiclesVm.get(0);
                vehiclesVm.set(0, new VehicleVM(first.getCode(), first.getLabel(), first.getSpecs(), first.getImg(), first.isFeatured(), true));
            }
            req.setAttribute("vehiclesVm", vehiclesVm);

            // 5) Contenuti hero già pronti (niente condizioni in JSP)
            final String exp = (product.getExperienceType() != null) ? product.getExperienceType().name() : "BASE";
            String displayName, itShort, itDesc, heroImg, overlayWall = null;
            String redBullHeroImg = "https://media.formula1.com/image/upload/c_lfill,w_3392/q_auto/v1740000000/content/dam/fom-website/manual/Misc/TeamByTeam2023/red-bull-tbt-2023.webp";
            if ("PREMIUM".equalsIgnoreCase(exp)) {
                displayName = "Esperienza Red Bull Ring — Premium";
                itShort     = "Pacchetto Premium: 5 giri, analisi telemetria e tuta personalizzata.";
                itDesc      = "Porta l'esperienza al livello successivo: 5 giri, coaching avanzato con analisi dati, accesso ai box e merchandising esclusivo.";
                heroImg     = redBullHeroImg;
            } else if ("ELITE".equalsIgnoreCase(exp)) {
                displayName = "Esperienza Red Bull Ring — Elite";
                itShort     = "Pacchetto Elite: 10 giri, coaching privato e tour pit lane.";
                itDesc      = "Il massimo: 10 giri, coaching one-to-one, tour esclusivo della pit lane e pacchetto premium di merchandising.";
                heroImg     = (product.getImageUrl()!=null && !product.getImageUrl().isBlank())
                                ? (ctx + "/" + product.getImageUrl())
                                : (ctx + "/images/experience-elite.jpg");
            } else {
                displayName = "Esperienza Red Bull Ring — Standard";
                itShort     = "Pacchetto Standard: 3 giri con istruttore, accesso circuito e kit di benvenuto.";
                itDesc      = "Vivi l'adrenalina del Red Bull Ring con il pacchetto Standard: briefing di sicurezza, 3 giri guidati con coach professionista e accesso alle aree dedicate.";
                heroImg     = redBullHeroImg;
                overlayWall = ctx + "/images/wallpapers/rb-standard-wallpaper.png";
            }
            req.setAttribute("displayName", displayName);
            req.setAttribute("itShort", itShort);
            req.setAttribute("itDesc", itDesc);
            req.setAttribute("heroImg", heroImg);
            req.setAttribute("overlayWall", overlayWall);
            req.setAttribute("expCode", exp.toLowerCase());

            // 6) Versione CSS per cache-busting (senza scriptlet in JSP)
            String cssVer = "1";
            try {
                String realPath = getServletContext().getRealPath("/styles/booking.css");
                if (realPath != null) {
                    java.io.File f = new java.io.File(realPath);
                    if (f.exists()) cssVer = String.valueOf(f.lastModified());
                }
            } catch (Exception ignore) {}
            req.setAttribute("cssVersion", cssVer);

            // 7) Forward alla vista
            req.getRequestDispatcher("/views/booking.jsp").forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Errore nel caricamento della pagina di prenotazione", e);
        }
    }
}