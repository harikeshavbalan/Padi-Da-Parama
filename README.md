# PADI DA PARAMA! (படிடா பரமா!)
### Personal Academic & Productivity Management System
**College Web Technology Project — Java 17 | Jakarta Servlets | JSP | JDBC | PostgreSQL / Supabase | Apache Tomcat 10.1+**

---

## 1. Project Overview

**Padi da Parama! (PdP)** is a comprehensive, production-grade personal "student operating system" designed for college undergraduates. When a student opens the application, they immediately know:
- What classes they have today and which class is next (Pre-configured for CIT B.E. CSE Semester V)
- What mid-semester and autonomous end-semester examination dates are approaching
- What assignments, lab records, and projects need attention
- What habits they have maintained and their active streak
- How they are progressing overall through a transparent productivity score

The system is built strictly in compliance with college **Web Technology** syllabus specifications using native **Jakarta Servlets 6.0**, **Jakarta Server Pages (JSP) 3.1**, **JDBC**, **HikariCP**, **PostgreSQL**, **JavaScript (Fetch API/AJAX)**, and **XML** endpoints.

---

## 2. Key Features

1. **Intelligent Dashboard**:
   - Time-aware greeting (`Good Morning / Afternoon / Evening, Harikeshav 👋`)
   - Real-time statistics: Today's Tasks, Pending, Completed, Overdue
   - Next scheduled class card with room and faculty
   - Next deadline countdown and upcoming examination readiness
   - Interactive checkbox task list and daily habit quick check-in
   - Transparent Productivity Score (0–100) with breakdown
2. **Task Management (Full CRUD)**:
   - Create, edit, complete, undo, and delete tasks
   - Academic, Assignment, Lab, Project, Personal, Club categories
   - Priority levels: `LOW`, `MEDIUM`, `HIGH`, `URGENT`
   - Due dates, times, and estimated effort
   - Recurring tasks support: `DAILY`, `WEEKLY`, `MONTHLY`
   - Real-time client-side search, filtering, and sorting
3. **Deadlines & Countdown**:
   - Categorized by Due Today, Due Tomorrow, Due This Week, Upcoming, Overdue, and Completed
   - Automatic days remaining calculation (e.g., *Due in 2 days*, *Overdue by 3 days*)
4. **Tests & Examinations**:
   - Supports CAT-I, CAT-II, Internal Tests, Lab Tests, Model Exams, Semester Exams, Practicals, and Viva
   - Syllabus tracking and preparation readiness slider (0–100%) with dynamic progress bar
5. **Weekly Timetable**:
   - Monday through Sunday periodic class scheduling
   - Automatic detection of Today's schedule, Current class, and Next upcoming class
6. **Habit Tracker & Streaks**:
   - Daily habit check-in via asynchronous AJAX
   - Streak calculation with 🔥 streak indicator
   - Weekly completion rate metrics
7. **Study Session Tracker**:
   - Log study duration, linked subjects, and revision notes
   - Daily, weekly, monthly, and subject-wise study time calculations
8. **Future Plans & Roadmaps**:
   - Track long-term initiatives (e.g., Master DSA, Web Development, Internship Prep)
   - Statuses: `PLANNED`, `ACTIVE`, `COMPLETED`, `PAUSED`, `CANCELLED`
9. **College Events & Holidays**:
   - Club meetings, presentations, project reviews, and seminars
   - College holidays and vacation countdown (*Next Holiday in X days*)
10. **Interactive Calendar**:
    - Month, Week, and Day views rendered via vanilla JavaScript
    - AJAX event feed combining tasks, exams, events, and holidays
11. **In-App Notifications**:
    - Unread alert badge in top navigation
    - Alerts for tasks due today, upcoming exams, and overdue submissions
12. **Analytics & Productivity**:
    - Task completion percentage and workload distribution
    - Study hours and habit consistency
    - Transparent 4-part formula:
      $$\text{Score} = (0.40 \times \text{TaskCompletion}) + (0.25 \times \text{DeadlineAdherence}) + (0.20 \times \text{StudyTarget}) + (0.15 \times \text{HabitConsistency})$$
13. **Mandatory Syllabus Demonstrations**:
    - **AJAX**: Username availability check, instant task toggle, dynamic event loading
    - **XML Feeds**: `/api/timetable.xml` and `/api/tasks.xml`
    - **Cookies**: "Remember username" persistent login cookie
    - **Session Management**: `HttpSession` lifecycle with `AuthenticationFilter`
    - **Security**: BCrypt salted password hashing and parameterized SQL via `PreparedStatement`

