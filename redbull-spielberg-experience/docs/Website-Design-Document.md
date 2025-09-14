# Website Design Document — Red Bull Spielberg Experience

## 1. Overview & Goals
Breve descrizione del sito (e-commerce per esperienze di guida + merchandise), obiettivi del progetto, vincoli principali (Tomcat 10, JSP/Servlet, MySQL, MVC, DAO, JNDI).

## 2. Actors & Personas
- Guest (non autenticato): naviga, riempie carrello, merge al login.
- Registered user: checkout, “I miei ordini”.
- Admin: CRUD catalogo, gestione slot, viste ordini per data/cliente.

## 3. Requirements Mapping (Exam Compliance)
Mappa 1:1 dei requisiti dell’esame → come sono soddisfatti (link a pagine/servlet/DAO). Allinea con la Compliance Matrix del README.

## 4. Information Architecture & Navigation
Sitemap (Home, Shop, Product, Cart, Checkout, My Orders, Admin/*). Regole di accesso (guest vs user vs admin). URL pattern principali.

## 5. UX Wireframes (high-level)
Schizzi/wireframe principali: Home/Shop, Product, Cart, Checkout (step), My Orders, Admin list/CRUD, Admin ordini con filtri.

## 6. Data Design (ER & Policies)
Schema concettuale/ER sintetico (users, products, categories, time_slots, cart, orders, order_items).
Decisioni chiave: snapshot prezzo, soft-delete prodotti, unique slot, indici, integrità referenziale.

## 7. Application Architecture (MVC)
- Packages: control/, model/, dao/, service/.
- Pattern: DAO, Service per transazioni (CheckoutService).
- Solo JSP generano HTML (JSTL/EL), servlet per flusso e controlli.
- Filtri: Auth/Role, CSRF, UTF-8.

## 8. Validation & AJAX
Regole di validazione (regex per email/telefono/CAP), errori DOM su change/submit (no alert).
Endpoint AJAX (cart, slot) con payload e risposte previste.

## 9. Security
Password hashing (bcrypt/PBKDF2), CSRF token, session cookie HttpOnly/SameSite, ACL su servlet/JSP, rate limiting login, logging sicuro.

## 10. Deployment (Production-like)
Tomcat 10, JNDI DataSource (jdbc/redbull), driver JDBC, build WAR, variabili ambiente, script SQL, utente demo. Health check /health.

## 11. Performance & Accessibility
Caching statiche, ottimizzazione immagini, lazy loading dove sensato, responsive, navigazione tastiera, aria-*, contrasto.

## 12. Test Plan & Demo Script
Test unit/integration (checkout, concorrenza, idempotenza), test manuali chiave (guest→merge, overbooking slot, stock).
Script demo per l’orale (sequenza passi).

## 13. Risks & Limitations
Limiti noti (es. pagamento simulato), possibili miglioramenti futuri.

## 14. References
Link a README, SQL, classi chiave, commit rilevanti.
