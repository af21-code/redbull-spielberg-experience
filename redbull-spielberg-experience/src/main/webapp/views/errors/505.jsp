<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <title>500 - Errore interno | RedBull Spielberg Experience</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet" />
  <style>
    :root{
      --rb-blue:#001E36; --rb-navy:#000B2B; --rb-red:#E30613; --rb-gold:#F5A600; --rb-white:#fff;
      --glass: rgba(255,255,255,.08); --glass-border: rgba(255,255,255,.18);
    }
    *{box-sizing:border-box}
    body{
      margin:0; font-family:"Bebas Neue", Arial, sans-serif; color:var(--rb-white);
      min-height:100vh; display:flex; align-items:center; justify-content:center; text-align:center;
      background:
        radial-gradient(1200px 600px at 10% -10%, #0d1b2a 0%, transparent 60%),
        radial-gradient(1200px 600px at 110% 110%, #1a0033 0%, transparent 60%),
        linear-gradient(135deg, var(--rb-navy), var(--rb-blue));
    }
    .card{
      width:min(700px, 92vw); padding:28px 24px; border-radius:20px;
      background:var(--glass); border:1px solid var(--glass-border); position:relative; overflow:hidden;
      box-shadow:0 20px 60px rgba(0,0,0,.5);
    }
    .card::before{
      content:""; position:absolute; inset:0; padding:1px; border-radius:20px;
      background:linear-gradient(135deg, rgba(245,166,0,.8), rgba(227,6,19,.6));
      -webkit-mask:linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
      -webkit-mask-composite:xor; mask-composite:exclude; pointer-events:none;
    }
    .brand{display:flex; align-items:center; gap:12px; justify-content:center}
    .brand img{width:48px; height:auto; border-radius:6px}
    h1{font-size:56px; letter-spacing:1.2px; margin:12px 0 0}
    .subtitle{font:600 15px/1.4 Arial, sans-serif; color:#d9e2ef; margin:6px 0 18px}
    .code{font-size:110px; line-height:1; margin:8px 0 6px; color:var(--rb-red); text-shadow:0 8px 24px rgba(0,0,0,.35)}
    .msg{font:600 15px/1.6 Arial, sans-serif; color:#cfd6e1; margin:0 auto 18px; max-width:560px}
    .btns{display:flex; gap:12px; justify-content:center; flex-wrap:wrap; margin-top:6px}
    .btn{
      display:inline-block; padding:12px 16px; border-radius:12px; text-decoration:none; font-weight:900;
      letter-spacing:.6px; text-transform:uppercase; border:1px solid rgba(255,255,255,.22);
      background:linear-gradient(135deg, var(--rb-red), #b4040e); color:var(--rb-white);
      box-shadow:0 10px 24px rgba(227,6,19,.35); transition:transform .08s ease, filter .15s ease, box-shadow .15s ease;
    }
    .btn:hover{filter:brightness(1.06)}
    .btn:active{transform:translateY(1px)}
    .btn-secondary{background:transparent; border-color:var(--rb-gold); color:var(--rb-gold)}
    .hint{margin-top:14px; font:600 13px/1.5 Arial, sans-serif; color:#9fb3c8}
    .details{
      margin-top:10px; font:600 12px/1.5 Arial, sans-serif; color:#9fb3c8; opacity:.9;
      max-width:600px; margin-left:auto; margin-right:auto;
    }
    code{font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace}
    @media (max-width:480px){ h1{font-size:40px} .code{font-size:84px} }
  </style>
</head>
<body>
  <div class="card">
    <div class="brand">
      <img src="https://cdn-3.motorsport.com/images/mgl/Y99JQRbY/s8/red-bull-racing-logo-1.jpg" alt="Red Bull" />
      <h1>Errore interno</h1>
    </div>

    <div class="code">500</div>
    <p class="subtitle">Something broke in the pit lane.</p>
    <p class="msg">
      Si è verificato un errore inatteso sul server. Abbiamo preso nota del problema.
      Torna alla home oppure riprova più tardi.
    </p>

    <div class="btns">
      <a class="btn" href="<%= request.getContextPath() %>/index.jsp">Home</a>
      <a class="btn btn-secondary" href="javascript:history.back()">Indietro</a>
    </div>

    <!-- Se vuoi mostrare dettagli dell'eccezione in dev: -->
    <div class="details">
      <% if (exception != null) { %>
        <div>Exception: <code><%= exception.getClass().getName() %></code></div>
        <div>Message: <code><%= exception.getMessage() %></code></div>
      <% } %>
    </div>

    <p class="hint">Se l’errore persiste, contatta l’amministratore.</p>
  </div>
</body>
</html>