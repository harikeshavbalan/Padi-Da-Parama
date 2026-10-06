-- ============================================================
-- STUDENT LIFE MANAGER - REALISTIC SEED DATA
-- Designed for MySQL Workbench execution
-- Generates dynamic relative dates around CURRENT_DATE so
-- today's schedule, deadlines, and streaks are always active.
-- ============================================================

USE student_life_manager;

-- Disable foreign key checks for clean insertion
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE user_settings;
TRUNCATE TABLE notifications;
TRUNCATE TABLE study_sessions;
TRUNCATE TABLE habit_logs;
TRUNCATE TABLE habits;
TRUNCATE TABLE plans;
TRUNCATE TABLE timetable;
TRUNCATE TABLE exams;
TRUNCATE TABLE deadlines;
TRUNCATE TABLE tasks;
TRUNCATE TABLE subjects;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. SEED USER
-- Default Demo Account:
-- Username: demo
-- Password: demo123 (hashed with BCrypt 10 rounds)
INSERT INTO users (id, username, email, password_hash, full_name, created_at)
VALUES (
    1,
    'demo',
    'demo@studentlife.edu',
    '$2a$10$678cKvyTfXrwKIaTZ5zVnucFRELmUMqgXKC5/9sH1zvaCzWa7P1hS',
    'Harikeshav',
    NOW()
);

-- Default User Settings
INSERT INTO user_settings (user_id, default_priority, week_start_day, reminders_enabled, theme_preference)
VALUES (1, 'MEDIUM', 'Monday', TRUE, 'dark');

-- 2. SEED SUBJECTS
INSERT INTO subjects (id, user_id, name, course_code, faculty, room, credits, color) VALUES
(1, 1, 'Computer Networks', 'CS302', 'Prof. R. Sharma', 'CS-302', 4, '#3b82f6'),
(2, 1, 'Web Technology', 'CS305', 'Dr. K. Raman', 'Lab-2', 4, '#8b5cf6'),
(3, 1, 'Database Management Systems', 'CS301', 'Prof. A. Verma', 'CS-204', 4, '#10b981'),
(4, 1, 'Operating Systems', 'CS304', 'Dr. S. Mukherjee', 'CS-105', 4, '#f59e0b'),
(5, 1, 'Design and Analysis of Algorithms', 'CS303', 'Prof. V. Nair', 'CS-301', 4, '#ef4444'),
(6, 1, 'Java Programming', 'CS306', 'Prof. M. Gupta', 'Lab-4', 3, '#06b6d4');

-- 3. SEED TASKS
-- Mix of Completed, Pending, In Progress, Overdue, and Today
INSERT INTO tasks (id, user_id, subject_id, title, description, category, priority, status, due_date, due_time, estimated_minutes, actual_minutes, recurrence, completed_at) VALUES
-- Today's tasks (due CURDATE())
(1, 1, 4, 'Complete OS Record', 'Finish write-up for CPU scheduling algorithms and memory management', 'Lab', 'HIGH', 'COMPLETED', CURDATE(), '17:00:00', 90, 85, 'NONE', NOW()),
(2, 1, 3, 'Finish DBMS Assignment', 'Write SQL queries for normalization and indexing exercises', 'Assignment', 'URGENT', 'PENDING', CURDATE(), '23:59:00', 60, 0, 'NONE', NULL),
(3, 1, 2, 'Study Web Technology Unit 1', 'Revise HTTP protocol, Servlets lifecycle, and JSP expressions', 'Academic', 'MEDIUM', 'PENDING', CURDATE(), '20:00:00', 75, 0, 'NONE', NULL),
(4, 1, 2, 'Work on Mini Project', 'Set up MVC architecture and implement authentication flow', 'Project', 'HIGH', 'IN_PROGRESS', CURDATE(), '22:00:00', 120, 45, 'DAILY', NULL),

