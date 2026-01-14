<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat, model.Order" %>
<%!
    private static String esc(Object o) {
        if (o == null) return "";
        String
                s = String.valueOf(o);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<% String ctx = request.getContextPath();
    Object ordAttr = request.getAttribute("orders");
    List<Order> orders = new ArrayList<>();
    if (ordAttr instanceof List
            <?>) {
        for (Object x : (List<?>) ordAttr) {
            if (x instanceof Order) orders.add((Order) x);
        }
    }

    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>I miei ordini</title>
    <link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
    <style>
        /* Base Layout */
        .wrap {
            padding: 30px 18px 80px;
            background: linear-gradient(135deg, #001e36 0%, #000b2b 100%);
            min-height: 60vh;
            color: #fff
        }

        .container {
            max-width: 1100px;
            margin: 0 auto
        }

        .card {
            background: rgba(255, 255, 255, .08);
            border: 1px solid rgba(255, 255, 255, .15);
            border-radius: 16px;
            padding: 16px;
            overflow: hidden;
        }

        .title {
            margin: 0 0 12px;
            font-size: 1.8rem;
        }

        /* Table Base */
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 12px
        }

        .table th,
        .table td {
            padding: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, .15);
            vertical-align: top
        }

        .table th {
            color: #F5A600;
            text-transform: uppercase;
            font-size: 0.85rem;
            letter-spacing: 0.5px;
        }

        .pill {
            display: inline-block;
            padding: 4px 10px;
            border: 1px solid rgba(255, 255, 255, .3);
            border-radius: 999px;
            font-size: 0.85rem;
        }

        .muted {
            opacity: .85
        }

        .btn {
            background: #444;
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 8px 12px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn.primary {
            background: #E30613
        }

        .btn:hover {
            filter: brightness(1.1);
        }

        /* Mobile Responsive Table -> Card View */
        @media (max-width: 768px) {
            .wrap {
                padding: 20px 16px 60px;
            }

            .title {
                font-size: 1.5rem;
                text-align: center;
            }

            .card {
                padding: 12px;
            }

            /* Hide table headers */
            .table thead {
                display: none;
            }

            /* Transform rows to cards */
            .table tbody tr {
                display: block;
                background: rgba(255, 255, 255, 0.04);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 12px;
                margin-bottom: 16px;
                padding: 16px;
                border-bottom: none;
            }

            .table tbody td {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 8px 0;
                border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            }

            .table tbody td:last-child {
                border-bottom: none;
                padding-top: 12px;
            }

            .table tbody td::before {
                content: attr(data-label);
                font-weight: 600;
                color: #F5A600;
                font-size: 0.8rem;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .table tbody td .btn {
                width: 100%;
                text-align: center;
                padding: 12px;
            }

            .pill {
                font-size: 0.8rem;
                padding: 3px 8px;
            }
        }
    </style>
</head>

<body>
<jsp:include page="/views/header.jsp"/>

<div class="wrap">
    <div class="container">

        <h2 class="title">I miei ordini</h2>

        <div class="card">
            <table class="table">
                <thead>
                <tr>
                    <th># Ordine</th>
                    <th>Data</th>
                    <th>Totale</th>
                    <th>Stato</th>
                    <th>Pagamento</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <% if (orders.isEmpty()) { %>
                <tr>
                    <td colspan="6" class="muted" style="text-align:center; padding: 40px;">Non hai ancora
                        effettuato ordini.
                    </td>
                </tr>
                <% } %>
                <% for (Order o : orders) {
                    String onum = o.getOrderNumber();
                    java.util.Date
                            od = (o.getOrderDate() instanceof java.util.Date) ? (java.util.Date) o.getOrderDate() : null;
                    String date = (od == null) ? "—" : df.format(od);
                    BigDecimal tot = o.getTotalAmount() == null ?
                            BigDecimal.ZERO : o.getTotalAmount();
                    String st = o.getStatus();
                    String
                            pay = o.getPaymentStatus(); %>
                <tr>
                    <td data-label="Ordine"><strong>
                        <%= esc(onum) %>
                    </strong></td>
                    <td data-label="Data" class="muted">
                        <%= date %>
                    </td>
                    <td data-label="Totale">€ <%= tot %>
                    </td>
                    <td data-label="Stato"><span class="pill">
                                  <%= esc(st) %>
                                </span></td>
                    <td data-label="Pagamento"><span class="pill">
                                  <%= esc(pay) %>
                                </span></td>
                    <td data-label=""><a class="btn"
                                         href="<%=ctx%>/order?id=<%= o.getOrderId() %>">Dettagli</a></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

    </div>
</div>

<jsp:include page="/views/footer.jsp"/>
</body>

</html>