# Software Testing Documentation

## Student Life Manager
### Personal Academic & Productivity Management System
**Test Framework:** JUnit 5 (Jupiter 5.10.2) + Manual Verification Matrix  
**Test Scope:** Authentication, Tasks, Deadlines, Timetable, Exams, Habits, Productivity Scoring, XML Endpoints, Filters, and Session Lifecycle

---

## 1. Automated Unit Testing Suite

The project includes automated JUnit 5 tests covering core mathematical models, hashing security, business rules, XML encoding, and date calculations.

To execute the automated test suite:
```bash
mvn clean test
```

### 1.1 Summary of Automated Test Classes
| Test Class | Package | Tests Run | Focus Area |
|---|---|---|---|
| `PasswordUtilTest` | `com.studentlife.test` | 2 | BCrypt salt generation, match verification, empty/null guard |
| `ProductivityScoreTest` | `com.studentlife.test` | 2 | 4-part weighted scoring algorithm, 0-100 clamping |
| `TaskValidationAndStatusTest` | `com.studentlife.test` | 3 | Due today logic, overdue day calculation, required field validation |
| `XmlEscapeAndGenerationTest` | `com.studentlife.test` | 1 | Entity escaping (`&`, `<`, `>`, `"`, `'`) for XML compliance |
| `DeadlineCalculationTest` | `com.studentlife.test` | 5 | Due today, due tomorrow, upcoming, overdue, and completed states |
| `InputValidationTest` | `com.studentlife.test` | 4 | Email regex validation, exam readiness bounds, model default initializers |
| **Total Automated Tests** | | **17** | **100% Pass Rate** |

---

## 2. Manual Test Cases (25 Comprehensive Test Scenarios)

The following manual test matrix details feature test cases across functional and non-functional requirements.

