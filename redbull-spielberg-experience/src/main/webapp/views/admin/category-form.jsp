<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.Category" %>
        <%! private static String esc(Object o) { if (o==null) return "" ; String s=String.valueOf(o); return
            s.replace("&", "&amp;" ).replace("<", "&lt;" ).replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
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
                    <link rel="stylesheet" href="<%=ctx%>/styles/order-details.css">
                </head>

                <body>
                    <jsp:include page="/views/header.jsp" />

                    <div class="admin-bg">
                        <div class="admin-shell">
                            <aside class="admin-sidebar">
                                <a href="<%=ctx%>/admin">Dashboard</a>
                                <a href="<%=ctx%>/admin/products">Prodotti</a>
                                <a href="<%=ctx%>/admin/categories" class="active">Categorie</a>
                                <a href="<%=ctx%>/admin/orders">Ordini</a>
                                <a href="<%=ctx%>/admin/users">Utenti</a>
                                <a href="<%=ctx%>/admin/slots">Slot</a>
                            </aside>

                            <section class="admin-content">
                                <div class="admin-actions-bar">
                                    <div>
                                        <h2 class="admin-header-title">
                                            <%= isEdit ? "Modifica Categoria" : "Nuova Categoria" %>
                                        </h2>
                                        <div class="admin-subtitle">Gestisci i dettagli della categoria</div>
                                    </div>
                                    <a class="btn outline" href="<%=ctx%>/admin/categories">← Torna alla lista</a>
                                </div>

                                <% if (error !=null) { %>
                                    <div class="alert danger" style="margin-bottom: 20px;">
                                        <%= esc(error) %>
                                    </div>
                                    <% } %>

                                        <div class="card" style="padding: 32px; max-width: 900px;">
                                            <form method="post" action="<%=ctx%>/admin/categories/edit">
                                                <% if (isEdit) { %>
                                                    <input type="hidden" name="id"
                                                        value="<%= category.getCategoryId() %>">
                                                    <% } %>
                                                        <% if (csrf !=null && !csrf.isEmpty()) { %>
                                                            <input type="hidden" name="csrf" value="<%= esc(csrf) %>">
                                                            <% } %>

                                                                <div style="margin-bottom: 24px;">
                                                                    <label
                                                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Nome
                                                                        Categoria *</label>
                                                                    <div class="input-group">
                                                                        <span class="input-icon">🏷️</span>
                                                                        <input type="text" id="name" name="name"
                                                                            value="<%= isEdit ? esc(category.getName()) : "" %>"
                                                                            required
                                                                            style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px 10px 10px 40px;">
                                                                    </div>
                                                                </div>

                                                                <div style="margin-bottom: 24px;">
                                                                    <label
                                                                        style="display:block; margin-bottom:8px; font-weight:600; color:#fff;">Descrizione</label>
                                                                    <textarea id="description" name="description"
                                                                        rows="4"
                                                                        style="width: 100%; border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; background: rgba(0,0,0,0.2); color: #fff; padding: 10px; resize: vertical;"><%= isEdit ? esc(category.getDescription()) : "" %></textarea>
                                                                </div>

                                                                <div
                                                                    style="background: rgba(255,255,255,0.05); padding: 20px; border-radius: 12px; display: flex; align-items: center; margin-bottom: 32px;">
                                                                    <label
                                                                        style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600;">
                                                                        <input type="checkbox" id="isActive"
                                                                            name="isActive" value="1" <%=(!isEdit ||
                                                                            category.isActive()) ? "checked" : "" %>
                                                                        style="width: 20px; height: 20px; accent-color:
                                                                        #4cd964;">
                                                                        Attiva
                                                                    </label>
                                                                    <span class="muted"
                                                                        style="margin-left: 12px; font-size: 0.9rem;">(Se
                                                                        disattiva, i prodotti non saranno navigabili per
                                                                        categoria)</span>
                                                                </div>

                                                                <div style="display: flex; gap: 16px;">
                                                                    <button type="submit" class="btn brand">
                                                                        <%= isEdit ? "Salva Modifiche"
                                                                            : "Crea Categoria" %>
                                                                    </button>
                                                                    <a href="<%=ctx%>/admin/categories"
                                                                        class="btn outline">
                                                                        Annulla
                                                                    </a>
                                                                </div>
                                            </form>
                                        </div>
                            </section>
                        </div>
                    </div>

                    <jsp:include page="/views/footer.jsp" />
                </body>

                </html>