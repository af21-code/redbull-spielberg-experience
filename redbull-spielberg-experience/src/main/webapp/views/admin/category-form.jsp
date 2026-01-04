<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.Category" %>
        <%! private static String esc(Object o){ if (o==null) return "" ; String s=String.valueOf(o); return
            s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
            .replace("\"","&quot;").replace("'","&#39;");
            }
            %>
            <% String ctx=request.getContextPath(); Category category=(Category) request.getAttribute("category");
                boolean isEdit=category !=null && category.getCategoryId()> 0;

                String csrf = (String) request.getAttribute("csrfToken");
                if (csrf == null || csrf.isBlank()) csrf = (String) session.getAttribute("csrfToken");

                String error = (String) request.getAttribute("error");
                %>
                <!DOCTYPE html>
                <html lang="it">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1" />
                    <title>Admin • <%= isEdit ? "Modifica" : "Nuova" %> Categoria</title>
                    <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
                    <link rel="stylesheet" href="<%=ctx%>/styles/admin.css">
                </head>

                <body>
                    <jsp:include page="/views/header.jsp" />

                    <div class="admin-bg">
                        <div class="container-900">

                            <h2 class="mt-0">
                                <%= isEdit ? "Modifica Categoria" : "Nuova Categoria" %>
                            </h2>

                            <% if (error !=null) { %>
                                <div class="err mb-12">
                                    <%= esc(error) %>
                                </div>
                                <% } %>

                                    <div class="card">
                                        <form method="post" action="<%=ctx%>/admin/categories/edit">
                                            <% if (isEdit) { %>
                                                <input type="hidden" name="id" value="<%= category.getCategoryId() %>">
                                                <% } %>
                                                    <% if (csrf !=null && !csrf.isEmpty()) { %>
                                                        <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
                                                        <% } %>

                                                            <div class="mb-12">
                                                                <label for="name">Nome *</label>
                                                                <input type="text" id="name" name="name"
                                                                    value="<%= isEdit ? esc(category.getName()) : "" %>"
                                                                    required>
                                                            </div>

                                                            <div class="mb-12">
                                                                <label for="description">Descrizione</label>
                                                                <textarea id="description"
                                                                    name="description"><%= isEdit ? esc(category.getDescription()) : "" %></textarea>
                                                            </div>

                                                            <div class="mb-12 filters">
                                                                <label class="checkbox-inline">
                                                                    <input type="checkbox" id="isActive" name="isActive"
                                                                        value="1" <%=(!isEdit || category.isActive())
                                                                        ? "checked" : "" %>>
                                                                    Attiva
                                                                </label>
                                                            </div>

                                                            <div class="gap-6 mt-16">
                                                                <button type="submit" class="btn">Salva</button>
                                                                <a href="<%=ctx%>/admin/categories"
                                                                    class="btn outline">Annulla</a>
                                                            </div>
                                        </form>
                                    </div>

                        </div>
                    </div>

                    <jsp:include page="/views/footer.jsp" />
                </body>

                </html>