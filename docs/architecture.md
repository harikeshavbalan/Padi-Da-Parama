# Architecture Documentation

## Student Life Manager
### Personal Academic & Productivity Management System

---

## 1. System Overview

Student Life Manager (SLM) is an enterprise-grade Java web application designed as a personal "student operating system". The system follows a strict **Model-View-Controller (MVC)** architectural pattern, decoupled across presentation, controller, service, data access object (DAO), and persistence layers.

```
+-------------------------------------------------------------------------+
|                               Browser Client                            |
|             (HTML5 / CSS3 / JavaScript / Fetch API / AJAX)              |
+------------------------------------+------------------------------------+
                                     |
                                     | HTTP Requests (REST-like & Form)
                                     v
+------------------------------------+------------------------------------+
|                         Servlet Controller Layer                        |
|   (AuthenticationFilter, LoginServlet, DashboardServlet, TaskServlet,   |
|         ExamServlet, TimetableServlet, ApiServlet, XmlServlet, etc.)    |
+------------------------------------+------------------------------------+
                                     |
                                     | Delegates Business Requests
                                     v
+------------------------------------+------------------------------------+
|                              Service Layer                              |
|       (AuthenticationService, TaskService, ProductivityService,         |
|             DashboardService, CalendarService, HabitService)            |
+------------------------------------+------------------------------------+
                                     |
                                     | Performs CRUD & Domain Rules
                                     v
+------------------------------------+------------------------------------+
|                                DAO Layer                                |
|   (UserDAO, SubjectDAO, TaskDAO, ExamDAO, TimetableDAO, HabitDAO, etc.)  |
+------------------------------------+------------------------------------+
                                     |
                                     | Parameterized SQL Queries
                                     v
+------------------------------------+------------------------------------+
|                              JDBC Driver                                |
|                  (com.mysql.cj.jdbc.Driver / Connection)                |
+------------------------------------+------------------------------------+
                                     |
                                     | TCP Socket Connection (Port 3306)
                                     v
+------------------------------------+------------------------------------+
|                            MySQL Server                                 |
|                     (Database: student_life_manager)                    |
+-------------------------------------------------------------------------+
```

---

## 2. Architectural Layers

### 2.1 View Layer (JSP & Dynamic Frontend)
- **Role**: Renders responsive UI templates and communicates with servlets.
- **Technologies**: Jakarta Server Pages (JSP), JSTL (`jakarta.tags.core`), Vanilla CSS3, and JavaScript Fetch API.
- **Modular Components**:
  - `header.jsp`: Sticky navigation, live clock, unread notification badge, search bar.
  - `sidebar.jsp`: Primary persistent navigation menu for all 14 student management modules.
  - `footer.jsp`: Script injections and global context configuration (`window.APP_CONTEXT`).
- **Separation of Concerns**: Absolutely zero business logic and zero SQL queries reside inside JSP templates. All data is passed as request attributes from controllers.

### 2.2 Controller Layer (Jakarta Servlets)
- **Role**: Intercepts incoming HTTP requests, decodes parameters, performs server-side validation, invokes appropriate domain services, and routes to JSPs or JSON/XML streams.
- **Key Controllers**:
  - `LoginServlet` (`/login`, `/register`): Authenticates users, generates `HttpSession`, manages "Remember Username" cookies.
  - `DashboardServlet` (`/dashboard`): Gathers dynamic analytics, next class, deadlines, and today's schedule.
  - `TaskServlet` (`/tasks`): Handles task creation, modification, deletion, status toggling, and multi-parameter filtering.
  - `ApiServlet` (`/api/*`): Serves asynchronous AJAX requests (instant task check, habit check, calendar event feed).
  - `XmlEndpointServlet` (`/api/timetable.xml`, `/api/tasks.xml`): Streams XML payloads compliant with syllabus requirements.

### 2.3 Security & Filter Layer
- **AuthenticationFilter**: Intercepts all incoming requests matching `/*`.
- Verifies session state (`userId` in `HttpSession`).
- Protects authenticated pages and redirects unauthenticated users to `/login`.
- Sets HTTP response security headers (`Cache-Control: no-cache, no-store, must-revalidate`).

### 2.4 Service Layer (Business Logic)
- **Role**: Contains all business algorithms, scoring calculations, and cross-DAO orchestrations.
- **Key Services**:
  - `ProductivityService`: Implements the 4-component transparent algorithm:
    $$\text{Score} = (0.40 \times \text{TaskCompletion}) + (0.25 \times \text{DeadlineAdherence}) + (0.20 \times \text{StudyTarget}) + (0.15 \times \text{HabitConsistency})$$
  - `DashboardService`: Dynamically aggregates today's schedule, next class based on day and current clock, upcoming exams, and habit streaks.
  - `CalendarService`: Aggregates events across tasks, exams, university events, and official holidays into standardized `CalendarEvent` models.

### 2.5 DAO Layer (Data Access Objects)
- **Role**: Encapsulates all relational database operations.
- Uses `PreparedStatement` exclusively to prevent SQL injection vulnerabilities.
- Handles `ResultSet` mapping to strongly-typed domain model objects.
- Utilizes try-with-resources blocks for `Connection`, `PreparedStatement`, and `ResultSet` to prevent connection leaks.

### 2.6 Persistence Layer (JDBC & MySQL)
- Managed via `DatabaseConnection.java`.
- Resolves configuration dynamically through Environment Variables (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`), fallback to `db.properties`, or system properties.
- Connects to MySQL Server using UTF-8 character encoding and UTC timezones.
