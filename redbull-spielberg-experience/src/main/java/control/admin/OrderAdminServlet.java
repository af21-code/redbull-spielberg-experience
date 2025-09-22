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
        int page        = parseInt(req.getParameter("page"), 1);
        int pageSize    = parseInt(req.getParameter("pageSize"), 20);
        if (pageSize <= 0 || pageSize > 200) pageSize = 20;
        int offset      = (page - 1) * pageSize;

        Date from = parseSqlDate(fromStr);
        Date to   = parseSqlDate(toStr);

        try {
            // --- Export CSV (opzionale) ---
            if ("csv".equalsIgnoreCase(export)) {
                List<Map<String,Object>> rows = orderDAO.findOrdersAdmin(from, to, q, status, 0, 5000);
                resp.setContentType("text/csv;charset=UTF-8");
                resp.setHeader("Content-Disposition", "attachment; filename=\"orders.csv\"");
                try (PrintWriter w = resp.getWriter()) {
                    w.println("order_id,order_number,order_date,customer,total_amount,status,payment_status");
                    for (Map<String,Object> r : rows) {
                        String onum = String.valueOf(r.get("order_number"));
                        String date = String.valueOf(r.get("order_date"));
                        String cust = (String) r.get("customer");
                        BigDecimal tot = (BigDecimal) r.get("total_amount");
                        String st   = String.valueOf(r.get("status"));
                        String pay  = String.valueOf(r.get("payment_status"));
                        w.printf("%s,%s,%s,%s,%s,%s,%s%n",
                                r.get("order_id"), sanitize(onum), sanitize(date), sanitize(cust),
                                tot==null?"0":tot.toPlainString(), sanitize(st), sanitize(pay));
                    }
                }
                return;
            }

            // --- Lista paginata ---
            int total = orderDAO.countOrdersAdmin(from, to, q, status);
            List<Map<String,Object>> orders = orderDAO.findOrdersAdmin(from, to, q, status, offset, pageSize);
            int totalPages = (int) Math.ceil(total / (double) pageSize);

            // --- Attributi view ---
            req.setAttribute("orders", orders);
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("pages", totalPages);

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
    private static String sanitize(String s) {
        if (s == null) return "";
        return s.replaceAll("[\\r\\n,]+", " ").trim();
    }
}