# Deployment and Configuration Guide

## Student Life Manager
### Personal Academic & Productivity Management System
**Target Environment:** Apache Tomcat 10.1+ / Java 17 / MySQL Server 8.0+

---

## 1. Prerequisites and System Requirements

Ensure the following software packages are installed on the deployment machine:

1. **Java Development Kit (JDK) 17 LTS**:
   - Download Eclipse Temurin 17 or Oracle OpenJDK 17.
   - Verify installation:
     ```bash
     java -version
     javac -version
     ```
   - Ensure `JAVA_HOME` environment variable points to your JDK 17 directory (e.g., `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`).
   - Add `%JAVA_HOME%\bin` to system `PATH`.

2. **Apache Maven 3.8+**:
   - Verify installation:
     ```bash
     mvn -version
     ```

3. **MySQL Server 8.0+**:
   - Running locally on port `3306`.
   - Default character set: `utf8mb4`.

4. **MySQL Workbench 8.0+**:
   - GUI management interface for executing schema and seed scripts.

5. **Apache Tomcat 10.1+**:
   - Tomcat 10.1 implements the **Jakarta EE 10 / Servlet 6.0 / JSP 3.1** specification (`jakarta.servlet.*`).
   - *Note: Do NOT use Tomcat 9 or earlier as they rely on legacy `javax.servlet.*` packages.*

6. **Eclipse IDE for Enterprise Java and Web Developers (2023-09 or newer)**:
   - Contains Web Tools Platform (WTP) and Maven Integration (m2e).

---

## 2. Database Initialization via MySQL Workbench

1. Start your local **MySQL Server** instance.
2. Launch **MySQL Workbench** and establish a connection to `localhost:3306` with user `root`.
3. Open `database/schema.sql`:
   - Click **File** &rarr; **Open SQL Script...**
   - Select `database/schema.sql`.
   - Click the **Execute (Lightning icon)** or press `Ctrl + Shift + Enter`.
   - This creates database `student_life_manager` and all 14 relational tables with constraints and indexes.
4. Open `database/seed.sql`:
   - Execute the script.
   - This seeds initial data for user `demo` (password: `demo123`), including courses, timetables, tasks, and habit logs.
5. Verification query:
   ```sql
   USE student_life_manager;
   SELECT username, email, full_name FROM users;
   SELECT name, course_code, faculty FROM subjects;
   SELECT title, due_date, status, priority FROM tasks;
   ```

---

## 3. Database Credentials Configuration

The application reads credentials flexibly via environment variables or properties:

### Option A: `src/main/resources/db.properties` (Recommended for Local Dev)
Edit `src/main/resources/db.properties`:
```properties
db.host=localhost
db.port=3306
db.name=student_life_manager
db.user=root
db.password=your_mysql_password
```

### Option B: System Environment Variables (Production & CI)
Set system environment variables (Windows PowerShell):
```powershell
[System.Environment]::SetEnvironmentVariable('DB_HOST', 'localhost', 'Machine')
[System.Environment]::SetEnvironmentVariable('DB_PORT', '3306', 'Machine')
[System.Environment]::SetEnvironmentVariable('DB_NAME', 'student_life_manager', 'Machine')
[System.Environment]::SetEnvironmentVariable('DB_USER', 'root', 'Machine')
[System.Environment]::SetEnvironmentVariable('DB_PASSWORD', 'your_password', 'Machine')
```

---

## 4. Developing & Running in Eclipse IDE

1. **Launch Eclipse**:
   - Select your desired workspace directory.
2. **Import Project**:
   - Click **File** &rarr; **Import...**
   - Select **Maven** &rarr; **Existing Maven Projects** &rarr; **Next**.
   - Browse to `d:\web-tech-project` (root containing `pom.xml`).
   - Check the `pom.xml` box and click **Finish**.
   - Allow Eclipse to download dependencies and build the workspace.
3. **Configure Tomcat 10.1 Server in Eclipse**:
   - Open the **Servers** tab (**Window** &rarr; **Show View** &rarr; **Servers**).
   - Click **No servers are available. Click this link to create a new server...**
   - Select **Apache** &rarr; **Tomcat v10.1 Server**.
   - Browse to your local Tomcat 10.1 installation folder (e.g., `C:\apache-tomcat-10.1.x`).
   - Select **Java SE 17** as the Server runtime JRE.
   - Click **Finish**.
4. **Deploy Application to Tomcat**:
   - Right-click the configured Tomcat 10.1 server &rarr; **Add and Remove...**
   - Move `student-life-manager` from *Available* to *Configured* &rarr; **Finish**.
5. **Start and Test**:
   - Right-click server &rarr; **Start** (or **Debug**).
   - Open browser and navigate to:
     `http://localhost:8080/student-life-manager/`
   - Log in with:
     - **Username:** `demo`
     - **Password:** `demo123`

---

## 5. Building the Production WAR & Standalone Tomcat Deployment

### Step 1: Package with Maven
Open PowerShell / Command Prompt in the project root:
```bash
mvn clean package
```
Maven compiles all classes, runs automated unit tests, and packages the application into:
`target/student-life-manager.war`

### Step 2: Deploy to Standalone Apache Tomcat 10.1
1. Stop your standalone Apache Tomcat service if running:
   ```bash
   bin/shutdown.bat
   ```
2. Copy `target/student-life-manager.war` into Tomcat's `webapps/` folder:
   ```powershell
   Copy-Item .\target\student-life-manager.war C:\apache-tomcat-10.1.x\webapps\
   ```
3. Start Tomcat:
   ```bash
   C:\apache-tomcat-10.1.x\bin\startup.bat
   ```
4. Tomcat automatically unpacks `student-life-manager.war` into a directory named `student-life-manager/`.
5. Access the application in any web browser:
   `http://localhost:8080/student-life-manager/`

---

## 6. Verification Checklist

| Item | Verification Step | Expected Result |
|---|---|---|
| Welcome Redirect | Navigate to `http://localhost:8080/student-life-manager/` | Redirects to `/login` |
| Authentication | Enter `demo` / `demo123` | Redirects to `/dashboard` with student greeting |
| Real Database Content | Check Dashboard today's schedule and metrics | Shows live courses, tasks, and streaks from MySQL |
| Task Completion AJAX | Check a task checkbox on Tasks or Dashboard page | Checkbox updates without full page refresh |
| XML Feed | Navigate to `/api/timetable.xml` | Displays well-formed XML timetable tree |
| Error Handling | Navigate to non-existent route `/invalid-page` | Custom branded 404 page displayed |

---

## 7. Troubleshooting Common Issues

### Issue 1: `java.lang.ClassNotFoundException: jakarta.servlet.http.HttpServlet`
- **Cause:** Application deployed onto Tomcat 9 or earlier, which uses `javax.servlet`.
- **Solution:** Ensure you are running Apache Tomcat 10.1+ with Jakarta EE 10 support.

### Issue 2: `Communications link failure: The last packet sent successfully...`
- **Cause:** MySQL Server is stopped or credentials in `db.properties` / environment variables are mismatched.
- **Solution:** Verify MySQL service is running via Windows Services (`services.msc`) or `net start MySQL80`. Check port (3306) and credentials.

### Issue 3: Port 8080 Conflict (`Address already in use`)
- **Cause:** Another process (e.g., Oracle, Jenkins, or an existing Tomcat instance) is using port 8080.
- **Solution:** Edit `conf/server.xml` in Tomcat and change `<Connector port="8080"` to `<Connector port="8081"`, then access `http://localhost:8081/student-life-manager/`.
