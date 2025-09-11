<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>RedBull Spielberg Experience</title>

    <!-- Styles -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css" />
    <!-- Stile bottone logout (perché qui non includiamo header.jsp) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/logoutbtn.css?v=2" />

    <link rel="icon" type="image/jpeg" href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" />
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet" />
</head>
<body>
<!-- Audio loading -->
<audio id="loading-sound" loop autoplay muted>
    <source src="${pageContext.request.contextPath}/sounds/loading.mp3" type="audio/mpeg" />
</audio>

<!-- Loading screen -->
<div class="loading-screen" aria-hidden="true">
    <div class="middle">
        <div class="bar bar1"></div><div class="bar bar2"></div><div class="bar bar3"></div><div class="bar bar4"></div>
        <div class="bar bar5"></div><div class="bar bar6"></div><div class="bar bar7"></div><div class="bar bar8"></div>
    </div>
</div>

<header>
    <div class="container nav-container">
        <div class="logo">
            <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull Racing Logo" />
        </div>

        <nav>
            <ul class="main-menu">
                <li><a href="#">ESPLORA</a></li>
                <!-- RB-21 ora porta alla pagina dedicata -->
                <li><a href="${pageContext.request.contextPath}/views/rb21.jsp">RB-21</a></li>
                <li><a href="#track">PISTA</a></li>
                <li><a href="${pageContext.request.contextPath}/shop">SHOP</a></li>
            </ul>

            <ul class="menu-right">
                <%
                    User authUser = (User) session.getAttribute("authUser");
                    if (authUser == null) {
                %>
                    <li><a class="btn-login" href="${pageContext.request.contextPath}/views/login.jsp">Login</a></li>
                <%
                    } else {
                %>
                    <li><a class="btn-cart" href="${pageContext.request.contextPath}/orders">Ordini</a></li>
                    <li><a class="btn-cart" href="${pageContext.request.contextPath}/cart/view">Carrello</a></li>
                    <li>
                        <form action="${pageContext.request.contextPath}/logout" method="get" style="display:inline;">
                            <button class="Btn" type="submit" title="Logout" aria-label="Logout">
                                <div class="sign">
                                    <svg viewBox="0 0 512 512" aria-hidden="true" focusable="false">
                                        <path d="M377.9 105.9L500.7 228.7c7.2 7.2 11.3 17.1 11.3 27.3s-4.1 20.1-11.3 27.3L377.9 406.1c-6.4 6.4-15 9.9-24 9.9c-18.7 0-33.9-15.2-33.9-33.9l0-62.1-128 0c-17.7 0-32-14.3-32-32l0-64c0-17.7 14.3-32 32-32l128 0 0-62.1c0-18.7 15.2-33.9 33.9-33.9c9 0 17.6 3.6 24 9.9zM160 96L96 96c-17.7 0-32 14.3-32 32l0 256c0 17.7 14.3 32 32 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32l-64 0c-53 0-96-43-96-96L0 128C0 75 43 32 96 32l64 0c17.7 0 32 14.3 32 32s-14.3 32-32 32z"></path>
                                    </svg>
                                </div>
                                <div class="text">Logout</div>
                            </button>
                        </form>
                    </li>
                <%
                    }
                %>
            </ul>
        </nav>
    </div>
</header>

<!-- Hero -->
<section class="hero-section">
    <div class="hero-overlay">
        <div class="hero-text">
            <span class="highlight">VIVI</span><br />
            <span class="highlight">LA</span> <span class="yellow">VELOCITÀ</span><br />
            <span class="highlight">DOMINA</span><br />
            <span class="highlight">LA</span> <span class="red">PISTA</span>
        </div>
    </div>
</section>

<!-- Intro -->
<section class="project-intro" id="rb-21">
    <div class="intro-container">
        <div class="intro-text">
            <h2>Passione <span class="red">Velocità</span> Vittoria</h2>
            <p>Un viaggio unico nel cuore del Red Bull Ring, dove l'adrenalina incontra la precisione, e ogni curva racconta una storia di coraggio e innovazione. Vivi l'esperienza attraverso gli occhi dei campioni.</p>
        </div>
        <div class="intro-image">
            <img src="https://dimages2.corriereobjects.it/uploads/2024/11/24/6742d933bc3f7.jpeg" alt="Max Verstappen vittorioso" />
        </div>
    </div>
</section>

<!-- Pacchetti -->
<section class="purchase-section" id="shop">
    <div class="container">
        <h2>Acquista il Tuo Pacchetto</h2>
        <p>Scegli tra Standard e Premium e vivi l’esperienza Red Bull come mai prima.</p>
        <div class="purchase-options">
            <a href="${pageContext.request.contextPath}/booking?productId=1" class="card-link">
                <div class="purchase-card">
                    <h3>Standard</h3>
                    <p>Accesso circuito, kit benvenuto, ristoro</p>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/booking?productId=2" class="card-link">
                <div class="purchase-card premium">
                    <h3>Premium</h3>
                    <p>Accesso circuito, giro in pista, box team, merchandising esclusivo</p>
                </div>
            </a>
        </div>
    </div>
</section>

<!-- Pista -->
<section id="track" class="track-section">
    <div class="container">
        <h2>Scopri la Pista</h2>
        <p>Entra nel cuore del <span class="red">Red Bull Ring</span> e lasciati travolgere...</p>
        <div class="slideshow-container">
            <img src="https://www.redbullring.com/en/wp-content/uploads/sites/1/2021/07/Red-Bull-Ring-Luftaufnahme-Styrian-GP-2021-e1649946807938-scaled.jpg" class="slide" alt="Red Bull Ring 1" />
            <img src="https://www.tauroa.at/wp-content/uploads/2024/03/red-bull-ringcarmin-walcher-red-bull-ring-4-scaled.jpg" class="slide" alt="Red Bull Ring 2" />
            <img src="https://motorsporttickets.com/blog/wp-content/uploads/2024/04/Red-Bull-Ring-during-Austrian-Grand-Prix.png" class="slide" alt="Red Bull Ring 3" />
        </div>
    </div>
</section>

<!-- Video -->
<section class="learn-track-section">
    <div class="container">
        <h2>Impariamo la Pista</h2>
        <p>Negli occhi del 4 volte campione del mondo Max Verstappen in Austria</p>
        <div class="video-wrapper">
            <iframe width="100%" height="480"
                src="https://www.youtube.com/embed/sIUL3VHODIE"
                title="Red Bull Racing Video"
                style="border:0"></iframe>
        </div>
    </div>
</section>

<script src="${pageContext.request.contextPath}/scripts/loadScript.js"></script>
</body>
</html>