-- Upcoming tasks (Tomorrow & This Week)
(5, 1, 1, 'CN Socket Programming Lab', 'Implement multi-client TCP echo server and chat room', 'Lab', 'MEDIUM', 'PENDING', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00:00', 90, 0, 'WEEKLY', NULL),
(6, 1, 5, 'DAA Dynamic Programming Problems', 'Solve 0/1 Knapsack and Longest Common Subsequence problems', 'Academic', 'HIGH', 'PENDING', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '18:00:00', 120, 0, 'NONE', NULL),
(7, 1, 6, 'Java Multithreading Practice', 'Producer-Consumer problem using synchronization and locks', 'Assignment', 'LOW', 'PENDING', DATE_ADD(CURDATE(), INTERVAL 4 DAY), '23:59:00', 60, 0, 'NONE', NULL),
(8, 1, NULL, 'Club Tech Fest Meeting', 'Prepare agenda for upcoming hackathon and workshop sessions', 'Club', 'MEDIUM', 'PENDING', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '16:30:00', 45, 0, 'WEEKLY', NULL),

-- Overdue task (Due 2 days ago, still pending)
(9, 1, 1, 'Submit CN Quiz Review', 'Review wire protocol analysis report for Chapter 3', 'Academic', 'HIGH', 'PENDING', DATE_SUB(CURDATE(), INTERVAL 2 DAY), '12:00:00', 40, 0, 'NONE', NULL),

-- Already Completed tasks (Past days)
(10, 1, 3, 'DBMS ER Diagram Exercise', 'Constructed hospital management ER diagram and mapped to tables', 'Assignment', 'MEDIUM', 'COMPLETED', DATE_SUB(CURDATE(), INTERVAL 3 DAY), '18:00:00', 60, 55, 'NONE', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(11, 1, 5, 'DAA Divide and Conquer Analysis', 'Analyzed Merge Sort and Quick Sort recurrences using Master Theorem', 'Academic', 'HIGH', 'COMPLETED', DATE_SUB(CURDATE(), INTERVAL 4 DAY), '19:00:00', 80, 80, 'NONE', DATE_SUB(NOW(), INTERVAL 4 DAY)),
(12, 1, 4, 'OS Process Synchronization Lab', 'Implemented Dining Philosophers semaphore solution in C', 'Lab', 'MEDIUM', 'COMPLETED', DATE_SUB(CURDATE(), INTERVAL 1 DAY), '16:00:00', 90, 95, 'NONE', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(13, 1, 2, 'HTML5 Semantic Layout Wireframe', 'Created initial responsive layout wireframes and navigation', 'Project', 'LOW', 'COMPLETED', DATE_SUB(CURDATE(), INTERVAL 1 DAY), '21:00:00', 45, 40, 'NONE', DATE_SUB(NOW(), INTERVAL 1 DAY));

-- 4. SEED DEADLINES
INSERT INTO deadlines (id, user_id, subject_id, task_id, title, due_date, due_time, priority, status) VALUES
(1, 1, 3, 2, 'DBMS Assignment Submission', CURDATE(), '23:59:00', 'URGENT', 'PENDING'),
(2, 1, 1, 5, 'CN Socket Lab Upload', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00:00', 'HIGH', 'PENDING'),
(3, 1, 5, 6, 'DAA Homework Deadline', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '18:00:00', 'HIGH', 'PENDING'),
(4, 1, 2, 4, 'Web Tech Project Milestone 1', DATE_ADD(CURDATE(), INTERVAL 5 DAY), '23:59:00', 'URGENT', 'PENDING'),
(5, 1, 1, 9, 'CN Chapter 3 Quiz Overdue', DATE_SUB(CURDATE(), INTERVAL 2 DAY), '12:00:00', 'HIGH', 'PENDING');

-- 5. SEED TESTS & EXAMS
INSERT INTO exams (id, user_id, subject_id, title, exam_type, exam_date, start_time, end_time, venue, syllabus, preparation_percentage, notes) VALUES
(1, 1, 2, 'Web Technology CAT-I', 'CAT-I', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '09:30:00', '11:00:00', 'LH-201', 'Unit 1: HTML5, CSS3, JavaScript basics, DOM manipulation. Unit 2: Servlets, JSP lifecycle, Request/Response architecture.', 72, 'Focus on Servlet lifecycle diagrams and state management.'),
(2, 1, 1, 'Computer Networks CAT-I', 'CAT-I', DATE_ADD(CURDATE(), INTERVAL 7 DAY), '14:00:00', '15:30:00', 'LH-202', 'Physical layer, Data link layer framing, Error correction, Flow control protocols (Go-Back-N, Selective Repeat).', 55, 'Revise Hamming codes and sliding window throughput calculations.'),
(3, 1, 3, 'DBMS Internal Test', 'Internal Test', DATE_ADD(CURDATE(), INTERVAL 12 DAY), '10:00:00', '11:30:00', 'CS-204', 'Relational Algebra, SQL queries (Joins, Subqueries), Normalization (1NF, 2NF, 3NF, BCNF).', 40, 'Practice BCNF decomposition proofs.'),
(4, 1, 4, 'Operating Systems Lab Exam', 'Lab Exam', DATE_ADD(CURDATE(), INTERVAL 18 DAY), '09:00:00', '12:00:00', 'Lab-3', 'UNIX system calls (fork, exec, wait), Semaphore IPC, Thread synchronization in C/Java.', 65, 'Review mutex lock examples.');

-- 6. SEED WEEKLY TIMETABLE
-- Monday
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 1, 'Monday', '09:00:00', '10:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 2, 'Monday', '10:00:00', '11:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 3, 'Monday', '11:15:00', '12:15:00', 'CS-204', 'Prof. A. Verma'),
(1, 4, 'Monday', '13:15:00', '14:15:00', 'CS-105', 'Dr. S. Mukherjee'),
(1, 5, 'Monday', '14:15:00', '15:15:00', 'CS-301', 'Prof. V. Nair');

-- Tuesday
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 2, 'Tuesday', '09:00:00', '10:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 1, 'Tuesday', '10:00:00', '11:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 6, 'Tuesday', '11:15:00', '13:15:00', 'Lab-4', 'Prof. M. Gupta'),
(1, 3, 'Tuesday', '14:15:00', '15:15:00', 'CS-204', 'Prof. A. Verma');

-- Wednesday
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 5, 'Wednesday', '09:00:00', '10:00:00', 'CS-301', 'Prof. V. Nair'),
(1, 4, 'Wednesday', '10:00:00', '11:00:00', 'CS-105', 'Dr. S. Mukherjee'),
(1, 2, 'Wednesday', '11:15:00', '12:15:00', 'Lab-2', 'Dr. K. Raman'),
(1, 1, 'Wednesday', '13:15:00', '15:15:00', 'Lab-1', 'Prof. R. Sharma');

-- Thursday
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 3, 'Thursday', '09:00:00', '10:00:00', 'CS-204', 'Prof. A. Verma'),
(1, 5, 'Thursday', '10:00:00', '11:00:00', 'CS-301', 'Prof. V. Nair'),
(1, 6, 'Thursday', '11:15:00', '12:15:00', 'Lab-4', 'Prof. M. Gupta'),
(1, 4, 'Thursday', '13:15:00', '15:15:00', 'Lab-3', 'Dr. S. Mukherjee');

