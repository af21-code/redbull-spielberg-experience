<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Red Bull RB21 — Esplora la Monoposto</title>

  <!-- Stili di base del sito -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/styles/indexStyle.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/styles/userLogo.css">
  <!-- Stile bottone logout (in caso non venga incluso da header o caricato tardi) -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/styles/logoutbtn.css?v=2">
  <!-- Stile della pagina RB21 -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/styles/rb21.css?v=3">

  <link href="https://fonts.googleapis.com/css2?family=Titillium+Web:wght@400;600;700;900&display=swap" rel="stylesheet">
</head>
<body>

  <!-- Header comune -->
  <jsp:include page="/views/header.jsp" />

  <!-- HERO -->
  <section class="rb21-hero">
    <div class="rb21-hero__inner">
      <h1 class="rb21-title">RED BULL RB21</h1>
      <p class="rb21-subtitle">IL FUTURO DELLA FORMULA 1</p>
      <div class="rb21-stats">
        <div class="stat"><span class="val">1000+</span><span class="lab">CAVALLI</span></div>
        <div class="stat"><span class="val">350+</span><span class="lab">KM/H</span></div>
        <div class="stat"><span class="val">~2.0</span><span class="lab">0–100 SEC</span></div>
      </div>
      <div class="rb21-scroll">SCORRI</div>
    </div>
  </section>

  <!-- Nav in-page -->
  <nav class="rb21-sticky">
    <div class="rb21-sticky__wrap">
      <span class="logo">RB21</span>
      <ul>
        <li><a href="#aero">Aerodinamica</a></li>
        <li><a href="#powertrain">Powertrain</a></li>
        <li><a href="#tech">Tecnologia</a></li>
        <li><a href="#perf">Prestazioni</a></li>
      </ul>
    </div>
  </nav>

  <!-- AERODINAMICA -->
  <section id="aero" class="rb21-section">
    <div class="container">
      <h2 class="rb21-h2">Aerodinamica Rivoluzionaria</h2>
      <div class="rb21-grid">
        <article class="card">
          <h3>Ground Effect Avanzato</h3>
          <p>Fondo vettura ottimizzato per massimizzare l’effetto suolo: fino al 60% del carico totale.</p>
          <div class="kpi"><span>+45%</span> Downforce</div>
        </article>
        <article class="card">
          <h3>Ali Adattive</h3>
          <p>Profili alari che si adattano dinamicamente per bilanciare velocità e stabilità.</p>
          <div class="kpi"><span>-8%</span> Drag</div>
        </article>
        <article class="card">
          <h3>Vortex Management</h3>
          <p>Controllo dei vortici per ridurre la turbolenza e aumentare l’efficienza.</p>
          <div class="kpi"><span>92%</span> Efficienza</div>
        </article>
      </div>
    </div>
  </section>

  <!-- POWERTRAIN -->
  <section id="powertrain" class="rb21-section rb21-section--alt">
    <div class="container">
      <h2 class="rb21-h2">Honda RBPT Hybrid</h2>
      <div class="rb21-two">
        <div class="col">
          <div class="info">
            <h3>Motore V6 Turbo</h3>
            <ul>
              <li><strong>Cilindrata:</strong> 1.6L</li>
              <li><strong>Config.:</strong> V6 90°</li>
              <li><strong>Regime Max:</strong> 15.000 RPM</li>
              <li><strong>Potenza ICE:</strong> ~850 CV</li>
            </ul>
          </div>
          <div class="info">
            <h3>Sistema Ibrido ERS</h3>
            <ul>
              <li><strong>MGU-K:</strong> 120 kW (160 CV)</li>
              <li><strong>MGU-H:</strong> Recupero Turbo</li>
              <li><strong>Batteria:</strong> 4 MJ/giro</li>
              <li><strong>Deploy:</strong> Smart Energy</li>
            </ul>
          </div>
        </div>
        <div class="col meter">
          <div class="meter-title">POTENZA TOTALE SISTEMA</div>
          <div class="meter-bar"><div class="meter-fill"></div></div>
          <div class="meter-value">1000+ CV</div>
        </div>
      </div>
    </div>
  </section>

  <!-- TECNOLOGIA -->
  <section id="tech" class="rb21-section">
    <div class="container">
      <h2 class="rb21-h2">Tecnologia all’Avanguardia</h2>
      <div class="rb21-grid rb21-grid--4">
        <article class="card small"><span class="n">01</span><h3>Telemetria Real-Time</h3><p>Oltre 300 sensori per strategie dinamiche al muretto.</p></article>
        <article class="card small"><span class="n">02</span><h3>Sospensioni Attive</h3><p>Pull-rod ant., push-rod post. con controllo altezza.</p></article>
        <article class="card small"><span class="n">03</span><h3>Brake-by-Wire</h3><p>Ripartizione frenante elettronica ottimizzata.</p></article>
        <article class="card small"><span class="n">04</span><h3>AI Strategy</h3><p>Analisi di scenari per suggerimenti in gara.</p></article>
      </div>
    </div>
  </section>

  <!-- PRESTAZIONI -->
  <section id="perf" class="rb21-section rb21-section--alt">
    <div class="container">
      <h2 class="rb21-h2">Prestazioni Estreme</h2>
      <div class="rb21-grid rb21-grid--4 perf">
        <div class="perf-card"><div class="val">355</div><div class="unit">KM/H</div><div class="lab">Velocità Massima</div></div>
        <div class="perf-card"><div class="val">1.9</div><div class="unit">SEC</div><div class="lab">0–100 km/h</div></div>
        <div class="perf-card"><div class="val">5.5</div><div class="unit">G</div><div class="lab">Forza G Laterale</div></div>
        <div class="perf-card"><div class="val">750</div><div class="unit">KG</div><div class="lab">Peso Minimo</div></div>
      </div>
    </div>
  </section>

  <!-- Footer (se lo hai) -->
  <!-- <jsp:include page="/views/footer.jsp" /> -->

  <script>
    // Smooth scroll per la nav interna
    document.querySelectorAll('.rb21-sticky a[href^="#"]').forEach(a=>{
      a.addEventListener('click', e=>{
        e.preventDefault();
        document.querySelector(a.getAttribute('href'))?.scrollIntoView({behavior:'smooth'});
      });
    });
    // Effetto sticky compattato
    const sn = document.querySelector('.rb21-sticky');
    window.addEventListener('scroll',()=> sn.classList.toggle('scrolled', window.scrollY>120));
  </script>
</body>
</html>