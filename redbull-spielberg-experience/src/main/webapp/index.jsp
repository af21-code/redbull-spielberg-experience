<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <!DOCTYPE html>
  <html lang="it">

  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>RedBull Spielberg Experience</title>

    <!-- Styles globali -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/indexStyle.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/userLogo.css" />
    <!-- (facoltativo) il logout CSS è già incluso in header.jsp -->
    <!-- <link rel="stylesheet" href="${pageContext.request.contextPath}/styles/logoutbtn.css?v=2" /> -->

    <link rel="icon" type="image/jpeg"
      href="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" />
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

    <!-- Header condiviso (mostra ADMIN se l’utente è admin) -->
    <jsp:include page="/views/header.jsp" />

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
          <p>Un viaggio unico nel cuore del Red Bull Ring, dove l'adrenalina incontra la precisione, e ogni curva
            racconta una storia di coraggio e innovazione. Vivi l'esperienza attraverso gli occhi dei campioni.</p>
        </div>
        <div class="intro-image">
          <img src="https://dimages2.corriereobjects.it/uploads/2024/11/24/6742d933bc3f7.jpeg"
            alt="Max Verstappen vittorioso" />
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
            <span class="purchase-card" style="display:block">
              <span class="h3-like"
                style="display:block; font-weight:bold; font-size:1.17em; margin:1em 0;">Standard</span>
              <span style="display:block">Accesso circuito, kit benvenuto, ristoro</span>
            </span>
          </a>
          <a href="${pageContext.request.contextPath}/booking?productId=2" class="card-link">
            <span class="purchase-card premium" style="display:block">
              <span class="h3-like"
                style="display:block; font-weight:bold; font-size:1.17em; margin:1em 0;">Premium</span>
              <span style="display:block">Accesso circuito, giro in pista, box team, merchandising esclusivo</span>
            </span>
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
          <img
            src="https://www.redbullring.com/en/wp-content/uploads/sites/1/2021/07/Red-Bull-Ring-Luftaufnahme-Styrian-GP-2021-e1649946807938-scaled.jpg"
            class="slide" alt="Red Bull Ring 1" />
          <img
            src="https://www.tauroa.at/wp-content/uploads/2024/03/red-bull-ringcarmin-walcher-red-bull-ring-4-scaled.jpg"
            class="slide" alt="Red Bull Ring 2" />
          <img
            src="https://motorsporttickets.com/blog/wp-content/uploads/2024/04/Red-Bull-Ring-during-Austrian-Grand-Prix.png"
            class="slide" alt="Red Bull Ring 3" />
        </div>
      </div>
    </section>

    <!-- Video -->
    <section class="learn-track-section">
      <div class="container">
        <h2>Impariamo la Pista</h2>
        <p>Negli occhi del 4 volte campione del mondo Max Verstappen in Austria</p>
        <div class="video-wrapper">
          <iframe width="100%" height="480" src="https://www.youtube.com/embed/sIUL3VHODIE"
            title="Red Bull Racing Video" style="border:0"></iframe>
        </div>
      </div>
    </section>

    <!-- Footer condiviso -->
    <jsp:include page="/views/footer.jsp" />

    <script src="${pageContext.request.contextPath}/scripts/loadScript.js"></script>
  </body>

  </html>