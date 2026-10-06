# Comprehensive Viva Questions & Answers

## Student Life Manager
### Personal Academic & Productivity Management System
**College Web Technology Project — Comprehensive Viva Voce Guide**  
*(Contains 55 detailed technical questions and answers designed for academic viva examinations)*

---

### 1. Fundamental Web Architecture & Core Concepts

#### Q1: What is a Servlet?
**Answer:** A Servlet is a Java class that executes on a server-side web container (such as Apache Tomcat) to handle incoming client HTTP requests and generate dynamic web responses. Servlets implement the `jakarta.servlet.Servlet` interface and form the core controller component in the Java EE / Jakarta EE MVC architecture.

#### Q2: What is the lifecycle of a Servlet?
**Answer:** The Servlet lifecycle is managed by the web container through three primary methods:
1. `init(ServletConfig config)`: Invoked once when the servlet is first loaded into memory for initialization.
2. `service(ServletRequest req, ServletResponse res)`: Invoked for each incoming client request; dispatches to `doGet()`, `doPost()`, `doPut()`, `doDelete()`, etc.
3. `destroy()`: Invoked once when the container is shutting down or undeploying the servlet to release resources.

#### Q3: What is JSP (Jakarta Server Pages)?
**Answer:** JSP is a server-side technology that allows developers to write standard HTML markup intermingled with dynamic Java tags, expressions, and scriptlets. During runtime, the servlet container translates the JSP file into a Java source file (a servlet) and then compiles it into bytecode `.class` file to service HTTP requests.