---

## 3. Technology Stack

| Layer | Technologies |
|---|---|
| **Backend** | Java 17 LTS, Jakarta Servlet 6.0, Jakarta Server Pages (JSP) 3.1, JSTL 3.0, JDBC |
| **Frontend** | HTML5, CSS3 (Modern custom design system, no Tailwind), Vanilla JavaScript (ES6+ / Fetch API) |
| **Database** | MySQL Server 8.0+, InnoDB, `utf8mb4` |
| **Web Server** | Apache Tomcat 10.1+ (Jakarta EE 10 compliant) |
| **Development** | Eclipse IDE for Enterprise Java and Web Developers |
| **Build & Packaging** | Apache Maven 3.8+, WAR packaging |
| **Testing** | JUnit 5 (Jupiter), 17 automated tests, 25 manual test cases |

---

## 4. Project Directory Structure

```
student-life-manager/
├── pom.xml                               # Maven project definition and dependencies
├── README.md                             # Complete project documentation
├── .gitignore                            # Git ignore rules
├── .env.example                          # Environment configuration template
│
├── database/
│   ├── schema.sql                        # Complete DDL script with tables, FKs, and indexes
│   ├── seed.sql                          # Realistic test data (demo user, subjects, timetable, tasks)
│   └── reset_database.sql                # Complete database reset script
│
├── docs/
│   ├── architecture.md                   # System MVC architecture and layer interactions
│   ├── database-design.md                # Data dictionary, ER diagram, and normalization
│   ├── deployment.md                     # Comprehensive Tomcat & Eclipse setup guide
│   ├── testing.md                        # Automated test summary + 25 manual test cases
│   ├── security.md                       # BCrypt, PreparedStatement, and session security
│   └── viva-questions.md                 # 55 viva questions and answers
│
└── src/
    ├── main/
    │   ├── java/com/studentlife/
    │   │   ├── controller/               # Servlet controllers (Dashboard, Task, Api, Xml, etc.)
    │   │   ├── dao/                      # Data Access Objects (User, Task, Subject, Timetable, etc.)
    │   │   ├── filter/                   # AuthenticationFilter (Session guard)
    │   │   ├── model/                    # Domain POJOs (Task, Subject, Exam, Deadline, etc.)
    │   │   ├── service/                  # Business logic (ProductivityService, TaskService, etc.)
    │   │   └── util/                     # DatabaseConnection, PasswordUtil
    │   │
    │   ├── resources/
    │   │   └── db.properties             # Database connection configuration
    │   │
    │   └── webapp/
    │       ├── assets/
    │       │   ├── css/                  # style.css (Core design system), dashboard.css
    │       │   └── js/                   # main.js, tasks.js, calendar.js, charts.js
    │       │
    │       ├── WEB-INF/
    │       │   ├── web.xml               # Deployment descriptor (Sessions, Errors)
    │       │   └── views/
    │       │       ├── fragments/        # header.jsp, sidebar.jsp, footer.jsp
    │       │       ├── pages/            # dashboard.jsp, tasks.jsp, calendar.jsp, etc.
    │       │       └── error/            # 404.jsp, 403.jsp, 500.jsp
    │       │
    │       ├── index.jsp                 # Context root redirector
    │       └── login.jsp                 # Authentication & Registration UI
    │
    └── test/java/com/studentlife/test/   # JUnit 5 automated test classes
```

---

## 5. Prerequisites

Before running the application, make sure you have:
1. **JDK 17 LTS** (Eclipse Temurin 17 or Oracle OpenJDK 17)
2. **Apache Maven 3.8+**
3. **Database**: **Supabase (Cloud PostgreSQL)** *(Recommended)* or **MySQL 8.0+**
4. **Apache Tomcat 10.1+**
5. **Eclipse IDE for Enterprise Java and Web Developers** or VS Code

---

## 6. Database Setup

