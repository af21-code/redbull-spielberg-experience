package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.dao.ProductDAO;
import model.dao.impl.ProductDAOImpl;
import utils.SecurityUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = "/admin/products/delete")
public class AdminProductDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private boolean checkCsrf(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null)
            return false;
        String token = (String) s.getAttribute("csrfToken");
        String provided = req.getParameter("csrf");
        return token != null && token.equals(provided);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!SecurityUtils.isAdmin(req.getSession(false))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (!checkCsrf(req)) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CSRF token mancante/non valido");
            return;
        }

        String idStr = req.getParameter("id");
        String back = req.getHeader("Referer");
        if (back == null || back.isBlank())
            back = req.getContextPath() + "/admin/products";

        try {
            int id = Integer.parseInt(idStr);
            ProductDAO dao = new ProductDAOImpl();
            dao.softDelete(id);
            resp.sendRedirect(backWith(back, "ok", "Prodotto disattivato"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(backWith(back, "err", "Errore: " + e.getMessage()));
        }
    }

    private String backWith(String url, String k, String v) {
        String sep = url.contains("?") ? "&" : "?";
        String enc = java.net.URLEncoder.encode(v, StandardCharsets.UTF_8);
        return url + sep + k + "=" + enc;
    }
}