-- Friday
INSERT INTO timetable (user_id, subject_id, day_of_week, start_time, end_time, room, faculty) VALUES
(1, 1, 'Friday', '09:00:00', '10:00:00', 'CS-302', 'Prof. R. Sharma'),
(1, 2, 'Friday', '10:00:00', '11:00:00', 'Lab-2', 'Dr. K. Raman'),
(1, 3, 'Friday', '11:15:00', '12:15:00', 'CS-204', 'Prof. A. Verma'),
(1, 5, 'Friday', '13:15:00', '14:15:00', 'CS-301', 'Prof. V. Nair');

-- 7. SEED FUTURE PLANS
INSERT INTO plans (id, user_id, title, description, start_date, target_date, priority, progress, status) VALUES
(1, 1, 'Master Data Structures & Algorithms', 'Solve 150 LeetCode problems covering Trees, Graphs, DP, and Heaps', DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 60 DAY), 'HIGH', 68, 'ACTIVE'),
(2, 1, 'Full-Stack Web Development Project', 'Build Student Life Manager with Java Servlets, JSP, JDBC, and modern UI', DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'URGENT', 85, 'ACTIVE'),
(3, 1, 'Prepare for Summer Internship', 'Resume optimization, mock interviews, system design fundamentals', DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 45 DAY), 'HIGH', 40, 'ACTIVE'),
(4, 1, 'Cloud Practitioner Certification', 'Complete AWS Cloud Practitioner course and practice tests', DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 90 DAY), 'MEDIUM', 10, 'PLANNED'),
(5, 1, 'Learn Docker & Containerization', 'Learn Dockerfiles, multi-stage builds, and docker-compose', DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'LOW', 100, 'COMPLETED');

