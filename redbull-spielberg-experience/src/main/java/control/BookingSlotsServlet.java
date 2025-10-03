package control;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

import model.TimeSlot;
import model.dao.TimeSlotDAO;
import model.dao.impl.TimeSlotDAOImpl;

@WebServlet("/booking/slots")
public class BookingSlotsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        String pidStr  = req.getParameter("productId");
        String dateStr = req.getParameter("date");
        if (pidStr == null || dateStr == null || pidStr.isBlank() || dateStr.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Parametri mancanti (productId, date)");
            return;
        }

        final int productId;
        final LocalDate date;
        try { productId = Integer.parseInt(pidStr); }
        catch (Exception e) { writeError(resp, 400, "productId non valido"); return; }

        try { date = LocalDate.parse(dateStr); }
        catch (DateTimeParseException e) { writeError(resp, 400, "date non valida (YYYY-MM-DD)"); return; }

        try {
            List<TimeSlot> slots = timeSlotDAO.findAvailableByProductAndDate(productId, date);

            int totalRemaining = 0;
            StringBuilder sb = new StringBuilder(512);
            sb.append("{\"date\":\"").append(date).append("\",");
            sb.append("\"slots\":[");
            boolean first = true;
            for (TimeSlot t : slots) {
                int rem = Math.max(0, t.getMaxCapacity() - t.getBookedCapacity());
                totalRemaining += rem;
                boolean soldOut = rem <= 0;

                if (!first) sb.append(',');
                first = false;

                sb.append("{\"id\":").append(t.getSlotId())
                  .append(",\"time\":\"").append(escape(t.getSlotTime().toString())).append("\"")
                  .append(",\"remaining\":").append(rem)
                  .append(",\"soldOut\":").append(soldOut)
                  .append(",\"label\":\"")
                  .append(escape(t.getSlotTime().toString())).append(" · posti ").append(rem)
                  .append("\"}");
            }
            sb.append("],\"totalRemaining\":").append(totalRemaining).append('}');

            try (PrintWriter out = resp.getWriter()) {
                out.write(sb.toString());
            }
        } catch (Exception ex) {
            writeError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore interno");
        }
    }

    private static String escape(String s){
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static void writeError(HttpServletResponse resp, int code, String msg) throws IOException {
        resp.setStatus(code);
        try (PrintWriter out = resp.getWriter()) {
            out.write("{\"error\":\"" + escape(msg) + "\"}");
        }
    }
}