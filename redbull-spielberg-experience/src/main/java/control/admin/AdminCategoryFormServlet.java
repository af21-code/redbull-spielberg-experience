package control.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import model.Category;
import model.dao.CategoryDAO;
import model.dao.impl.CategoryDAOImpl;
import utils.SecurityUtils;

import java.io.IOException;

public class AdminCategoryFormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        this.categoryDAO = new CategoryDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (!SecurityUtils.isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        String idStr = req.getParameter("id");
        Category category = null;
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                category = categoryDAO.adminFindById(id);
            } catch (NumberFormatException ignore) {
            }
        }

        req.setAttribute("category", category);
        req.getRequestDispatcher("/views/admin/category-form.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (!SecurityUtils.isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idStr = req.getParameter("id");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String activeStr = req.getParameter("isActive");
        boolean isActive = "1".equals(activeStr) || "on".equals(activeStr);

        if (name == null || name.trim().isEmpty()) {
            req.setAttribute("error", "Il nome è obbligatorio.");
            doGet(req, resp);
            return;
        }

        Category category = new Category();
        category.setName(name.trim());
        category.setDescription(description != null ? description.trim() : "");
        category.setActive(isActive);

        if (idStr != null && !idStr.isEmpty()) {
            try {
                category.setCategoryId(Integer.parseInt(idStr));
                categoryDAO.update(category);
            } catch (NumberFormatException e) {
                categoryDAO.insert(category);
            }
        } else {
            categoryDAO.insert(category);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories?ok=Categoria+salvata");
    }
}
