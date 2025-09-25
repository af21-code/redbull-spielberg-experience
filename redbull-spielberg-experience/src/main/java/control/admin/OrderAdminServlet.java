package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.User;
import model.dao.OrderDAO;
import model.dao.impl.OrderDAOImpl;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/orders")
public class OrderAdminServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final OrderDAO orderDAO = new OrderDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null || auth.getUserType() == null || !"ADMIN".equalsIgnoreCase(String.valueOf(auth.getUserType()))) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        // --- Filtri ---
        String fromStr  = trim(req.getParameter("from"));     // yyyy-MM-dd
        String toStr    = trim(req.getParameter("to"));       // yyyy-MM-dd
        String q        = trim(req.getParameter("q"));        // email o nome/cognome
        String status   = trim(req.getParameter("status"));   // PENDING/CONFIRMED/PROCESSING/COMPLETED/CANCELLED
        String export   = trim(req.getParameter("export"));   // "csv" per export

        int pageParam  = parseInt(req.getParameter("page"), 1);
        int pageSize   = parseInt(req.getParameter("pageSize"), 20);
        if (pageSize != 10 && pageSize != 20 && pageSize != 50 && pageSize != 100) pageSize = 20;

        Date from = parseSqlDate(fromStr);
        Date to   = parseSqlDate(toStr);

        try {
            // --- Export CSV (opzionale) ---
            if ("csv".equalsIgnoreCase(export)) {
                exportCsv(resp, from, to, q, status);
                return;
            }

            // --- Lista paginata ---
            int total = orderDAO.countOrdersAdmin(from, to, q, status);
            int pages = (int) Math.ceil(total / (double) pageSize);
            if (pages <= 0) pages = 1;

            int page = Math.max(1, Math.min(pageParam, pages));
            int offset = (page - 1) * pageSize;

            List<Map<String,Object>> orders = orderDAO.findOrdersAdmin(from, to, q, status, offset, pageSize);

            // --- Attributi view ---
            req.setAttribute("orders", orders);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("pages", pages);

            req.setAttribute("from", fromStr);
            req.setAttribute("to", toStr);
            req.setAttribute("q", q);
            req.setAttribute("status", status);

            req.getRequestDispatcher("/views/admin/orders.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Errore nel caricamento ordini admin.");
        }
    }

    // ---------------- CSV export ----------------

    private void exportCsv(HttpServletResponse resp,
                           Date from, Date to,
                           String q, String status) throws ServletException, IOException {
        try {
            // Esportiamo un numero ampio ma ragionevole di righe
            List<Map<String,Object>> rows =
                    orderDAO.findOrdersAdmin(from, to, q, status, 0, 10000);

            resp.setCharacterEncoding("UTF-8");
            resp.setContentType("text/csv; charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=\"orders.csv\"");

            SimpleDateFormat dtf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            try (PrintWriter w = resp.getWriter()) {
                // BOM per Excel
                w.write('\uFEFF');

                // intestazione (includo anche payment_method per coerenza con la JSP)
                w.println("order_id,order_number,order_date,customer,total_amount,status,payment_status,payment_method");

                for (Map<String,Object> r : rows) {
                    String orderId   = s(r.get("order_id"));
                    String onum      = s(r.get("order_number"));
                    String customer  = s(r.get("customer"));
                    BigDecimal tot   = (BigDecimal) r.get("total_amount");
                    String st        = s(r.get("status"));
                    String paySt     = s(r.get("payment_status"));
                    String payMeth   = s(r.get("payment_method"));

                    String dateStr = "";
                    Object tsObj = r.get("order_date");
                    if (tsObj instanceof Timestamp) dateStr = dtf.format((Timestamp) tsObj);
                    else if (tsObj != null)         dateStr = s(tsObj);

                    // CSV semplice con sanificazione di virgole e CR/LF
                    w.printf("%s,%s,%s,%s,%s,%s,%s,%s%n",
                            sanitize(orderId),
                            sanitize(onum),
                            sanitize(dateStr),
                            sanitize(customer),
                            (tot == null ? "0" : tot.toPlainString()),
                            sanitize(st),
                            sanitize(paySt),
                            sanitize(payMeth));
                }
            }
        } catch (Exception e) {
            throw new ServletException("Errore durante l'export CSV", e);
        }
    }

    // ---------------- helpers ----------------
    private static String trim(String s) { return s == null ? null : s.trim(); }

    private static int parseInt(String s, int def) {
        try { return (s == null || s.isBlank()) ? def : Integer.parseInt(s); }
        catch (Exception e) { return def; }
    }

    private static Date parseSqlDate(String s) {
        try { return (s == null || s.isBlank()) ? null : Date.valueOf(s); }
        catch (Exception e) { return null; }
    }

    private static String s(Object o) { return (o == null) ? "" : String.valueOf(o); }

    /** Rimuove CR/LF e virgole per non rompere il CSV "semplice". */
    private static String sanitize(String s) {
        if (s == null) return "";
        return s.replaceAll("[\\r\\n,]+", " ").trim();
    }
}