package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;

import utils.DatabaseConnection;
import utils.SecurityUtils;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * REST: GET /admin/stats?from=YYYY-MM-DD&to=YYYY-MM-DD
 * Risposta JSON:
 * {
 * "kpi": {"orders":N, "paidOrders":N, "revenue":123.45, "avgOrder":12.34},
 * "series":[{"date":"2025-09-20","orders":2,"revenue":199.98}, ...]
 * }
 * Protetto da AuthFilter su /admin/*.
 */
public class AdminStatsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    public void init() throws ServletException {
        super.init();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        if (!SecurityUtils.isAdmin(req.getSession(false))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        LocalDate today = LocalDate.now();
        String fromStr = nz(req.getParameter("from"));
        String toStr = nz(req.getParameter("to"));

        LocalDate from = fromStr.isEmpty() ? today.minusDays(6) : parseDateSafe(fromStr);
        LocalDate to = toStr.isEmpty() ? today : parseDateSafe(toStr);

        if (from == null || to == null) {
            bad(resp, "Parametri 'from'/'to' non validi (YYYY-MM-DD).");
            return;
        }
        if (to.isBefore(from)) {
            bad(resp, "'to' non può precedere 'from'.");
            return;
        }
        if (from.plusDays(180).isBefore(to)) {
            bad(resp, "Intervallo troppo ampio (max 180 giorni).");
            return;
        }

        try (Connection con = DatabaseConnection.getInstance().getConnection()) {

            Kpi kpi = loadKpi(con, from, to);
            Map<LocalDate, DayRow> series = loadSeries(con, from, to);

            // completa giorni mancanti (senza lambda inutilizzato)
            for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
                if (!series.containsKey(d)) {
                    series.put(d, new DayRow(0, BigDecimal.ZERO));
                }
            }

            // costruisci JSON
            StringBuilder sb = new StringBuilder(256);
            sb.append("{\"kpi\":{");
            sb.append("\"orders\":").append(kpi.orders).append(",");
            sb.append("\"paidOrders\":").append(kpi.paidOrders).append(",");
            sb.append("\"revenue\":").append(kpi.revenue.toPlainString());
            BigDecimal avg = (kpi.paidOrders > 0)
                    ? safeDiv(kpi.revenue, new BigDecimal(kpi.paidOrders))
                    : BigDecimal.ZERO;
            sb.append(",\"avgOrder\":").append(avg.toPlainString());
            sb.append("},\"series\":[");

            boolean first = true;
            for (Map.Entry<LocalDate, DayRow> e : series.entrySet()) {
                if (!first)
                    sb.append(',');
                first = false;
                sb.append("{\"date\":\"").append(e.getKey()).append("\",");
                sb.append("\"orders\":").append(e.getValue().orders).append(",");
                sb.append("\"revenue\":").append(e.getValue().revenue.toPlainString());
                sb.append('}');
            }
            sb.append("]}");

            write(resp, sb.toString());

        } catch (Exception ex) {
            ex.printStackTrace();
            error(resp, "Errore interno nel calcolo statistiche.");
        }
    }

    // ===== Query =====

    private static Kpi loadKpi(Connection con, LocalDate from, LocalDate to) throws SQLException {
        String sql = """
                SELECT
                  COUNT(*)                                                               AS total_orders,
                  SUM(CASE WHEN payment_status='PAID' THEN 1 ELSE 0 END)                 AS paid_orders,
                  COALESCE(SUM(CASE WHEN payment_status='PAID' THEN total_amount END),0) AS revenue
                FROM orders
                WHERE order_date >= ? AND order_date < ?
                """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(from.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Kpi(
                            rs.getInt("total_orders"),
                            rs.getInt("paid_orders"),
                            rs.getBigDecimal("revenue"));
                }
            }
        }
        return new Kpi(0, 0, BigDecimal.ZERO);
    }

    private static Map<LocalDate, DayRow> loadSeries(Connection con, LocalDate from, LocalDate to) throws SQLException {
        String sql = """
                SELECT DATE(order_date) AS d,
                       COUNT(*) AS orders,
                       COALESCE(SUM(CASE WHEN payment_status='PAID' THEN total_amount END),0) AS revenue
                FROM orders
                WHERE order_date >= ? AND order_date < ?
                GROUP BY d
                ORDER BY d
                """;
        Map<LocalDate, DayRow> out = new LinkedHashMap<>();
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(from.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(to.plusDays(1).atStartOfDay()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LocalDate d = rs.getDate("d").toLocalDate();
                    out.put(d, new DayRow(
                            rs.getInt("orders"),
                            rs.getBigDecimal("revenue")));
                }
            }
        }
        return out;
    }

    // ===== Utils =====

    private static String nz(String s) {
        return s == null ? "" : s.trim();
    }

    private static LocalDate parseDateSafe(String iso) {
        try {
            return LocalDate.parse(iso);
        } catch (Exception e) {
            return null;
        }
    }

    private static void write(HttpServletResponse resp, String json) throws IOException {
        try (PrintWriter out = resp.getWriter()) {
            out.write(json);
        }
    }

    private static void bad(HttpServletResponse resp, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        write(resp, "{\"error\":\"" + msg.replace("\"", "\\\"") + "\"}");
    }

    private static void error(HttpServletResponse resp, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        write(resp, "{\"error\":\"" + msg.replace("\"", "\\\"") + "\"}");
    }

    private static class Kpi {
        int orders, paidOrders;
        BigDecimal revenue;

        Kpi(int o, int p, BigDecimal r) {
            orders = o;
            paidOrders = p;
            revenue = (r == null ? BigDecimal.ZERO : r);
        }
    }

    private static class DayRow {
        int orders;
        BigDecimal revenue;

        DayRow(int o, BigDecimal r) {
            orders = o;
            revenue = (r == null ? BigDecimal.ZERO : r);
        }
    }

    private static BigDecimal safeDiv(BigDecimal a, BigDecimal b) {
        if (b == null || BigDecimal.ZERO.compareTo(b) == 0)
            return BigDecimal.ZERO;
        return a.divide(b, 2, java.math.RoundingMode.HALF_UP).stripTrailingZeros();
    }
}