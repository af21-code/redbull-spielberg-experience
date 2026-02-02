package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Category;
import model.dao.CategoryDAO;
import model.dao.impl.CategoryDAOImpl;
import utils.SecurityUtils;

import java.io.IOException;
import java.util.List;

public class AdminCategoriesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        this.categoryDAO = new CategoryDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // --- Accesso solo ADMIN ---
        HttpSession session = req.getSession(false);
        if (!SecurityUtils.isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        // --- Parametri ---
        String q = req.getParameter("q");
        String sort = req.getParameter("sort");
        String dir = req.getParameter("dir");
        String inactiveStr = req.getParameter("onlyInactive");
        Boolean onlyInactive = (inactiveStr != null) && inactiveStr.equals("1");

        // Defaults
        if (sort == null || sort.isEmpty())
            sort = "created_at";
        if (dir == null || dir.isEmpty())
            dir = "DESC";

        int limit = 10;
        int page = 1;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null)
                page = Integer.parseInt(pStr);
        } catch (Exception ignore) {
        }
        int offset = (page - 1) * limit;

        // --- Query helper: count ---
        // Warning: categoryDAO doesn't accept paging count.
        // For simplicity in this fix, we might not have total count easily unless added
        // to DAO.
        // Let's just fetch the list. Pagination might be "next/prev" only if we don't
        // know total.
        // Or we can modify DAO to return count.
        // Given constraints, I'll just implementations simple list for now.

        List<Category> categories = categoryDAO.adminFindAllPaged(q, onlyInactive, sort, dir, limit, offset);

        req.setAttribute("categories", categories);
        req.setAttribute("page", page);
        // req.setAttribute("total", ...); // DAO doesn't support count yet.

        req.getRequestDispatcher("/views/admin/categories.jsp").forward(req, resp);
    }
}
