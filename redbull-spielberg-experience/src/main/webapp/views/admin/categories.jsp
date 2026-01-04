<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page import="java.util.*, model.Category" %>
    <%! private static String esc(Object o){ if (o==null) return "" ; String s=String.valueOf(o); return
      s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
      .replace("\"","&quot;").replace("'","&#39;");
      }
      %>
      <% String ctx=request.getContextPath(); List<Category> categories = (List<Category>)
          request.getAttribute("categories");
          if (categories == null) categories = new ArrayList<>();

            String ok = request.getParameter("ok");
            String err = request.getParameter("err");
            %>
            <!DOCTYPE html>
            <html lang="it">

            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1" />
              <title>Admin • Categorie</title>
              <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
              <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
            </head>

            <body>
              <jsp:include page="/views/header.jsp" />

              <div class="admin-bg">
                <div class="container-1100">

                  <div class="top">
                    <h2 class="mt-0">Categorie</h2>
                    <a class="btn" href="<%=ctx%>/admin/categories/edit">+ Aggiungi Categoria</a>
                  </div>

                  <% if (ok !=null) { %>
                    <div class="chip success mb-12">
                      <%= esc(ok) %>
                    </div>
                    <% } %>
                      <% if (err !=null) { %>
                        <div class="err mb-12">
                          <%= esc(err) %>
                        </div>
                        <% } %>

                          <div class="card">
                            <table>
                              <thead>
                                <tr>
                                  <th>ID</th>
                                  <th>Nome</th>
                                  <th>Descrizione</th>
                                  <th>Attiva</th>
                                  <th>Azioni</th>
                                </tr>
                              </thead>
                              <tbody>
                                <% if (categories.isEmpty()) { %>
                                  <tr>
                                    <td colspan="5" class="muted">Nessuna categoria trovata.</td>
                                  </tr>
                                  <% } %>
                                    <% for (Category c : categories) { %>
                                      <tr>
                                        <td>
                                          <%= c.getCategoryId() %>
                                        </td>
                                        <td><strong>
                                            <%= esc(c.getName()) %>
                                          </strong></td>
                                        <td class="muted">
                                          <%= esc(c.getDescription()) %>
                                        </td>
                                        <td>
                                          <span class="chip <%= c.isActive()?" success":"warn" %>">
                                            <%= c.isActive()?"SI":"NO" %>
                                          </span>
                                        </td>
                                        <td>
                                          <a class="btn sm outline"
                                            href="<%=ctx%>/admin/categories/edit?id=<%= c.getCategoryId() %>">Modifica</a>
                                        </td>
                                      </tr>
                                      <% } %>
                              </tbody>
                            </table>
                          </div>

                </div>
              </div>

              <jsp:include page="/views/footer.jsp" />
            </body>

            </html>