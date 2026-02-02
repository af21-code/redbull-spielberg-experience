<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.User, java.util.List, model.CartItem" %>
        <% User authUser=(User) session.getAttribute("authUser"); String ctx=request.getContextPath(); String
            uri=request.getRequestURI()==null ? "" : request.getRequestURI(); boolean
            exploreActive=uri.endsWith("/index.jsp"); boolean rb21Active=uri.contains("/rb21"); boolean
            trackActive=uri.contains("#track"); boolean shopActive=uri.contains("/shop") || uri.contains("/booking") ||
            uri.endsWith("/views/shop.jsp"); boolean ordersActive=uri.contains("/orders") ||
            uri.endsWith("/views/orders.jsp"); boolean cartActive=uri.contains("/cart"); boolean
            adminActive=uri.contains("/admin"); boolean isAdmin=false; if (authUser !=null) { try { Object
            t=authUser.getClass().getMethod("getUserType").invoke(authUser); isAdmin=(t !=null && "ADMIN"
            .equalsIgnoreCase(String.valueOf(t))); } catch (Exception ignored) { } } Integer cartCountObj=(Integer)
            request.getAttribute("cartCount"); int cartCount=(cartCountObj !=null) ? cartCountObj : 0; if (cartCount
            <=0) { Object cartObj=session.getAttribute("cartItems"); if (cartObj instanceof java.util.List<?>) {
            for (Object itObj : (java.util.List
            <?>) cartObj) {
                if (itObj instanceof CartItem) {
                    CartItem it = (CartItem) itObj;
                    cartCount += Math.max(1, it.getQuantity());
                }
            }
        }
    }

    // --- CSRF: crea token in sessione se assente e rendilo disponibile ---
    String csrfToken = (String) session.getAttribute("csrfToken");
    if (csrfToken == null || csrfToken.isBlank()) {
        csrfToken = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrfToken", csrfToken);
    }
%>

<!-- CSS globali -->
<link rel="stylesheet" href="<%=ctx%>/styles/indexStyle.css">
<link rel="stylesheet" href="<%=ctx%>/styles/userLogo.css">
<link rel="stylesheet" href="<%=ctx%>/styles/logoutBtn.css?v=3">

<!-- Espone il token CSRF anche come meta per gli script -->
<meta name="csrf-token" content="<%= csrfToken %>">

