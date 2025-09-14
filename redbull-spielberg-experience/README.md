# Red Bull Spielberg Experience — E-commerce (JSP/Servlet, Tomcat 10)

An educational e-commerce web app for selling **driving experiences** and **merchandise**, built with **Jakarta Servlets/JSP (Tomcat 10)**, **DAO pattern**, and **MySQL**. It meets exam requirements for a dynamic, responsive site with persistence, access control, AJAX, and an **admin area**.

---

## TL;DR — Quickstart (Production-like)

1. **Prerequisites**: JDK 17+, Tomcat 10.x, MySQL 8.x (or MariaDB 10.5+), JDBC driver in Tomcat `lib/`.
2. **Create DB**: import `sql/01-schema-and-seed.sql` (schema + seed).
3. **Configure JNDI DataSource** in Tomcat with name `jdbc/redbull`.
4. **App config**: DAOs use JNDI lookup `java:comp/env/jdbc/redbull`.
5. **Deploy**: export a WAR → drop in Tomcat `webapps/`.
6. **Run**: open `http://localhost:8080/edbull-spielberg-experience/.
7. **Demo login (DEV only)**: admin `admin@redbull.com` / `admin123` *(in production, store **hashed** passwords)*.

> Optional: expose `/health` to test DB connection via the DataSource.

---

## Why this project

- Covers the **exam checklist**: guest cart + merge on login, registration/login/logout, checkout with order persistence, **admin** CRUD, orders by date and customer, MVC, DAO, JNDI, AJAX, **regex validation**, access control.
- Clean MVC and production-like Tomcat deployment.

---

## Architecture

**Stack**: JSP/Servlet (Jakarta EE 10), Tomcat 10, MySQL, JSTL, vanilla JS (Fetch), CSS.

**Packages**
- `control/` — Servlets & Filters (`LoginServlet`, `RegisterServlet`, `CartServlet`, `CheckoutServlet`, `AuthFilter`, `Admin*Servlet`).
- `model/` — DTOs (`User`, `Product`, `Order`, `OrderItem`, `TimeSlot`).
- `dao/` — DAO interfaces & impl (`UserDAO`, `ProductDAO`, `OrderDAO`, `TimeSlotDAO`).
- `service/` — Business logic (`CheckoutService`) and transactions.

**MVC**
- Servlets: routing, auth checks, call services/DAOs.
- JSP: render HTML (no HTML in Servlets), shared header/footer via `jsp:include`.
- Filters: authentication/authorization and cross-cutting concerns.

**Session & access control**
- Session token `authUser`, role from `users.user_type` (`VISITOR`, `REGISTERED`, `PREMIUM`, `ADMIN`).
- `/admin/*` restricted to **ADMIN** (Filter + checks in Servlets/JSP).
- CSRF tokens on sensitive POST; cookies `HttpOnly` + `SameSite`.

---

## Features

### Customer
- **Guest cart** (add/update/remove/clear) without login.
- **Merge on login**: session cart → DB cart (merch: sum qty; experience: slot unique, qty=1).
- **Account**: register, login, logout.
- **Catalog**: experiences with **time slots** + merchandise with **stock**.
- **Checkout**: transactional, price snapshot & availability checks; creates `orders`/`order_items`; clears cart.
- **My Orders**: list & detail; experiences show slot; shipments can show `carrier`/`tracking_code`.

### Admin
- **Catalog**: create/update/soft-delete products & categories; stock & featured.
- **Time slots**: bulk generation (e.g., 21 days) and availability.
- **Orders**: filters by **date x–y** and **customer**, pagination, **CSV export**.
- **Users**: list/search.

### AJAX & Validation
- JSON endpoints for cart and slots.
- Client-side **regex** validations; errors via DOM (no `alert()`), on `change` and `submit`.

---

## Database (MySQL)

Key tables: `users`, `categories`, `products` (`EXPERIENCE`/`MERCHANDISE`, `experience_type`, `is_active`), `time_slots` (unique product/date/time, `max_capacity`, `booked_capacity`), `cart` (unique per user/product/slot), `orders`, `order_items` (**`unit_price`** & **`product_name`** snapshot), tracking in `orders` (`carrier`, `tracking_code`, `shipped_at`, `estimated_delivery`).

**Design choices**
- **Historical price**: snapshot of price & name at order time.
- **Soft delete**: `is_active=false` to preserve historical orders.
- **Concurrency**: checkout row locks to avoid overbooking/overselling.

**Indexes**
- `orders(user_id, order_date)`, `cart(user_id)`, `time_slots(product_id, slot_date)`.

---

## Production Deployment (Tomcat 10)

**JNDI Resource** — `conf/context.xml` or app `META-INF/context.xml`:
```xml
<Resource name="jdbc/redbull"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="com.mysql.cj.jdbc.Driver"
          url="jdbc:mysql://localhost:3306/red_bull_spielberg?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
          username="root"
          password="RedBull2025!"
          maxTotal="50" maxIdle="10" maxWaitMillis="10000"/>

ookup: java:comp/env/jdbc/redbull.

Build & deploy
	•	Export WAR → tomcat/webapps/.
	•	Or exploded deployment (context = project folder name).
	•	Import sql/01-schema-and-seed.sql and create a demo user.

Environment
	•	Timezone & DB collation UTF-8 (utf8mb4).
	•	mysql-connector-j in Tomcat lib/.

⸻

Security
	•	Password hashing (bcrypt/PBKDF2 with salt), never plaintext in DB.
	•	CSRF: per-session token in forms and AJAX headers.
	•	Session: invalidate on logout; cookies HttpOnly + SameSite.
	•	ACL: enforce in Filters/Servlets; UI is not enough.

⸻

AJAX Endpoints (examples)
	•	POST /api/cart/add — { productId, slotId?, quantity }
	•	POST /api/cart/update — { itemId|productId, slotId?, quantity }
	•	POST /api/cart/remove — { itemId|productId, slotId? }
	•	GET  /api/slots?productId=..&date=.. — { slots:[{time, remaining}...] }

Client: live badge & totals; disable checkout if validation fails; inline errors.

⸻

Testing & Quality
	•	Unit/Integration tests for checkout (merch vs experience, concurrency, idempotency).
	•	-Xlint:all, Checkstyle, PMD, SpotBugs (goal: zero warnings).
	•	Manual test script for the demo.



License & Credits
For academic use only. Built for the “Tecnologie Software Web” exam.
