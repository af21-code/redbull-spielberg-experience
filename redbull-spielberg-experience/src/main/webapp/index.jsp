<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RedBull Spielberg Experience</title>
    <link rel="stylesheet" href="styles/indexStyle.css">
    <link rel="icon" type="image/jpeg" href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg">
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet">
</head>
<body>
<!-- Audio per la loading screen -->
<audio id="loading-sound" loop autoplay muted>
    <source src="sounds/loading.mp3" type="audio/mpeg">
</audio>

<!-- Loading Screen -->
<div class="loading-screen">
    <div class="middle">
        <div class="bar bar1"></div>
        <div class="bar bar2"></div>
        <div class="bar bar3"></div>
        <div class="bar bar4"></div>
        <div class="bar bar5"></div>
        <div class="bar bar6"></div>
        <div class="bar bar7"></div>
        <div class="bar bar8"></div>
    </div>
</div>

<!-- Header -->
<header>
    <div class="container nav-container">
        <div class="logo">
            <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull Racing Logo">
        </div>
        <nav>
            <ul>
                <li><a href="#">ESPLORA</a></li>
                <li><a href="#rb-21">RB-21</a></li>
                <li><a href="#track">PISTA</a></li>
                <li><a href="#shop">SHOP</a></li>
            </ul>
        </nav>
        <div class="login-button">
            <a href="views/login.jsp" class="btn-login">Login</a>
        </div>
    </div>
</header>

<!-- Hero Section con GIF di sfondo -->
<section class="hero-section">
    <div class="hero-overlay">
        <div class="hero-text">
            <span class="highlight">VIVI</span><br>
            <span class="highlight">LA</span> <span class="yellow">VELOCITÀ</span><br>
            <span class="highlight">DOMINA</span><br>
            <span class="highlight">LA</span> <span class="red">PISTA</span>
        </div>
    </div>
</section>

<!-- Nuova descrizione del progetto con immagine di Verstappen -->
<section class="project-intro">
    <div class="intro-container">
        <div class="intro-text">
            <h2>Passione <span class="red">Velocità</span> Vittoria</h2>
            <p>Un viaggio unico nel cuore del Red Bull Ring, dove l'adrenalina incontra la precisione, e ogni curva racconta una storia di coraggio e innovazione. Vivi l'esperienza attraverso gli occhi dei campioni.</p>
        </div>
        <div class="intro-image">
            <img src="https://dimages2.corriereobjects.it/uploads/2024/11/24/6742d933bc3f7.jpeg" alt="Max Verstappen vittorioso">
        </div>
    </div>
</section>

<!-- Sezione Acquisto -->
<section class="purchase-section">
    <div class="container">
        <h2>Acquista il Tuo Pacchetto</h2>
        <p>Scegli tra Standard e Premium e vivi l’esperienza Red Bull come mai prima.</p>
        <div class="purchase-options">
            <a href="pages/acquisto.html" class="card-link">
                <div class="purchase-card">
                    <h3>Standard</h3>
                    <p>Accesso circuito, kit benvenuto, ristoro</p>
                </div>
            </a>
            <a href="pages/acquisto.html" class="card-link">
                <div class="purchase-card premium">
                    <h3>Premium</h3>
                    <p>Accesso circuito, giro in pista, box team, merchandising esclusivo</p>
                </div>
            </a>
        </div>
    </div>
</section>

<!-- Sezione dedicata alla pista -->
<section id="track" class="track-section">
    <div class="container">
        <h2>Scopri la Pista</h2>
        <p>Entra nel cuore del <span class="red">Red Bull Ring</span> e lasciati travolgere dalla sua storia, le sue curve leggendarie e l'adrenalina pura che solo un circuito di Formula 1 può offrire.</p>
        <div class="slideshow-container">
            <img src="https://www.redbullring.com/en/wp-content/uploads/sites/1/2021/07/Red-Bull-Ring-Luftaufnahme-Styrian-GP-2021-e1649946807938-scaled.jpg" class="slide" alt="Red Bull Ring 1">
            <img src="https://www.tauroa.at/wp-content/uploads/2024/03/red-bull-ringcarmin-walcher-red-bull-ring-4-scaled.jpg" class="slide" alt="Red Bull Ring 2">
            <img src="https://motorsporttickets.com/blog/wp-content/uploads/2024/04/Red-Bull-Ring-during-Austrian-Grand-Prix.png" class="slide" alt="Red Bull Ring 3">
        </div>
    </div>
</section>

<!-- Sezione Impariamo la pista -->
<section class="learn-track-section">
    <div class="container">
        <h2>Impariamo la Pista</h2>
        <p>Negli occhi del 4 volte campione del mondo Max Verstappen in Austria</p>
        <div class="video-wrapper">
            <iframe width="100%" height="480" src="https://www.youtube.com/embed/sIUL3VHODIE"
                title="Red Bull Racing Video" frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen></iframe>
        </div>
    </div>
</section>

<script src="scripts/loadScript.js"></script>
</body>
</html>