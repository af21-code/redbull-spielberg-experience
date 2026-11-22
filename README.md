<div align="center">
  <h1>🏎️ RedBull Spielberg Experience</h1>
  <h3>Piattaforma E-Commerce per Esperienze di Guida al Red Bull Ring</h3>
  
  <p align="center">
    <a href="#-il-team">Il Team</a> •
    <a href="#-visione-del-progetto">Visione</a> •
    <a href="#-funzionalità-principali">Funzionalità</a> •
    <a href="#-architettura-di-sistema">Architettura</a> •
    <a href="#-funzionalità-per-ruolo">Ruoli Utente</a> •
    <a href="#-sicurezza">Sicurezza</a> •
    <a href="#-installazione">Installazione</a> •
    <a href="#-struttura-del-progetto">Struttura</a>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Java-17+-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java" />
    <img src="https://img.shields.io/badge/Jakarta_EE-5.0-007396?style=for-the-badge&logo=eclipse&logoColor=white" alt="Jakarta EE" />
    <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
    <img src="https://img.shields.io/badge/Tomcat-10+-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black" alt="Tomcat" />
  </p>
</div>

> **Nota:** progetto universitario a scopo didattico, non affiliato né approvato da Red Bull GmbH o dal Red Bull Ring. Marchi e nomi appartengono ai rispettivi proprietari.

---

## 👥 Il Team

**RedBull Spielberg Experience** è sviluppato con passione per il corso di **Tecnologie Software per il Web** dell'Università degli Studi di Salerno.

<br />

### Sviluppatori

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/gianlucaam">
        <img src="https://github.com/gianlucaam.png" width="80" style="border-radius: 50%;" />
        <br />
        <strong>Gianluca Ambrosio</strong>
      </a>
    </td>
    <td align="center">
      <a href="https://github.com/af21-code">
        <img src="https://github.com/af21-code.png" width="80" style="border-radius: 50%;" />
        <br />
        <strong>Angelo Fusco</strong>
      </a>
    </td>
  </tr>
</table>

---

## 📖 Visione del Progetto

**RedBull Spielberg Experience** è una piattaforma e-commerce che permette agli appassionati di motorsport di vivere l'emozione della guida in pista al leggendario **Red Bull Ring** di Spielberg, Austria.

Il progetto nasce dall'idea di unire due mondi:

- 🏁 **Esperienze di guida esclusive** — Dalla Formula 2 alla vera RB21 di Formula 1
- 🛒 **Merchandising ufficiale** — Abbigliamento e accessori Red Bull Racing

### Obiettivi del Progetto

1. **Esperienza Utente Premium**: Interfaccia moderna e responsive che riflette l'eccellenza del brand Red Bull Racing

2. **Prenotazione Intelligente**: Sistema di slot temporali con gestione dinamica della disponibilità e capacità

3. **Sicurezza First**: Protezione completa con CSRF, session management e password hashing

4. **Architettura Solida**: Pattern MVC e DAO per manutenibilità e scalabilità del codice

---

## 🆚 Il Problema vs La Soluzione

<table>
  <thead>
    <tr>
      <th width="45%" align="center">🚫 Prenotazione Tradizionale</th>
      <th width="10%" align="center"></th>
      <th width="45%" align="center">✅ RedBull Spielberg Experience</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <strong>Telefonate e Email</strong><br>
        Prenotare richiede chiamate, attese e scambio di email per confermare la disponibilità.
      </td>
      <td align="center">➡️</td>
      <td>
        <strong>Booking Real-Time</strong><br>
        Disponibilità slot visualizzata <em>in tempo reale</em> con prenotazione istantanea e conferma immediata.
      </td>
    </tr>
    <tr>
      <td>
        <strong>Pagamento Separato</strong><br>
        Bonifico, PayPal o pagamento in loco con tempi di attesa per la conferma.
      </td>
      <td align="center">➡️</td>
      <td>
        <strong>Checkout Integrato</strong><br>
        Carrello unificato per esperienze e merchandising con processo di checkout sicuro e idempotente.
      </td>
    </tr>
    <tr>
      <td>
        <strong>Gestione Manuale</strong><br>
        L'organizzatore gestisce prenotazioni su fogli Excel, rischiando overbooking.
      </td>
      <td align="center">➡️</td>
      <td>
        <strong>Dashboard Admin</strong><br>
        Pannello di controllo completo con gestione ordini, prodotti e slot con aggiornamento automatico delle capacità.
      </td>
    </tr>
  </tbody>
