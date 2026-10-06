# Application Security Architecture

## Student Life Manager
### Personal Academic & Productivity Management System
**Security Standard:** OWASP Top 10 Compliance for Enterprise Web Applications

---

## 1. Overview

The Student Life Manager architecture implements defense-in-depth principles across all tiers. Security is enforced through strict session authorization, parameterized data access, robust hashing algorithms, sanitized input processing, and secured cookies.

---

## 2. Core Security Mechanisms

### 2.1 Password Hashing with BCrypt
- **Principle**: Passwords must never be stored as plaintext, MD5, or SHA-1.
- **Implementation**: The application uses the **jBCrypt** library implementing the Blowfish adaptive cipher with standard 10 salt rounds ($2a$10$).
- **Salting**: A unique cryptographically secure 128-bit salt is generated automatically per password, protecting against rainbow table attacks and precomputed dictionary attacks.
- **Verification**: `BCrypt.checkpw(plainPassword, storedHash)` performs constant-time comparison to prevent timing side-channel attacks.

```java
// PasswordUtil.java
public static String hashPassword(String plainPassword) {
    if (plainPassword == null || plainPassword.trim().isEmpty()) {
        throw new IllegalArgumentException("Password cannot be empty");
    }
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt(10));
}

public static boolean checkPassword(String plainPassword, String hashedPassword) {
    if (plainPassword == null || hashedPassword == null) return false;
    return BCrypt.checkpw(plainPassword, hashedPassword);
}
```

---

### 2.2 SQL Injection Prevention via JDBC Prepared Statements
- **Principle**: User input must never be directly concatenated into SQL statement strings.
- **Implementation**: Every single DAO operation (`TaskDAO`, `SubjectDAO`, `UserDAO`, `ExamDAO`, etc.) uses `java.sql.PreparedStatement` with typed parameter placeholders (`?`).
- **Mechanism**: The MySQL database engine compiles the SQL query plan before parameter substitution occurs. User input is treated strictly as literal data values, completely neutralizing SQL injection vectors (e.g., `' OR '1'='1`).

```java
// Example from TaskDAO.java
String sql = "SELECT * FROM tasks WHERE user_id = ? AND category = ? ORDER BY due_date ASC";
try (Connection conn = DatabaseConnection.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql)) {
    ps.setInt(1, userId);
    ps.setString(2, category);
    try (ResultSet rs = ps.executeQuery()) {
        // Safe execution
    }
}
```

---

### 2.3 Authentication and Authorization Filter
- **Filter**: `com.studentlife.filter.AuthenticationFilter` intercepts all incoming requests matching `/*`.
- **Enforcement**:
  1. Verifies that the incoming request has a valid `HttpSession` containing an active `userId` attribute.
  2. Public resources (such as `/login`, `/register`, CSS, JS, images, and syllabus XML endpoints) are whitelisted.
  3. All student productivity modules (`/dashboard`, `/tasks`, `/calendar`, `/timetable`, `/deadlines`, `/exams`, `/plans`, `/habits`, `/analytics`, `/settings`) are strictly guarded.
  4. Unauthenticated regular requests are redirected to `/login?error=Please+login...`.
  5. Unauthenticated AJAX requests receive HTTP 401 Unauthorized with a JSON redirect descriptor.

---

### 2.4 Session Security & Lifecycle Management
- **Session Timeout**: Configured in `web.xml` to 60 minutes of inactivity.
  ```xml
  <session-config>
      <session-timeout>60</session-timeout>
      <cookie-config>
          <http-only>true</http-only>
          <secure>false</secure>
      </cookie-config>
      <tracking-mode>COOKIE</tracking-mode>
  </session-config>
  ```
- **Session Fixation Prevention**: Upon successful login, the existing session is invalidated and a fresh session is established via `request.getSession(true)`.
- **Logout Destruction**: `LogoutServlet` calls `session.invalidate()` and destroys the session on the server.
- **Cache Control**: Authenticated responses include HTTP headers:
  ```http
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0
  ```
  This prevents shared browser caches from storing confidential student schedules or grades.

---

### 2.5 Cookie Security
- **Remember Username Cookie**:
  - Name: `slm_username`
  - Max Age: 30 days (`30 * 24 * 60 * 60` seconds).
  - Scope: Restricted to application context path (`req.getContextPath()`).
  - Flag: `HttpOnly = true` prevents client-side script access via JavaScript (`document.cookie`), mitigating Cross-Site Scripting (XSS) cookie theft.
  - **Zero Credential Exposure**: Passwords and session keys are never stored in cookies.

---

### 2.6 Cross-Site Scripting (XSS) Prevention & Output Escaping
- **JSP Output**: JSP expressions use JSTL `<c:out value="${param}" />` or HTML entity escaping for user-supplied content to prevent malicious script injection.
- **XML Output**: All dynamic values in `/api/timetable.xml` and `/api/tasks.xml` pass through `escapeXml()` utility converting `&`, `<`, `>`, `"`, and `'` to XML character entities.

---

### 2.7 Exception Handling and Error Pages
- **Information Leakage Prevention**: Stack traces, MySQL error codes, database credentials, and filesystem directory structures are NEVER exposed to the end-user.
- **Custom Error Handlers** configured in `web.xml`:
  - `404 Not Found` &rarr; `/WEB-INF/views/error/404.jsp`
  - `403 Forbidden` &rarr; `/WEB-INF/views/error/403.jsp`
  - `500 Internal Server Error` &rarr; `/WEB-INF/views/error/500.jsp`
- Errors are logged on the server using `java.util.logging.Logger` while presenting user-friendly messages on the client.

---

### 2.8 Environment Variable and Credential Isolation
- Database credentials are not hardcoded in the source code.
- Resolved dynamically via `System.getenv("DB_PASSWORD")`, `-Ddb.password`, or local `db.properties`.
- `.gitignore` explicitly prevents accidental leakage of private configuration files.