-- 8. SEED HABITS
INSERT INTO habits (id, user_id, name, description, category, target_frequency, color) VALUES
(1, 1, 'Study', 'At least 2 hours focused technical study daily', 'Academic', 'DAILY', '#3b82f6'),
(2, 1, 'Coding', 'Solve minimum 1 algorithm or project feature', 'Productivity', 'DAILY', '#10b981'),
(3, 1, 'Exercise', '30 minutes workout or jog', 'Health', 'DAILY', '#f59e0b'),
(4, 1, 'Reading', 'Read 15 pages of technical book or paper', 'Self-growth', 'DAILY', '#8b5cf6'),
(5, 1, 'Revision', 'Review class lecture notes and summaries', 'Academic', 'DAILY', '#06b6d4');

-- 9. SEED HABIT LOGS (Continuous 5-day streak up to yesterday, Study & Coding done today)
-- Today
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, CURDATE(), TRUE), -- Study: Done
(2, CURDATE(), TRUE), -- Coding: Done
(3, CURDATE(), TRUE), -- Exercise: Done
(4, CURDATE(), FALSE); -- Reading: Pending

-- Yesterday (Day -1)
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), TRUE),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), TRUE),
(3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), TRUE),
(4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), TRUE);

-- Day -2
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), TRUE),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), TRUE),
(3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), TRUE),
(4, DATE_SUB(CURDATE(), INTERVAL 2 DAY), TRUE);

-- Day -3
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 3 DAY), TRUE),
(2, DATE_SUB(CURDATE(), INTERVAL 3 DAY), TRUE),
(3, DATE_SUB(CURDATE(), INTERVAL 3 DAY), TRUE),
(4, DATE_SUB(CURDATE(), INTERVAL 3 DAY), FALSE);

-- Day -4
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), TRUE),
(2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), TRUE),
(3, DATE_SUB(CURDATE(), INTERVAL 4 DAY), TRUE),
(4, DATE_SUB(CURDATE(), INTERVAL 4 DAY), TRUE);

-- Day -5
INSERT INTO habit_logs (habit_id, log_date, completed) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), TRUE),
(2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), TRUE),
(3, DATE_SUB(CURDATE(), INTERVAL 5 DAY), FALSE),
(4, DATE_SUB(CURDATE(), INTERVAL 5 DAY), TRUE);

-- 10. SEED STUDY SESSIONS
-- Today: 2 sessions totaling 2h 40m (160 mins)
INSERT INTO study_sessions (user_id, subject_id, task_id, start_time, end_time, duration_minutes, notes) VALUES
(1, 2, 4, CONCAT(CURDATE(), ' 08:30:00'), CONCAT(CURDATE(), ' 10:10:00'), 100, 'Implemented Servlets, filters, and JDBC connection pool handling.'),
(1, 4, 1, CONCAT(CURDATE(), ' 11:30:00'), CONCAT(CURDATE(), ' 12:30:00'), 60, 'Revised CPU scheduling algorithms and Round Robin turnaround times.');