</table>

---

## ✨ Funzionalità Principali

### 🛒 Carrello Intelligente

- **Dual-mode**: Funziona sia per utenti guest (sessione) che registrati (persistenza DB)
- **Merge automatico**: Al login, il carrello guest viene unito a quello salvato
- **Gestione esperienze**: Slot temporali, dati pilota e accompagnatore
- **Gestione merchandising**: Taglie, varianti e stock in tempo reale

### 📅 Sistema di Booking

- **Calendario disponibilità**: Visualizzazione slot liberi per i prossimi 21 giorni
- **Capacità dinamica**: Aggiornamento automatico posti disponibili
- **Validazione date**: Impossibile prenotare slot passati o esauriti
- **Dati pilota**: Raccolta informazioni pilota e accompagnatore per sicurezza

### 💳 Checkout Sicuro

- **Idempotenza**: Protezione contro doppi submit
- **CSRF protection**: Token di sicurezza su tutte le form
- **Verifica disponibilità**: Controllo atomico prima della conferma
- **Snapshot prezzi**: I prezzi vengono "fotografati" nell'ordine

---

## 🏗 Architettura di Sistema

L'applicazione segue il pattern **MVC (Model-View-Controller)** con pattern **DAO** per l'accesso ai dati.

### ⚡ Tech Stack

<div align="center">