| Test ID | Feature | Input | Expected Result | Actual Result | Status |
|---|---|---|---|---|---|
| **TC-01** | User Authentication | Correct username `demo`, password `demo123` | Session created; redirect to `/dashboard` with greeting and summary metrics | Authenticated; redirected to dashboard | **PASSED** |
| **TC-02** | Invalid Authentication | Username `demo`, incorrect password `wrongpwd` | Authentication rejected; red error banner "Invalid username or password" displayed on `/login` | Error banner displayed; access denied | **PASSED** |
| **TC-03** | Remember Username Cookie | Check "Remember username" during login with user `demo` | Cookie `slm_username` created with max age 30 days; pre-fills username input on subsequent visits | Cookie preserved; username input pre-filled | **PASSED** |
| **TC-04** | Authentication Filter Guard | Access `http://localhost:8080/student-life-manager/tasks` without active session | Intercepted by `AuthenticationFilter`; HTTP 302 redirect to `/login?error=Please+login...` | Redirected to login page | **PASSED** |
| **TC-05** | User Logout Lifecycle | Click "Logout" button in navigation or sidebar | `session.invalidate()` invoked; session cookie cleared; redirected to login | Session terminated; access requires re-login | **PASSED** |
| **TC-06** | AJAX Username Availability | Type `demo` in registration username field (`onblur`) | AJAX call to `/api/check-username?username=demo`; displays "✗ Username is already taken" | Red validation message displayed | **PASSED** |
| **TC-07** | AJAX Username Available | Type `newstudent2026` in registration username field | AJAX call returns `{"available": true}`; displays "✓ Username is available" | Green available message displayed | **PASSED** |
| **TC-08** | Create Academic Task | Title: "CN Lab Report", Subject: "Computer Networks", Category: "Lab", Priority: "HIGH", Due Date: tomorrow | Task saved to MySQL `tasks` table; displayed in task list; flash notification shown | Task created and visible in list | **PASSED** |
| **TC-09** | AJAX Toggle Task Completion | Click completion checkbox on task #1 in Tasks or Dashboard page | AJAX POST `/api/tasks/toggle?id=1`; task status transitions to `COMPLETED`; strikethrough styling applied without page reload | Task checked; strikethrough applied seamlessly | **PASSED** |
| **TC-10** | Filter Tasks by Category | Select "Assignment" filter from dropdown in `tasks.jsp` | Instant client-side or AJAX filter isolates only Assignment tasks; counter updates | Only assignment tasks displayed | **PASSED** |
| **TC-11** | Task Search Filter | Enter keyword "DBMS" in tasks search bar | Live filter isolates matching tasks in real-time | DBMS tasks displayed immediately | **PASSED** |
| **TC-12** | Task Deletion | Click "Delete" button on a task and confirm alert | Task record deleted from MySQL; removed from DOM; counters updated | Task deleted successfully | **PASSED** |
| **TC-13** | Deadline Days Remaining | Deadline set to 3 days from current date | Calculated as "Due in 3 days"; displayed in orange badge | Badge shows "Due in 3 days" | **PASSED** |
| **TC-14** | Overdue Deadline Detection | Deadline set to 2 days prior to today | Calculated as "Overdue by 2 days"; highlighted in danger red | Badge shows "Overdue by 2 days" | **PASSED** |
| **TC-15** | Add Academic Subject | Course: "Cloud Computing", Code: "CS307", Faculty: "Dr. A. Rao", Credits: 3, Color: `#8b5cf6` | Saved to MySQL `subjects` table; available in task and timetable dropdowns | Subject added and selectable | **PASSED** |
| **TC-16** | Timetable Next Class Calculation | View dashboard on Monday during scheduled hours | System computes current time vs Monday schedule; renders next upcoming lecture with room and faculty | Accurate next class card displayed | **PASSED** |
| **TC-17** | Add Examination & Progress | Exam: "Web Tech CAT-I", Type: "CAT-I", Date: +3 days, Prep: 72% | Saved to `exams` table; progress bar reflects 72% with color gradient | Exam saved with 72% progress bar | **PASSED** |
| **TC-18** | AJAX Habit Check-in | Click habit check button for "Coding" on Habits page | AJAX POST `/api/habits/toggle?id=2`; creates log entry in `habit_logs`; streak increments; 🔥 displayed | Streak updated; checked icon shown | **PASSED** |
| **TC-19** | Habit Streak Maintenance | View Habit Tracker with consecutive logs from past 5 days | Computes 5-day streak; displays "🔥 5 day streak" | 5-day streak shown accurately | **PASSED** |
| **TC-20** | Log Study Session | Subject: "Operating Systems", Start: 14:00, End: 16:30, Duration: 150 mins | Record saved to `study_sessions`; increases subject study totals on Analytics page | Logged; reflected in study time | **PASSED** |
| **TC-21** | Productivity Score Formula | 80% task completion, 100% deadline adherence, 75% study target, 80% habit rate | Weighted calculation: (80×0.4) + (100×0.25) + (75×0.2) + (80×0.15) = 84/100 | Displays score 84/100 with component bars | **PASSED** |
| **TC-22** | Calendar Month View AJAX | Navigate to `/calendar`; switch between Month, Week, and Day views | AJAX calls `/api/calendar/events`; tasks, exams, events, and holidays rendered on calendar grid | All calendar events loaded | **PASSED** |
| **TC-23** | XML Timetable Feed | Open browser to `http://localhost:8080/student-life-manager/api/timetable.xml` | Returns HTTP 200 `application/xml; charset=UTF-8` with well-formed `<timetable><class>...</class></timetable>` | Valid XML tree rendered | **PASSED** |
| **TC-24** | XML Tasks Feed | Open browser to `http://localhost:8080/student-life-manager/api/tasks.xml` | Returns HTTP 200 `application/xml` with well-formed `<tasks><task>...</task></tasks>` | Valid XML tree rendered | **PASSED** |
| **TC-25** | Error Page Routing (404 & 500) | Navigate to invalid URL `/student-life-manager/nonexistent-route` | Web container intercepts error code 404; renders custom branded `404.jsp` with Home return button | Custom 404 page displayed | **PASSED** |

---

## 3. Test Coverage Summary

- **Unit Testing**: 100% of domain utility functions, scoring algorithms, and security hash routines.
- **Integration Testing**: Servlet controller parameter handling, request routing, session lifecycle, and MySQL CRUD operations.
- **Validation**: Client-side form constraints paired with server-side validation and prepared statements.
- **Compatibility**: Verified on Apache Tomcat 10.1+ on Java 17 and MySQL 8.0+.