-- Earlier this week: additional sessions totaling ~9h 40m (Overall week = ~12h 20m)
INSERT INTO study_sessions (user_id, subject_id, task_id, start_time, end_time, duration_minutes, notes) VALUES
(1, 1, 5, CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 15:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), ' 17:30:00'), 150, 'Socket programming multi-threaded server architecture.'),
(1, 3, 2, CONCAT(DATE_SUB(CURDATE(), INTERVAL 2 DAY), ' 09:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 2 DAY), ' 11:30:00'), 150, 'SQL complex joins, subqueries, and B-Tree indexing mechanisms.'),
(1, 5, 6, CONCAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY), ' 16:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY), ' 18:30:00'), 150, 'Dynamic programming memoization and bottom-up tabulation.'),
(1, 2, 3, CONCAT(DATE_SUB(CURDATE(), INTERVAL 4 DAY), ' 14:00:00'), CONCAT(DATE_SUB(CURDATE(), INTERVAL 4 DAY), ' 16:10:00'), 130, 'Deep dive into Jakarta EE request dispatching and session management.');

-- 11. SEED HOLIDAYS
INSERT INTO holidays (id, user_id, title, holiday_date, description, holiday_type) VALUES
(1, 1, 'Mid-Semester Break', DATE_ADD(CURDATE(), INTERVAL 6 DAY), 'College autumn mid-semester break and study leave', 'College Holiday'),
(2, 1, 'National Youth Day', DATE_ADD(CURDATE(), INTERVAL 25 DAY), 'National holiday and college cultural exhibition', 'Public Holiday'),
(3, 1, 'Semester End Vacation', DATE_ADD(CURDATE(), INTERVAL 75 DAY), 'Winter semester break', 'Vacation');

-- 12. SEED EVENTS
INSERT INTO events (id, user_id, title, description, event_date, start_time, end_time, category, location) VALUES
(1, 1, 'Annual Hackathon 2026', '24-hour inter-college hackathon on AI and Web Technologies', DATE_ADD(CURDATE(), INTERVAL 5 DAY), '09:00:00', '18:00:00', 'College event', 'Auditorium Block A'),
(2, 1, 'Project Review Phase 1', 'Evaluation of system architecture, schema design, and prototype', DATE_ADD(CURDATE(), INTERVAL 9 DAY), '14:00:00', '16:00:00', 'Project review', 'Seminar Hall CS-2'),
(3, 1, 'Coding Club Weekly Meetup', 'Hands-on live problem solving on Graph Algorithms', DATE_ADD(CURDATE(), INTERVAL 4 DAY), '17:00:00', '18:30:00', 'Club meeting', 'Lab-4'),
(4, 1, 'Industry Guest Lecture', 'Modern Enterprise Cloud Architecture by Lead Architect', DATE_ADD(CURDATE(), INTERVAL 14 DAY), '11:00:00', '13:00:00', 'Seminar', 'Main Hall');

-- 13. SEED NOTIFICATIONS
INSERT INTO notifications (user_id, title, message, type, link, is_read) VALUES
(1, 'Task Due Today', 'Your task "Finish DBMS Assignment" is due tonight at 11:59 PM.', 'ALERT', 'tasks', FALSE),
(2, 'Upcoming CAT-I Exam', 'Web Technology CAT-I exam is in 3 days. Current prep: 72%.', 'WARNING', 'exams', FALSE),
(3, 'Study Streak Active!', 'Congratulations! You have maintained a 5-day habit streak.', 'SUCCESS', 'habits', FALSE),
(4, 'Upcoming College Holiday', 'Mid-Semester Break begins in 6 days.', 'INFO', 'holidays', TRUE);
