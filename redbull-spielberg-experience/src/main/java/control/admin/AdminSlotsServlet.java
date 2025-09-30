package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import java.io.IOException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.sql.Date;         // attenzione: java.sql.Date
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Admin: Gestione slot prenotazioni Experience.
 *
 * GET  /admin/slots           -> mostra form
 * POST /admin/slots/generate  -> genera slot nel DB
 */
public class AdminSlotsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private DataSource jndiDataSource; // opzionale

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            InitialContext ic = new InitialContext();
            this.jndiDataSource = (DataSource) ic.lookup("java:comp/env/jdbc/redbull");
        } catch (NamingException ignore) {
            this.jndiDataSource = null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- lettura parametri ---
        String pidStr   = nz(req.getParameter("productId"));
        String startStr = nz(req.getParameter("start"));
        String daysStr  = nz(req.getParameter("days"));
        String timesStr = nz(req.getParameter("times"));
        String capStr   = nz(req.getParameter("capacity"));

        if (timesStr.isEmpty()) timesStr = "09:00,11:00,14:00,16:00";

        int productId;
        try { productId = Integer.parseInt(pidStr); }
        catch (Exception e) {
            flash(req, "ProductId non valido.");
            req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);
            return;
        }

        LocalDate start = startStr.isEmpty() ? LocalDate.now() : parseDateSafe(startStr);
        if (start == null) {
            flash(req, "Data di inizio non valida (usa YYYY-MM-DD).");
            req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);
            return;
        }

        int days = 90;
        try { if (!daysStr.isEmpty()) days = Math.max(1, Integer.parseInt(daysStr)); } catch (Exception ignore) {}

        int capacity = 8;
        try { if (!capStr.isEmpty()) capacity = Math.max(1, Integer.parseInt(capStr)); } catch (Exception ignore) {}

        // parse orari
        List<LocalTime> times = new ArrayList<>();
        for (String t : timesStr.split(",")) {
            String s = t.trim();
            if (s.isEmpty()) continue;
            try { times.add(LocalTime.parse(s)); } catch (Exception ignore) {}
        }
        if (times.isEmpty()) {
            flash(req, "Nessun orario valido. Usa formato HH:mm, es. 09:00,11:00,14:00.");
            req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);
            return;
        }

        // --- esecuzione ---
        int inserted = 0;
        int skipped  = 0;

        try (Connection con = obtainConnection()) {
            con.setAutoCommit(false);

            final String sqlCheck = "SELECT slot_id FROM time_slots WHERE product_id=? AND slot_date=? AND slot_time=?";
            final String sqlIns   = "INSERT INTO time_slots(product_id, slot_date, slot_time, max_capacity, booked_capacity) VALUES (?,?,?,?,0)";

            try (PreparedStatement psCheck = con.prepareStatement(sqlCheck);
                 PreparedStatement psIns   = con.prepareStatement(sqlIns)) {

                for (int i = 0; i < days; i++) {
                    LocalDate d = start.plusDays(i);
                    Date sqlDate = Date.valueOf(d); // java.sql.Date

                    for (LocalTime lt : times) {
                        psCheck.clearParameters();
                        psCheck.setInt(1, productId);
                        psCheck.setDate(2, sqlDate);
                        psCheck.setTime(3, Time.valueOf(lt));
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                skipped++;
                            } else {
                                psIns.clearParameters();
                                psIns.setInt(1, productId);
                                psIns.setDate(2, sqlDate);
                                psIns.setTime(3, Time.valueOf(lt));
                                psIns.setInt(4, capacity);
                                psIns.executeUpdate();
                                inserted++;
                            }
                        }
                    }
                }
                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            }

            // feedback alla pagina
            req.setAttribute("result_ok", true);
            req.setAttribute("result_msg", "Generazione completata: inseriti " + inserted + " slot, saltati (già presenti) " + skipped + ".");
            req.setAttribute("echo_productId", productId);
            req.setAttribute("echo_start", start.toString());
            req.setAttribute("echo_days", days);
            req.setAttribute("echo_times", timesStr);
            req.setAttribute("echo_capacity", capacity);

            req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);

        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("result_ok", false);
            req.setAttribute("result_msg", "Errore durante la generazione: " + safe(ex.getMessage()));
            req.getRequestDispatcher("/views/admin/slots.jsp").forward(req, resp);
        }
    }

    // ====== infra ======

    private Connection obtainConnection() throws Exception {
        if (jndiDataSource != null) return jndiDataSource.getConnection();

        // Fallback dinamico su utils.DatabaseConnection (varie firme comuni)
        try {
            Class<?> c = Class.forName("utils.DatabaseConnection");

            // static Connection getConnection()
            try {
                Method m = c.getMethod("getConnection");
                if (Modifier.isStatic(m.getModifiers())) {
                    Object res = m.invoke(null);
                    if (res instanceof Connection) return (Connection) res;
                }
            } catch (NoSuchMethodException ignore) {}

            // static getInstance()/get() -> instance.getConnection()
            Method getInst = null;
            for (String name : new String[]{"getInstance", "get"}) {
                try { getInst = c.getMethod(name); break; }
                catch (NoSuchMethodException ignore) {}
            }
            if (getInst != null && Modifier.isStatic(getInst.getModifiers())) {
                Object inst = getInst.invoke(null);
                if (inst != null) {
                    try {
                        Method m = inst.getClass().getMethod("getConnection");
                        Object res = m.invoke(inst);
                        if (res instanceof Connection) return (Connection) res;
                    } catch (NoSuchMethodException ignore) {}
                }
            }

            // static DataSource getDataSource()
            try {
                Method m = c.getMethod("getDataSource");
                if (Modifier.isStatic(m.getModifiers())) {
                    Object res = m.invoke(null);
                    if (res instanceof DataSource ds) return ds.getConnection();
                }
            } catch (NoSuchMethodException ignore) {}

            throw new IllegalStateException("Impossibile ottenere Connection da utils.DatabaseConnection");

        } catch (ClassNotFoundException cnf) {
            throw new IllegalStateException("Né JNDI né utils.DatabaseConnection disponibili");
        }
    }

    private static String nz(String s){ return s==null ? "" : s.trim(); }
    private static String safe(String s){ return s==null ? "" : s.replace("\"","'"); }
    private static LocalDate parseDateSafe(String s){
        try { return LocalDate.parse(s); } catch(Exception e){ return null; }
    }
    private static void flash(HttpServletRequest req, String msg){
        req.setAttribute("result_ok", false);
        req.setAttribute("result_msg", msg);
    }
}