### Option A: Supabase Cloud PostgreSQL (Recommended)
1. Log in to [Supabase](https://supabase.com) and create a free project.
2. Open the **SQL Editor** in the Supabase Dashboard.
3. Open `database/supabase_setup.sql` in this repo, copy all contents, and click **Run**.
   - This creates all 14 tables, indexes, triggers, realistic seed records, and synchronizes sequences.
4. Copy your project connection details from **Project Settings -> Database**.
5. See [docs/supabase-setup.md](file:///d:/web-tech-project/docs/supabase-setup.md) for full details.

### Option B: Local MySQL Workbench (Alternative)
1. Start your local **MySQL Server** instance (Port `3306`).
2. Launch **MySQL Workbench** and connect as `root`.
3. Open `database/schema.sql` and execute the script (`Ctrl + Shift + Enter`).
4. Open `database/seed.sql` and execute it.

---

## 7. Database Configuration

### For Supabase:
Edit `src/main/resources/db.properties` with your Supabase credentials:
```properties
db.type=postgresql
db.host=db.YOUR_PROJECT_REF.supabase.co
db.port=5432
db.name=postgres
db.user=postgres
db.password=YOUR_SUPABASE_PASSWORD
db.sslmode=require
```
*(Or set `DATABASE_URL=postgresql://postgres.YOUR_PROJECT_REF:PASSWORD@aws-0-ap-south-1.pooler.supabase.com:6543/postgres`)*

### For Local MySQL:
```properties
db.type=mysql
db.host=localhost
db.port=3306
db.name=student_life_manager
db.user=root
db.password=your_mysql_password
```

---

## 8. Importing & Running in Eclipse IDE

1. Open **Eclipse IDE for Enterprise Java and Web Developers**.
2. Go to **File** &rarr; **Import...** &rarr; **Maven** &rarr; **Existing Maven Projects**.
3. Select the `student-life-manager` folder and click **Finish**.
4. In the **Servers** tab, click **New** &rarr; **Server** &rarr; **Apache** &rarr; **Tomcat v10.1 Server**.
5. Specify your Tomcat 10.1 installation directory and select **Java 17**.
6. Right-click the server &rarr; **Add and Remove...** &rarr; Add `student-life-manager` &rarr; **Finish**.
7. Start the server.
8. Open your browser and navigate to:
   `http://localhost:8080/student-life-manager/`

---

## 9. Building the WAR & Standalone Tomcat Deployment

### Step 1: Build with Maven
```bash
mvn clean package
```
Maven compiles all classes, runs automated tests, and generates:
`target/student-life-manager.war`

### Step 2: Deploy to Tomcat
1. Copy `target/student-life-manager.war` into your Tomcat `webapps/` folder:
   ```bash
   cp target/student-life-manager.war /path/to/tomcat-10.1/webapps/
   ```
2. Start Tomcat:
   - **Windows:** `bin\startup.bat`
   - **Linux/Mac:** `bin/startup.sh`
3. Access the application:
   `http://localhost:8080/student-life-manager/`

---

## 10. Default Login Credentials

| Role | Username | Password | Notes |
|---|---|---|---|
| **Demo Student** | `demo` | `demo123` | Pre-seeded with 6 subjects, 13 tasks, 4 exams, streaks, and timetable |

*Note: New student accounts can also be created on the login page via the "Create Account" tab with live AJAX username availability verification.*

---

## 11. Syllabus Verification Endpoints

| Feature | URL | Description |
|---|---|---|
| **Timetable XML** | `/api/timetable.xml` | Live XML feed representing student timetable |
| **Tasks XML** | `/api/tasks.xml` | Live XML feed representing student tasks |
| **AJAX Username Check** | `/api/check-username?username=demo` | Returns JSON `{"available": false}` |
| **AJAX Calendar Feed** | `/api/calendar/events` | Returns JSON calendar events array |
| **AJAX Dashboard Stats** | `/api/dashboard/stats` | Returns real-time task and habit counts |

---

## 12. Troubleshooting

- **404 / 500 on Tomcat start**:
  Verify that Tomcat 10.1+ is used (not Tomcat 9). Tomcat 10.1 uses Jakarta EE (`jakarta.*`).
- **Database Connection Refused**:
  Check if MySQL service is running on port 3306. Check credentials in `src/main/resources/db.properties`.
- **Port 8080 Conflict**:
  Change `<Connector port="8080"` to `<Connector port="8081"` in Tomcat's `conf/server.xml`.
- **CSS / JS not updating**:
  Perform a hard refresh in your browser (`Ctrl + F5` or `Cmd + Shift + R`).