| Layer | Tecnologie | Descrizione |
|:---:|:---|:---|
| **Frontend** | ![JSP](https://img.shields.io/badge/JSP-007396?style=flat&logo=java&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black) ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=flat&logo=css3&logoColor=white) | Pagine dinamiche con validazione client-side |
| **Controller** | ![Servlet](https://img.shields.io/badge/Jakarta_Servlet-5.0-007396?style=flat&logo=eclipse&logoColor=white) | Gestione richieste HTTP e logica di routing |
| **Model** | ![Java](https://img.shields.io/badge/Java_17-ED8B00?style=flat&logo=openjdk&logoColor=white) ![DAO](https://img.shields.io/badge/DAO_Pattern-4B8BBE?style=flat) | Entity e Data Access Objects |
| **Database** | ![MySQL](https://img.shields.io/badge/MySQL_8-4479A1?style=flat&logo=mysql&logoColor=white) | RDBMS con connection pooling |
| **Server** | ![Tomcat](https://img.shields.io/badge/Apache_Tomcat_10-F8DC75?style=flat&logo=apache-tomcat&logoColor=black) | Servlet container Jakarta EE 9+ |

</div>

### 📁 Struttura Package

```
src/main/java/
├── control/              # Servlet (Controller)
│   ├── admin/            # Servlet area amministrativa
│   ├── CartServlet.java
│   ├── CheckoutServlet.java
│   ├── LoginServlet.java
│   └── ...
├── model/                # Entity e DAO (Model)
│   ├── dao/
│   │   ├── impl/         # Implementazioni DAO
│   │   ├── ProductDAO.java
│   │   ├── OrderDAO.java
│   │   └── ...
│   ├── Product.java
│   ├── Order.java
│   └── ...
├── filter/               # Filtri sicurezza
│   ├── AuthFilter.java
│   ├── AdminOnlyFilter.java
│   └── SecurityCsrfFilter.java
├── service/              # Business Logic
│   └── CheckoutService.java
└── utils/                # Utility
    ├── DatabaseConnection.java
    └── PasswordUtil.java
```

---

## 👤 Funzionalità per Ruolo

### 🏎️ Per gli Utenti (Guest e Registrati)

| Funzionalità | Guest | Registrato |
|:---|:---:|:---:|
| Visualizzazione catalogo esperienze | ✅ | ✅ |
| Visualizzazione shop merchandising | ✅ | ✅ |
| Aggiunta prodotti al carrello | ✅ | ✅ |
| Prenotazione slot esperienze | ✅ | ✅ |
| Checkout e pagamento | ❌ | ✅ |
| Storico ordini personale | ❌ | ✅ |
| Dettaglio ordine | ❌ | ✅ |
| Carrello persistente | ❌ | ✅ |

### Dettaglio Funzionalità Utente

- **Booking Esperienze**: Selezione veicolo (RB21, F2, etc.), data, slot orario e inserimento dati pilota
- **Shop Merchandising**: Navigazione per categoria, selezione taglia, gestione quantità
- **Carrello**: Visualizzazione items, modifica quantità, rimozione prodotti, svuotamento
- **Checkout**: Inserimento indirizzi spedizione/fatturazione, selezione metodo pagamento
- **I Miei Ordini**: Lista ordini con stato, dettagli completi di ogni ordine

---

### 👨‍💼 Per gli Amministratori (Web Dashboard)

- **Dashboard**: Panoramica rapida con statistiche vendite e accessi
- **Gestione Prodotti**: 
  - Creazione, modifica, disattivazione prodotti
  - Upload immagini (Base64)
  - Gestione varianti taglia con stock separato
  - Distinzione EXPERIENCE vs MERCHANDISE
- **Gestione Categorie**: CRUD completo categorie prodotto
- **Gestione Ordini**:
  - Visualizzazione con filtri (data da/a, cliente, stato)
  - Dettaglio ordine completo
  - Export CSV
  - Aggiornamento stato e tracking
- **Gestione Utenti**: Visualizzazione e gestione account
- **Gestione Slot**: Creazione e gestione slot temporali per esperienze

---

## 🔐 Sicurezza

Il progetto implementa multiple layer di sicurezza:

### Autenticazione & Autorizzazione

| Meccanismo | Implementazione |
|:---|:---|
| **Password Hashing** | PBKDF2 con salt (PasswordUtil) |
| **Session Management** | HttpSession con rotazione ID post-login |
| **Session Fixation** | `req.changeSessionId()` dopo autenticazione |
| **Access Control** | AuthFilter per aree protette |
| **Role-Based Access** | AdminOnlyFilter per area admin |

### Protezione Attacchi

| Attacco | Contromisura |
|:---|:---|
| **CSRF** | SecurityCsrfFilter + token in form e header |
| **SQL Injection** | PreparedStatement in tutti i DAO |
| **XSS** | Escape HTML nelle JSP (`esc()` function) |
| **Credential Exposure** | Env vars per credenziali DB |

### Catena Filtri (web.xml)

```
Request → UTF8Filter → SecurityCsrfFilter → CartSyncFilter 
        → CartBadgeFilter → AuthFilter → AdminOnlyFilter → Servlet
```

---

## 🚀 Installazione

### Prerequisiti

- **Java JDK 17+**
- **Apache Tomcat 10+** (Jakarta EE 9+)
- **MySQL 8.0+**
- **Maven 3.8+**

### Setup Database

1. Creare il database:
```sql
CREATE DATABASE red_bull_spielberg CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Eseguire lo script di schema e seed:
```bash
mysql -u root -p red_bull_spielberg < sql/01-schema-and-seed.sql
```

### Configurazione

#### Opzione A: JNDI DataSource (Raccomandato)

Configurare `context.xml` in Tomcat:

```xml
<Resource name="jdbc/redbull"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="com.mysql.cj.jdbc.Driver"
          url="jdbc:mysql://localhost:3306/red_bull_spielberg"
          username="your_user"
          password="your_password"
          maxTotal="40"
          maxIdle="10"
          maxWaitMillis="10000"/>
```

#### Opzione B: Environment Variables

```bash
export RB_DB_URL="jdbc:mysql://localhost:3306/red_bull_spielberg"
export RB_DB_USER="your_user"
export RB_DB_PASS="your_password"
```

### Build & Deploy

```bash
# Build del progetto
mvn clean package

# Deploy su Tomcat
cp target/redbull-spielberg-experience.war $CATALINA_HOME/webapps/
```

### Accesso

- **Sito**: http://localhost:8080/redbull-spielberg-experience/
- **Admin**: Effettuare login con account ADMIN

---

## 📂 Struttura del Progetto

```
redbull-spielberg-experience/
├── 📁 src/main/
│   ├── 📁 java/
│   │   ├── 📁 control/          # Servlet Controllers
│   │   ├── 📁 model/            # Entity + DAO
│   │   ├── 📁 filter/           # Security Filters
│   │   ├── 📁 service/          # Business Logic
│   │   └── 📁 utils/            # Utilities
│   └── 📁 webapp/
│       ├── 📁 views/            # JSP Pages
│       │   ├── 📁 admin/        # Admin Dashboard
│       │   ├── 📁 errors/       # Error Pages
│       │   ├── header.jsp
│       │   ├── footer.jsp
│       │   ├── cart.jsp
│       │   ├── checkout.jsp
│       │   └── ...
│       ├── 📁 styles/           # CSS Files
│       ├── 📁 scripts/          # JavaScript Files
│       ├── 📁 images/           # Static Images
│       ├── 📁 WEB-INF/
│       │   └── web.xml          # Deployment Descriptor
│       └── 📁 META-INF/
│           └── context.xml      # Tomcat Context
├── 📁 sql/
│   └── 01-schema-and-seed.sql   # Database DDL + DML
├── 📄 pom.xml                   # Maven Configuration
└── 📄 README.md
```

---

## 📊 Schema Database

### Tabelle Principali

| Tabella | Descrizione |
|:---|:---|
| `users` | Utenti registrati (REGISTERED, ADMIN) |
| `products` | Prodotti (EXPERIENCE, MERCHANDISE) |
| `product_variants` | Varianti taglia con stock separato |
| `categories` | Categorie prodotto |
| `time_slots` | Slot temporali per esperienze |
| `orders` | Ordini con snapshot indirizzi |
| `order_items` | Righe ordine con snapshot prezzi |
| `cart` | Carrello persistente utenti loggati |

### Relazioni Chiave

```
users ──< orders ──< order_items >── products
                          │
                          └──> time_slots (per EXPERIENCE)
                          
products ──< product_variants (per MERCHANDISE)
```

---

## 🗺️ Roadmap Futura

- [ ] **Pagamenti Reali**: Integrazione Stripe/PayPal
- [ ] **Email Transazionali**: Conferma ordine e promemoria
- [ ] **Multi-lingua**: Supporto EN/DE oltre IT
- [ ] **PWA Mobile**: Versione mobile installabile
- [ ] **Calendario Avanzato**: Vista mensile disponibilità
- [ ] **Reviews**: Sistema di recensioni esperienze

---

<p align="center">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status" />
  <img src="https://img.shields.io/badge/University-UNISA-blue?style=for-the-badge" alt="University" />
  <img src="https://img.shields.io/badge/Course-Tecnologie_Web-blueviolet?style=for-the-badge" alt="Course" />
</p>

<p align="center">
  <strong>🏁 Feel the speed. Live the experience. 🏁</strong>
</p>

<p align="center">
  Copyright © 2025 RedBull Spielberg Experience — Gianluca Ambrosio & Angelo Fusco
</p>