<!-- Fallback minimo per il bottone Logout + badge carrello -->
<style>
    /* Logout come link testuale, stesso stile delle altre voci menu */
    header .menu-right .logout-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #fff;
        text-decoration: none;
        font-weight: 600;
        font-size: 0.95rem;
        letter-spacing: 0.5px;
        padding: 8px 0;
        transition: color .15s ease;
        background: none;
        border: none;
        cursor: pointer;
    }
    header .menu-right .logout-link:hover {
        color: #E30613;
    }
    header .menu-right .logout-link svg {
        width: 18px;
        height: 18px;
        fill: currentColor;
        transition: fill .15s ease;
    }

    header .menu-right .Btn .text { white-space: nowrap; }

    header .menu-right .Btn:hover { background: #222c3f; box-shadow: 0 6px 14px rgba(0,0,0,.25); }

    header .menu-right .Btn:active { background: #1a2233; box-shadow: none; }

    header .menu-right .Btn:focus-visible { outline: 2px solid #F5A600; outline-offset: 2px; }

    /* Badge quantità carrello */
    header .menu-right .btn-cart .badge {
        display: inline-grid;
        place-items: center;
        min-width: 18px;
        height: 18px;
        padding: 0 5px;
        margin-left: 6px;
        border-radius: 999px;
        background: #E30613;
        color: #fff;
        font-weight: 800;
        font-size: .75rem;
    }
</style>

<!-- CSRF bootstrap + patch globale fetch() + XMLHttpRequest + auto-hidden nelle form POST -->
<script>
    (function () {
        var meta = document.querySelector('meta[name="csrf-token"]');
        var token = meta ? meta.content : "<%= csrfToken %>";
        window.RBX = window.RBX || {};
        window.RBX.csrfToken = token;

        var _fetch = window.fetch;
        window.fetch = function (input, init) {
            init = init || {};
            var method = (init.method || 'GET').toUpperCase();
            if (!/^(GET|HEAD|OPTIONS|TRACE)$/.test(method)) {
                var headers = init.headers instanceof Headers ? init.headers : new Headers(init.headers || {});
                if (!headers.has('X-CSRF-Token') && token) headers.set('X-CSRF-Token', token);
                init.headers = headers;
                if (!init.credentials) init.credentials = 'same-origin';
            }
            return _fetch(input, init);
        };

        var _open = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function (method, url) {
            this._csrfMethod = (method || 'GET').toUpperCase();
            return _open.apply(this, arguments);
        };
        var _send = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function (body) {
            try {
                if (this._csrfMethod && !/^(GET|HEAD|OPTIONS|TRACE)$/.test(this._csrfMethod) && token) {
                    this.setRequestHeader('X-CSRF-Token', token);
                }
            } catch (e) {
            }
            return _send.apply(this, arguments);
        };

        document.addEventListener('submit', function (ev) {
            var form = ev.target;
            if (!form || form.nodeName !== 'FORM') return;
            var method = (form.getAttribute('method') || 'GET').toUpperCase();
            if (method === 'POST') {
                if (!form.querySelector('input[name="csrf"]')) {
                    var inp = document.createElement('input');
                    inp.type = 'hidden';
                    inp.name = 'csrf';
                    inp.value = token || '';
                    form.appendChild(inp);
                }
            }
        }, true);
    })();
</script>

<header>
    <div class="container nav-container">
        <div class="logo">
            <a href="<%=ctx%>/index.jsp" aria-label="Home">
                <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg"
                     alt="Red Bull Racing Logo"/>
            </a>
        </div>

        <button class="hamburger" aria-label="Menu" onclick="toggleMenu()">
            <span></span>
            <span></span>
            <span></span>
        </button>

        <nav id="navbar">
            <ul class="main-menu">
                <li><a href="<%=ctx%>/index.jsp" class="<%= exploreActive ? "active" : "" %>">ESPLORA</a></li>
                <li><a href="<%=ctx%>/rb21" class="<%= rb21Active ? "active" : "" %>">RB-21</a></li>
                <li><a href="<%=ctx%>/index.jsp#track" class="<%= trackActive ? "active" : "" %>">PISTA</a></li>
                <li><a href="<%=ctx%>/shop" class="<%= shopActive ? "active" : "" %>">SHOP</a></li>
                <% if (isAdmin) { %>
                <li><a href="<%=ctx%>/admin" class="<%= adminActive ? "active" : "" %>">ADMIN</a></li>
                <% } %>
            </ul>

            <ul class="menu-right">
                <% if (authUser != null) { %>
                <li><a href="<%=ctx%>/profile" class="btn-cart">Profilo</a></li>
                <li><a href="<%=ctx%>/orders" class="btn-cart <%= ordersActive ? "active" : "" %>">Ordini</a></li>
                <% } %>

                <li>
                    <a href="<%=ctx%>/cart/view" class="btn-cart <%= cartActive ? "active" : "" %>" style="display:inline-flex;align-items:center;gap:6px;">
                        <span>Carrello</span>
                        <% if (cartCount > 0) { %><span class="badge"><%= cartCount %></span><% } %>
                    </a>
                </li>

                <% if (authUser == null) { %>
                <li><a href="<%=ctx%>/views/login.jsp" class="btn-login">Login</a></li>
                <% } else { %>
                <li>
                    <form action="<%=ctx%>/logout" method="get" style="display:inline;">
                        <button class="logout-link" type="submit" title="Logout" aria-label="Logout">
                            <!-- Icona logout via data-URI SVG (niente tag SVG inline => niente warning JSP) -->
                            <img src="<%=ctx%>/images/logout.svg" alt="" style="width:18px;height:18px;">
                            Logout
                        </button>
                    </form>
                </li>
                <% } %>
            </ul>
        </nav>
    </div>
</header>

<script>
    function toggleMenu(event) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }
        var navbar = document.getElementById('navbar');
        var hamburger = document.querySelector('.hamburger');
        navbar.classList.toggle('mobile-active');
        hamburger.classList.toggle('open');
    }

    // Close menu when clicking outside
    document.addEventListener('click', function (e) {
        var navbar = document.getElementById('navbar');
        var hamburger = document.querySelector('.hamburger');
        if (navbar && navbar.classList.contains('mobile-active')) {
            // If click is outside the nav and hamburger
            if (!navbar.contains(e.target) && !hamburger.contains(e.target)) {
                navbar.classList.remove('mobile-active');
                hamburger.classList.remove('open');
            }
        }
    });

    // Close menu when a link is clicked
    document.querySelectorAll('#navbar a').forEach(function (link) {
        link.addEventListener('click', function () {
            var navbar = document.getElementById('navbar');
            var hamburger = document.querySelector('.hamburger');
            if (navbar) navbar.classList.remove('mobile-active');
            if (hamburger) hamburger.classList.remove('open');
        });
    });
</script>