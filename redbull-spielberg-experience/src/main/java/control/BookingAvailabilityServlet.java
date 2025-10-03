package control;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/booking/availability")
public class BookingAvailabilityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DataSource jndiDataSource; // opzionale via JNDI

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            InitialContext ic = new InitialContext();
            this.jndiDataSource = (DataSource) ic.lookup("java:comp/env/jdbc/redbull");
        } catch (NamingException ignore) {
            this.jndiDataSource = null; // fallback su utils.DatabaseConnection
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        String pid = nz(req.getParameter("productId"));
        if (pid.isEmpty()) { bad(resp, "productId mancante"); return; }

        int productId;
        try { productId = Integer.parseInt(pid); }
        catch (NumberFormatException nfe) { bad(resp, "productId non valido"); return; }

        // start=YYYY-MM-DD (opz), days=21 (default, max 90)
        LocalDate start = LocalDate.now();
        String startParam = nz(req.getParameter("start"));
        if (!startParam.isEmpty()) {
            try { start = LocalDate.parse(startParam); } catch (Exception ignore) {}
        }
        int days = 21;
        String daysParam = nz(req.getParameter("days"));
        if (!daysParam.isEmpty()) {
            try { days = Math.max(1, Math.min(90, Integer.parseInt(daysParam))); } catch (NumberFormatException ignore) {}
        }
        LocalDate endExcl = start.plusDays(days); // [start, end)

        try (Connection con = obtainConnection()) {

            // Mappa date -> posti rimanenti
            Map<LocalDate, Integer> remainingByDay = new LinkedHashMap<>();
            for (LocalDate d = start; d.isBefore(endExcl); d = d.plusDays(1)) {
                remainingByDay.put(d, 0);
            }

            String sql =
                "SELECT slot_date AS d, " +
                "       COALESCE(SUM(CASE WHEN (max_capacity - booked_capacity) > 0 " +
                "           THEN (max_capacity - booked_capacity) ELSE 0 END), 0) AS remaining " +
                "FROM time_slots " +
                "WHERE product_id = ? AND slot_date >= ? AND slot_date < ? " +
                "GROUP BY d ORDER BY d";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, productId);
                ps.setDate(2, Date.valueOf(start));
                ps.setDate(3, Date.valueOf(endExcl));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Date d = rs.getDate("d");
                        int rem = rs.getInt("remaining");
                        if (d != null) remainingByDay.put(d.toLocalDate(), Math.max(0, rem));
                    }
                }
            }

            // JSON
            StringBuilder sb = new StringBuilder(256);
            sb.append("{\"days\":[");
            boolean first = true;
            for (Map.Entry<LocalDate,Integer> e : remainingByDay.entrySet()) {
                if (!first) sb.append(',');
                first = false;
                sb.append("{\"date\":\"").append(e.getKey()).append("\",\"remaining\":").append(e.getValue()).append('}');
            }
            sb.append("]}");
            write(resp, sb.toString());

        } catch (Exception ex) {
            ex.printStackTrace();
            error(resp, "Errore nel calcolo disponibilità");
        }
    }

    // ==== Connection helpers (JNDI -> utils.DatabaseConnection fallback) ====
    private Connection obtainConnection() throws Exception {
        if (jndiDataSource != null) return jndiDataSource.getConnection();

        try {
            Class<?> c = Class.forName("utils.DatabaseConnection");

            // static getConnection()
            try {
                var m = c.getMethod("getConnection");
                if (java.lang.reflect.Modifier.isStatic(m.getModifiers())) {
                    Object res = m.invoke(null);
                    if (res instanceof Connection) return (Connection) res;
                }
            } catch (NoSuchMethodException ignore) {}

            // static getInstance()/get() -> .getConnection()
            for (String name : new String[]{"getInstance", "get"}) {
                try {
                    var getInst = c.getMethod(name);
                    if (java.lang.reflect.Modifier.isStatic(getInst.getModifiers())) {
                        Object inst = getInst.invoke(null);
                        if (inst != null) {
                            try {
                                var m2 = inst.getClass().getMethod("getConnection");
                                Object res = m2.invoke(inst);
                                if (res instanceof Connection) return (Connection) res;
                            } catch (NoSuchMethodException ignore) {}
                        }
                    }
                    break;
                } catch (NoSuchMethodException ignore) {}
            }

            // static getDataSource()
            try {
                var m = c.getMethod("getDataSource");
                if (java.lang.reflect.Modifier.isStatic(m.getModifiers())) {
                    Object res = m.invoke(null);
                    if (res instanceof DataSource ds) return ds.getConnection();
                }
            } catch (NoSuchMethodException ignore) {}

            throw new IllegalStateException("Impossibile ottenere Connection da utils.DatabaseConnection");
        } catch (ClassNotFoundException cnf) {
            throw new IllegalStateException("Né JNDI né utils.DatabaseConnection disponibili");
        }
    }

    // ==== small utils ====
    private static String nz(String s){ return s==null? "": s.trim(); }
    private static void write(HttpServletResponse resp, String json) throws IOException {
        try (PrintWriter out = resp.getWriter()) { out.write(json); }
    }
    private static void bad(HttpServletResponse resp, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        write(resp, "{\"error\":\""+msg.replace("\"","\\\"")+"\"}");
    }
    private static void error(HttpServletResponse resp, String msg) throws IOException {
        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        write(resp, "{\"error\":\""+msg.replace("\"","\\\"")+"\"}");
    }
}