#### Q4: How is JSP converted and executed by Apache Tomcat?
**Answer:** When a user requests a JSP page for the first time:
1. Tomcat's Jasper engine parses the `.jsp` file.
2. It generates an equivalent Java servlet source file (`<page_name>_jsp.java` in Tomcat's `work/` directory).
3. The Java compiler compiles this source file into bytecode (`<page_name>_jsp.class`).
4. The container loads the class into memory, executes `_jspInit()`, and invokes `_jspService(HttpServletRequest, HttpServletResponse)` to generate the output HTML sent to the browser.
Subsequent requests bypass compilation and execute the pre-compiled servlet directly.

#### Q5: What is MVC architecture and how is it implemented in this project?
**Answer:** Model-View-Controller (MVC) is an architectural design pattern that separates application concerns:
- **Model**: Represents data structures and database access (`com.studentlife.model` and `com.studentlife.dao`).
- **View**: Presentation layer rendered in the browser (`.jsp` templates in `/WEB-INF/views/`).
- **Controller**: Directs user requests, validates inputs, and coordinates business flow (`com.studentlife.controller.*` Servlets).
In our project, requests reach Servlet controllers, which invoke services/DAOs and forward the resulting model objects to JSPs using `request.setAttribute()` and `request.getRequestDispatcher().forward()`.

#### Q6: Why should we not write database or business logic inside JSP pages?
**Answer:** 
1. **Separation of Concerns**: JSP should only be responsible for presentation and UI rendering.
2. **Maintainability**: Mixing Java SQL code and HTML creates "spaghetti code" that is difficult to read and debug.
3. **Security**: Business logic inside JSP files increases vulnerability to script errors and database credential leakage.
4. **Testability**: Java code inside JSP files cannot be unit-tested with JUnit.

#### Q7: What is JDBC (Java Database Connectivity)?
**Answer:** JDBC is a standard Java API (`java.sql`) that enables Java applications to connect to relational databases, execute SQL statements, and retrieve structured query results. It uses database-specific drivers (e.g., MySQL Connector/J) that translate standard JDBC calls into the native network protocol of the database server.

#### Q8: What is a Database Connection and how is it managed in this project?
**Answer:** A database connection represents an active TCP socket session between the Java application and MySQL Server. In our project, connection parameters (host, port, database, user, password) are centralized in `DatabaseConnection.java`, which reads from system environment variables or `db.properties` and connects via `DriverManager.getConnection()`.

#### Q9: What is `PreparedStatement` and why is it preferred over `Statement`?
**Answer:** `PreparedStatement` is a pre-compiled SQL statement interface in JDBC. It is preferred because:
1. **SQL Injection Prevention**: Parameter values are passed separately using placeholders (`?`), ensuring user inputs are treated strictly as literal data, not executable SQL syntax.
2. **Performance**: The database parses, compiles, and optimizes the SQL query plan once and reuses it for multiple executions with different parameter bindings.
3. **Type Safety**: It provides strongly typed setter methods like `setInt()`, `setString()`, `setDate()`, etc.

#### Q10: What is SQL Injection and how does this application prevent it?
**Answer:** SQL Injection is a vulnerability where an attacker injects malicious SQL statements into user input fields (e.g., `' OR '1'='1`) to alter database query logic. Student Life Manager prevents SQL injection by exclusively using `PreparedStatement` for all database interactions. No user input is ever concatenated directly into SQL queries.

---

### 2. State Management: Sessions & Cookies

#### Q11: What is an `HttpSession`?
**Answer:** `HttpSession` is a server-side state management mechanism in the Servlet API. It allows the server to maintain conversational state across multiple HTTP requests from the same client. When a session is created, Tomcat assigns a unique Session ID (`JSESSIONID`) and sends it to the browser as a cookie or via URL rewriting.

#### Q12: How does the login process work in this application?
**Answer:**
1. The student submits their credentials via a POST request to `/login`.
2. `LoginServlet` intercepts the request and calls `AuthenticationService.authenticate(username, password)`.
3. The service fetches the user's record via `UserDAO.findByUsername()`.
4. `PasswordUtil.checkPassword()` verifies the submitted password against the BCrypt hash stored in MySQL.
5. If valid, `request.getSession(true)` creates a new session, sets `session.setAttribute("userId", user.getId())`, and redirects to `/dashboard`.
6. If invalid, the user is redirected back to `/login` with an error message.

#### Q13: What is a Cookie?
**Answer:** A cookie is a small piece of data sent by the web server to the client's browser in the `Set-Cookie` HTTP response header. The browser stores it locally and automatically transmits it back to the server in subsequent requests in the `Cookie` header.

#### Q14: How are cookies used in this project?
**Answer:** Cookies are used for the **Remember Username** feature. When a student checks "Remember username" upon logging in:
- The servlet creates a cookie: `Cookie c = new Cookie("slm_username", username)`.
- It sets an expiration age (e.g., 30 days) via `c.setMaxAge(30 * 24 * 60 * 60)`.
- On future visits, `LoginServlet` inspects incoming cookies; if `slm_username` is present, it pre-fills the login form.
- Passwords and sensitive session tokens are never stored inside cookies.

#### Q15: What is the difference between a Cookie and a Session?
**Answer:**
| Feature | Cookie | Session |
|---|---|---|
| **Storage Location** | Client browser | Server memory/disk |
| **Security** | Lower (can be inspected/tampered) | Higher (client only holds Session ID) |
| **Capacity** | Limited to ~4 KB per cookie | Limited only by server memory |
| **Data Types** | Text strings only | Any Java Object (`Object`) |
| **Transmission** | Transmitted with every HTTP request | Only Session ID (`JSESSIONID`) is transmitted |

#### Q16: What is the `HttpOnly` cookie flag and why is it important?
**Answer:** The `HttpOnly` flag instructs the browser that the cookie should not be accessible via client-side JavaScript (`document.cookie`). This protects sensitive tokens (such as `JSESSIONID`) from being stolen by malicious scripts in Cross-Site Scripting (XSS) attacks.

#### Q17: What is an `AuthenticationFilter`?
**Answer:** An `AuthenticationFilter` is a class implementing `jakarta.servlet.Filter`. It acts as an interceptor in front of servlet controllers. It inspects incoming HTTP requests to check if an active `HttpSession` containing `userId` exists. If not, it blocks unauthorized access and redirects the user to `/login`.

#### Q18: What is the difference between `sendRedirect()` and `RequestDispatcher.forward()`?
**Answer:**
- **`RequestDispatcher.forward()`**: Performed internally entirely on the server. The client's browser URL does not change. Request attributes are preserved.
- **`sendRedirect()`**: Sends an HTTP 302 redirect status code to the browser with a `Location` header. The browser initiates a new HTTP GET request to the target URL. The URL changes in the browser address bar, and previous request-scope attributes are lost.

---

### 3. Asynchronous Communication: AJAX & XML

#### Q19: What is AJAX (Asynchronous JavaScript and XML)?
**Answer:** AJAX is a client-side web development technique that allows web pages to send and receive data asynchronously from the server in the background without requiring a full page reload. This results in faster, more dynamic user interfaces.

#### Q20: How is AJAX implemented in this project?
**Answer:** We use the modern browser **Fetch API** (`fetch()`). Examples include:
1. **Live Username Availability**: Checking whether a username is already taken when registering without submitting the form.
2. **Instant Task Completion**: Checking a task checkbox instantly sends a POST request to `/api/tasks/toggle?id=...`, updates MySQL, and strikes through the task without page refresh.
3. **Live Task Filtering & Search**: Fetching filtered task arrays in JSON format.
4. **Calendar Data Feed**: Fetching events dynamically from `/api/calendar/events`.

#### Q21: What is JSON and why is it used for AJAX responses?
**Answer:** JSON (JavaScript Object Notation) is a lightweight, text-based, language-independent data interchange format. It is easy for humans to read and write and trivial for JavaScript engines to parse into native objects using `response.json()`. We use Google's **Gson** library on the server to serialize Java objects into JSON.

#### Q22: What is XML (Extensible Markup Language)?
**Answer:** XML is a markup language designed for storing and transporting structured data in a platform-independent and human-readable format using user-defined tags.

#### Q23: Why does this project implement XML endpoints?
**Answer:** XML is a mandatory curriculum requirement in the Web Technology syllabus to demonstrate proficiency in XML data generation, hierarchical document modeling, and entity escaping. The endpoints `/api/timetable.xml` and `/api/tasks.xml` output valid XML documents representing the student's timetable and tasks.

#### Q24: How does the servlet generate XML?
**Answer:** `XmlEndpointServlet`:
1. Sets the response MIME type: `resp.setContentType("application/xml; charset=UTF-8")`.
2. Queries the database using DAOs.
3. Streams well-formed XML elements through `PrintWriter`, properly escaping special XML characters (`&`, `<`, `>`, `"`, `'`) using `escapeXml()` to ensure valid syntax.

#### Q25: What special characters must be escaped in XML?
**Answer:**
1. `&` &rarr; `&amp;`
2. `<` &rarr; `&lt;`
3. `>` &rarr; `&gt;`
4. `"` &rarr; `&quot;`
5. `'` &rarr; `&apos;`

---

### 4. Database & Persistence Layer

#### Q26: Why was MySQL chosen as the database?
**Answer:** MySQL is an open-source, ACID-compliant relational database management system (RDBMS) widely used in enterprise production environments. It provides strong referential integrity (foreign keys), transaction isolation (InnoDB), efficient indexing, and seamless integration with Java via JDBC.

#### Q27: What is the purpose of database indexes and where are they used in this project?
**Answer:** Database indexes (B-Tree indexes) speed up query search and retrieval operations by maintaining sorted pointer structures. In our application, indexes are defined on:
- `users(username)` and `users(email)` for fast login checks.
- `tasks(user_id)`, `tasks(due_date)`, `tasks(status)`, `tasks(priority)` for rapid dashboard and filter queries.
- `exams(user_id, exam_date)` and `events(user_id, event_date)` for chronological ordering.

#### Q28: What is a Foreign Key constraint and ON DELETE CASCADE?
**Answer:** A Foreign Key is a column that establishes a link between data in two tables, referencing the Primary Key of another table. `ON DELETE CASCADE` specifies that if a parent record (e.g., a user) is deleted, all dependent child records (such as that user's tasks, subjects, and habits) are automatically deleted by the database engine to maintain referential integrity.

#### Q29: What is the DAO (Data Access Object) design pattern?
**Answer:** The DAO pattern isolates the application/business layer from the persistence layer. Each DAO class (`TaskDAO`, `SubjectDAO`, etc.) encapsulates all database CRUD (Create, Read, Update, Delete) queries and maps SQL `ResultSet` rows into strongly typed Java domain model objects.

#### Q30: What is the Service Layer and why is it separated from the DAO layer?
**Answer:** 
- The **DAO Layer** is purely responsible for raw database operations.
- The **Service Layer** encapsulates business rules, domain logic, validation, and multi-DAO workflows (e.g., calculating productivity scores, checking streak rules, formatting composite summaries).
Separating them ensures business logic can be tested independently of the database.

---

### 5. Application Modules & Business Logic

#### Q31: How is the Productivity Score calculated?
**Answer:** The Productivity Score is a transparent 0–100 metric calculated dynamically across four components:
$$\text{Score} = (0.40 \times \text{TaskCompletionRate}) + (0.25 \times \text{DeadlineAdherenceRate}) + (0.20 \times \text{StudyTargetRate}) + (0.15 \times \text{HabitConsistencyRate})$$
Each component is calculated from live MySQL records and clamped between 0% and 100%.

#### Q32: How is the Habit Streak calculated?
**Answer:** In `HabitDAO`, `getHabitStreak()` inspects entries in the `habit_logs` table for the given habit. It counts consecutive calendar days ending today or yesterday where `completed = TRUE`. If the habit was checked today, the streak includes today; if checked yesterday but not yet today, the streak remains unbroken.

#### Q33: How does the application identify the "Next Class"?
**Answer:** In `TimetableDAO`:
1. It queries the `timetable` table for the current day of the week (e.g., Monday).
2. It filters classes where `start_time >= CURRENT_TIME`.
3. It orders by `start_time ASC` and selects the first entry (`LIMIT 1`).
4. If all classes for today are complete, it retrieves the earliest class for the next scheduled day.

#### Q34: How are deadlines categorized into "Due today", "Due tomorrow", "Upcoming", and "Overdue"?
**Answer:** In `Deadline.java` and `Task.java`, the system calculates `ChronoUnit.DAYS.between(LocalDate.now(), dueDate)`:
- `days == 0`: Due today
- `days == 1`: Due tomorrow
- `days > 1`: Due in $N$ days (Upcoming)
- `days < 0`: Overdue by $|N|$ days

#### Q35: How does the application support recurring tasks?
**Answer:** The `tasks` table includes a `recurrence` column supporting `NONE`, `DAILY`, `WEEKLY`, and `MONTHLY`. When a recurring task is completed, the system can preserve the template and generate the next scheduled instance based on the specified interval.

---

### 6. Security & Best Practices

#### Q36: How are user passwords stored in the database?
**Answer:** Passwords are never stored as plaintext. They are hashed using **BCrypt** (`jBCrypt` library) with 10 salt rounds. BCrypt automatically generates a unique 128-bit cryptographically random salt per user and hashes the password using the Blowfish algorithm.

#### Q37: Why is MD5 or SHA-256 alone not recommended for password storage?
**Answer:** MD5 and SHA-256 are general-purpose cryptographic hash functions designed to be extremely fast. Attackers can compute billions of hashes per second using modern GPUs and crack passwords via precomputed rainbow tables or dictionary attacks. BCrypt is intentionally slow and adaptive (computational cost can be adjusted via workload rounds), making brute-force attacks computationally impractical.

#### Q38: What is Cross-Site Scripting (XSS) and how is it prevented?
**Answer:** XSS is an attack where an attacker injects malicious JavaScript into user-submitted data, which is then rendered on other users' browsers. In our application:
- All output in JSP uses JSTL `<c:out>` or HTML escaping.
- XML endpoints escape all XML entity delimiters.
- Cookies use the `HttpOnly` attribute to prevent stolen session tokens via scripts.

#### Q39: What is Session Hijacking and how is it mitigated?
**Answer:** Session Hijacking occurs when an attacker obtains a victim's Session ID (`JSESSIONID`). We mitigate this by:
1. Marking session cookies as `HttpOnly`.
2. Invalidating old sessions and issuing fresh session IDs upon login.
3. Setting an idle session timeout (60 minutes).
4. Destroying sessions completely on logout.

#### Q40: Why should database passwords not be hardcoded in Java source files?
**Answer:** Hardcoded credentials in source files are easily exposed in source control repositories (e.g., GitHub), decompiled `.class` files, or project archives. In this project, database credentials are read dynamically from environment variables (`DB_PASSWORD`) or external properties files (`db.properties`), while `.env.example` provides a template without secrets.

---

### 7. Server & Build Environment

#### Q41: What is Apache Tomcat?
**Answer:** Apache Tomcat is an open-source HTTP web server and servlet container developed by the Apache Software Foundation. It executes Java servlets and renders Jakarta Server Pages (JSP) web applications according to the Jakarta EE Web Profile specifications.

#### Q42: What is the difference between Tomcat 9 and Tomcat 10+?
**Answer:** 
- **Tomcat 9**: Implements Java EE 8, which uses the legacy `javax.servlet.*` package namespace.
- **Tomcat 10.1+**: Implements Jakarta EE 10, which uses the modern `jakarta.servlet.*` package namespace following the transition of Java EE to the Eclipse Foundation.
Our project strictly uses Tomcat 10.1+ and `jakarta.*` packages.

#### Q43: What is a WAR (Web Application Archive) file?
**Answer:** A WAR file is a packaged ZIP archive containing all components of a Java web application: compiled servlet classes (`WEB-INF/classes/`), third-party dependency JARs (`WEB-INF/lib/`), deployment descriptor (`WEB-INF/web.xml`), JSP pages, and static assets (CSS, JS, images). It can be deployed directly into Tomcat's `webapps/` directory.

#### Q44: What is Maven and what role does `pom.xml` play?
**Answer:** Apache Maven is a build automation and dependency management tool for Java projects. The `pom.xml` (Project Object Model) file defines project metadata, dependencies (such as MySQL Connector/J, jBCrypt, Gson, JUnit 5), plugins (compiler, surefire, war), and build configurations. Maven automatically downloads dependencies and compiles the application.

#### Q45: What does the `<scope>provided</scope>` tag mean in Maven?
**Answer:** In `pom.xml`, the `provided` scope indicates that the dependency (such as `jakarta.servlet-api` and `jakarta.servlet.jsp-api`) is required for compilation, but will be provided by the runtime container (Apache Tomcat) at runtime. Therefore, it is not bundled inside the WAR's `WEB-INF/lib` folder, avoiding class-loader conflicts.

#### Q46: What is `web.xml`?
**Answer:** `web.xml` is the standard Web Application Deployment Descriptor located in `/WEB-INF/`. It defines configuration settings for the web container, such as session timeout intervals, cookie flags, welcome file lists, and custom error page mappings (e.g., 404, 403, 500).

#### Q47: What is the difference between `@WebServlet` annotation and configuring servlets in `web.xml`?
**Answer:** 
- **`@WebServlet`**: Introduced in Servlet 3.0, allows declaring servlets, their names, and URL mappings directly in the Java source file using annotations (e.g., `@WebServlet("/tasks")`).
- **`web.xml`**: Traditional XML-based configuration.
Annotations reduce boilerplate XML configuration while `web.xml` is still used for global container settings like session timeouts and error pages.

#### Q48: What are Servlet Filters and what are their common use cases?
**Answer:** A Servlet Filter intercepts requests and responses before they reach the servlet or before the response is returned to the client. Common use cases include:
- Authentication and authorization checks (`AuthenticationFilter`).
- Character encoding enforcement (`request.setCharacterEncoding("UTF-8")`).
- Logging and auditing request arrival times.
- Response compression (GZIP).
- Setting HTTP security headers (Cache-Control, X-Content-Type-Options).

#### Q49: What is the difference between client-side validation and server-side validation?
**Answer:**
- **Client-Side Validation**: Executes in the user's browser via HTML5 attributes (`required`, `type="email"`) or JavaScript before form submission. Provides immediate user feedback, but can easily be bypassed by disabling JavaScript or using tools like cURL/Postman.
- **Server-Side Validation**: Executes inside the Servlet controllers in Java. It is mandatory because it cannot be bypassed by malicious clients, ensuring data integrity and security before processing.

#### Q50: How does the application handle 404 and 500 errors?
**Answer:** `web.xml` registers custom error pages:
```xml
<error-page>
    <error-code>404</error-code>
    <location>/WEB-INF/views/error/404.jsp</location>
</error-page>
<error-page>
    <error-code>500</error-code>
    <location>/WEB-INF/views/error/500.jsp</location>
</error-page>
```
When an unknown route or unhandled exception occurs, Tomcat forwards to the custom branded JSP pages instead of displaying a raw Apache Tomcat error page or exposing server stack traces.

---

### 8. Frontend & UI Engineering

#### Q51: How is responsive web design implemented without front-end frameworks like Bootstrap?
**Answer:** Responsive design is implemented using pure modern **CSS3**:
- **CSS Grid & Flexbox**: Used for layout structures that fluidly adapt across viewports.
- **Media Queries** (`@media (max-width: 768px)`): Used to transform desktop sidebar navigation into a collapsible mobile drawer, collapse multi-column cards into single columns, and enable horizontal scrolling on data tables.
- **CSS Custom Properties (Variables)**: Centralized design tokens for colors, spacing, borders, and shadows in `style.css`.

#### Q52: What is the purpose of `<jsp:include>` in our JSP pages?
**Answer:** `<jsp:include page="..." />` is a standard JSP action that dynamically includes the output of another JSP resource at request time. It allows modular reuse of common UI components (`header.jsp`, `sidebar.jsp`, `footer.jsp`) across all 15 application pages without duplicating HTML code.

#### Q53: How does the calendar module render events?
**Answer:** In `calendar.jsp` and `calendar.js`:
1. The calendar grid (Month, Week, Day) is generated dynamically via vanilla JavaScript DOM manipulation.
2. An asynchronous AJAX request fetches `/api/calendar/events`.
3. The server merges tasks, exam dates, events, and holidays into a unified `CalendarEvent` list.
4. JavaScript plots each event onto the appropriate date cell with category color tags.

#### Q54: How does the application ensure database-driven dynamic dashboards rather than static mock values?
**Answer:** When `/dashboard` is accessed, `DashboardServlet` executes:
- `taskDAO.countToday(userId)`, `taskDAO.countPending()`, `countCompleted()`, `countOverdue()`.
- `timetableDAO.findNextClass(userId, currentDay, currentTime)`.
- `examDAO.findUpcoming()`, `deadlineDAO.findUpcoming()`, `holidayDAO.findNext()`.
- `habitDAO.findAllWithTodayStatus()`, `habitDAO.getUserMaxStreak()`.
- `productivityService.calculateMetrics(userId)`.
All figures are computed in real time from MySQL and passed as request attributes to `dashboard.jsp`.

#### Q55: What are the main benefits of using Vanilla CSS and JavaScript instead of bulky frontend frameworks for this project?
**Answer:**
1. **Lightweight & Fast**: Zero external bundle size overhead; loads instantaneously in all browsers.
2. **Complete Control**: Precise customization of color palettes, glassmorphism, animations, and typography.
3. **Syllabus Demonstration**: Demonstrates deep, foundational knowledge of core Web Technologies (HTML5, CSS3, DOM API, Fetch API, Event Listeners) without relying on abstractions.
